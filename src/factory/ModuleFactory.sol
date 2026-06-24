// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {
    AccessManagedUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

import {Errors} from "../libraries/Errors.sol";
import {IMakinaLiteModule} from "../interfaces/IMakinaLiteModule.sol";
import {IMakinaLiteRegistry} from "../interfaces/IMakinaLiteRegistry.sol";
import {MakinaLiteContext} from "../utils/MakinaLiteContext.sol";
import {IModuleFactory} from "../interfaces/IModuleFactory.sol";

contract ModuleFactory layout at erc7201("makina.storage.ModuleFactory")
    is
    MakinaLiteContext,
    AccessManagedUpgradeable,
    IModuleFactory
{
    /// @dev Full scale value for fee rates.
    uint256 private constant MAX_FEE_RATE = 1e18;

    /// @inheritdoc IModuleFactory
    mapping(address module => bool isModule) public isMakinaLiteModule;

    /// @inheritdoc IModuleFactory
    address public defaultProvider;

    /// @inheritdoc IModuleFactory
    uint256 public defaultSwapFeeRate;

    /// @inheritdoc IModuleFactory
    bool public freeDeployment;

    constructor(address _registry) MakinaLiteContext(_registry) {
        _disableInitializers();
    }

    function initialize(
        address initialAuthority,
        address initialDefaultProvider,
        uint256 initialDefaultSwapFeeRate,
        bool initialFreeDeployment
    ) external initializer {
        __AccessManaged_init(initialAuthority);

        _setDefaultProvider(initialDefaultProvider);
        _setDefaultSwapFeeRate(initialDefaultSwapFeeRate);
        _setFreeDeployment(initialFreeDeployment);
    }

    /// @inheritdoc IModuleFactory
    function createModule(
        IMakinaLiteModule.MakinaLiteModuleInitParams calldata params,
        IMakinaLiteModule.MakinaLiteModuleServiceParams calldata serviceParams,
        bytes32 salt,
        bytes32 referralKey
    ) external restricted returns (address) {
        if (salt == bytes32(0)) {
            revert Errors.ZeroSalt();
        }

        return _createModule(params, serviceParams, salt, referralKey);
    }

    /// @inheritdoc IModuleFactory
    function createModuleFree(
        IMakinaLiteModule.MakinaLiteModuleInitParams calldata params,
        bytes32 salt,
        bytes32 referralKey
    ) external returns (address) {
        if (!freeDeployment) {
            revert Errors.FreeDeploymentDisabled();
        }

        bytes32 namespacedSalt = keccak256(abi.encode(msg.sender, salt));

        return _createModule(
            params,
            IMakinaLiteModule.MakinaLiteModuleServiceParams({
                initialProvider: defaultProvider, initialSwapFeeRate: defaultSwapFeeRate
            }),
            namespacedSalt,
            referralKey
        );
    }

    /// @inheritdoc IModuleFactory
    function setDefaultProvider(address newDefaultProvider) external restricted {
        _setDefaultProvider(newDefaultProvider);
    }

    /// @inheritdoc IModuleFactory
    function setDefaultSwapFeeRate(uint256 newDefaultSwapFeeRate) external restricted {
        _setDefaultSwapFeeRate(newDefaultSwapFeeRate);
    }

    /// @inheritdoc IModuleFactory
    function setFreeDeployment(bool enabled) external restricted {
        _setFreeDeployment(enabled);
    }

    /// @dev Internal logic to deploy and initialize a new MakinaLiteModule clone.
    function _createModule(
        IMakinaLiteModule.MakinaLiteModuleInitParams calldata params,
        IMakinaLiteModule.MakinaLiteModuleServiceParams memory serviceParams,
        bytes32 salt,
        bytes32 referralKey
    ) private returns (address) {
        address implementation = IMakinaLiteRegistry(registry).moduleImplementation();

        address module = Clones.cloneDeterministic(implementation, salt);
        IMakinaLiteModule(module).initialize(params, serviceParams);

        emit MakinaLiteModuleCreated(module, implementation, referralKey);

        isMakinaLiteModule[module] = true;

        return module;
    }

    /// @dev Internal setter for the default provider.
    function _setDefaultProvider(address newDefaultProvider) internal {
        emit DefaultProviderChanged(defaultProvider, newDefaultProvider);
        defaultProvider = newDefaultProvider;
    }

    /// @dev Internal setter for the default swap fee rate.
    function _setDefaultSwapFeeRate(uint256 newDefaultSwapFeeRate) internal {
        _checkFeeRate(newDefaultSwapFeeRate);
        emit DefaultSwapFeeRateChanged(defaultSwapFeeRate, newDefaultSwapFeeRate);
        defaultSwapFeeRate = newDefaultSwapFeeRate;
    }

    /// @dev Internal setter for free deployment.
    function _setFreeDeployment(bool enabled) internal {
        emit FreeDeploymentChanged(enabled);
        freeDeployment = enabled;
    }

    /// @dev Performs sanity check on a fee rate.
    function _checkFeeRate(uint256 rate) internal pure {
        if (rate > MAX_FEE_RATE) {
            revert Errors.InvalidFeeRate();
        }
    }
}
