// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {IAccessManaged} from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";

import {Errors} from "src/libraries/Errors.sol";
import {IAcrossV4BridgeEncoder} from "src/interfaces/IAcrossV4BridgeEncoder.sol";

import {AcrossV4BridgeEncoder_Unit_Concrete_Test} from "../AcrossV4BridgeEncoder.t.sol";

contract AddRoute_Unit_Concrete_Test is AcrossV4BridgeEncoder_Unit_Concrete_Test {
    function test_RevertWhen_CallerWithoutRole() public {
        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, address(this)));
        acrossV4BridgeEncoder.addRoute(address(0), 0, address(0));
    }

    function test_RevertWhen_RouteAlreadyRegistered() public {
        vm.startPrank(address(dao));

        acrossV4BridgeEncoder.addRoute(address(0), 0, address(0));

        vm.expectRevert(Errors.RouteAlreadyRegistered.selector);
        acrossV4BridgeEncoder.addRoute(address(0), 0, address(0));
    }

    function test_AddRoute() public {
        vm.startPrank(address(dao));

        assertFalse(acrossV4BridgeEncoder.isRouteRegistered(address(1), 1, address(2)));
        assertFalse(acrossV4BridgeEncoder.isRouteRegistered(address(1), 1, address(3)));
        assertFalse(acrossV4BridgeEncoder.isRouteRegistered(address(1), 2, address(3)));
        assertFalse(acrossV4BridgeEncoder.isRouteRegistered(address(2), 2, address(3)));

        vm.expectEmit(true, true, true, false, address(acrossV4BridgeEncoder));
        emit IAcrossV4BridgeEncoder.RouteAdded(address(1), 1, address(2));
        acrossV4BridgeEncoder.addRoute(address(1), 1, address(2));
        assertTrue(acrossV4BridgeEncoder.isRouteRegistered(address(1), 1, address(2)));
        assertFalse(acrossV4BridgeEncoder.isRouteRegistered(address(1), 1, address(3)));
        assertFalse(acrossV4BridgeEncoder.isRouteRegistered(address(1), 2, address(3)));
        assertFalse(acrossV4BridgeEncoder.isRouteRegistered(address(2), 2, address(3)));

        vm.expectEmit(true, true, true, false, address(acrossV4BridgeEncoder));
        emit IAcrossV4BridgeEncoder.RouteAdded(address(1), 1, address(3));
        acrossV4BridgeEncoder.addRoute(address(1), 1, address(3));
        assertTrue(acrossV4BridgeEncoder.isRouteRegistered(address(1), 1, address(2)));
        assertTrue(acrossV4BridgeEncoder.isRouteRegistered(address(1), 1, address(3)));
        assertFalse(acrossV4BridgeEncoder.isRouteRegistered(address(1), 2, address(3)));
        assertFalse(acrossV4BridgeEncoder.isRouteRegistered(address(2), 2, address(3)));

        vm.expectEmit(true, true, true, false, address(acrossV4BridgeEncoder));
        emit IAcrossV4BridgeEncoder.RouteAdded(address(1), 2, address(3));
        acrossV4BridgeEncoder.addRoute(address(1), 2, address(3));
        assertTrue(acrossV4BridgeEncoder.isRouteRegistered(address(1), 1, address(2)));
        assertTrue(acrossV4BridgeEncoder.isRouteRegistered(address(1), 1, address(3)));
        assertTrue(acrossV4BridgeEncoder.isRouteRegistered(address(1), 2, address(3)));
        assertFalse(acrossV4BridgeEncoder.isRouteRegistered(address(2), 2, address(3)));

        vm.expectEmit(true, true, true, false, address(acrossV4BridgeEncoder));
        emit IAcrossV4BridgeEncoder.RouteAdded(address(2), 2, address(3));
        acrossV4BridgeEncoder.addRoute(address(2), 2, address(3));
        assertTrue(acrossV4BridgeEncoder.isRouteRegistered(address(1), 1, address(2)));
        assertTrue(acrossV4BridgeEncoder.isRouteRegistered(address(1), 1, address(3)));
        assertTrue(acrossV4BridgeEncoder.isRouteRegistered(address(1), 2, address(3)));
        assertTrue(acrossV4BridgeEncoder.isRouteRegistered(address(2), 2, address(3)));
    }
}
