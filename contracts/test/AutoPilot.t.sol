// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import {AutoPilot, IEntryPoint} from "../src/AutoPilot.sol";
import {Test} from "forge-std/Test.sol";

contract AutoilotTest is Test {
    AutoPilot public autopilot;
    address public owner;
    address public entryPoint = 0x0576a174D229E3cFA37253523E645A78A0C91B57;

    function setUp() public {
        owner = msg.sender;
        autopilot = new AutoPilot(IEntryPoint(entryPoint), msg.sender);
    }

    function testSetup() public {
        assertEq(autopilot.owner(), owner);
        assertEq(address(autopilot.entryPoint()), entryPoint);
    }
}
