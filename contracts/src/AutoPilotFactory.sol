// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Create2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {AutoPilot, IEntryPoint} from "./AutoPilot.sol";

contract AutoPilotFactory {
    AutoPilot public immutable autoPilotImplementation;

    constructor(IEntryPoint _entryPoint) {
        autoPilotImplementation = new AutoPilot(_entryPoint, address(this));
    }

    function createAccount(
        address owner,
        uint256 salt
    ) public returns (AutoPilot ret) {
        address addr = getAddress(owner, salt);
        uint codeSize = addr.code.length;
        if (codeSize > 0) {
            return AutoPilot(payable(addr));
        }
        ret = AutoPilot(
            payable(
                new ERC1967Proxy{salt: bytes32(salt)}(
                    address(autoPilotImplementation),
                    abi.encodeCall(AutoPilot.initialize, (owner))
                )
            )
        );
    }

    function getAddress(
        address owner,
        uint256 salt
    ) public view returns (address) {
        return
            Create2.computeAddress(
                bytes32(salt),
                keccak256(
                    abi.encodePacked(
                        type(ERC1967Proxy).creationCode,
                        abi.encode(
                            address(autoPilotImplementation),
                            abi.encodeCall(AutoPilot.initialize, (owner))
                        )
                    )
                )
            );
    }
}
