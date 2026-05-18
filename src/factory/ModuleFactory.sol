// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.35;

import {
    AccessManagedUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

import {Errors} from "../libraries/Errors.sol";
import {IMakinaLiteModule} from "../interfaces/IMakinaLiteModule.sol";
import {IMakinaLiteRegistry} from "../interfaces/IMakinaLiteRegistry.sol";
import {MakinaLiteContext} from "../utils/MakinaLiteContext.sol";
import {IModuleFactory} from "../interfaces/IModuleFactory.sol";

contract ModuleFactory layout at erc7201("makina.storage.ModuleFactory")
    is
    MakinaLiteContext,
    AccessManagedUpgradeable,
    IModuleFactory
{
    /// @inheritdoc IModuleFactory
    mapping(address module => bool isModule) public isMakinaLiteModule;

    constructor(address _registry) MakinaLiteContext(_registry) {}

    function initialize(address initialAuthority) external initializer {
        __AccessManaged_init(initialAuthority);
    }

    /// @inheritdoc IModuleFactory
    function createModule(
        IMakinaLiteModule.MakinaLiteModuleInitParams calldata params,
        bytes32 salt,
        bytes32 referralKey
    ) external restricted returns (address) {
        if (salt == bytes32(0)) {
            revert Errors.ZeroSalt();
        }

        address implementation = IMakinaLiteRegistry(registry).moduleImplementation();

        address module = Clones.cloneDeterministic(implementation, salt);
        IMakinaLiteModule(module).initialize(params);

        emit MakinaLiteModuleCreated(module, implementation, referralKey);

        isMakinaLiteModule[module] = true;

        return module;
    }
}
