// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.34;

import {Errors} from "src/libraries/Errors.sol";
import {IAcrossV4SpokePool} from "src/interfaces/IAcrossV4SpokePool.sol";
import {IBridgeComponent} from "src/interfaces/IBridgeComponent.sol";

import {AcrossV4BridgeEncoder_Integration_Concrete_Test} from "../AcrossV4BridgeEncoder.t.sol";

contract GetBridgeTransferData_AcrossV4BridgeEncoder_Integration_Concrete_Test is
    AcrossV4BridgeEncoder_Integration_Concrete_Test
{
    function test_RevertGiven_ZeroRefundAddress() public {
        IBridgeComponent.BridgeOrder memory order;
        order.extraData = abi.encode(address(0), address(0), uint32(0));

        vm.expectRevert(Errors.ZeroRefundAddress.selector);
        acrossV4BridgeEncoder.getBridgeTransferData(order, false);
    }

    function test_GetBridgeTransferData_RouteNotRegistered() public view {
        IBridgeComponent.BridgeOrder memory order;
        order.extraData = abi.encode(address(0), address(safe), uint32(0));

        (address approvalTarget, address executionTarget, uint256 value, bytes memory cd) =
            acrossV4BridgeEncoder.getBridgeTransferData(order, false);

        assertEq(approvalTarget, acrossV4SpokePool);
        assertEq(executionTarget, acrossV4SpokePool);
        assertEq(value, 0);
        assertEq(
            cd,
            abi.encodeCall(
                IAcrossV4SpokePool.depositV3Now,
                (address(safe), address(0), address(0), address(0), 0, 0, 0, address(0), 0, 0, "")
            )
        );
    }

    function test_GetBridgeTransferData_RouteRegistered() public {
        uint256 inputAmount = 1e18;
        uint256 minOutputAmount = 999e15;

        address outputToken = makeAddr("outputToken");

        IBridgeComponent.BridgeOrder memory order = IBridgeComponent.BridgeOrder({
            bridgeId: DUMMY_BRIDGE_ID,
            destinationChainId: L2_CHAIN_ID,
            recipient: transferRecipient,
            inputToken: baseToken,
            inputAmount: inputAmount,
            minOutputAmount: minOutputAmount,
            extraData: abi.encode(outputToken, address(safe), ACROSS_V4_FILL_DEADLINE_OFFSET)
        });

        (address approvalTarget, address executionTarget, uint256 value, bytes memory cd) =
            acrossV4BridgeEncoder.getBridgeTransferData(order, false);

        assertEq(approvalTarget, acrossV4SpokePool);
        assertEq(executionTarget, acrossV4SpokePool);
        assertEq(value, 0);
        assertEq(
            cd,
            abi.encodeCall(
                IAcrossV4SpokePool.depositV3Now,
                (
                    address(safe),
                    transferRecipient,
                    baseToken,
                    outputToken,
                    inputAmount,
                    minOutputAmount,
                    L2_CHAIN_ID,
                    address(0),
                    ACROSS_V4_FILL_DEADLINE_OFFSET,
                    0,
                    ""
                )
            )
        );
    }

    function test_RevertGiven_RouteNotRegistered_WhileInLockdownMode() public {
        IBridgeComponent.BridgeOrder memory order;
        order.extraData = abi.encode(address(0), address(0), uint32(0));

        vm.expectRevert(Errors.RouteNotRegistered.selector);
        acrossV4BridgeEncoder.getBridgeTransferData(order, true);
    }

    function test_RevertGiven_ZeroRefundAddress_WhileInLockdownMode() public {
        address outputToken = makeAddr("outputToken");

        vm.prank(dao);
        acrossV4BridgeEncoder.addRoute(baseToken, L2_CHAIN_ID, outputToken);

        IBridgeComponent.BridgeOrder memory order;
        order.inputToken = baseToken;
        order.destinationChainId = L2_CHAIN_ID;
        order.extraData = abi.encode(outputToken, address(0), uint32(0));

        vm.expectRevert(Errors.ZeroRefundAddress.selector);
        acrossV4BridgeEncoder.getBridgeTransferData(order, true);
    }
}
