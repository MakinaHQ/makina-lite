// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {LayerZeroV2BridgeEncoder} from "src/bridge-encoders/LayerZeroV2BridgeEncoder.sol";

import {Base_Test} from "test/base/Base.t.sol";

abstract contract LayerZeroV2BridgeEncoder_Unit_Concrete_Test is Base_Test {
    address internal oft;

    LayerZeroV2BridgeEncoder internal layerZeroV2BridgeEncoder;

    function setUp() public virtual override {
        Base_Test.setUp();

        oft = makeAddr("oft");

        layerZeroV2BridgeEncoder = _deployLayerZeroV2BridgeEncoder(address(accessManager), address(accessManager));
    }
}
