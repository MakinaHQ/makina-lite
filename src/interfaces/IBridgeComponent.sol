// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IBridgeComponent {
    event BridgeTransferRecipientAdded(uint256 indexed foreignChainId, address indexed recipient);
    event BridgeTransferRecipientRemoved(uint256 indexed foreignChainId, address indexed recipient);
    event BridgeCooldownDurationChanged(uint256 oldBridgeCooldownDuration, uint256 newBridgeCooldownDuration);
    event MaxBridgeLossBpsChanged(
        uint16 indexed bridgeId, uint256 indexed oldMaxBridgeLossBps, uint256 indexed newMaxBridgeLossBps
    );

    /// @notice Generic bridge transfer params
    /// @param bridgeId The ID of the bridge.
    /// @param destinationChainId The destination EVM chain ID
    /// @param recipient The address of the recipient
    /// @param inputToken The address of the input token.
    /// @param inputAmount The amount of input token to bridge.
    /// @param minOutputAmount The minimum amount of output token expected.
    /// @param extraData Extra data specific to each bridge integration
    struct BridgeOrder {
        uint16 bridgeId;
        uint256 destinationChainId;
        address recipient;
        address inputToken;
        uint256 inputAmount;
        uint256 minOutputAmount;
        bytes extraData;
    }

    /// @notice Bridge ID => Max allowed value loss in basis points for transfers via this bridge, while in lockdown mode.
    function getMaxBridgeLossBps(uint16 bridgeId) external view returns (uint256);

    /// @notice Foreign Chain ID => Recipient => Whitelisting status while in lockdown mode.
    function isWhitelistedRecipient(uint256 foreignChainId, address recipient) external view returns (bool);

    /// @notice Cooldown duration for bridge transfers in seconds.
    function bridgeCooldownDuration() external view returns (uint256);

    /// @notice Executes an outgoing bridge transfer.
    /// @param order The bridge transfer params.
    function sendOutBridgeTransfer(BridgeOrder calldata order) external;

    /// @notice Sets the maximum allowed value loss in basis points for transfers via this bridge.
    /// @param bridgeId The ID of the bridge.
    /// @param maxBridgeLossBps The maximum allowed value loss in basis points.
    function setMaxBridgeLossBps(uint16 bridgeId, uint256 maxBridgeLossBps) external;

    /// @notice Adds a whitelisted recipient for bridge transfer towards given foreign chain while in lockdown mode.
    /// @param foreignChainId The foreign chain ID.
    /// @param recipient The address of the recipient.
    function addRecipient(uint256 foreignChainId, address recipient) external;

    /// @notice Removes a whitelisted recipient for bridge transfer towards given foreign chain while in lockdown mode.
    /// @param foreignChainId The foreign chain ID.
    /// @param recipient The address of the recipient.
    function removeRecipient(uint256 foreignChainId, address recipient) external;

    /// @notice Sets the cooldown duration for bridge transfers.
    /// @param newBridgeCooldownDuration The new cooldown duration in seconds.
    function setBridgeCooldownDuration(uint256 newBridgeCooldownDuration) external;
}
