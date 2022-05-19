// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "../interfaces/MfiIssueInterfaces.sol";

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";


contract MfiIssueStorages {

    /* ========== STATE VARIABLES ========== */
    struct UserPledge {
        uint256 pledgeTotal;
        uint256 startTime;
        uint256 enderTime;
        uint256 lastTime;
        uint256 generateQuantity;
        uint256 numberOfRewardsPerSecond;
    }

    uint256 public poolStartTime;
    uint256 public _totalSupply;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public lockDays;
    IERC20Metadata public rewardsToken;
    uint256 public rewardPerTokenStored;
    IMetaFinanceClubInfo public metaFinanceClubInfo;

    mapping(address => uint256) public received;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public _balances;
    mapping(address => UserPledge) public userData;
    mapping(address => uint256) public userRewardPerTokenPaid;


}
