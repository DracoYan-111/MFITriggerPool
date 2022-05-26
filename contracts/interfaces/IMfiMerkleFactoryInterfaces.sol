// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/**
 * @title MetaFinanceMerkleDistributor contract interface
 */
interface IMfiMerkleDistributor {

    /**
     * @notice Recover the remaining tokens of the contract to the factory contract
     */
    function extract() external;

    /**
     * @notice View the address of the reward token in the current contract
     */
    function token() external view returns (address);

    /**
     * @notice  Returns the merkle root of the merkle tree containing account balances available to claim.
     */
    function merkleRoot() external view returns (bytes32);

    /**
     * @notice Users receive their own rewards
     * @param index_ The state of the index in this payout pool
     * @param account_ The address of the user in this payment pool
     * @param amount_ The amount corresponding to the user in this payment pool
     * @param merkleProof_ Merkle Proof of users in this payment pool
     */
    function claim(uint256 index_, address account_, uint256 amount_, bytes32[] calldata merkleProof_) external;

    /**
     * @notice add user to blacklist
     * @param userList_ User address array
     * @param state_ Blacklist status
     */
    function blackList(address[] calldata userList_, bool state_) external;
}