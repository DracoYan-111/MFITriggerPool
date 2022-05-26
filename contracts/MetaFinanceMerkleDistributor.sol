// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./storages/MfiMerkleStorages.sol";

contract MetaFinanceMerkleDistributor is MfiMerkleStorages, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Metadata;

    //
    //    address public immutable  token;
    //    bytes32 public immutable  merkleRoot;
    //
    //    mapping(address => bool)public blackListUser;
    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    event blackListStart(uint256 blockTimestamp, address userAddress, bool state);
    // This event is triggered whenever a call to #claim succeeds.
    event Claimed(uint256 index, address account, uint256 amount);

    /*
    * @dev Create a payment pool for users to receive the corresponding amount
    * @param token_ The token address paid by this payment pool to the user
    * @param merkleRoot_ The merkle Root to check for this payment pool
    */
    constructor(
        address token_,
        bytes32 merkleRoot_){
        token = token_;
        merkleRoot = merkleRoot_;
    }

    /*
    * @notice Check whether the user corresponding to
              the index has already received it
    * @dev Use an algorithm to achieve state uniqueness for each number
    * @param index_ The state of the index in this payout pool
    * @return the state of the incoming index
    */
    function isClaimed(
        uint256 index_
    ) public view returns (bool) {
        uint256 claimedWordIndex = index_ / 256;
        uint256 claimedBitIndex = index_ % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    /*
    * @dev Modify the state corresponding to
           the user index when the user successfully receives it
    * @param index_ The state of the index in this payout pool
    */
    function _setClaimed(
        uint256 index_
    ) private {
        uint256 claimedWordIndex = index_ / 256;
        uint256 claimedBitIndex = index_ % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    /*
    * @notice Users receive their own rewards
    * @dev After successful claim, modify the state corresponding to
           the user index and trigger the Claimed event
    * @param index_ The state of the index in this payout pool
    * @param account_ The address of the user in this payment pool
    * @param amount_ The amount corresponding to the user in this payment pool
    * @param merkleProof_ Merkle Proof of users in this payment pool
    */
    function claim(
        uint256 index_,
        address account_,
        uint256 amount_,
        bytes32[] calldata merkleProof_
    ) external onlyOwner {
        require(!isClaimed(index_), "MFMD:E0");
        require(!blackListUser[account_], "MFMD:E1");
        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index_, account_, amount_));
        require(MerkleProof.verify(merkleProof_, merkleRoot, node), "MFMD:E2");

        // Mark it claimed and send the token.
        _setClaimed(index_);
        /// IERC20Metadata(token).safeTransfer(account_, amount_);
        emit Claimed(index_, account_, amount_);
    }

    /*
    * @notice Add user to blacklist
    * @dev Only the owner can use it, add the user to
           the blacklist, and trigger the black List Start event
    * @param userList_ User address array
    * @param state_ Blacklist status corresponding to user address
    */
    function blackList(
        address[] calldata userList_,
        bool state_
    ) external onlyOwner {
        for (uint256 i = 0; i < userList_.length; i++) {
            blackListUser[userList_[i]] = state_;
            emit blackListStart(block.timestamp, userList_[i], state_);
        }
    }

    /*
    * @notice The administrator withdraws the remaining tokens in this payment pool
    * @dev Only the owner can use it
    */
    function extract() external onlyOwner {
        uint256 balance = IERC20Metadata(token).balanceOf(address(this));
        IERC20Metadata(token).safeTransfer(owner(), balance);
        selfdestruct(payable(owner()));
    }
}
