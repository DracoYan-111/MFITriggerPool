// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./events/MfiMerkleEvents.sol";
import "./utils/MfiAccessControl.sol";
import "./MetaFinanceMerkleDistributor.sol";
import "./storages/MfiMerkleFactoryStorages.sol";
import "./interfaces/IMfiMerkleFactoryInterfaces.sol";

contract MetaFinanceMerkleDistributorFactory is MfiAccessControl, MfiMerkleEvents, MfiMerkleFactoryStorages, ReentrancyGuardUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeMath for uint256;
    using SafeERC20 for IERC20Metadata;

    CountersUpgradeable.Counter private _merkleDistributorIds;

    /**
    * @notice Initialization method
    * @dev Initialization method, can only be used once,
    *      And set project default administrator
    */
    function initialize(
    ) public initializer {
        lockDays = 180 days;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function getInitializeAbi() public pure returns (bytes memory){
        return abi.encodeWithSelector(this.initialize.selector);
    }

    /**
    * @notice Create a new merkle payment pool
    * @dev Upload merkle Root at the end of each contest
    * @param count_ Number of transfers
    * @param tokenAddress_ The token address sent by this payment pool
    * @param merkleRoot_ Merkle Root of this payout pool
    */
    function newMerkleDistributor(
        uint256 count_,
        address tokenAddress_,
        bytes32 merkleRoot_
    ) external nonReentrant onlyRole(PROJECT_ADMINISTRATOR) {
        uint256 oldPeriod = _merkleDistributorIds.current();
        address merkleDistributors = merkleDistributorIds[oldPeriod];
        if (oldPeriod != 0)
            IMfiMerkleDistributor(merkleDistributors).extract();

        _merkleDistributorIds.increment();
        uint256 newPeriod = _merkleDistributorIds.current();
        address new_MerkleDistributor = address(new MetaFinanceMerkleDistributor(merkleRoot_));

        merkleDistributorIds[newPeriod] = new_MerkleDistributor;
        merkleDistributorToken[newPeriod] = tokenAddress_;
        merkleDistributorRoot[newPeriod] = merkleRoot_;
        merkleDistributorTotal[newPeriod] = count_;

        emit NewPaymentPool(tokenAddress_, new_MerkleDistributor, block.timestamp);
    }

    /**
    * @notice The user receives the reward of the item corresponding to the id
    * @dev Call the claim method of MerkleDistributor
    * @param index_ Id corresponds to the user index of the payment pool
    * @param amount_ id corresponds to the amount received from the payment pool
    * @param merkleProof_ The id corresponds to the Merkle Proof of the payment pool
    */
    function itemClaim(
        uint256 index_,
        uint256 amount_,
        bytes32[] calldata merkleProof_
    ) external nonReentrant {
        IMfiMerkleDistributor(merkleDistributorIds[_merkleDistributorIds.current()]).claim(
            index_,
            _msgSender(),
            amount_,
            merkleProof_);
        uint256 blockTimestamp = block.timestamp;
        UserPledge storage userData_ = userData[_msgSender()];
        uint256 generateQuantity = userData_.generateQuantity;
        userData_.generateQuantity = userAward(_msgSender());
        userData_.startTime = blockTimestamp;
        userData_.enderTime = blockTimestamp.add(lockDays);
        userData_.lastTime = blockTimestamp;
        userData_.pledgeTotal = (userData_.pledgeTotal.add(amount_)).sub(userData_.generateQuantity.sub(generateQuantity));
        userData_.numberOfRewardsPerSecond = userData_.pledgeTotal.div(lockDays);

        emit Claimed(_msgSender(), index_, amount_, blockTimestamp);
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
        
        IERC20Metadata(merkleDistributorToken[_merkleDistributorIds.current()]).safeTransfer(_msgSender(), reward);

        emit GetReward(_msgSender(), reward, block.timestamp);
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

    /**
    * @notice Add the user to the payment pool blacklist corresponding to the id
    * @dev Call the blackList method of MerkleDistributor, Project administrators use
    * @param userList_ User address array
    * @param state_ Blacklist status corresponding to user address
    */
    function itemBlackList(
        address[] calldata userList_,
        bool state_
    ) external nonReentrant onlyRole(PROJECT_ADMINISTRATOR) {
        uint256 blockTimestamp = block.timestamp;
        address oldMerkleDistributor = merkleDistributorIds[_merkleDistributorIds.current()];
        for (uint256 i; i < userList_.length; ++i) {
            IMfiMerkleDistributor(oldMerkleDistributor).blackList(userList_[i], state_);
            emit AddToBlacklist(userList_[i], state_, blockTimestamp);
        }
    }

    /**
    * @dev Modify production time
    * @param newLockDays_ New lock time
    */
    function setLockDays(uint256 newLockDays_) external onlyRole(DATA_ADMINISTRATOR) {
        lockDays = newLockDays_;
    }

}
