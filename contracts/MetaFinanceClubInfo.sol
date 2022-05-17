// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./utils/MfiAccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MetaFinanceClubInfo is MfiAccessControl {
using SafeMath for uint256;

    uint256 public yesClub;
    uint256 public noClub;
    address[] public userArray;
    address[] public clubArray;
    address public treasuryAddress;
    uint256 public clubIncentive = 10;
    // User Club Information
    mapping(address => address) public userClub;
    // club data
    mapping(address => mapping(address => uint256)) public foundationData;

    constructor (
        address treasuryAddress_
    )  {
        treasuryAddress = treasuryAddress_;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    }

    event UserRegistration(address userAddress, address clubAddress);
    /**
    * @dev User binding club
    * @param clubAddress_ Club address
    */
    function boundClub(address clubAddress_) external  {
        require(userClub[_msgSender()] == address(0) && clubAddress_ != _msgSender(), "MFTP:E5");
        userClub[_msgSender()] = clubAddress_;
        userArray.push(_msgSender());
        if (clubAddress_ != treasuryAddress)
            clubArray.push(clubAddress_);
        emit UserRegistration(_msgSender(),clubAddress_);
    }

    /**
    * @dev Calculate Club Rewards
    * @param clubAddress_ Club address
    * @param tokenAddress_ Token address
    * @param amount_ Amount
    * @param addOrSub_ Add or sub
    */
    function calculateReward(
        address clubAddress_,
        address tokenAddress_,
        uint256 amount_,
        bool addOrSub_) external onlyRole(META_FINANCE_TRIGGER_POOL) {
        if (addOrSub_) {
            foundationData[clubAddress_][tokenAddress_] = foundationData[clubAddress_][tokenAddress_].add(amount_);
        } else {
            foundationData[clubAddress_][tokenAddress_] = foundationData[clubAddress_][tokenAddress_].sub(amount_);
        }
    }
}
