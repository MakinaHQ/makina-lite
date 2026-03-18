// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import {IBridgeEncoder} from "./IBridgeEncoder.sol";

interface ICctpV2BridgeEncoder is IBridgeEncoder {
    event CctpDomainRegistered(uint256 indexed evmChainId, uint32 indexed cctpDomain);

    /// @notice Address of the CCTP TokenMessengerV2
    function cctpV2TokenMessenger() external view returns (address);

    /// @notice EVM chain ID => CCTP domain
    function getCctpDomain(uint256 evmChainId) external view returns (uint32);

    /// @notice Associates an EVM chain ID with a CCTP domain in the contract storage.
    /// @param evmChainId The EVM chain ID.
    /// @param cctpDomain The CCTP domain.
    function setCctpDomain(uint256 evmChainId, uint32 cctpDomain) external;
}
