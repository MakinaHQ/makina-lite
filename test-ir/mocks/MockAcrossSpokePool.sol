// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IMockAcrossSpokePool} from "test/mocks/IMockAcrossSpokePool.sol";

/// @dev MockAcrossSpokePool contract for testing use only
contract MockAcrossSpokePool is IMockAcrossSpokePool {
    using SafeERC20 for IERC20;

    uint256 public numberOfDeposits;

    constructor() {
        numberOfDeposits = 1;
    }

    function depositV3Now(
        address depositor,
        address recipient,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        address exclusiveRelayer,
        uint32 fillDeadlineOffset,
        uint32 exclusivityParameter,
        bytes calldata message
    ) external payable override {
        IERC20(inputToken).safeTransferFrom(msg.sender, address(this), inputAmount);

        _depositV3(
            DepositV3Params({
                depositor: _addressToBytes32(depositor),
                recipient: _addressToBytes32(recipient),
                inputToken: _addressToBytes32(inputToken),
                outputToken: _addressToBytes32(outputToken),
                inputAmount: inputAmount,
                outputAmount: outputAmount,
                destinationChainId: destinationChainId,
                exclusiveRelayer: _addressToBytes32(exclusiveRelayer),
                depositId: numberOfDeposits,
                quoteTimestamp: uint32(block.timestamp),
                fillDeadline: uint32(block.timestamp + fillDeadlineOffset),
                exclusivityParameter: exclusivityParameter,
                message: message
            })
        );

        numberOfDeposits++;
    }

    function _depositV3(DepositV3Params memory params) internal {
        emit Deposit(
            params.inputToken,
            params.outputToken,
            params.inputAmount,
            params.outputAmount,
            params.destinationChainId,
            params.depositId,
            params.quoteTimestamp,
            params.fillDeadline,
            params.exclusivityParameter,
            params.depositor,
            params.recipient,
            params.exclusiveRelayer,
            params.message
        );
    }

    function _addressToBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}
