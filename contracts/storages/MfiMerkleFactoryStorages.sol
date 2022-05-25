// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "../interfaces/IMfiMerkleDistributorFactoryInterfaces.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";


contract MfiMerkleFactoryStorages {

    mapping(uint256 => address) public merkleDistributorIds;
    mapping(uint256 => bytes32) public merkleDistributorRoot;
    mapping(uint256 => uint256) public merkleDistributorTotal;
    mapping(uint256 => uint256) public merkleDistributorReturn;

}
