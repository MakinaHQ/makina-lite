// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import {IOracleRegistry} from "./IOracleRegistry.sol";
import {ISwapComponent} from "./ISwapComponent.sol";
import {IWeirollComponent} from "./IWeirollComponent.sol";

interface IMakinaLiteModule is IOracleRegistry, IWeirollComponent, ISwapComponent {}
