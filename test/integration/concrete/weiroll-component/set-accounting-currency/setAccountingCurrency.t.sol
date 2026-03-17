// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {IWeirollComponent} from "src/interfaces/IWeirollComponent.sol";
import {Errors} from "src/libraries/Errors.sol";

import {WeirollComponent_Integration_Concrete_Test} from "../WeirollComponent.t.sol";

contract SetAccountingCurrency_Integration_Concrete_Test is WeirollComponent_Integration_Concrete_Test {
    function test_RevertWhen_CallerNotSafe() public {
        vm.expectRevert(Errors.UnauthorizedCaller.selector);
        makinaLiteModule.setAccountingCurrency(address(0));
    }

    function test_RevertGiven_FeedRouteNotRegistered() public {
        address newToken = makeAddr("newToken");
        vm.expectRevert(abi.encodeWithSelector(Errors.PriceFeedRouteNotRegistered.selector, newToken));
        vm.prank(address(safe));
        makinaLiteModule.setAccountingCurrency(newToken);
    }

    function test_SetAccountingCurrency() public {
        vm.expectEmit(true, true, false, false, address(makinaLiteModule));
        emit IWeirollComponent.AccountingCurrencyChanged(address(0), address(tokenA));
        vm.prank(address(safe));
        makinaLiteModule.setAccountingCurrency(address(tokenA));

        assertEq(makinaLiteModule.accountingCurrency(), address(tokenA));
    }
}
