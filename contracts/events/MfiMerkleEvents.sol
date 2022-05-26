// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

contract MfiMerkleEvents {
    /**
    * @dev Create a new reward pool event
    * @param _tokenAddress Award token address
    * @param _newMerkleDistributor New merkle distributor
    * @param _blockTimestamp Operation time
    */
    event NewPaymentPool(address _tokenAddress, address _newMerkleDistributor, uint256 _blockTimestamp);

    /**
    * @dev User pick up event event
    * @param _user User address
    * @param _index Child node index
    * @param _amount Pick up quantity
    * @param _blockTimestamp Operation time
    */
    event Claimed(address indexed _user, uint256 _index, uint256 _amount, uint256 _blockTimestamp);

    /**
    * @dev Add user to blacklist event
    * @param _user User address
    * @param _condition User blacklist condition
    * @param _blockTimestamp Operation time
    */
    event AddToBlacklist(address indexed _user, bool _condition, uint256 _blockTimestamp);

    /**
    * @dev User receives wallet event
    * @param _user User address
    * @param _reward Amount to account
    * @param _blockTimestamp Operation time
    */
    event GetReward(address indexed _user, uint256 _reward, uint256 _blockTimestamp);

}
