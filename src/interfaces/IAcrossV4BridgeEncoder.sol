// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import {IBridgeEncoder} from "./IBridgeEncoder.sol";

interface IAcrossV4BridgeEncoder is IBridgeEncoder {
    event RouteAdded(address indexed inputToken, uint256 indexed foreignChainId, address indexed outputToken);
    event RouteRemoved(address indexed inputToken, uint256 indexed foreignChainId, address indexed outputToken);

    /// @notice Address of the Across SpokePool.
    function acrossV4SpokePool() external view returns (address);

    /// @notice Returns whether a bridge transfer route is registered.
    /// @param inputToken The token to be sent from the source chain.
    /// @param foreignChainId The destination chain ID.
    /// @param outputToken The token to be received on the destination chain.
    /// @return True if the route is registered, false otherwise.
    function isRouteRegistered(address inputToken, uint256 foreignChainId, address outputToken)
        external
        view
        returns (bool);

    /// @notice Registers a transfer route.
    /// @param inputToken The token to be sent from the source chain.
    /// @param foreignChainId The destination chain ID.
    /// @param outputToken The token to be received on the destination chain.
    function addRoute(address inputToken, uint256 foreignChainId, address outputToken) external;

    /// @notice Unregisters a transfer route.
    /// @param inputToken The token to be sent from the source chain.
    /// @param foreignChainId The destination chain ID.
    /// @param outputToken The token to be received on the destination chain.
    function removeRoute(address inputToken, uint256 foreignChainId, address outputToken) external;
}
