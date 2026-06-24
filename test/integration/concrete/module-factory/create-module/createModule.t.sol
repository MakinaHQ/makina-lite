// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IAccessManaged} from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";
import {Errors as OZErrors} from "@openzeppelin/contracts/utils/Errors.sol";

import {Errors} from "src/libraries/Errors.sol";
import {IMakinaLiteModule} from "src/interfaces/IMakinaLiteModule.sol";
import {IModuleFactory} from "src/interfaces/IModuleFactory.sol";
import {MakinaLiteModule} from "src/MakinaLiteModule.sol";

import {ModuleFactory_Integration_Concrete_Test} from "../ModuleFactory.t.sol";

contract CreateModule_Integration_Concrete_Test is ModuleFactory_Integration_Concrete_Test {
    function test_RevertWhen_CallerWithoutRole() public {
        IMakinaLiteModule.MakinaLiteModuleInitParams memory params;
        IMakinaLiteModule.MakinaLiteModuleServiceParams memory serviceParams;

        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, address(this)));
        moduleFactory.createModule(params, serviceParams, bytes32(0), 0);
    }

    function test_RevertWhen_ZeroSalt() public {
        IMakinaLiteModule.MakinaLiteModuleInitParams memory params;
        IMakinaLiteModule.MakinaLiteModuleServiceParams memory serviceParams;

        vm.prank(dao);
        vm.expectRevert(Errors.ZeroSalt.selector);
        moduleFactory.createModule(params, serviceParams, bytes32(0), 0);
    }

    function test_RevertWhen_SaltAlreadyUsed() public {
        IMakinaLiteModule.MakinaLiteModuleInitParams memory params;
        IMakinaLiteModule.MakinaLiteModuleServiceParams memory serviceParams;

        vm.prank(dao);
        vm.expectRevert(OZErrors.FailedDeployment.selector);
        moduleFactory.createModule(params, serviceParams, TEST_DEPLOYMENT_SALT, 0);
    }

    function test_RevertWhen_ZeroSafe() public {
        IMakinaLiteModule.MakinaLiteModuleInitParams memory params;
        IMakinaLiteModule.MakinaLiteModuleServiceParams memory serviceParams;
        bytes32 salt = bytes32(uint256(TEST_DEPLOYMENT_SALT) + 1);

        vm.prank(dao);
        vm.expectRevert(Errors.ZeroAddress.selector);
        moduleFactory.createModule(params, serviceParams, salt, 0);
    }

    function test_CreateModule() public {
        bytes32 initialAllowedInstrRoot = bytes32("0x12345");
        bytes32 salt = bytes32(uint256(TEST_DEPLOYMENT_SALT) + 1);
        bytes32 referralKey = bytes32("referralKey");

        IMakinaLiteModule.MakinaLiteModuleInitParams memory params = _defaultInitParams(address(safe));
        params.initialAllowedInstrRoot = initialAllowedInstrRoot;

        address expectedModuleAddr =
            Clones.predictDeterministicAddress(makinaLiteModuleImplem, salt, address(moduleFactory));

        vm.expectEmit(true, true, false, false, address(moduleFactory));
        emit IModuleFactory.MakinaLiteModuleCreated(expectedModuleAddr, makinaLiteModuleImplem, referralKey);

        vm.prank(dao);
        makinaLiteModule = MakinaLiteModule(
            payable(moduleFactory.createModule(
                    params,
                    IMakinaLiteModule.MakinaLiteModuleServiceParams({
                        initialProvider: dao, initialSwapFeeRate: DEFAULT_SWAP_FEE_RATE
                    }),
                    salt,
                    referralKey
                ))
        );

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
