// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import {Autopilot, IEntryPoint} from "../src/Autopilot.sol";
import {Test} from "forge-std/Test.sol";

contract NOXTest is Test {
    Autopilot public autopilot;
    address public owner;
    address public entryPoint = 0x0576a174D229E3cFA37253523E645A78A0C91B57;

    function setUp() public {
        owner = msg.sender;
        autopilot = new Autopilot(IEntryPoint(entryPoint), msg.sender);
    }

    function testSetup() public {
        assertEq(autopilot.owner(), owner);
        assertEq(address(autopilot.entryPoint()), entryPoint);
    }
}
