// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title IPancakeProfile
 */
interface IPancakeProfile {
    function createProfile(
        uint256 _teamId,
        address _nftAddress,
        uint256 _tokenId
    ) external;

    function increaseUserPoints(
        address _userAddress,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external;

    function removeUserPoints(address _userAddress, uint256 _numberPoints) external;

    function addNftAddress(address _nftAddress) external;

    function addTeam(string calldata _teamName, string calldata _teamDescription) external;

    function getUserProfile(address _userAddress)
    external
    view
    returns (
        uint256,
        uint256,
        uint256,
        address,
        uint256,
        bool
    );

    function getUserStatus(address _userAddress) external view returns (bool);

    function getTeamProfile(uint256 _teamId)
    external
    view
    returns (
        string memory,
        string memory,
        uint256,
        uint256,
        bool
    );
}

/**
 * @title ISmartChefInitializable
 */
interface ISmartChefInitializable {
    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function deposit(uint256 _amount) external;

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function withdraw(uint256 _amount) external;

    /*
     * @notice Withdraw staked tokens without caring about rewards rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external;

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) external view returns (uint256);

    /*
     * @notice Return user limit is set or zero.
     */
    function hasUserLimit() public view returns (bool);
}

contract MetaFinanceTriggerPool is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event UserPledgeCake(address _userAddress,uint256 );


}
