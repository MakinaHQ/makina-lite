// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {CctpV2BridgeEncoder} from "src/bridge-encoders/CctpV2BridgeEncoder.sol";

import {Base_Test} from "test/base/Base.t.sol";

abstract contract CctpV2BridgeEncoder_Unit_Concrete_Test is Base_Test {
    CctpV2BridgeEncoder internal cctpV2BridgeEncoder;

    address internal cctpV2TokenMessenger;

    function setUp() public virtual override {
        Base_Test.setUp();

        cctpV2TokenMessenger = makeAddr("cctpV2TokenMessenger");

        cctpV2BridgeEncoder =
            _deployCctpV2BridgeEncoder(address(accessManager), address(accessManager), cctpV2TokenMessenger);
    }
}

contract Getters_CctpV2BridgeEncoder_Unit_Concrete_Test is CctpV2BridgeEncoder_Unit_Concrete_Test {
    function test_Getters() public view {
        assertEq(cctpV2BridgeEncoder.cctpV2TokenMessenger(), cctpV2TokenMessenger);
    }
}
