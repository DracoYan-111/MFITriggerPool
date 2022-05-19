// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./utils/MfiAccessControl.sol";
import "./storages/MfiClubStorages.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MetaFinanceClubInfo is MfiAccessControl, MfiClubStorages, Initializable {
    using SafeMath for uint256;

    /* ========== EVENT ========== */
    event UserRegistration(address userAddress, address clubAddress);

    /* ========== CONSTRUCTOR ========== */

    function initialize(address treasuryAddress_) initializer public {
        noClub = 85;
        yesClub = 80;
        proportion = 100;
        clubIncentive = 10;
        treasuryAddress = treasuryAddress_;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function getInitializeAbi(address treasuryAddress_) public pure returns (bytes memory){
        return abi.encodeWithSelector(this.initialize.selector, treasuryAddress_);
    }

    /* ========== EXTERNAL ========== */

    /**
    * @dev User binding club
    * @param userAddress_ User address
    * @param clubAddress_ Club address
    */
    function boundClub(address userAddress_, address clubAddress_) external onlyRole(META_FINANCE_TRIGGER_POOL) {
        require(userClub[userAddress_] == address(0) && clubAddress_ != userAddress_ && treasuryAddress != address(0), "MFCI:E1");
        userClub[userAddress_] = clubAddress_;
        userArray.push(userAddress_);
        if (clubAddress_ != treasuryAddress)
            clubArray.push(clubAddress_);
        emit UserRegistration(userAddress_, clubAddress_);
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
        foundationData[clubAddress_][tokenAddress_] = addOrSub_ ?
        foundationData[clubAddress_][tokenAddress_].add(amount_) :
        foundationData[clubAddress_][tokenAddress_].sub(amount_);
    }

    /**
    * @dev Set proportion
    * @param newProportion_ New proportion
    */
    function setProportion(uint256 newProportion_) external onlyRole(DATA_ADMINISTRATOR) {
        if (newProportion_ == 100 || newProportion_ == 1000 || newProportion_ == 10000 || newProportion_ == 100000) {
            if (newProportion_ > proportion) {
                uint256 difference = newProportion_.div(proportion);
                difference = difference != 0 ? difference : 1;
                proportion = proportion.mul(difference);
                yesClub = yesClub.mul(difference);
                noClub = noClub.mul(difference);
            }
            if (proportion > newProportion_) {
                uint256 difference = proportion.div(newProportion_);
                difference = difference != 0 ? difference : 1;
                proportion = proportion.div(difference);
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
