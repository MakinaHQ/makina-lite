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
    /// @dev Full scale value in basis points.
    uint256 private constant MAX_BPS = 10_000;

    /// @dev Full scale value for fee rates (matches MakinaLiteModule).
    uint256 private constant MAX_FEE_RATE = 1e18;

    /// @inheritdoc IModuleFactory
    mapping(address module => bool isModule) public isMakinaLiteModule;

    /// @inheritdoc IModuleFactory
    address public permissionlessProvider;

    /// @inheritdoc IModuleFactory
    uint256 public permissionlessMaxPositionIncreaseLossBps;

    /// @inheritdoc IModuleFactory
    uint256 public permissionlessMaxPositionDecreaseLossBps;

    /// @inheritdoc IModuleFactory
    uint256 public permissionlessMaxSwapLossBps;

    /// @inheritdoc IModuleFactory
    uint256 public permissionlessSwapFeeRate;

    constructor(address _registry) MakinaLiteContext(_registry) {
        _disableInitializers();
    }

    function initialize(ModuleFactoryInitParams calldata params) external initializer {
        __AccessManaged_init(params.initialAuthority);

        _setPermissionlessProvider(params.initialPermissionlessProvider);
        _setPermissionlessMaxPositionIncreaseLossBps(params.initialPermissionlessMaxPositionIncreaseLossBps);
        _setPermissionlessMaxPositionDecreaseLossBps(params.initialPermissionlessMaxPositionDecreaseLossBps);
        _setPermissionlessMaxSwapLossBps(params.initialPermissionlessMaxSwapLossBps);
        _setPermissionlessSwapFeeRate(params.initialPermissionlessSwapFeeRate);
    }

    /// @inheritdoc IModuleFactory
    function createModule(
        IMakinaLiteModule.MakinaLiteModuleInitParams calldata params,
        bytes32 salt,
        bytes32 referralKey
    ) external restricted returns (address) {
        if (salt == bytes32(0)) {
            revert Errors.ZeroSalt();
        }

        return _deployAndInit(params, salt, referralKey);
    }

    /// @inheritdoc IModuleFactory
    function createModulePermissionless(
        address safe,
        bytes32 initialAllowedInstrRoot,
        bytes32 salt,
        bytes32 referralKey
    ) external returns (address) {
        if (salt == bytes32(0)) {
            revert Errors.ZeroSalt();
        }
        if (safe == address(0)) {
            revert Errors.ZeroAddress();
        }
        if (permissionlessProvider == address(0)) {
            revert Errors.ZeroAddress();
        }
        if (!_isSafe(safe)) {
            revert Errors.NotASafe();
        }

        IMakinaLiteModule.MakinaLiteModuleInitParams memory params = IMakinaLiteModule.MakinaLiteModuleInitParams({
            safe: safe,
            initialProvider: permissionlessProvider,
            initialAllowedInstrRoot: initialAllowedInstrRoot,
            initialMaxPositionIncreaseLossBps: permissionlessMaxPositionIncreaseLossBps,
            initialMaxPositionDecreaseLossBps: permissionlessMaxPositionDecreaseLossBps,
            initialMaxSwapLossBps: permissionlessMaxSwapLossBps,
            initialSwapFeeRate: permissionlessSwapFeeRate
        });

        return _deployAndInit(params, salt, referralKey);
    }

    /// @inheritdoc IModuleFactory
    function setPermissionlessProvider(address newProvider) external restricted {
        _setPermissionlessProvider(newProvider);
    }

    /// @inheritdoc IModuleFactory
    function setPermissionlessMaxPositionIncreaseLossBps(uint256 newBps) external restricted {
        _setPermissionlessMaxPositionIncreaseLossBps(newBps);
    }

    /// @inheritdoc IModuleFactory
    function setPermissionlessMaxPositionDecreaseLossBps(uint256 newBps) external restricted {
        _setPermissionlessMaxPositionDecreaseLossBps(newBps);
    }

    /// @inheritdoc IModuleFactory
    function setPermissionlessMaxSwapLossBps(uint256 newBps) external restricted {
        _setPermissionlessMaxSwapLossBps(newBps);
    }

    /// @inheritdoc IModuleFactory
    function setPermissionlessSwapFeeRate(uint256 newRate) external restricted {
        _setPermissionlessSwapFeeRate(newRate);
    }

    /// @dev Clones the module implementation deterministically and initializes it.
    function _deployAndInit(
        IMakinaLiteModule.MakinaLiteModuleInitParams memory params,
        bytes32 salt,
        bytes32 referralKey
    ) internal returns (address) {
        address implementation = IMakinaLiteRegistry(registry).moduleImplementation();

        address module = Clones.cloneDeterministic(implementation, salt);
        IMakinaLiteModule(module).initialize(params);

        emit MakinaLiteModuleCreated(module, implementation, referralKey);

        isMakinaLiteModule[module] = true;

        return module;
    }

    /// @dev Best-effort Safe detection via `getThreshold()` staticcall.
    ///      A contract exposing a fake `getThreshold()` will pass — convenience check only.
    function _isSafe(address account) internal view returns (bool) {
        (bool ok, bytes memory data) = account.staticcall(abi.encodeWithSignature("getThreshold()"));
        if (!ok || data.length < 32) {
            return false;
        }
        return abi.decode(data, (uint256)) > 0;
    }

    function _setPermissionlessProvider(address newProvider) internal {
        emit PermissionlessProviderChanged(permissionlessProvider, newProvider);
        permissionlessProvider = newProvider;
    }

    function _setPermissionlessMaxPositionIncreaseLossBps(uint256 newBps) internal {
        if (newBps > MAX_BPS) {
            revert Errors.InvalidBpsValue();
        }
        emit PermissionlessMaxPositionIncreaseLossBpsChanged(permissionlessMaxPositionIncreaseLossBps, newBps);
        permissionlessMaxPositionIncreaseLossBps = newBps;
    }

    function _setPermissionlessMaxPositionDecreaseLossBps(uint256 newBps) internal {
        if (newBps > MAX_BPS) {
            revert Errors.InvalidBpsValue();
        }
        emit PermissionlessMaxPositionDecreaseLossBpsChanged(permissionlessMaxPositionDecreaseLossBps, newBps);
        permissionlessMaxPositionDecreaseLossBps = newBps;
    }

    function _setPermissionlessMaxSwapLossBps(uint256 newBps) internal {
        if (newBps > MAX_BPS) {
            revert Errors.InvalidBpsValue();
        }
        emit PermissionlessMaxSwapLossBpsChanged(permissionlessMaxSwapLossBps, newBps);
        permissionlessMaxSwapLossBps = newBps;
    }

    function _setPermissionlessSwapFeeRate(uint256 newRate) internal {
        if (newRate > MAX_FEE_RATE) {
            revert Errors.InvalidFeeRate();
        }
        emit PermissionlessSwapFeeRateChanged(permissionlessSwapFeeRate, newRate);
        permissionlessSwapFeeRate = newRate;
    }
}
