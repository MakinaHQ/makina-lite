// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @dev Mock DEX contract for testing use only.
contract MockDex {
    using SafeERC20 for IERC20;

    error InvalidToken();
    error InvalidQuote();

    struct Quote {
        uint256 numerator;
        uint256 denominator;
    }

    mapping(address tokenIn => mapping(address tokenOut => Quote)) public quotes;

    function setQuote(address tokenIn, address tokenOut, uint256 numerator, uint256 denominator) external {
        if (tokenIn == address(0) || tokenOut == address(0) || tokenIn == tokenOut) {
            revert InvalidToken();
        }
        if (numerator == 0 || denominator == 0) {
            revert InvalidQuote();
        }

        quotes[tokenIn][tokenOut] = Quote({numerator: numerator, denominator: denominator});
    }

    function previewSwap(address tokenIn, address tokenOut, uint256 amountIn) public view returns (uint256) {
        if (tokenIn == address(0) || tokenOut == address(0) || tokenIn == tokenOut) {
            revert InvalidToken();
        }

        Quote memory quote = quotes[tokenIn][tokenOut];
        if (quote.numerator == 0 || quote.denominator == 0) {
            return amountIn;
        }

        return amountIn * quote.numerator / quote.denominator;
    }

    function swap(address tokenIn, address tokenOut, uint256 amountIn) external returns (uint256 amountOut) {
        amountOut = previewSwap(tokenIn, tokenOut, amountIn);

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenOut).safeTransfer(msg.sender, amountOut);
    }
}
