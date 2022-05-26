// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "../interfaces/IMfiMerkleFactoryInterfaces.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";


contract MfiMerkleFactoryStorages {

    // ID of each project
    mapping(uint256 => address) public merkleDistributorIds;
    // The root node of each project
    mapping(uint256 => bytes32) public merkleDistributorRoot;
    // The total number of awards for each phase of the project
    mapping(uint256 => uint256) public merkleDistributorTotal;
    // The number of remaining rewards for each phase of the project
    mapping(uint256 => uint256) public merkleDistributorReturn;

}
