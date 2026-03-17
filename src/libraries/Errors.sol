// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

library Errors {
    error AccountingMandatory();
    error AlreadyGuardian();
    error AlreadyOperator();
    error AmountOutTooLow();
    error InstructionsMismatch();
    error InvalidAccounting();
    error InvalidBpsValue();
    error InvalidDecimals();
    error InvalidFeedRoute();
    error InvalidFeeRate();
    error InvalidInstructionProof();
    error InvalidInstructionType();
    error InvalidPositionChangeDirection();
    error MaxValueLossExceeded();
    error MismatchedLengths();
    error NegativeTokenPrice(address priceFeed);
    error NotGuardian();
    error NotOperator();
    error Paused();
    error ProtectedGuardian();
    error Suspended();
    error PriceFeedRouteNotRegistered(address token);
    error PriceFeedStale(address priceFeed, uint256 updatedAt);
    error SwapperTargetsNotSet();
    error SwapFailed();
    error UnauthorizedCaller();
}
