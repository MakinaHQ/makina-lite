// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

abstract contract Constants {
    uint256 public constant DEFAULT_PF_STALE_THRSHLD = 2 hours;

    uint256 internal constant DEFAULT_MAX_POS_INCREASE_LOSS_BPS = 100;
    uint256 internal constant DEFAULT_MAX_POS_DECREASE_LOSS_BPS = 1000;
    uint256 internal constant DEFAULT_MAX_SWAP_LOSS_BPS = 200;
    uint256 internal constant DEFAULT_SWAP_FEE_RATE = 1e15; // 0.1%

    uint256 internal constant VAULT_POS_ID = 3;
    uint256 internal constant SUPPLY_POS_ID = 4;
    uint256 internal constant BORROW_POS_ID = 5;

    uint16 public constant TEST_SWAPPER_ID = 100;
}
