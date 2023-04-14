// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import {AutoPilotFactory, IEntryPoint, AutoPilot} from "../src/AutoPilotFactory.sol";

import {UserOperation} from "../src/AutoPilot.sol";
import {Test} from "forge-std/Test.sol";
import {DummyContract} from "./DummyContract.sol";

contract AutoPilotExecuteTest is Test {
    AutoPilot public autopilot;

    uint256 privateKeyBot =
        uint256(
            bytes32(
                0x1c5a1a856270f46b6007ad5a163d93ae5cf418486f4f81aa56f328bf1a5596ae
            )
        );
    address public bot = 0xB5cdafA4932Ae6f5EA1d37FAD9642AB6195337DC;

    uint256 privateKeyOwner =
        uint256(
            bytes32(
                0x16d18a5980a191f43a457e23cfb9a72beb301b41aad581bfb33d5f127c008bd0
            )
        );
    address public owner = 0xb70A6cD9150A2F4b4a3CEC7D4E12144Cd6E73A5e;

    address public entryPoint = 0x0576a174D229E3cFA37253523E645A78A0C91B57;
    DummyContract public externalContract;
    DummyContract public externalContract2;

    address stranger = 0x65c2BcB59711B04BfE36c5911Cd32F4EC2771c25;

    address[] public dest;
    bytes[] public func;

    function setUp() public {
        AutoPilotFactory autopilotFac = new AutoPilotFactory(
            IEntryPoint(entryPoint)
        );
        autopilot = autopilotFac.createAccount(
            owner,
            uint256(keccak256(abi.encode("autopilot")))
        );
        externalContract = new DummyContract();
        externalContract2 = new DummyContract();

        vm.startPrank(owner);
        autopilot.setBot(bot);
        vm.stopPrank();
        assertEq(autopilot.owner(), owner);
        assertEq(address(autopilot.entryPoint()), entryPoint);
    }

    function testExecuteHappyCase() public {
        // owner
        vm.startPrank(owner);
        bytes memory calldataAutoPilot = abi.encodeWithSignature(
            "setX(uint256)",
            1
        );
        autopilot.execute(address(externalContract), 0, calldataAutoPilot);
        assertEq(externalContract.x(), 1);
        vm.stopPrank();

        // bot
        vm.warp(100);
        externalContract.setX(0);
        vm.startPrank(owner);
        autopilot.addAllowedCall(
            keccak256(
                abi.encode(
                    address(externalContract),
                    10000000,
                    calldataAutoPilot
                )
            ),
            type(uint48).max,
            10
        );
        vm.stopPrank();
        // bot validate signature state update
        vm.store(
            address(autopilot),
            bytes32(uint256(4)),
            bytes32(abi.encode(address(bot)))
        );

        vm.startPrank(entryPoint);
        vm.deal(address(autopilot), 100 ether);
        autopilot.execute(
            address(externalContract),
            10000000,
            calldataAutoPilot
        );
        assertEq(externalContract.x(), 1);
        assertEq(autopilot.temp(), address(0));
    }

    function testBotCheckTimeGap() public {
        // add allowed call
        vm.startPrank(owner);
        bytes memory calldataAutoPilot = abi.encodeWithSignature(
            "setX(uint256)",
            1
        );
        autopilot.addAllowedCall(
            keccak256(
                abi.encode(address(externalContract), 0, calldataAutoPilot)
            ),
            type(uint48).max,
            10
        );
        vm.stopPrank();

        // first call
        vm.warp(1000);
        vm.store(
            address(autopilot),
            bytes32(uint256(4)),
            bytes32(abi.encode(bot))
        );
        vm.startPrank(entryPoint);
        autopilot.execute(address(externalContract), 0, calldataAutoPilot);
        assertEq(externalContract.x(), 1);
        (
            bool allowed,
            uint48 allowance,
            uint96 timegap,
            uint96 lastCallTime
        ) = autopilot.allowedCalls(
                keccak256(
                    abi.encode(address(externalContract), 0, calldataAutoPilot)
                )
            );
        assertEq(lastCallTime, 1000);
        externalContract.setX(0);

        // second call before time gap
        vm.warp(1001);
        vm.store(
            address(autopilot),
            bytes32(uint256(4)),
            bytes32(abi.encode(bot))
        ); // I understnad that this not needed, doing it for clarity
        vm.expectRevert("account: timegap not reached");
        autopilot.execute(address(externalContract), 0, calldataAutoPilot);
        assertEq(externalContract.x(), 0);
        (allowed, allowance, timegap, lastCallTime) = autopilot.allowedCalls(
            keccak256(
                abi.encode(address(externalContract), 0, calldataAutoPilot)
            )
        );
        assertEq(lastCallTime, 1000);

        // second call after time gap
        vm.warp(1010);
        vm.store(
            address(autopilot),
            bytes32(uint256(4)),
            bytes32(abi.encode(bot))
        ); // I understnad that this not needed, doing it for clarity
        autopilot.execute(address(externalContract), 0, calldataAutoPilot);
        assertEq(externalContract.x(), 1);
        (allowed, allowance, timegap, lastCallTime) = autopilot.allowedCalls(
            keccak256(
                abi.encode(address(externalContract), 0, calldataAutoPilot)
            )
        );
        assertEq(lastCallTime, 1010);
    }
}
