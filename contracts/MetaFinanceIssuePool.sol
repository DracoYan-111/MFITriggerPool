// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./utils/MfiAccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";


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
    uint256 public lockDays = 180 days;
    IERC20Metadata public rewardsToken;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public rewards;
    mapping(address => uint256) private _balances;
    mapping(address => UserPledge) public userData;
    mapping(address => uint256) public userRewardPerTokenPaid;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _rewardsToken){
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        rewardsToken = IERC20Metadata(_rewardsToken);
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account_) external view returns (uint256) {
        return _balances[account_];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, MAX);
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
        );
    }

    function earned(address account_) public view returns (uint256) {
        return _balances[account_].mul(rewardPerToken().sub(userRewardPerTokenPaid[account_])).div(1e18).add(rewards[account_]);
    }

    function userAward(address account_) public view returns (uint256){
        UserPledge memory userData_ = userData[account_];
        if (userData_.startTime == 0) return 0;
        return userData_.numberOfRewardsPerSecond.mul(Math.min(block.timestamp, userData_.enderTime).sub(userData_.lastTime)).add(userData_.generateQuantity);
    }

    /* ========== EXTERNAL ========== */

    function stake(address account_, uint256 amount_) external nonReentrant updateReward(account_) onlyRole(META_FINANCE_TRIGGER_POOL) {
        require(amount_ > 0, "MFIP:E1");
        _totalSupply = _totalSupply.add(amount_);
        _balances[account_] = _balances[account_].add(amount_);
        emit Staked(account_, amount_);
    }

    function withdraw(address account_, uint256 amount) external nonReentrant updateReward(account_) onlyRole(META_FINANCE_TRIGGER_POOL) {
        require(amount > 0, "MFIP:E2");
        _totalSupply = _totalSupply.sub(amount);
        _balances[account_] = _balances[account_].sub(amount);
        emit Withdrawn(account_, amount);
    }

    function liquidate(address account_) public nonReentrant updateReward(account_) {
        uint256 reward = rewards[account_];
        if (reward > lockDays) {
            rewards[account_] = 0;
            uint256 blockTimestamp = block.timestamp;
            UserPledge storage userData_ = userData[account_];
            userData_.generateQuantity = userAward(account_);
            userData_.startTime = blockTimestamp;
            userData_.enderTime = blockTimestamp.add(lockDays);
            userData_.lastTime = blockTimestamp;
            userData_.pledgeTotal = (userData_.pledgeTotal.add(reward)).sub(userData_.generateQuantity);
            userData_.numberOfRewardsPerSecond = userData_.pledgeTotal.div(lockDays);
            //rewardsToken.safeTransfer(account_, reward);
            //emit RewardPaid(account_, reward);
        }
    }

    function getReward() public nonReentrant {
        uint256 reward = userAward(_msgSender());
        if (reward > 10 ** 10) {
            userData[_msgSender()].lastTime = Math.min(block.timestamp,userData[_msgSender()].enderTime);
            rewardsToken.safeTransfer(_msgSender(), reward);
        }
        emit RewardPaid(_msgSender(), reward);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(uint256 startingTime, uint256 reward) external updateReward(address(0)) onlyRole(DATA_ADMINISTRATOR) {

        rewardRate = reward;

        lastUpdateTime = block.timestamp;//startingTime;
        emit RewardAdded(reward);
    }

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
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
}
