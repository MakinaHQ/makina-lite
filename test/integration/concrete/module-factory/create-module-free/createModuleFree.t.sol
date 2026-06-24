// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Errors as OZErrors} from "@openzeppelin/contracts/utils/Errors.sol";

import {Errors} from "src/libraries/Errors.sol";
import {IMakinaLiteModule} from "src/interfaces/IMakinaLiteModule.sol";
import {IModuleFactory} from "src/interfaces/IModuleFactory.sol";
import {MakinaLiteModule} from "src/MakinaLiteModule.sol";

import {ModuleFactory_Integration_Concrete_Test} from "../ModuleFactory.t.sol";

contract CreateModuleFree_Integration_Concrete_Test is ModuleFactory_Integration_Concrete_Test {
    function test_RevertWhen_FreeDeploymentDisabled() public {
        vm.expectRevert(Errors.FreeDeploymentDisabled.selector);
        moduleFactory.createModuleFree(_defaultInitParams(address(safe)), TEST_DEPLOYMENT_SALT, 0);
    }

    function test_RevertWhen_SaltAlreadyUsed() public {
        vm.prank(dao);
        moduleFactory.setFreeDeployment(true);

        bytes32 salt = bytes32(uint256(42));

        moduleFactory.createModuleFree(_defaultInitParams(address(safe)), salt, 0);

        vm.expectRevert(OZErrors.FailedDeployment.selector);
        moduleFactory.createModuleFree(_defaultInitParams(address(safe)), salt, 0);
    }

    function test_CreateModuleFree() public {
        vm.prank(dao);
        moduleFactory.setFreeDeployment(true);

        bytes32 initialAllowedInstrRoot = bytes32("0x12345");
        bytes32 salt = bytes32(uint256(42));
        bytes32 referralKey = bytes32("referralKey");

        IMakinaLiteModule.MakinaLiteModuleInitParams memory params = _defaultInitParams(address(safe));
        params.initialAllowedInstrRoot = initialAllowedInstrRoot;

        bytes32 namespacedSalt = keccak256(abi.encode(address(this), salt));
        address expectedModuleAddr =
            Clones.predictDeterministicAddress(makinaLiteModuleImplem, namespacedSalt, address(moduleFactory));

        vm.expectEmit(true, true, false, false, address(moduleFactory));
        emit IModuleFactory.MakinaLiteModuleCreated(expectedModuleAddr, makinaLiteModuleImplem, referralKey);

        makinaLiteModule = MakinaLiteModule(payable(moduleFactory.createModuleFree(params, salt, referralKey)));

        assertEq(address(makinaLiteModule), expectedModuleAddr);
        assertTrue(moduleFactory.isMakinaLiteModule(address(makinaLiteModule)));

        assertEq(makinaLiteModule.registry(), address(registry));
        assertEq(makinaLiteModule.safe(), address(safe));
        assertEq(makinaLiteModule.provider(), dao);
        assertFalse(makinaLiteModule.paused());
        assertFalse(makinaLiteModule.suspendedByProvider());
        assertEq(makinaLiteModule.allowedInstrRoot(), initialAllowedInstrRoot);
        assertEq(makinaLiteModule.maxPositionIncreaseLossBps(), DEFAULT_MAX_POS_INCREASE_LOSS_BPS);
        assertEq(makinaLiteModule.maxPositionDecreaseLossBps(), DEFAULT_MAX_POS_DECREASE_LOSS_BPS);
        assertEq(makinaLiteModule.maxSwapLossBps(), DEFAULT_MAX_SWAP_LOSS_BPS);
        assertEq(makinaLiteModule.swapFeeRate(), DEFAULT_SWAP_FEE_RATE);
    }
}
