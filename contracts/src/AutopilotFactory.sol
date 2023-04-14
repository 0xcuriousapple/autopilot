// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Create2.sol";

import {Autopilot, IEntryPoint} from "./Autopilot.sol";

contract AutopilotFactory {

    IEntryPoint public immutable entryPoint;
    constructor(IEntryPoint _entryPoint) { 
        entryPoint = _entryPoint;
    }

   
    function createAccount(address owner,bytes32 salt) public returns (Autopilot ret) {
        address addr = getAddress(owner, salt);
        uint codeSize = addr.code.length;
        if (codeSize > 0) {
            return Autopilot(payable(addr));
        }
        ret = Autopilot(new Autopilot{salt : salt}(entryPoint, owner));
    }

    
    function getAddress(address owner,bytes32 salt) public view returns (address) {
        return Create2.computeAddress(salt, keccak256(abi.encodePacked(
                type(Autopilot).creationCode,
                abi.encode(
                    address(entryPoint),
                    owner
                )
        )));
    }
}