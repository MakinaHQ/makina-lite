// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {ISafe} from "../../src/interfaces/ISafe.sol";

/// @dev Mock Safe contract for testing use only.
contract MockSafe is ISafe {
    event ModuleTransactionExecuted(
        address indexed to, uint256 value, bytes data, Operation operation, bool success, bytes returnData
    );

    bool public revertOnReceive;

    /// @dev Lets ModuleFactory._isSafe() recognise this mock as a Safe.
    function getThreshold() external pure returns (uint256) {
        return 1;
    }

    receive() external payable {
        if (revertOnReceive) {
            revert();
        }
    }

    function execTransactionFromModuleReturnData(address to, uint256 value, bytes memory data, Operation operation)
        external
        override
        returns (bool success, bytes memory returnData)
    {
        (success, returnData) = _execute(to, value, data, operation);
    }

    function setRevertOnReceive(bool value) external {
        revertOnReceive = value;
    }

    function _execute(address to, uint256 value, bytes memory data, Operation operation)
        internal
        returns (bool success, bytes memory returnData)
    {
        if (operation == Operation.Call) {
            (success, returnData) = to.call{value: value}(data);
        } else {
            (success, returnData) = to.delegatecall(data);
        }

        emit ModuleTransactionExecuted(to, value, data, operation, success, returnData);
    }
}
