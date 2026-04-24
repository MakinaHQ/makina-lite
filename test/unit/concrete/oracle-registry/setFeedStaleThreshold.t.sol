// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {Errors} from "src/libraries/Errors.sol";
import {MockPriceFeed} from "test/mocks/MockPriceFeed.sol";
import {IOracleRegistry} from "src/interfaces/IOracleRegistry.sol";

import {OracleRegistry_Unit_Concrete_Test} from "./OracleRegistry.t.sol";

contract SetFeedStaleThreshold_Unit_Concrete_Test is OracleRegistry_Unit_Concrete_Test {
    MockPriceFeed internal priceFeed1;

    function test_RevertWhen_CallerNotSafe() public {
        vm.expectRevert(Errors.UnauthorizedCaller.selector);
        oracleRegistry.setFeedStaleThreshold(address(0), 0);
    }

    function test_SetFeedStaleThreshold() public {
        priceFeed1 = new MockPriceFeed(18, 1e18, block.timestamp);

        assertEq(oracleRegistry.getFeedStaleThreshold(address(priceFeed1)), 0);

        vm.prank(address(safe));
        oracleRegistry.setFeedRoute(address(baseToken), address(priceFeed1), DEFAULT_PF_STALE_THRSHLD, address(0), 0);

        assertEq(oracleRegistry.getFeedStaleThreshold(address(priceFeed1)), DEFAULT_PF_STALE_THRSHLD);

        vm.expectEmit(true, true, true, true, address(oracleRegistry));
        emit IOracleRegistry.FeedStaleThresholdChanged(address(priceFeed1), DEFAULT_PF_STALE_THRSHLD, 1 days);
        vm.prank(address(safe));
        oracleRegistry.setFeedStaleThreshold(address(priceFeed1), 1 days);

        assertEq(oracleRegistry.getFeedStaleThreshold(address(priceFeed1)), 1 days);
    }
}
