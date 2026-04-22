// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {AggregatorV2V3Interface} from "../interfaces/AggregatorV2V3Interface.sol";
import {IOracleRegistry} from "../interfaces/IOracleRegistry.sol";
import {DecimalsUtils} from "../libraries/DecimalsUtils.sol";
import {Errors} from "../libraries/Errors.sol";

abstract contract OracleRegistry is IOracleRegistry {
    using Math for uint256;

    mapping(address token => FeedRoute feedRoute) private _feedRoutes;
    mapping(address feed => uint256 stalenessThreshold) private _feedStaleThreshold;

    /// @inheritdoc IOracleRegistry
    function getFeedStaleThreshold(address feed) external view override returns (uint256) {
        return _feedStaleThreshold[feed];
    }

    /// @inheritdoc IOracleRegistry
    function isFeedRouteRegistered(address token) public view override returns (bool) {
        return _feedRoutes[token].feed1 != address(0);
    }

    /// @inheritdoc IOracleRegistry
    function getFeedRoute(address token) external view override returns (address, address) {
        FeedRoute memory route = _feedRoutes[token];
        if (route.feed1 == address(0)) {
            revert Errors.PriceFeedRouteNotRegistered(token);
        }
        return (route.feed1, route.feed2);
    }

    /// @inheritdoc IOracleRegistry
    function getReferencePrice(address baseToken) public view override returns (uint256) {
        FeedRoute memory baseFR = _feedRoutes[baseToken];
        if (baseFR.feed1 == address(0)) {
            revert Errors.PriceFeedRouteNotRegistered(baseToken);
        }

        uint8 baseFRDecimalsSum = _getFeedDecimals(baseFR.feed1) + _getFeedDecimals(baseFR.feed2);
        uint8 quoteTokenDecimals = DecimalsUtils.REFERENCE_CURRENCY_DECIMALS;

        // price = 10^(refCurrencyDecimals - baseFeedsDecimalsSum) *
        //  (baseFeedPrice1 * baseFeedPrice2)

        if (quoteTokenDecimals < baseFRDecimalsSum) {
            return _getFeedPrice(baseFR.feed1) * _getFeedPrice(baseFR.feed2)
                / (10 ** (baseFRDecimalsSum - quoteTokenDecimals));
        }
        return
            (10 ** (quoteTokenDecimals - baseFRDecimalsSum))
                * (_getFeedPrice(baseFR.feed1) * _getFeedPrice(baseFR.feed2));
    }

    /// @inheritdoc IOracleRegistry
    function getPrice(address baseToken, address quoteToken) public view override returns (uint256) {
        FeedRoute memory baseFR = _feedRoutes[baseToken];
        FeedRoute memory quoteFR = _feedRoutes[quoteToken];

        if (baseFR.feed1 == address(0)) {
            revert Errors.PriceFeedRouteNotRegistered(baseToken);
        }
        if (quoteFR.feed1 == address(0)) {
            revert Errors.PriceFeedRouteNotRegistered(quoteToken);
        }

        uint8 baseFRDecimalsSum = _getFeedDecimals(baseFR.feed1) + _getFeedDecimals(baseFR.feed2);
        uint8 quoteFRDecimalsSum = _getFeedDecimals(quoteFR.feed1) + _getFeedDecimals(quoteFR.feed2);
        uint8 quoteTokenDecimals = IERC20Metadata(quoteToken).decimals();

        // price = 10^(quoteTokenDecimals + quoteFeedsDecimalsSum - baseFeedsDecimalsSum) *
        //  (baseFeedPrice1 * baseFeedPrice2) / (quoteFeedPrice1 * quoteFeedPrice2)

        if (quoteTokenDecimals + quoteFRDecimalsSum < baseFRDecimalsSum) {
            return _getFeedPrice(baseFR.feed1) * _getFeedPrice(baseFR.feed2)
                / ((10 ** (baseFRDecimalsSum - quoteTokenDecimals - quoteFRDecimalsSum))
                    * _getFeedPrice(quoteFR.feed1)
                    * _getFeedPrice(quoteFR.feed2));
        }

        return (10 ** (quoteTokenDecimals + quoteFRDecimalsSum - baseFRDecimalsSum))
        .mulDiv(
            _getFeedPrice(baseFR.feed1) * _getFeedPrice(baseFR.feed2),
            _getFeedPrice(quoteFR.feed1) * _getFeedPrice(quoteFR.feed2)
        );
    }

    /// @dev Returns the last price of the feed.
    /// @dev Reverts if the feed is stale or the price is negative.
    function _getFeedPrice(address feed) private view returns (uint256) {
        if (feed == address(0)) {
            return 1;
        }
        (, int256 answer,, uint256 updatedAt,) = AggregatorV2V3Interface(feed).latestRoundData();
        if (answer < 0) {
            revert Errors.NegativeTokenPrice(feed);
        }
        if (block.timestamp - updatedAt < _feedStaleThreshold[feed]) {
            return uint256(answer);
        }
        revert Errors.PriceFeedStale(feed, updatedAt);
    }

    /// @dev Returns the number of decimals of the feed.
    /// @dev Returns 0 if the feed is not set.
    function _getFeedDecimals(address feed) private view returns (uint8) {
        if (feed == address(0)) {
            return 0;
        }
        return AggregatorV2V3Interface(feed).decimals();
    }

    /// @dev Internal logic to set feed route for a token.
    function _setFeedRoute(
        address token,
        address feed1,
        uint256 stalenessThreshold1,
        address feed2,
        uint256 stalenessThreshold2
    ) internal {
        if (feed1 == address(0)) {
            revert Errors.InvalidFeedRoute();
        }

        DecimalsUtils._checkDecimals(token);

        _feedRoutes[token] = FeedRoute({feed1: feed1, feed2: feed2});

        _feedStaleThreshold[feed1] = stalenessThreshold1;
        if (feed2 != address(0)) {
            _feedStaleThreshold[feed2] = stalenessThreshold2;
        }

        emit FeedRouteRegistered(token, feed1, feed2);
    }

    /// @dev Internal logic to clear feed route for a token.
    function _clearFeedRoute(address token) internal {
        if (_feedRoutes[token].feed1 == address(0)) {
            revert Errors.PriceFeedRouteNotRegistered(token);
        }
        delete _feedRoutes[token];
        emit FeedRouteCleared(token);
    }

    /// @dev Internal logic to set the price staleness threshold for a given feed.
    function _setFeedStaleThreshold(address feed, uint256 newThreshold) internal {
        emit FeedStaleThresholdChanged(feed, _feedStaleThreshold[feed], newThreshold);
        // zero is allowed in order to disable a feed
        _feedStaleThreshold[feed] = newThreshold;
    }
}
