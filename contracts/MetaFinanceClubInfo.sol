// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./utils/MfiAccessControl.sol";
import "./storages/MfiClubStorages.sol";

contract MetaFinanceClubInfo is MfiAccessControl,MfiClubStorages {
    using SafeMath for uint256;

    /* ========== EVENT ========== */
    event UserRegistration(address userAddress, address clubAddress);

    /* ========== CONSTRUCTOR ========== */
    constructor (address treasuryAddress_)  {
        treasuryAddress = treasuryAddress_;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /* ========== EXTERNAL ========== */
    /**
    * @dev User binding club
    * @param clubAddress_ Club address
    */
    function boundClub(address clubAddress_) external {
        require(userClub[_msgSender()] == address(0) && clubAddress_ != _msgSender() && treasuryAddress != address(0), "MFCI:E1");
        userClub[_msgSender()] = clubAddress_;
        userArray.push(_msgSender());
        if (clubAddress_ != treasuryAddress)
            clubArray.push(clubAddress_);
        emit UserRegistration(_msgSender(), clubAddress_);
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

    /**
    * @dev Set proportion
    * @param newProportion_ New proportion
    */
    function setProportion(uint256 newProportion_) external onlyRole(DATA_ADMINISTRATOR) {
        if (newProportion_ == 100 || newProportion_ == 1000 || newProportion_ == 10000 || newProportion_ == 100000) {
            if (newProportion_ > proportion) {
                uint256 difference = newProportion_.div(proportion);
                proportion = newProportion_;
                yesClub = yesClub.mul(difference);
                noClub = noClub.mul(difference);
            }
            if (proportion > newProportion_) {
                uint256 difference = proportion.div(newProportion_);
                proportion = newProportion_;
                yesClub = yesClub.div(difference);
                noClub = noClub.div(difference);
            }
        }
    }

    /**
    * @dev Set the club reward ratio
    * @param newYesClub_ New yes Club
    * @param newNoClub_ New no Club
    */
    function setClubProportion(uint256 newYesClub_, uint256 newNoClub_) external onlyRole(DATA_ADMINISTRATOR) {
        if (newYesClub_ != 0) yesClub = newYesClub_;
        if (newNoClub_ != 0) noClub = newNoClub_;
    }


}
