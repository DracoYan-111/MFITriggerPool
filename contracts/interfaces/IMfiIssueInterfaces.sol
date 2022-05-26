// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/**
 * @title MetaFinanceClubInfo contract interface
 */
interface IMetaFinanceClubInfo {
    /**
    * @notice Query user club address
    * @param userAddress_ User address
    * @return Return to user club address
    */
    function userClub(address userAddress_) external view returns (address);

    /**
    * @notice Query treasury address
    * @return Return to Treasury Address
    */
    function treasuryAddress() external view returns (address);

    /**
    * @notice Inquiry Club Accuracy
    * @return Returns the precision in the club contract
    */
    function proportion() external view returns (uint256);

    /**
    * @notice Query the proportion of users in the club
    * @return return scale
    */
    function yesClub() external view returns (uint256);

    /**
    * @notice Query the percentage of users who are not in the club
    * @return return scale
    */
    function noClub() external view returns (uint256);

}
