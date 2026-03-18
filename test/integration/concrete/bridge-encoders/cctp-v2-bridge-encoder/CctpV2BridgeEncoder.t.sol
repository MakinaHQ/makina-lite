// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {CctpV2BridgeEncoder} from "src/bridge-encoders/CctpV2BridgeEncoder.sol";

import {BridgeEncoder_Integration_Concrete_Test} from "../BridgeEncoder.t.sol";

abstract contract CctpV2BridgeEncoder_Integration_Concrete_Test is BridgeEncoder_Integration_Concrete_Test {
    CctpV2BridgeEncoder internal cctpV2BridgeEncoder;

    address internal cctpV2TokenMessenger;

    function setUp() public virtual override {
        BridgeEncoder_Integration_Concrete_Test.setUp();

        cctpV2TokenMessenger = makeAddr("cctpV2TokenMessenger");

        cctpV2BridgeEncoder =
            _deployCctpV2BridgeEncoder(address(accessManager), address(accessManager), cctpV2TokenMessenger);

        vm.prank(dao);
        cctpV2BridgeEncoder.setCctpDomain(L2_CHAIN_ID, CCTP_V2_SPOKE_DOMAIN);
    }
}
