// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IMakinaLiteContext {
    /// @notice Address of the registry.
    function registry() external view returns (address);
}
