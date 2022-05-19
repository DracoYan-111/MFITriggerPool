// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./events/MfiIssueEvents.sol";
import "./utils/MfiAccessControl.sol";
import "./storages/MfiIssueStorages.sol";

contract MetaFinanceIssuePool is Context, MfiIssueStorages, MfiIssueEvents, MfiAccessControl, ReentrancyGuardUpgradeable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Metadata;

    /* ========== CONSTRUCTOR ========== */

    function initialize(address _rewardsToken, address metaFinanceClubInfo_) initializer public {
        lockDays = 180 days;
        __ReentrancyGuard_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        rewardsToken = IERC20Metadata(_rewardsToken);
        metaFinanceClubInfo = IMetaFinanceClubInfo(metaFinanceClubInfo_);
    }

    function getInitializeAbi(address _rewardsToken, address metaFinanceClubInfo_) public pure returns (bytes memory){
        return abi.encodeWithSelector(this.initialize.selector, _rewardsToken, metaFinanceClubInfo_);
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
        uint256 generateQuantity = userData[_msgSender()].generateQuantity;
        uint256 reward = userAward(_msgSender());
        userData[_msgSender()].lastTime = Math.min(block.timestamp, userData[_msgSender()].enderTime);
        userData[_msgSender()].generateQuantity = 0;
        block.timestamp >= userData[_msgSender()].enderTime ?
        userData[_msgSender()].pledgeTotal = 0 :
        userData[_msgSender()].pledgeTotal = (userData[_msgSender()].pledgeTotal.add(generateQuantity)).sub(reward);
        received[_msgSender()] = received[_msgSender()].add(reward);
        rewardsToken.safeTransfer(_msgSender(), reward);

        emit RewardPaid(_msgSender(), reward);
    }
    /* ========== VIEWS ========== */
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
        uint256 userEarned = (_balances[account_].mul(rewardPerToken().sub(userRewardPerTokenPaid[account_])).div(1e18).add(rewards[account_]));
        if (metaFinanceClubInfo.userClub(account_) == metaFinanceClubInfo.treasuryAddress())
            return userEarned.mul(metaFinanceClubInfo.noClub()).div(metaFinanceClubInfo.proportion());
        return userEarned.mul(metaFinanceClubInfo.yesClub()).div(metaFinanceClubInfo.proportion());
    }

    /**
    * @dev Rewards that users can already claim
    * @param account_ User address
    * @return Returns the reward that the user has moderated
    */
    function userAward(address account_) public view returns (uint256){
        UserPledge memory userData_ = userData[account_];
        if (userData_.startTime <= 0) return 0;
        return userData_.numberOfRewardsPerSecond.mul(Math.min(block.timestamp, userData_.enderTime).sub(userData_.lastTime)).add(userData_.generateQuantity);
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
        if (startingTime_ > 0) {
            lastUpdateTime = startingTime_;
            poolStartTime = startingTime_;
        }

        emit RewardAdded(reward_);
    }

    /**
    * @dev Modify production time
    * @param newLockDays_ New lock time
    */
    function setLockDays(uint256 newLockDays_) external onlyRole(DATA_ADMINISTRATOR) {
        lockDays = newLockDays_;
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
}
