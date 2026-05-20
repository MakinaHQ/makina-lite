// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IMakinaLiteModule} from "./IMakinaLiteModule.sol";

interface IModuleFactory {
    /// @notice Initialization parameters for the ModuleFactory proxy.
    /// @param initialAuthority The AccessManager that owns the proxy's restricted functions.
    /// @param initialPermissionlessProvider Default provider seeded onto modules deployed via `createModulePermissionless`.
    /// @param initialPermissionlessMaxPositionIncreaseLossBps Default lockdown bps for position increases.
    /// @param initialPermissionlessMaxPositionDecreaseLossBps Default lockdown bps for position decreases.
    /// @param initialPermissionlessMaxSwapLossBps Default lockdown bps for swaps.
    /// @param initialPermissionlessSwapFeeRate Default swap fee rate (1e18 = 100%).
    struct ModuleFactoryInitParams {
        address initialAuthority;
        address initialPermissionlessProvider;
        uint256 initialPermissionlessMaxPositionIncreaseLossBps;
        uint256 initialPermissionlessMaxPositionDecreaseLossBps;
        uint256 initialPermissionlessMaxSwapLossBps;
        uint256 initialPermissionlessSwapFeeRate;
    }

    event MakinaLiteModuleCreated(address indexed module, address indexed implementation, bytes32 indexed referralKey);

    event PermissionlessProviderChanged(address indexed oldProvider, address indexed newProvider);
    event PermissionlessMaxPositionIncreaseLossBpsChanged(uint256 oldBps, uint256 newBps);
    event PermissionlessMaxPositionDecreaseLossBpsChanged(uint256 oldBps, uint256 newBps);
    event PermissionlessMaxSwapLossBpsChanged(uint256 oldBps, uint256 newBps);
    event PermissionlessSwapFeeRateChanged(uint256 oldRate, uint256 newRate);

    /// @notice Module => Whether the module was deployed by this factory.
    function isMakinaLiteModule(address module) external view returns (bool);

    /// @notice The default provider address used by `createModulePermissionless`.
    function permissionlessProvider() external view returns (address);

    /// @notice The default max position increase loss bps used by `createModulePermissionless`.
    function permissionlessMaxPositionIncreaseLossBps() external view returns (uint256);

    /// @notice The default max position decrease loss bps used by `createModulePermissionless`.
    function permissionlessMaxPositionDecreaseLossBps() external view returns (uint256);

    /// @notice The default max swap loss bps used by `createModulePermissionless`.
    function permissionlessMaxSwapLossBps() external view returns (uint256);

    /// @notice The default swap fee rate used by `createModulePermissionless`, in 1e18 scale.
    function permissionlessSwapFeeRate() external view returns (uint256);

    /// @notice Deploys a new MakinaLiteModule clone with the given parameters.
    /// @param params The initialization parameters for the MakinaLiteModule.
    /// @param salt The salt used for deterministic deployment of the module clone.
    /// @param referralKey The referral key associated with the module creation.
    /// @return The address of the newly deployed MakinaLiteModule.
    function createModule(
        IMakinaLiteModule.MakinaLiteModuleInitParams calldata params,
        bytes32 salt,
        bytes32 referralKey
    ) external returns (address);

    /// @notice Permissionlessly deploys a new MakinaLiteModule clone bound to `safe`,
    ///         using factory-stored defaults for provider, loss bps and swap fee rate.
    /// @param safe The Safe address the module will be bound to. A best-effort `getThreshold()`
    ///             staticcall is performed to reject obvious non-Safe targets; this is a
    ///             convenience check, not a security boundary.
    /// @param initialAllowedInstrRoot The Merkle root of the allowed Weiroll instructions.
    /// @param salt The salt used for deterministic deployment of the module clone.
    /// @param referralKey The referral key associated with the module creation.
    /// @return The address of the newly deployed MakinaLiteModule.
    function createModulePermissionless(
        address safe,
        bytes32 initialAllowedInstrRoot,
        bytes32 salt,
        bytes32 referralKey
    ) external returns (address);

    /// @notice Updates the default provider used by `createModulePermissionless`.
    function setPermissionlessProvider(address newProvider) external;

    /// @notice Updates the default max position increase loss bps used by `createModulePermissionless`.
    function setPermissionlessMaxPositionIncreaseLossBps(uint256 newBps) external;

    /// @notice Updates the default max position decrease loss bps used by `createModulePermissionless`.
    function setPermissionlessMaxPositionDecreaseLossBps(uint256 newBps) external;

    /// @notice Updates the default max swap loss bps used by `createModulePermissionless`.
    function setPermissionlessMaxSwapLossBps(uint256 newBps) external;

    /// @notice Updates the default swap fee rate used by `createModulePermissionless`.
    function setPermissionlessSwapFeeRate(uint256 newRate) external;
}
