// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {Vm} from "forge-std/Vm.sol";

abstract contract IRCodeReader {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function getWeirollVMCode() internal view returns (bytes memory creationBytecode) {
        return vm.getCode("out-ir-based/WeirollVM.sol/WeirollVM.json");
    }
}
