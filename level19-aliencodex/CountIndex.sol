// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Test {
    uint256 index = type(uint256).max - uint256(keccak256(abi.encode(1))) + 1;
    function getIndex() public view returns (uint256) {
        return index;
    }
}
