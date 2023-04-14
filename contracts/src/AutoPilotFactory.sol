// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Create2.sol";

import {AutoPilot, IEntryPoint} from "./AutoPilot.sol";

contract AutoPilotFactory {
    IEntryPoint public immutable entryPoint;

    constructor(IEntryPoint _entryPoint) {
        entryPoint = _entryPoint;
    }

    function createAccount(
        address owner,
        bytes32 salt
    ) public returns (AutoPilot ret) {
        address addr = getAddress(owner, salt);
        uint codeSize = addr.code.length;
        if (codeSize > 0) {
            return AutoPilot(payable(addr));
        }
        ret = AutoPilot(new AutoPilot{salt: salt}(entryPoint, owner));
    }

    function getAddress(
        address owner,
        bytes32 salt
    ) public view returns (address) {
        return
            Create2.computeAddress(
                salt,
                keccak256(
                    abi.encodePacked(
                        type(AutoPilot).creationCode,
                        abi.encode(address(entryPoint), owner)
                    )
                )
            );
    }
}
