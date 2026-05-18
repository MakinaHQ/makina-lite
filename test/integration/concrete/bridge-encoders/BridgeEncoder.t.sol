// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {Base_Test} from "test/base/Base.t.sol";

abstract contract BridgeEncoder_Integration_Concrete_Test is Base_Test {
    address internal transferRecipient;
    address internal baseToken;

    function setUp() public virtual override {
        Base_Test.setUp();

        transferRecipient = makeAddr("transferRecipient");
        baseToken = makeAddr("baseToken");
    }
}
