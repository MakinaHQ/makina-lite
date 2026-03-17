// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

library Errors {
    error AlreadyGuardian();
    error AlreadyOperator();
    error InvalidDecimals();
    error InvalidFeedRoute();
    error NegativeTokenPrice(address priceFeed);
    error NotGuardian();
    error NotOperator();
    error Paused();
    error ProtectedGuardian();
    error Suspended();
    error PriceFeedRouteNotRegistered(address token);
    error PriceFeedStale(address priceFeed, uint256 updatedAt);
    error UnauthorizedCaller();
}
