// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IMorphoFlashLoanCallback {
    function onMorphoFlashLoan(uint256 assets, bytes calldata data) external;
}
