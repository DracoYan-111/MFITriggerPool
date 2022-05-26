// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract MetaFinanceMerkleDistributor is Ownable {
    using SafeMath for uint256;

    bytes32 public merkleRoot;
    // blacklist users
    mapping(address => bool)public blackListUser;
    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    /*
    * @dev Create a payment pool for users to receive the corresponding amount
    * @param merkleRoot_ The merkle Root to check for this payment pool
    */
    constructor(
        bytes32 merkleRoot_){
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
    }

    /*
    * @notice Add user to blacklist
    * @dev Only the owner can use it, add the user to
           the blacklist, and trigger the black List Start event
    * @param userList_ User address array
    * @param state_ Blacklist status corresponding to user address
    */
    function blackList(
        address user_,
        bool state_
    ) external onlyOwner {
        blackListUser[user_] = state_;
    }

    /*
    * @notice The administrator withdraws the remaining tokens in this payment pool
    * @dev Only the owner can use it
    */
    function extract() external onlyOwner {
        selfdestruct(payable(owner()));
    }

}
