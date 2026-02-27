// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import "forge-std/Test.sol";

import {Base} from "./Base.sol";

abstract contract Base_Test is Base, Test {
    function setUp() public virtual {}
}
