// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {DecimalsUtils} from "./libraries/DecimalsUtils.sol";
import {IMakinaLiteModule} from "./interfaces/IMakinaLiteModule.sol";
import {IMakinaLiteRegistry} from "./interfaces/IMakinaLiteRegistry.sol";
import {ISafe} from "./interfaces/ISafe.sol";
import {Errors} from "./libraries/Errors.sol";
import {MakinaLiteContext} from "./utils/MakinaLiteContext.sol";
import {MakinaLiteGovernable} from "./utils/MakinaLiteGovernable.sol";
import {OracleRegistry, IOracleRegistry} from "./module-components/OracleRegistry.sol";
import {WeirollComponent, IWeirollComponent} from "./module-components/WeirollComponent.sol";
import {SwapComponent, ISwapComponent} from "./module-components/SwapComponent.sol";

contract MakinaLiteModule is
    MakinaLiteContext,
    MakinaLiteGovernable,
    OracleRegistry,
    WeirollComponent,
    SwapComponent,
    ReentrancyGuard,
    IMakinaLiteModule
{
    using Math for uint256;
    using SafeERC20 for IERC20;

    /// @dev Full scale value in basis points
    uint256 private constant MAX_BPS = 10_000;

    /// @dev Full scale value for fee rates
    uint256 private constant MAX_FEE_RATE = 1e18;

    constructor(
        address _registry,
        address _safe,
        address _provider,
        address _weirollVm,
        bytes32 _allowedInstrRoot,
        uint256 _maxPositionIncreaseLossBps,
        uint256 _maxPositionDecreaseLossBps,
        uint256 _maxSwapLossBps,
        uint256 _swapFeeRate
    ) MakinaLiteContext(_registry) MakinaLiteGovernable(_safe, _provider) WeirollComponent(_weirollVm) {
        _setAllowedInstrRoot(_allowedInstrRoot);

        _checkBps(_maxPositionIncreaseLossBps);
        _setMaxPositionIncreaseLossBps(_maxPositionIncreaseLossBps);

        _checkBps(_maxPositionDecreaseLossBps);
        _setMaxPositionDecreaseLossBps(_maxPositionDecreaseLossBps);

        _checkBps(_maxSwapLossBps);
        _setMaxSwapLossBps(_maxSwapLossBps);

        _checkFeeRate(_swapFeeRate);
        _setSwapFeeRate(_swapFeeRate);
    }

    /// @inheritdoc IOracleRegistry
    function setFeedRoute(
        address token,
        address feed1,
        uint256 stalenessThreshold1,
        address feed2,
        uint256 stalenessThreshold2
    ) external override onlySafe {
        _setFeedRoute(token, feed1, stalenessThreshold1, feed2, stalenessThreshold2);
    }

    /// @inheritdoc IOracleRegistry
    function clearFeedRoute(address token) external override onlySafe {
        _clearFeedRoute(token);
    }

    /// @inheritdoc IOracleRegistry
    function setFeedStaleThreshold(address feed, uint256 newThreshold) external override onlySafe {
        _setFeedStaleThreshold(feed, newThreshold);
    }

    /// @inheritdoc IWeirollComponent
    function accountForPosition(IWeirollComponent.Instruction calldata instruction)
        external
        override
        nonReentrant
        whenOperational
        onlyOperator
        returns (uint256)
    {
        return _accountForPosition(instruction, true, safe);
    }

    /// @inheritdoc IWeirollComponent
    function accountForPositionBatch(IWeirollComponent.Instruction[] calldata instructions, uint256[] calldata)
        external
        override
        nonReentrant
        whenOperational
        onlyOperator
        returns (uint256[] memory)
    {
        uint256 len = instructions.length;
        uint256[] memory values = new uint256[](len);
        for (uint256 i; i < len; ++i) {
            values[i] = _accountForPosition(instructions[i], true, safe);
        }

        return (values);
    }

    /// @inheritdoc IWeirollComponent
    function managePosition(
        IWeirollComponent.Instruction calldata mgmtInstruction,
        IWeirollComponent.Instruction calldata acctInstruction
    ) external override nonReentrant whenOperational onlyOperator returns (uint256, int256) {
        return _managePosition(mgmtInstruction, acctInstruction, lockdownMode, safe);
    }

    /// @inheritdoc IWeirollComponent
    function managePositionBatch(
        IWeirollComponent.Instruction[] calldata mgmtInstructions,
        IWeirollComponent.Instruction[] calldata acctInstructions
    ) external override nonReentrant whenOperational onlyOperator returns (uint256[] memory, int256[] memory) {
        uint256 len = mgmtInstructions.length;
        if (len != acctInstructions.length) {
            revert Errors.MismatchedLengths();
        }

        uint256[] memory values = new uint256[](len);
        int256[] memory changes = new int256[](len);

        for (uint256 i; i < len; ++i) {
            (values[i], changes[i]) = _managePosition(mgmtInstructions[i], acctInstructions[i], lockdownMode, safe);
        }

        return (values, changes);
    }

    /// @inheritdoc IWeirollComponent
    function harvest(IWeirollComponent.Instruction calldata instruction, ISwapComponent.SwapOrder[] calldata swapOrders)
        external
        override
        nonReentrant
        onlyOperator
        whenOperational
    {
        _harvest(instruction, safe);

        uint256 len = swapOrders.length;
        for (uint256 i; i < len; ++i) {
            _swapForSafe(swapOrders[i]);
        }
    }

    /// @inheritdoc IWeirollComponent
    function setAllowedInstrRoot(bytes32 newAllowedInstrRoot) external override onlySafe {
        _setAllowedInstrRoot(newAllowedInstrRoot);
    }

    /// @inheritdoc IWeirollComponent
    function setAccountingCurrency(address newAccountingCurrency) external override onlySafe {
        if (!isFeedRouteRegistered(newAccountingCurrency)) {
            revert Errors.PriceFeedRouteNotRegistered(newAccountingCurrency);
        }
        _setAccountingCurrency(newAccountingCurrency);
    }

    /// @inheritdoc IWeirollComponent
    function setMaxPositionIncreaseLossBps(uint256 newMaxPositionIncreaseLossBps) external override onlySafe {
        _checkBps(newMaxPositionIncreaseLossBps);
        _setMaxPositionIncreaseLossBps(newMaxPositionIncreaseLossBps);
    }

    /// @inheritdoc IWeirollComponent
    function setMaxPositionDecreaseLossBps(uint256 newMaxPositionDecreaseLossBps) external override onlySafe {
        _checkBps(newMaxPositionDecreaseLossBps);
        _setMaxPositionDecreaseLossBps(newMaxPositionDecreaseLossBps);
    }

    /// @inheritdoc ISwapComponent
    function swap(ISwapComponent.SwapOrder calldata order) external override nonReentrant whenOperational onlyOperator {
        _swapForSafe(order);
    }

    /// @inheritdoc ISwapComponent
    function setMaxSwapLossBps(uint256 newMaxSwapLossBps) external override onlySafe {
        _checkBps(newMaxSwapLossBps);
        _setMaxSwapLossBps(newMaxSwapLossBps);
    }

    function setSwapFeeRate(uint256 newSwapFeeRate) external override onlyProvider {
        _checkFeeRate(newSwapFeeRate);
        _setSwapFeeRate(newSwapFeeRate);
    }

    /// @inheritdoc ISwapComponent
    function setSwapperTargets(uint16 swapperId, address approvalTarget, address executionTarget)
        external
        override
        onlySafe
    {
        _setSwapperTargets(swapperId, approvalTarget, executionTarget);
    }

    /// @dev Internal logic to execute swap tokens on behalf of Safe using a given swapper.
    function _swapForSafe(ISwapComponent.SwapOrder calldata order) internal {
        _transferFromSafe(order.inputToken, order.inputAmount);

        uint256 amountOut = _swap(order, lockdownMode);

        uint256 fee = _chargeSwapFee(order.outputToken, amountOut);

        IERC20(order.outputToken).safeTransfer(safe, amountOut - fee);
    }

    /// @dev Returns the value of `baseTokenAmount` of `baseToken` denominated in `quoteToken`,  using the registered price feed.
    function _valueOf(address baseToken, address quoteToken, uint256 baseTokenAmount)
        internal
        view
        override(WeirollComponent, SwapComponent)
        returns (uint256)
    {
        if (baseToken == quoteToken) {
            return baseTokenAmount;
        }

        uint256 price;
        if (quoteToken == address(0)) {
            price = getReferencePrice(baseToken);
        } else {
            price = getPrice(baseToken, quoteToken);
        }

        return baseTokenAmount.mulDiv(price, 10 ** DecimalsUtils._getDecimals(baseToken));
    }

    /// @dev Approves this contract via a Safe module call to spend `amount` of `token`,
    ///      then pulls the tokens from the Safe.
    ///      Intentionally optimistic: does not check the Safe call result.
    ///      Safety relies on `transferFrom` reverting if approval/allowance is insufficient.
    function _transferFromSafe(address token, uint256 amount) internal {
        ISafe(safe)
            .execTransactionFromModule(
                token, 0, abi.encodeCall(IERC20.approve, (address(this), amount)), ISafe.Operation.Call
            );
        IERC20(token).safeTransferFrom(safe, address(this), amount);
    }

    /// @dev Performs sanity check on a basis points value.
    function _checkBps(uint256 bpsValue) internal pure {
        if (bpsValue > MAX_BPS) {
            revert Errors.InvalidBpsValue();
        }
    }

    /// @dev Performs sanity check on a fee rate.
    function _checkFeeRate(uint256 rate) internal pure {
        if (rate > MAX_FEE_RATE) {
            revert Errors.InvalidFeeRate();
        }
    }

    /// @dev Computes the fee for a given swap output, transfers it to the fee collector, and returns it.
    function _chargeSwapFee(address tokenOut, uint256 amountOut) internal returns (uint256) {
        if (swapFeeRate == 0) {
            return 0;
        }

        uint256 fee = amountOut.mulDiv(swapFeeRate, MAX_FEE_RATE);
        if (fee > 0) {
            address feeCollector = IMakinaLiteRegistry(registry).feeCollector();
            IERC20(tokenOut).safeTransfer(feeCollector, fee);
        }

        return fee;
    }
}
