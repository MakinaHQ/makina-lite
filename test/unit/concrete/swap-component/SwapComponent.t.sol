// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {Errors} from "src/libraries/Errors.sol";
import {ISwapComponent} from "src/interfaces/ISwapComponent.sol";

import {Unit_Concrete_Test} from "../UnitConcrete.t.sol";

abstract contract SwapComponent_Unit_Concrete_Test is Unit_Concrete_Test {
    ISwapComponent internal swapComponent;

    function setUp() public virtual override {
        Unit_Concrete_Test.setUp();

        swapComponent = ISwapComponent(address(makinaLiteModule));
    }
}

contract Getters_Setters_SwapComponent_Unit_Concrete_Test is SwapComponent_Unit_Concrete_Test {
    function test_SetMaxSwapLossBps_RevertWhen_CallerNotSafe() public {
        vm.expectRevert(Errors.UnauthorizedCaller.selector);
        swapComponent.setMaxSwapLossBps(0);
    }

    function test_SetMaxSwapLossBps_RevertWhen_InvalidBpsValue() public {
        vm.expectRevert(Errors.InvalidBpsValue.selector);
        vm.prank(address(safe));
        swapComponent.setMaxSwapLossBps(10_001);
    }

    function test_SetMaxSwapLossBps() public {
        uint256 newMaxSwapLossBps = 300;

        vm.expectEmit(true, true, false, false, address(swapComponent));
        emit ISwapComponent.MaxSwapLossBpsChanged(DEFAULT_MAX_SWAP_LOSS_BPS, newMaxSwapLossBps);
        vm.prank(address(safe));
        swapComponent.setMaxSwapLossBps(newMaxSwapLossBps);

        assertEq(swapComponent.maxSwapLossBps(), newMaxSwapLossBps);
    }

    function test_SetSwapperTargets_RevertWhen_CallerNotSafe() public {
        vm.expectRevert(Errors.UnauthorizedCaller.selector);
        swapComponent.setSwapperTargets(0, address(0), address(0));
    }

    function test_SetSwapperTargets() public {
        address newApprovalTarget = makeAddr("newApprovalTarget");
        address newExecutionTarget = makeAddr("newExecutionTarget");

        vm.expectEmit(true, false, false, true, address(swapComponent));
        emit ISwapComponent.SwapperTargetsSet(TEST_SWAPPER_ID, newApprovalTarget, newExecutionTarget);
        vm.prank(address(safe));
        swapComponent.setSwapperTargets(TEST_SWAPPER_ID, newApprovalTarget, newExecutionTarget);

        (address approvalTarget, address executionTarget) = swapComponent.getSwapperTargets(TEST_SWAPPER_ID);
        assertEq(approvalTarget, newApprovalTarget);
        assertEq(executionTarget, newExecutionTarget);
    }
}
