// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./utils/MfiAccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title MetaFinanceClubInfo contract interface
 */
interface IMetaFinanceClubInfo {
    function userClub(address userAddress_) external view returns (address);

    function treasuryAddress() external view returns (address);

    function proportion() external view returns (uint256);

    function yesClub() external view returns (uint256);

    function noClub() external view returns (uint256);
}

contract MetaFinanceIssuePool is Context, ReentrancyGuard, MfiAccessControl {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Metadata;

    /* ========== STATE VARIABLES ========== */
    struct UserPledge {
        uint256 pledgeTotal;
        uint256 startTime;
        uint256 enderTime;
        uint256 lastTime;
        uint256 generateQuantity;
        uint256 numberOfRewardsPerSecond;
    }

    uint256 private _totalSupply;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public lockDays = 30;//180 days;
    IERC20Metadata public rewardsToken;
    uint256 public rewardPerTokenStored;
    IMetaFinanceClubInfo public metaFinanceClubInfo;

    mapping(address => uint256) public rewards;
    mapping(address => uint256) private _balances;
    mapping(address => UserPledge) public userData;
    mapping(address => uint256) public userRewardPerTokenPaid;

    /* ========== CONSTRUCTOR ========== */

    /**
    * @dev Constructor
    * @param _rewardsToken Reward Token Address
    */
    constructor(address _rewardsToken, address metaFinanceClubInfo_){
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        rewardsToken = IERC20Metadata(_rewardsToken);
        metaFinanceClubInfo = IMetaFinanceClubInfo(metaFinanceClubInfo_);

    }

    /* ========== VIEWS ========== */

    /**
    * @dev Total pledge amount
    * @return Returns the total pledge amount
    */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev User pledge amount
    * @param account_ User address
    * @return Returns the users pledge amount
    */
    function balanceOf(address account_) external view returns (uint256) {
        return _balances[account_];
    }

    /**
    * @dev Rewards per token
    * @return Returns the reward amount for staked tokens
    */
    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            block.timestamp.sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
        );
    }

    /**
    * @dev View user revenue
    * @param account_ User address
    * @return Returns the revenue the user has already earned
    */
    function earned(address account_) public view returns (uint256) {
        if (metaFinanceClubInfo.userClub(account_) == metaFinanceClubInfo.treasuryAddress())
            return
            (_balances[account_].mul(rewardPerToken().sub(userRewardPerTokenPaid[account_])).div(1e18).add(rewards[account_])).add(
                (_balances[account_].mul(rewardPerToken().sub(userRewardPerTokenPaid[account_])).div(1e18).add(rewards[account_])).mul(metaFinanceClubInfo.noClub()).div(metaFinanceClubInfo.proportion()));
        return
        (_balances[account_].mul(rewardPerToken().sub(userRewardPerTokenPaid[account_])).div(1e18).add(rewards[account_])).add(
            (_balances[account_].mul(rewardPerToken().sub(userRewardPerTokenPaid[account_])).div(1e18).add(rewards[account_])).mul(metaFinanceClubInfo.yesClub()).div(metaFinanceClubInfo.proportion()));
    }

    /**
    * @dev Rewards that users can already claim
    * @param account_ User address
    * @return Returns the reward that the user has moderated
    */
    function userAward(address account_) public view returns (uint256){
        UserPledge memory userData_ = userData[account_];
        if (userData_.startTime == 0) return 0;
        return userData_.numberOfRewardsPerSecond.mul(Math.min(block.timestamp, userData_.enderTime).sub(userData_.lastTime)).add(userData_.generateQuantity);
    }

    /* ========== EXTERNAL ========== */

    /**
    * @dev User pledge
    * @notice nonReentrant,updateReward(user address),onlyRole(META_FINANCE_TRIGGER_POOL)
    * @param account_ User address
    * @param amount_ Pledge amount
    */
    function stake(address account_, uint256 amount_) external nonReentrant updateReward(account_) onlyRole(META_FINANCE_TRIGGER_POOL) {
        require(amount_ > 0, "MFIP:E1");
        _totalSupply = _totalSupply.add(amount_);
        _balances[account_] = _balances[account_].add(amount_);
        emit Staked(account_, amount_);
    }

    /**
    * @dev User unstakes
    * @notice nonReentrant,updateReward(user address),onlyRole(META_FINANCE_TRIGGER_POOL)
    * @param account_ User address
    * @param amount_ Unstakes amount
    */
    function withdraw(address account_, uint256 amount_) external nonReentrant updateReward(account_) onlyRole(META_FINANCE_TRIGGER_POOL) {
        require(amount_ > 0, "MFIP:E2");
        _totalSupply = _totalSupply.sub(amount_);
        _balances[account_] = _balances[account_].sub(amount_);
        emit Withdrawn(account_, amount_);
    }

    /**
    * @dev Users receive staking rewards
    * @notice nonReentrant,updateReward(account_)
    */
    function harvest() external nonReentrant updateReward(_msgSender()) {
        uint256 reward = rewards[_msgSender()];
        require(reward >= 10 ** 12, "MFIP:E3");
        rewards[_msgSender()] = 0;
        uint256 blockTimestamp = block.timestamp;
        UserPledge storage userData_ = userData[_msgSender()];
        uint256 generateQuantity = userData_.generateQuantity;
        userData_.generateQuantity = userAward(_msgSender());
        userData_.startTime = blockTimestamp;
        userData_.enderTime = blockTimestamp.add(lockDays);
        userData_.lastTime = blockTimestamp;
        userData_.pledgeTotal = (userData_.pledgeTotal.add(reward)).sub(userData_.generateQuantity.sub(generateQuantity));
        userData_.numberOfRewardsPerSecond = userData_.pledgeTotal.div(lockDays);
        emit UserHarvest(_msgSender(), reward);
    }

    /**
    * @dev User gets rewarded
    * @notice nonReentrant
    */
    function getReward() external nonReentrant {
        uint256 reward = userAward(_msgSender());
        userData[_msgSender()].lastTime = Math.min(block.timestamp, userData[_msgSender()].enderTime);
        userData[_msgSender()].generateQuantity = 0;
        block.timestamp >= userData[_msgSender()].enderTime ?
        userData[_msgSender()].pledgeTotal = 0 : userData[_msgSender()].pledgeTotal = userData[_msgSender()].pledgeTotal.sub(reward);
        rewardsToken.safeTransfer(_msgSender(), reward);
        emit RewardPaid(_msgSender(), reward);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    /**
    * @dev Notification Rewards
    * @notice updateReward(address(0)) onlyRole(DATA_ADMINISTRATOR)
    * @param startingTime_ Reward start time
    * @param reward_ Number of experiences per second
    */
    function notifyRewardAmount(uint256 startingTime_, uint256 reward_) external updateReward(address(0)) onlyRole(DATA_ADMINISTRATOR) {

        rewardRate = reward_;
        lastUpdateTime = startingTime_;

        emit RewardAdded(reward_);
    }

    /* ========== MODIFIERS ========== */
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event UserHarvest(address indexed user, uint256 reward);
}
