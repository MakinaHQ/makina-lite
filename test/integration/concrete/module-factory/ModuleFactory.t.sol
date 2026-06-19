// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {IMakinaLiteGovernable} from "src/interfaces/IMakinaLiteGovernable.sol";
import {IMakinaLiteModule} from "src/interfaces/IMakinaLiteModule.sol";

import {Integration_Concrete_Test} from "../IntegrationConcrete.t.sol";

abstract contract ModuleFactory_Integration_Concrete_Test is Integration_Concrete_Test {
    function _defaultInitParams(address _safe)
        internal
        view
        returns (IMakinaLiteModule.MakinaLiteModuleInitParams memory)
    {
        return IMakinaLiteModule.MakinaLiteModuleInitParams({
            safe: _safe,
            initialOperatingMode: IMakinaLiteGovernable.OperatingMode.OPEN,
            initialAllowedInstrRoot: bytes32(0),
            initialMaxPositionIncreaseLossBps: DEFAULT_MAX_POS_INCREASE_LOSS_BPS,
            initialMaxPositionDecreaseLossBps: DEFAULT_MAX_POS_DECREASE_LOSS_BPS,
            initialInstrCooldownDuration: DEFAULT_INSTR_COOLDOWN_DURATION,
            initialMaxSwapLossBps: DEFAULT_MAX_SWAP_LOSS_BPS,
            initialSwapCooldownDuration: DEFAULT_SWAP_COOLDOWN_DURATION
        });
    }
}
