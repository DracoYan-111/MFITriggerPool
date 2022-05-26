// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./utils/MfiAccessControl.sol";
import "./MetaFinanceMerkleDistributor.sol";
import "./storages/MfiMerkleFactoryStorages.sol";
import "./interfaces/IMfiMerkleFactoryInterfaces.sol";

contract MetaFinanceMerkleDistributorFactory is MfiAccessControl, MfiMerkleFactoryStorages, ReentrancyGuardUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeMath for uint256;
    using SafeERC20 for IERC20Metadata;

    CountersUpgradeable.Counter private _merkleDistributorIds;

    /*
     * New payment pool event
     * blockTimestamp,tokenAddress,newMerkleDistributor
     */
    event newPaymentPool(uint256 blockTimestamp, address tokenAddress, address newMerkleDistributor);

    // This event is triggered whenever a call to #claim succeeds.
    event Claimed(uint256 index, address account, uint256 amount);

    /*
    * @notice Initialization method
    * @dev Initialization method, can only be used once,
    *      And set project default administrator
    */
    function initialize(
    ) public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function getInitializeAbi() public pure returns (bytes memory){
        return abi.encodeWithSelector(this.initialize.selector);
    }

    /*
    * @notice Create a new merkle payment pool
    * @dev Upload merkle Root at the end of each contest
    * @param count Number of transfers
    * @param tokenAddress_ The token address sent by this payment pool
    * @param merkleRoot_ Merkle Root of this payout pool
    */
    function newMerkleDistributor(
        uint256 count,
        address tokenAddress,
        bytes32 merkleRoot
    ) external onlyRole(PROJECT_ADMINISTRATOR) {
        uint256 oldPeriod = _merkleDistributorIds.current();
        address merkleDistributors = merkleDistributorIds[oldPeriod];
        if (oldPeriod != 0) {
            merkleDistributorReturn[oldPeriod] = IERC20Metadata(IMfiMerkleDistributor(merkleDistributors).token()).balanceOf(merkleDistributors);
            IMfiMerkleDistributor(merkleDistributors).extract();
        }

        _merkleDistributorIds.increment();
        uint256 newPeriod = _merkleDistributorIds.current();
        address new_MerkleDistributor = address(new MetaFinanceMerkleDistributor(tokenAddress, merkleRoot));

        merkleDistributorIds[newPeriod] = new_MerkleDistributor;
        merkleDistributorRoot[newPeriod] = merkleRoot;
        merkleDistributorTotal[newPeriod] = count;
        IERC20Metadata(tokenAddress).safeTransfer(new_MerkleDistributor, count);

        emit newPaymentPool(block.timestamp, tokenAddress, new_MerkleDistributor);
    }

    /*
    * @notice The user receives the reward of the item corresponding to the id
    * @dev Call the claim method of MerkleDistributor
    * @param index Id corresponds to the user index of the payment pool
    * @param amount id corresponds to the amount received from the payment pool
    * @param merkleProof The id corresponds to the Merkle Proof of the payment pool
    */
    function itemClaim(
        uint256 index,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        IMfiMerkleDistributor(merkleDistributorIds[_merkleDistributorIds.current()]).claim(
            index,
            _msgSender(),
            amount,
            merkleProof);
    }

    /*
    * @notice Add the user to the payment pool blacklist corresponding to the id
    * @dev Call the blackList method of MerkleDistributor, Project administrators use
    * @param id Item Number
    * @param userList User address array
    * @param state Blacklist status corresponding to user address
    */
    function itemBlackList(
        uint256 id,
        address[] calldata userList,
        bool state
    ) external onlyRole(PROJECT_ADMINISTRATOR) {
        IMfiMerkleDistributor(merkleDistributorIds[id]).blackList(userList, state);
    }
}
