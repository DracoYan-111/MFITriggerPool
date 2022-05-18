// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MfiClubStorages {

    uint256 public yesClub = 80;
    uint256 public noClub = 85;
    address[] public userArray;
    address[] public clubArray;
    address public treasuryAddress;
    uint256 public clubIncentive = 10;

    // User Club Information
    mapping(address => address) public userClub;
    // club data
    mapping(address => mapping(address => uint256)) public foundationData;

}
