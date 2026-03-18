// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {
    AccessManagedUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";

import {IMakinaLiteRegistry} from "../interfaces/IMakinaLiteRegistry.sol";
import {Errors} from "../libraries/Errors.sol";

contract MakinaLiteRegistry is AccessManagedUpgradeable, IMakinaLiteRegistry {
    /// @custom:storage-location erc7201:makina.storage.MakinaLiteRegistry
    struct MakinaLiteRegistryStorage {
        address _feeCollector;
        mapping(uint16 bridgeId => address encoder) _bridgeEncoders;
    }

    // keccak256(abi.encode(uint256(keccak256("makina.storage.MakinaLiteRegistry")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant MakinaLiteRegistryStorageLocation =
        0xef78750e7ffffd9087e6b5da2ceae6958dbfa00caaf5353b49cdf645f9a1dc00;

    function _getCoreRegistryStorage() private pure returns (MakinaLiteRegistryStorage storage $) {
        assembly {
            $.slot := MakinaLiteRegistryStorageLocation
        }
    }

    function initialize(address initialAuthority) external initializer {
        __AccessManaged_init(initialAuthority);
    }

    /// @inheritdoc IMakinaLiteRegistry
    function feeCollector() external view override returns (address) {
        return _getCoreRegistryStorage()._feeCollector;
    }

    /// @inheritdoc IMakinaLiteRegistry
    function getBridgeEncoder(uint16 bridgeId) external view returns (address) {
        address encoder = _getCoreRegistryStorage()._bridgeEncoders[bridgeId];
        if (encoder == address(0)) {
            revert Errors.BridgeEncoderDoesNotExist();
        }
        return encoder;
    }

    /// @inheritdoc IMakinaLiteRegistry
    function setFeeCollector(address newFeeCollector) external restricted {
        MakinaLiteRegistryStorage storage $ = _getCoreRegistryStorage();
        emit FeeCollectorChanged($._feeCollector, newFeeCollector);
        $._feeCollector = newFeeCollector;
    }

    /// @inheritdoc IMakinaLiteRegistry
    function setBridgeEncoder(uint16 bridgeId, address bridgeEncoder) external restricted {
        MakinaLiteRegistryStorage storage $ = _getCoreRegistryStorage();
        emit BridgeEncoderChanged(bridgeId, $._bridgeEncoders[bridgeId], bridgeEncoder);
        $._bridgeEncoders[bridgeId] = bridgeEncoder;
    }
}
