// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {IModuleFactory} from "../../src/interfaces/IModuleFactory.sol";
import {ModuleFactory} from "../../src/factory/ModuleFactory.sol";

import {Base} from "../../test/base/Base.sol";

/// @notice Standalone script to deploy a *new* ModuleFactory proxy that wires into the
///         already-deployed MakinaLiteRegistry. Permissionless defaults are seeded as part
///         of the proxy's initialize() call, so the broadcaster needs no roles on the
///         existing AccessManager — only gas.
///
///         This does NOT upgrade the existing factory — it stands up a parallel one.
///
/// Notes:
/// - Clones produced by this new factory inherit `moduleImplementation`, `feeCollector`,
///   `flashLoanModule`, and bridge encoders from the existing registry (read at call time).
/// - HOWEVER: the existing FlashLoanModule has an immutable reference to the *original*
///   ModuleFactory, so clones deployed by this new factory will not be authorized as
///   flash-loan takers. Flash loans remain limited to clones of the original factory.
/// - The new proxy is initialized with the existing AccessManager as its authority, so
///   the existing INFRA_CONFIG_ROLE / ADMIN_ROLE holders can update defaults later via the
///   `setPermissionless*` setters.
///
/// Usage:
///   INFRA_INPUT_FILENAME=Mainnet-Test.json INFRA_OUTPUT_FILENAME=Mainnet-Test.json \
///       forge script script/deployments/DeployFactoryPermissionless.s.sol \
///       --rpc-url <rpc> --broadcast --account <any-funded-eoa>
contract DeployFactoryPermissionless is Base, Script {
    using stdJson for string;

    string public inputJson;
    string public outputPath;

    address public moduleFactoryImplem;
    address public moduleFactoryProxy;

    constructor() {
        string memory inputFilename = vm.envString("INFRA_INPUT_FILENAME");
        string memory outputFilename = vm.envString("INFRA_OUTPUT_FILENAME");

        string memory basePath = string.concat(vm.projectRoot(), "/script/deployments/");

        string memory inputPath = string.concat(basePath, "inputs/deploy-factory-permissionless/");
        inputPath = string.concat(inputPath, inputFilename);
        inputJson = vm.readFile(inputPath);

        outputPath = string.concat(basePath, "outputs/deploy-factory-permissionless/");
        outputPath = string.concat(outputPath, outputFilename);
    }

    function run() public {
        address registry = vm.parseJsonAddress(inputJson, ".registry");
        address accessManager = vm.parseJsonAddress(inputJson, ".accessManager");
        address proxyOwner = vm.parseJsonAddress(inputJson, ".proxyOwner");

        IModuleFactory.ModuleFactoryInitParams memory params = IModuleFactory.ModuleFactoryInitParams({
            initialAuthority: accessManager,
            initialPermissionlessProvider: vm.parseJsonAddress(inputJson, ".permissionlessDefaults.provider"),
            initialPermissionlessMaxPositionIncreaseLossBps: vm.parseJsonUint(
                inputJson, ".permissionlessDefaults.maxPositionIncreaseLossBps"
            ),
            initialPermissionlessMaxPositionDecreaseLossBps: vm.parseJsonUint(
                inputJson, ".permissionlessDefaults.maxPositionDecreaseLossBps"
            ),
            initialPermissionlessMaxSwapLossBps: vm.parseJsonUint(
                inputJson, ".permissionlessDefaults.maxSwapLossBps"
            ),
            initialPermissionlessSwapFeeRate: vm.parseJsonUint(inputJson, ".permissionlessDefaults.swapFeeRate")
        });

        address sender = vm.envOr("TEST_SENDER", address(0));
        if (sender != address(0)) {
            vm.startBroadcast(sender);
        } else {
            vm.startBroadcast();
        }

        // 1. Deploy a fresh ModuleFactory implementation wired to the existing registry.
        ModuleFactory implem = new ModuleFactory(registry);
        moduleFactoryImplem = address(implem);

        // 2. Deploy a TransparentUpgradeableProxy, initializing it under the existing
        //    AccessManager and seeding the permissionless defaults atomically.
        bytes memory initCall = abi.encodeCall(ModuleFactory.initialize, (params));
        TransparentUpgradeableProxy proxy =
            new TransparentUpgradeableProxy(moduleFactoryImplem, proxyOwner, initCall);
        moduleFactoryProxy = address(proxy);

        vm.stopBroadcast();

        // Output addresses.
        string memory key = "key-deploy-factory-permissionless-output-file";
        vm.serializeAddress(key, "ModuleFactory", moduleFactoryProxy);
        vm.writeJson(vm.serializeAddress(key, "ModuleFactoryImplem", moduleFactoryImplem), outputPath);
    }
}
