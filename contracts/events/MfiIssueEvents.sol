// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract MfiIssueEvents {
    /**
    * @dev Reward update event
    * @param _reward Reward amount
    */
    event RewardAdded(uint256 _reward);

    /**
    * @dev User staked event
    * @param _user User address
    * @param _amount User staked amount
    */
    event Staked(address indexed _user, uint256 _amount);

    /**
    * @dev User withdrawn event
    * @param _user User address
    * @param _amount User withdrawn amount
    */
    event Withdrawn(address indexed _user, uint256 _amount);

    /**
    * @dev User harvest event
    * @param _user User address
    * @param _reward User harvest amount
    */
    event UserHarvest(address indexed _user, uint256 _reward);

    /**
    * @dev User receive reward event
    * @param _user User address
    * @param _reward User receive amount
    */
    event RewardPaid(address indexed _user, uint256 _reward);

}
