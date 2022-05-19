// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MfiClubStorages {

    uint256 public yesClub;
    uint256 public noClub;
    address[] public userArray;
    address[] public clubArray;
    address public treasuryAddress;
    uint256 public clubIncentive;

    // User Club Information
    mapping(address => address) public userClub;
    // club data
    mapping(address => mapping(address => uint256)) public foundationData;

}
