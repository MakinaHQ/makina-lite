// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {IAccessManaged} from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";

import {ILayerZeroV2BridgeEncoder} from "src/interfaces/ILayerZeroV2BridgeEncoder.sol";
import {Errors} from "src/libraries/Errors.sol";

import {LayerZeroV2BridgeEncoder_Unit_Concrete_Test} from "../LayerZeroV2BridgeEncoder.t.sol";

contract RemoveOft_Unit_Concrete_Test is LayerZeroV2BridgeEncoder_Unit_Concrete_Test {
    function test_RevertWhen_CallerWithoutRole() public {
        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, address(this)));
        layerZeroV2BridgeEncoder.removeOft(address(0));
    }

    function test_RevertWhen_ZeroAddress() public {
        vm.startPrank(dao);

        vm.expectRevert(abi.encodeWithSelector(Errors.ZeroAddress.selector));
        layerZeroV2BridgeEncoder.removeOft(address(0));
    }

    function test_RevertWhen_OftNotRegistered() public {
        vm.startPrank(dao);

        vm.expectRevert(abi.encodeWithSelector(Errors.OftNotRegistered.selector));
        layerZeroV2BridgeEncoder.removeOft(oft);
    }

    function test_RemoveOft() public {
        vm.startPrank(dao);

        layerZeroV2BridgeEncoder.addOft(oft);

        vm.expectEmit(true, true, false, false, address(layerZeroV2BridgeEncoder));
        emit ILayerZeroV2BridgeEncoder.OftRemoved(oft);
        layerZeroV2BridgeEncoder.removeOft(oft);

        assertFalse(layerZeroV2BridgeEncoder.isOftRegistered(oft));
    }
}
