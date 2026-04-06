// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {
    AccessManagedUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {IAcrossV4BridgeEncoder} from "../interfaces/IAcrossV4BridgeEncoder.sol";
import {IAcrossV4SpokePool} from "../interfaces/IAcrossV4SpokePool.sol";
import {IBridgeComponent} from "../interfaces/IBridgeComponent.sol";
import {IBridgeEncoder} from "../interfaces/IBridgeEncoder.sol";
import {Errors} from "../libraries/Errors.sol";

contract AcrossV4BridgeEncoder is AccessManagedUpgradeable, IAcrossV4BridgeEncoder {
    using EnumerableSet for EnumerableSet.AddressSet;

    address public immutable acrossV4SpokePool;

    /// @custom:storage-location erc7201:makina.storage.AcrossV4BridgeEncoder
    struct AcrossV4BridgeEncoderStorage {
        mapping(address localToken => mapping(uint256 chainId => EnumerableSet.AddressSet foreignTokens))
            _foreignTokens;
    }

    // keccak256(abi.encode(uint256(keccak256("makina.storage.AcrossV4BridgeEncoder")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AcrossV4BridgeEncoderStorageLocation =
        0x7ac48160dcadfe48aa9955deee253225b971e43ffbc0563788d75cfc0c119200;

    function _getAcrossV4BridgeEncoderStorage() private pure returns (AcrossV4BridgeEncoderStorage storage $) {
        assembly {
            $.slot := AcrossV4BridgeEncoderStorageLocation
        }
    }

    constructor(address _acrossV4SpokePool) {
        acrossV4SpokePool = _acrossV4SpokePool;
        _disableInitializers();
    }

    function initialize(address initialAuthority) external initializer {
        __AccessManaged_init(initialAuthority);
    }

    /// @inheritdoc IAcrossV4BridgeEncoder
    function isRouteRegistered(address inputToken, uint256 foreignChainId, address outputToken)
        public
        view
        override
        returns (bool)
    {
        return _getAcrossV4BridgeEncoderStorage()._foreignTokens[inputToken][foreignChainId].contains(outputToken);
    }

    /// @inheritdoc IBridgeEncoder
    function getBridgeTransferData(IBridgeComponent.BridgeOrder calldata order, bool lockdownMode)
        external
        view
        override
        returns (address, address, uint256, bytes memory)
    {
        (address outputToken, address refundAddress, uint32 fillDeadlineOffset) =
            abi.decode(order.extraData, (address, address, uint32));

        if (lockdownMode && !isRouteRegistered(order.inputToken, order.destinationChainId, outputToken)) {
            revert Errors.RouteNotRegistered();
        }

        if (refundAddress == address(0)) {
            revert Errors.ZeroRefundAddress();
        }

        bytes memory cd = abi.encodeCall(
            IAcrossV4SpokePool.depositV3Now,
            (
                refundAddress,
                order.recipient,
                order.inputToken,
                outputToken,
                order.inputAmount,
                order.minOutputAmount,
                order.destinationChainId,
                address(0),
                fillDeadlineOffset,
                0,
                ""
            )
        );

        return (acrossV4SpokePool, acrossV4SpokePool, 0, cd);
    }

    /// @inheritdoc IAcrossV4BridgeEncoder
    function addRoute(address inputToken, uint256 foreignChainId, address outputToken) external override restricted {
        if (!_getAcrossV4BridgeEncoderStorage()._foreignTokens[inputToken][foreignChainId].add(outputToken)) {
            revert Errors.RouteAlreadyRegistered();
        }

        emit RouteAdded(inputToken, foreignChainId, outputToken);
    }

    /// @inheritdoc IAcrossV4BridgeEncoder
    function removeRoute(address inputToken, uint256 foreignChainId, address outputToken) external override restricted {
        if (!_getAcrossV4BridgeEncoderStorage()._foreignTokens[inputToken][foreignChainId].remove(outputToken)) {
            revert Errors.RouteNotRegistered();
        }

        emit RouteRemoved(inputToken, foreignChainId, outputToken);
    }
}
