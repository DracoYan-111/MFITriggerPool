// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "../interfaces/MfiInterfaces.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract MfiStorages {
    uint256 public proportion = 100;
    uint256 public totalPledgeValue;
    uint256 public totalPledgeAmount;
    //uint256 public clubIncentive = 10;
    uint256 public treasuryRatio = 50;
    uint256 public exchequerAmount;
    address public exchequerAddress;
    uint256 public cakeTokenBalanceOf;
    IMetaFinanceClubInfo public metaFinanceClubInfo;
    ISmartChefInitializable[] public smartChefArray;
    IMetaFinanceIssuePool public metaFinanceIssuePoolAddress;

    // club data
    //mapping(address => uint256) public foundationData;
    // User Club Information
    //mapping(address => address) public userFoundation;
    // User pledge amount
    mapping(address => uint256) public userPledgeAmount;
    // Storage quantity
    mapping(ISmartChefInitializable => uint256) public storageQuantity;
    // Storage ratio
    mapping(ISmartChefInitializable => uint256) public storageProportion;


    /// @notice main chain
    IPancakeRouter02 public constant pancakeRouterAddress = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IERC20Metadata public constant cakeTokenAddress = IERC20Metadata(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);

    /// @notice test chain
    //IPancakeRouter02 public constant pancakeRouterAddress = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    //IERC20Metadata public constant cakeTokenAddress = IERC20Metadata(0xF9f93cF501BFaDB6494589Cb4b4C15dE49E85D0e);

}
