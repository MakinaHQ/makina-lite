// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IMakinaLiteModule} from "./IMakinaLiteModule.sol";

interface IModuleFactory {
    event MakinaLiteModuleCreated(address indexed module, address indexed implementation, bytes32 indexed referralKey);
    event DefaultProviderChanged(address indexed oldDefaultProvider, address indexed newDefaultProvider);
    event DefaultSwapFeeRateChanged(uint256 oldDefaultSwapFeeRate, uint256 newDefaultSwapFeeRate);
    event FreeDeploymentChanged(bool enabled);

    /// @notice Module => Whether the module was deployed by this factory.
    function isMakinaLiteModule(address module) external view returns (bool);

    /// @notice Provider enforced by default on modules deployed through the free path.
    function defaultProvider() external view returns (address);

    /// @notice Swap fee rate enforced by default on modules deployed through the free path, 1e18 = 100%.
    function defaultSwapFeeRate() external view returns (uint256);

    /// @notice Whether free module deployment is currently enabled.
    function freeDeployment() external view returns (bool);

    /// @notice Deploys a new MakinaLiteModule clone with caller-provided service parameters.
    /// @dev Restricted to authorized deployers.
    /// @param params The strategy and risk initialization parameters for the MakinaLiteModule.
    /// @param serviceParams The protocol-controlled service initialization parameters.
    /// @param salt The salt used for deterministic deployment of the module clone.
    /// @param referralKey The referral key associated with the module creation.
    /// @return The address of the newly deployed MakinaLiteModule.
    function createModule(
        IMakinaLiteModule.MakinaLiteModuleInitParams calldata params,
        IMakinaLiteModule.MakinaLiteModuleServiceParams calldata serviceParams,
        bytes32 salt,
        bytes32 referralKey
    ) external returns (address);

    /// @notice Deploys a new MakinaLiteModule clone, with service parameters enforced by the factory.
    /// @dev Callable by anyone while free deployment is enabled.
    /// @param params The strategy and risk initialization parameters for the MakinaLiteModule.
    /// @param salt The caller-scoped salt used for deterministic deployment of the module clone.
    /// @param referralKey The referral key associated with the module creation.
    /// @return The address of the newly deployed MakinaLiteModule.
    function createModuleFree(
        IMakinaLiteModule.MakinaLiteModuleInitParams calldata params,
        bytes32 salt,
        bytes32 referralKey
    ) external returns (address);

    /// @notice Sets the provider enforced on free deployment.
    /// @param newDefaultProvider The new default provider address.
    function setDefaultProvider(address newDefaultProvider) external;

    /// @notice Sets the swap fee rate enforced on free deployment.
    /// @param newDefaultSwapFeeRate The new default swap fee rate, 1e18 = 100%.
    function setDefaultSwapFeeRate(uint256 newDefaultSwapFeeRate) external;

    /// @notice Enables or disables free module deployment.
    /// @param enabled True to enable free deployment, false to disable it.
    function setFreeDeployment(bool enabled) external;
}
