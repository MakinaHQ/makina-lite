// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import {IAcrossV4SpokePool} from "src/interfaces/IAcrossV4SpokePool.sol";

interface IMockAcrossSpokePool is IAcrossV4SpokePool {
    event Deposit(
        bytes32 inputToken,
        bytes32 outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        uint256 depositId,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        bytes32 depositor,
        bytes32 recipient,
        bytes32 exclusiveRelayer,
        bytes message
    );

    struct DepositV3Params {
        bytes32 depositor;
        bytes32 recipient;
        bytes32 inputToken;
        bytes32 outputToken;
        uint256 inputAmount;
        uint256 outputAmount;
        uint256 destinationChainId;
        bytes32 exclusiveRelayer;
        uint256 depositId;
        uint32 quoteTimestamp;
        uint32 fillDeadline;
        uint32 exclusivityParameter;
        bytes message;
    }

    function numberOfDeposits() external view returns (uint256);
}
