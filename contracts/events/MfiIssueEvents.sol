// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract MfiIssueEvents {
    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event UserHarvest(address indexed user, uint256 reward);
}
