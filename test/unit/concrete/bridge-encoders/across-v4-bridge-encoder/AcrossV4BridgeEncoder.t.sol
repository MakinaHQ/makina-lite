// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {AcrossV4BridgeEncoder} from "src/bridge-encoders/AcrossV4BridgeEncoder.sol";

import {Base_Test} from "test/base/Base.t.sol";

abstract contract AcrossV4BridgeEncoder_Unit_Concrete_Test is Base_Test {
    AcrossV4BridgeEncoder internal acrossV4BridgeEncoder;

    address internal acrossV4SpokePool;

    function setUp() public virtual override {
        Base_Test.setUp();

        acrossV4SpokePool = makeAddr("acrossV4SpokePool");

        acrossV4BridgeEncoder =
            _deployAcrossV4BridgeEncoder(address(accessManager), address(accessManager), acrossV4SpokePool);
    }
}

contract Getters_AcrossV4BridgeEncoder_Unit_Concrete_Test is AcrossV4BridgeEncoder_Unit_Concrete_Test {
    function test_Getters() public view {
        assertEq(acrossV4BridgeEncoder.acrossV4SpokePool(), acrossV4SpokePool);
    }
}
