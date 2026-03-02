// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {ISwapComponent} from "src/interfaces/ISwapComponent.sol";

import {Integration_Concrete_Test} from "../IntegrationConcrete.t.sol";

abstract contract SwapComponent_Integration_Concrete_Test is Integration_Concrete_Test {
    ISwapComponent internal swapComponent;

    function setUp() public virtual override {
        Integration_Concrete_Test.setUp();

        swapComponent = ISwapComponent(address(makinaLiteModule));
    }
}
