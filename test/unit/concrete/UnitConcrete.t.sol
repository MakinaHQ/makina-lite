// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {IMakinaLiteGovernable} from "src/interfaces/IMakinaLiteGovernable.sol";
import {IMakinaLiteModule} from "src/interfaces/IMakinaLiteModule.sol";
import {MakinaLiteModule} from "src/MakinaLiteModule.sol";

import {Base_Test} from "../../base/Base.t.sol";

abstract contract Unit_Concrete_Test is Base_Test {
    MakinaLiteModule internal makinaLiteModule;

    function setUp() public virtual override {
        Base_Test.setUp();

        vm.prank(dao);
        makinaLiteModule = MakinaLiteModule(
            payable(moduleFactory.createModule(
                    IMakinaLiteModule.MakinaLiteModuleInitParams({
                        safe: address(safe),
                        initialProvider: dao,
                        initialOperatingMode: IMakinaLiteGovernable.OperatingMode.OPEN,
                        initialAllowedInstrRoot: bytes32(0),
                        initialMaxPositionIncreaseLossBps: DEFAULT_MAX_POS_INCREASE_LOSS_BPS,
                        initialMaxPositionDecreaseLossBps: DEFAULT_MAX_POS_DECREASE_LOSS_BPS,
                        initialInstrCooldownDuration: DEFAULT_INSTR_COOLDOWN_DURATION,
                        initialMaxSwapLossBps: DEFAULT_MAX_SWAP_LOSS_BPS,
                        initialSwapCooldownDuration: DEFAULT_SWAP_COOLDOWN_DURATION,
                        initialSwapFeeRate: DEFAULT_SWAP_FEE_RATE
                    }),
                    TEST_DEPLOYMENT_SALT,
                    0
                ))
        );
    }
}
