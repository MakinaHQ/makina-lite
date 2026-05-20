// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {IAccessManaged} from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";

import {Errors} from "src/libraries/Errors.sol";
import {IModuleFactory} from "src/interfaces/IModuleFactory.sol";

import {Unit_Concrete_Test} from "../UnitConcrete.t.sol";

contract Getters_ModuleFactory_Unit_Concrete_Test is Unit_Concrete_Test {
    function test_Getters() public view {
        assertEq(moduleFactory.registry(), address(registry));
        assertTrue(moduleFactory.isMakinaLiteModule(address(makinaLiteModule)));

        assertEq(moduleFactory.permissionlessProvider(), dao);
        assertEq(moduleFactory.permissionlessMaxPositionIncreaseLossBps(), DEFAULT_MAX_POS_INCREASE_LOSS_BPS);
        assertEq(moduleFactory.permissionlessMaxPositionDecreaseLossBps(), DEFAULT_MAX_POS_DECREASE_LOSS_BPS);
        assertEq(moduleFactory.permissionlessMaxSwapLossBps(), DEFAULT_MAX_SWAP_LOSS_BPS);
        assertEq(moduleFactory.permissionlessSwapFeeRate(), DEFAULT_PERMISSIONLESS_SWAP_FEE_RATE);
    }

    function test_SetPermissionlessProvider_RevertWhen_CallerWithoutRole() public {
        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, address(this)));
        moduleFactory.setPermissionlessProvider(address(0));
    }

    function test_SetPermissionlessProvider() public {
        address newProvider = makeAddr("newProvider");

        vm.expectEmit(true, true, false, false, address(moduleFactory));
        emit IModuleFactory.PermissionlessProviderChanged(dao, newProvider);
        vm.prank(dao);
        moduleFactory.setPermissionlessProvider(newProvider);

        assertEq(moduleFactory.permissionlessProvider(), newProvider);
    }

    function test_SetPermissionlessMaxPositionIncreaseLossBps_RevertWhen_CallerWithoutRole() public {
        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, address(this)));
        moduleFactory.setPermissionlessMaxPositionIncreaseLossBps(0);
    }

    function test_SetPermissionlessMaxPositionIncreaseLossBps_RevertWhen_AboveMaxBps() public {
        vm.expectRevert(Errors.InvalidBpsValue.selector);
        vm.prank(dao);
        moduleFactory.setPermissionlessMaxPositionIncreaseLossBps(10_001);
    }

    function test_SetPermissionlessMaxPositionIncreaseLossBps() public {
        uint256 newBps = 500;

        vm.expectEmit(false, false, false, true, address(moduleFactory));
        emit IModuleFactory.PermissionlessMaxPositionIncreaseLossBpsChanged(
            DEFAULT_MAX_POS_INCREASE_LOSS_BPS, newBps
        );
        vm.prank(dao);
        moduleFactory.setPermissionlessMaxPositionIncreaseLossBps(newBps);

        assertEq(moduleFactory.permissionlessMaxPositionIncreaseLossBps(), newBps);
    }

    function test_SetPermissionlessMaxPositionDecreaseLossBps_RevertWhen_CallerWithoutRole() public {
        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, address(this)));
        moduleFactory.setPermissionlessMaxPositionDecreaseLossBps(0);
    }

    function test_SetPermissionlessMaxPositionDecreaseLossBps_RevertWhen_AboveMaxBps() public {
        vm.expectRevert(Errors.InvalidBpsValue.selector);
        vm.prank(dao);
        moduleFactory.setPermissionlessMaxPositionDecreaseLossBps(10_001);
    }

    function test_SetPermissionlessMaxPositionDecreaseLossBps() public {
        uint256 newBps = 2_500;

        vm.expectEmit(false, false, false, true, address(moduleFactory));
        emit IModuleFactory.PermissionlessMaxPositionDecreaseLossBpsChanged(
            DEFAULT_MAX_POS_DECREASE_LOSS_BPS, newBps
        );
        vm.prank(dao);
        moduleFactory.setPermissionlessMaxPositionDecreaseLossBps(newBps);

        assertEq(moduleFactory.permissionlessMaxPositionDecreaseLossBps(), newBps);
    }

    function test_SetPermissionlessMaxSwapLossBps_RevertWhen_CallerWithoutRole() public {
        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, address(this)));
        moduleFactory.setPermissionlessMaxSwapLossBps(0);
    }

    function test_SetPermissionlessMaxSwapLossBps_RevertWhen_AboveMaxBps() public {
        vm.expectRevert(Errors.InvalidBpsValue.selector);
        vm.prank(dao);
        moduleFactory.setPermissionlessMaxSwapLossBps(10_001);
    }

    function test_SetPermissionlessMaxSwapLossBps() public {
        uint256 newBps = 300;

        vm.expectEmit(false, false, false, true, address(moduleFactory));
        emit IModuleFactory.PermissionlessMaxSwapLossBpsChanged(DEFAULT_MAX_SWAP_LOSS_BPS, newBps);
        vm.prank(dao);
        moduleFactory.setPermissionlessMaxSwapLossBps(newBps);

        assertEq(moduleFactory.permissionlessMaxSwapLossBps(), newBps);
    }

    function test_SetPermissionlessSwapFeeRate_RevertWhen_CallerWithoutRole() public {
        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, address(this)));
        moduleFactory.setPermissionlessSwapFeeRate(0);
    }

    function test_SetPermissionlessSwapFeeRate_RevertWhen_AboveMaxFeeRate() public {
        vm.expectRevert(Errors.InvalidFeeRate.selector);
        vm.prank(dao);
        moduleFactory.setPermissionlessSwapFeeRate(1e18 + 1);
    }

    function test_SetPermissionlessSwapFeeRate() public {
        uint256 newRate = 1e16; // 1%

        vm.expectEmit(false, false, false, true, address(moduleFactory));
        emit IModuleFactory.PermissionlessSwapFeeRateChanged(DEFAULT_PERMISSIONLESS_SWAP_FEE_RATE, newRate);
        vm.prank(dao);
        moduleFactory.setPermissionlessSwapFeeRate(newRate);

        assertEq(moduleFactory.permissionlessSwapFeeRate(), newRate);
    }
}
