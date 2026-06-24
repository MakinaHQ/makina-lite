// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IBridgeComponent} from "./IBridgeComponent.sol";
import {IMakinaLiteContext} from "./IMakinaLiteContext.sol";
import {IMakinaLiteGovernable} from "./IMakinaLiteGovernable.sol";
import {IOracleRegistry} from "./IOracleRegistry.sol";
import {ISwapComponent} from "./ISwapComponent.sol";
import {IWeirollComponent} from "./IWeirollComponent.sol";

interface IMakinaLiteModule is
    IMakinaLiteContext,
    IMakinaLiteGovernable,
    IOracleRegistry,
    IWeirollComponent,
    ISwapComponent,
    IBridgeComponent
{
    /// @notice Strategy and risk initialization parameters.
    /// @param safe The address of the Safe that the module will be connected to.
    /// @param initialOperatingMode The initial operating mode of the module.
    /// @param initialAllowedInstrRoot The root of the Merkle tree containing the allowed instructions for the module.
    /// @param initialMaxPositionIncreaseLossBps The max allowed value loss (in basis points) for position increases while in WALLED mode.
    /// @param initialMaxPositionDecreaseLossBps The max allowed value loss (in basis points) for position decreases while in WALLED mode.
    /// @param initialInstrCooldownDuration The cooldown duration (in seconds) for position management while in WALLED mode.
    /// @param initialMaxSwapLossBps The maximum allowed loss in basis points for swap operations while in FENCED or WALLED mode.
    /// @param initialSwapCooldownDuration The cooldown duration (in seconds) for swap operations while in FENCED or WALLED mode.
    struct MakinaLiteModuleInitParams {
        address safe;
        IMakinaLiteGovernable.OperatingMode initialOperatingMode;
        bytes32 initialAllowedInstrRoot;
        uint256 initialMaxPositionIncreaseLossBps;
        uint256 initialMaxPositionDecreaseLossBps;
        uint256 initialInstrCooldownDuration;
        uint256 initialMaxSwapLossBps;
        uint256 initialSwapCooldownDuration;
    }

    /// @notice Protocol-controlled service initialization parameters.
    /// @param initialProvider The address of the MakinaLite service account.
    /// @param initialSwapFeeRate The fee rate for swap operations, 1e18 = 100%.
    struct MakinaLiteModuleServiceParams {
        address initialProvider;
        uint256 initialSwapFeeRate;
    }

    /// @notice Initializes the module with the given parameters.
    /// @param params The strategy and risk initialization parameters.
    /// @param serviceParams The protocol-controlled service initialization parameters.
    function initialize(
        MakinaLiteModuleInitParams calldata params,
        MakinaLiteModuleServiceParams calldata serviceParams
    ) external;

    /// @notice Sweeps the entire balance of a given ERC20 token to the Safe.
    /// @param token The address of the ERC20 token to sweep.
    function sweepERC20(address token) external;

    /// @notice Sweeps the entire native currency balance (e.g. ETH) to the Safe.
    function sweepNative() external;
}
