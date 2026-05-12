// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

import {ICctpV2TokenMessenger} from "src/interfaces/ICctpV2TokenMessenger.sol";

import {MockERC20} from "./MockERC20.sol";

/// @dev MockCctpV2TokenMessenger contract for testing use only
contract MockCctpV2TokenMessenger is ICctpV2TokenMessenger {
    event Deposit(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 mintRecipient,
        address burnToken,
        bytes32 destinationCaller,
        uint256 maxFee,
        uint32 minFinalityThreshold,
        bytes hookData
    );

    uint256 private minFee;

    address public localMinter;

    constructor(uint256 _minFee) {
        minFee = _minFee;
    }

    function getMinFeeAmount(uint256 amount) external view returns (uint256) {
        uint256 _minFeeAmount = amount * minFee / 10_000_000;
        return _minFeeAmount == 0 ? 1 : _minFeeAmount;
    }

    function depositForBurnWithHook(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 mintRecipient,
        address burnToken,
        bytes32 destinationCaller,
        uint256 maxFee,
        uint32 minFinalityThreshold,
        bytes calldata hookData
    ) external {
        MockERC20(burnToken).burn(msg.sender, amount);

        emit Deposit(
            amount,
            destinationDomain,
            mintRecipient,
            burnToken,
            destinationCaller,
            maxFee,
            minFinalityThreshold,
            hookData
        );
    }
}
