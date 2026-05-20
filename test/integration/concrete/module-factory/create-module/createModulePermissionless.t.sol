// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Errors as OZErrors} from "@openzeppelin/contracts/utils/Errors.sol";

import {Errors} from "src/libraries/Errors.sol";
import {IMakinaLiteModule} from "src/interfaces/IMakinaLiteModule.sol";
import {IModuleFactory} from "src/interfaces/IModuleFactory.sol";
import {MakinaLiteModule} from "src/MakinaLiteModule.sol";
import {MockSafe} from "test/mocks/MockSafe.sol";

import {Integration_Concrete_Test} from "../../IntegrationConcrete.t.sol";

contract CreateModulePermissionless_Integration_Concrete_Test is Integration_Concrete_Test {
    function test_RevertWhen_ZeroSalt() public {
        vm.expectRevert(Errors.ZeroSalt.selector);
        moduleFactory.createModulePermissionless(address(safe), bytes32(0), bytes32(0), 0);
    }

    function test_RevertWhen_ZeroSafe() public {
        bytes32 salt = bytes32(uint256(TEST_DEPLOYMENT_SALT) + 1);

        vm.expectRevert(Errors.ZeroAddress.selector);
        moduleFactory.createModulePermissionless(address(0), bytes32(0), salt, 0);
    }

    function test_RevertWhen_NotASafe_Eoa() public {
        address eoa = makeAddr("eoa");
        bytes32 salt = bytes32(uint256(TEST_DEPLOYMENT_SALT) + 1);

        vm.expectRevert(Errors.NotASafe.selector);
        moduleFactory.createModulePermissionless(eoa, bytes32(0), salt, 0);
    }

    function test_RevertWhen_NotASafe_RandomContract() public {
        // Use the registry as a "random contract" — it has no getThreshold().
        bytes32 salt = bytes32(uint256(TEST_DEPLOYMENT_SALT) + 1);

        vm.expectRevert(Errors.NotASafe.selector);
        moduleFactory.createModulePermissionless(address(registry), bytes32(0), salt, 0);
    }

    function test_RevertWhen_PermissionlessProviderUnset() public {
        vm.prank(dao);
        moduleFactory.setPermissionlessProvider(address(0));

        bytes32 salt = bytes32(uint256(TEST_DEPLOYMENT_SALT) + 1);

        vm.expectRevert(Errors.ZeroAddress.selector);
        moduleFactory.createModulePermissionless(address(safe), bytes32(0), salt, 0);
    }

    function test_RevertWhen_SaltAlreadyUsed() public {
        // TEST_DEPLOYMENT_SALT is already consumed by the makinaLiteModule deploy in setUp.
        vm.expectRevert(OZErrors.FailedDeployment.selector);
        moduleFactory.createModulePermissionless(address(safe), bytes32(0), TEST_DEPLOYMENT_SALT, 0);
    }

    function test_CreateModulePermissionless() public {
        bytes32 initialAllowedInstrRoot = bytes32("0x12345");
        bytes32 salt = bytes32(uint256(TEST_DEPLOYMENT_SALT) + 1);
        bytes32 referralKey = bytes32("referralKey");
        MockSafe newSafe = new MockSafe();

        address expectedModuleAddr =
            Clones.predictDeterministicAddress(makinaLiteModuleImplem, salt, address(moduleFactory));

        vm.expectEmit(true, true, true, false, address(moduleFactory));
        emit IModuleFactory.MakinaLiteModuleCreated(expectedModuleAddr, makinaLiteModuleImplem, referralKey);

        // Permissionless: anyone can call. No prank — use the test contract address.
        address moduleAddr =
            moduleFactory.createModulePermissionless(address(newSafe), initialAllowedInstrRoot, salt, referralKey);

        MakinaLiteModule deployed = MakinaLiteModule(payable(moduleAddr));

        assertTrue(moduleFactory.isMakinaLiteModule(moduleAddr));
        assertEq(deployed.registry(), address(registry));
        assertEq(deployed.safe(), address(newSafe));
        assertEq(deployed.provider(), dao);
        assertFalse(deployed.paused());
        assertFalse(deployed.suspendedByProvider());
        assertEq(deployed.allowedInstrRoot(), initialAllowedInstrRoot);
        assertEq(deployed.maxPositionIncreaseLossBps(), DEFAULT_MAX_POS_INCREASE_LOSS_BPS);
        assertEq(deployed.maxPositionDecreaseLossBps(), DEFAULT_MAX_POS_DECREASE_LOSS_BPS);
        assertEq(deployed.maxSwapLossBps(), DEFAULT_MAX_SWAP_LOSS_BPS);
        assertEq(deployed.swapFeeRate(), DEFAULT_PERMISSIONLESS_SWAP_FEE_RATE);
    }

    function test_CreateModulePermissionless_UsesUpdatedDefaults() public {
        // Bump the swap fee rate, then verify the next permissionless deploy picks it up.
        uint256 newSwapFeeRate = 1e16; // 1%
        address newProvider = makeAddr("newProvider");

        vm.startPrank(dao);
        moduleFactory.setPermissionlessSwapFeeRate(newSwapFeeRate);
        moduleFactory.setPermissionlessProvider(newProvider);
        vm.stopPrank();

        MockSafe newSafe = new MockSafe();
        bytes32 salt = bytes32(uint256(TEST_DEPLOYMENT_SALT) + 1);

        address moduleAddr = moduleFactory.createModulePermissionless(address(newSafe), bytes32(0), salt, 0);

        MakinaLiteModule deployed = MakinaLiteModule(payable(moduleAddr));
        assertEq(deployed.swapFeeRate(), newSwapFeeRate);
        assertEq(deployed.provider(), newProvider);
    }

    function test_CreateModulePermissionless_AnyCallerIsAllowed() public {
        MockSafe newSafe = new MockSafe();
        bytes32 salt = bytes32(uint256(TEST_DEPLOYMENT_SALT) + 1);
        address randomCaller = makeAddr("randomCaller");

        vm.prank(randomCaller);
        address moduleAddr = moduleFactory.createModulePermissionless(address(newSafe), bytes32(0), salt, 0);

        assertTrue(moduleFactory.isMakinaLiteModule(moduleAddr));
    }
}
