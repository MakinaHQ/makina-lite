// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {
    AccessManagedUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";

import {IMakinaLiteRegistry} from "../interfaces/IMakinaLiteRegistry.sol";
import {Errors} from "../libraries/Errors.sol";

contract MakinaLiteRegistry layout at erc7201("makina.storage.MakinaLiteRegistry")
    is
    AccessManagedUpgradeable,
    IMakinaLiteRegistry
{
    /// @inheritdoc IMakinaLiteRegistry
    address public moduleFactory;

    /// @inheritdoc IMakinaLiteRegistry
    address public moduleImplementation;

    /// @inheritdoc IMakinaLiteRegistry
    address public feeCollector;

    /// @inheritdoc IMakinaLiteRegistry
    address public flashLoanModule;

    mapping(uint16 bridgeId => address encoder) private _bridgeEncoders;

    function initialize(address initialAuthority) external initializer {
        __AccessManaged_init(initialAuthority);
    }

    /// @inheritdoc IMakinaLiteRegistry
    function getBridgeEncoder(uint16 bridgeId) external view returns (address) {
        address encoder = _bridgeEncoders[bridgeId];
        if (encoder == address(0)) {
            revert Errors.BridgeEncoderDoesNotExist();
        }
        return encoder;
    }

    /// @inheritdoc IMakinaLiteRegistry
    function setModuleFactory(address factory) external restricted {
        emit ModuleFactoryChanged(moduleFactory, factory);
        moduleFactory = factory;
    }

    /// @inheritdoc IMakinaLiteRegistry
    function setModuleImplementation(address newImplementation) external restricted {
        emit ModuleImplementationChanged(moduleImplementation, newImplementation);
        moduleImplementation = newImplementation;
    }

    /// @inheritdoc IMakinaLiteRegistry
    function setFeeCollector(address newFeeCollector) external restricted {
        emit FeeCollectorChanged(feeCollector, newFeeCollector);
        feeCollector = newFeeCollector;
    }

    /// @inheritdoc IMakinaLiteRegistry
    function setFlashLoanModule(address newFlashLoanModule) external restricted {
        emit FlashLoanModuleChanged(flashLoanModule, newFlashLoanModule);
        flashLoanModule = newFlashLoanModule;
    }

    /// @inheritdoc IMakinaLiteRegistry
    function setBridgeEncoder(uint16 bridgeId, address bridgeEncoder) external restricted {
        emit BridgeEncoderChanged(bridgeId, _bridgeEncoders[bridgeId], bridgeEncoder);
        _bridgeEncoders[bridgeId] = bridgeEncoder;
    }
}
