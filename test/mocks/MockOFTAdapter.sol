// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IOFT} from "../../src/interfaces/IOFT.sol";

/// @dev MockOFTAdapter contract for testing use only
contract MockOFTAdapter is IOFT {
    using SafeERC20 for IERC20;

    event Send(
        uint32 dstEid,
        bytes32 to,
        uint256 amountLD,
        uint256 minAmountLD,
        uint128 lzReceiveGas,
        uint256 nativeFee,
        address refundAddress
    );

    address public token;

    bool public faultyModeSend;
    bool public faultyModeReceive;

    uint128 public verifyGas;
    uint256 public gasPrice;

    constructor(address _token) {
        token = _token;
    }

    function approvalRequired() external pure returns (bool) {
        return true;
    }

    function quoteOFT(SendParam calldata _sendParam)
        external
        view
        returns (OFTLimit memory oftLimit, OFTFeeDetail[] memory oftFeeDetails, OFTReceipt memory oftReceipt)
    {
        uint256 amountSentLD = faultyModeSend ? _sendParam.amountLD / 2 : _sendParam.amountLD;
        uint256 amountReceivedLD = faultyModeReceive ? _sendParam.amountLD / 2 : _sendParam.amountLD;

        oftReceipt.amountSentLD = amountSentLD;
        oftReceipt.amountReceivedLD = amountReceivedLD;

        return (oftLimit, oftFeeDetails, oftReceipt);
    }

    function quoteSend(SendParam calldata _sendParam, bool) external view returns (MessagingFee memory messagingFee) {
        uint128 lzReceiveGas;
        if (_sendParam.extraOptions.length != 0) {
            lzReceiveGas = uint128(bytes16(_sendParam.extraOptions[6:22]));
        }

        return MessagingFee((verifyGas + lzReceiveGas) * gasPrice, 0);
    }

    function send(SendParam calldata _sendParam, MessagingFee calldata _fee, address _refundAddress)
        external
        payable
        returns (MessagingReceipt memory messagingReceipt, OFTReceipt memory oftReceipt)
    {
        uint256 amountSentLD = faultyModeSend ? _sendParam.amountLD / 2 : _sendParam.amountLD;
        uint256 amountReceivedLD = faultyModeReceive ? _sendParam.amountLD / 2 : _sendParam.amountLD;

        if (amountReceivedLD < _sendParam.minAmountLD) {
            revert();
        }

        IERC20(token).safeTransferFrom(msg.sender, address(this), amountSentLD);

        uint128 lzReceiveGas;
        if (_sendParam.extraOptions.length != 0) {
            lzReceiveGas = uint128(bytes16(_sendParam.extraOptions[6:22]));
        }

        emit Send(
            _sendParam.dstEid,
            _sendParam.to,
            _sendParam.amountLD,
            _sendParam.minAmountLD,
            lzReceiveGas,
            _fee.nativeFee,
            _refundAddress
        );

        return (messagingReceipt, oftReceipt);
    }

    function setFaultyModeSend(bool _faultyMode) public {
        faultyModeSend = _faultyMode;
    }

    function setFaultyModeReceive(bool _faultyMode) public {
        faultyModeReceive = _faultyMode;
    }

    function setVerifyGas(uint128 _verifyGas) public {
        verifyGas = _verifyGas;
    }

    function setGasPrice(uint256 _gasPrice) public {
        gasPrice = _gasPrice;
    }
}
