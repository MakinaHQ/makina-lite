// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

interface IMakinaLiteRegistry {
    event BridgeEncoderChanged(
        uint16 indexed bridgeId, address indexed oldBridgeEncoder, address indexed newBridgeEncoder
    );
    event FeeCollectorChanged(address indexed oldFeeCollector, address indexed newFeeCollector);

    /// @notice Address of the fee collector.
    function feeCollector() external view returns (address);

    /// @notice Bridge ID => Address of the corresponding bridge encoder.
    function getBridgeEncoder(uint16 bridgeId) external view returns (address);

    /// @notice Sets the address of the fee collector.
    /// @param newFeeCollector The address of the new fee collector.
    function setFeeCollector(address newFeeCollector) external;

    /// @notice Sets a bridge encoder instance for a given bridge ID.
    /// @param bridgeId The ID of the bridge.
    /// @param bridgeEncoder The address of the new bridge encoder instance.
    function setBridgeEncoder(uint16 bridgeId, address bridgeEncoder) external;
}
