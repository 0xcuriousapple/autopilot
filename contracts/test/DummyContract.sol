// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

contract DummyContract {
    uint256 public x;

    function setX(uint256 _x) public payable {
        x = _x;
    }

    function sayHello() public pure returns (string memory) {
        return "Hello";
    }

    function sheSaidNo() public pure {
        revert("sorry, I have a boyfriend");
    }
}
