// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/**
 * @title PancakeRouter02 contract interface
 */
interface IPancakeRouter02 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

/**
 * @title MetaFinanceClubInfo contract interface
 */
interface IMetaFinanceClubInfo {
    /**
    * @dev User binding club
    * @param userAddress_ User address
    * @param clubAddress_ Club address
    */
    function boundClub(address userAddress_, address clubAddress_) external;

    /**
    * @dev Calculate the number of club rewards
    * @param clubAddress_ Club address
    * @param tokenAddress_ Club token address
    * @param amount_ Number of operations
    * @param addOrSub_ Add or sub
    */
    function calculateReward(address clubAddress_, address tokenAddress_, uint256 amount_, bool addOrSub_) external;

    /**
    * @dev Query user club address
    * @param userAddress_ User address
    * @return Return to club address
    */
    function userClub(address userAddress_) external view returns (address);

    /**
    * @dev Get Club Rewards
    * @return Back to Club Reward Scale
    */
    function clubIncentive() external view returns (uint256);

    /**
    * @dev Query treasury address
    * @return Return to Treasury Address
    */
    function treasuryAddress() external view returns (address);
}

/**
 * @title MetaFinanceIssuePool contract interface
 */
interface IMetaFinanceIssuePool {
    /**
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param userAddress_ Pledged user address
     * @param amount_ The amount of users pledge
     */
    function stake(address userAddress_, uint256 amount_) external;

    /**
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param userAddress_ Release the user address
     * @param amount_ The number of users released
     */
    function withdraw(address userAddress_, uint256 amount_) external;
}

/**
 * @title ISmartChefInitializable contract interface
 */
interface ISmartChefInitializable {
    /**
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function deposit(uint256 _amount) external;

    /**
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function withdraw(uint256 _amount) external;

    /**
     * @notice Withdraw staked tokens without caring about rewards rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external;

    /**
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) external view returns (uint256);

    /**
     * @notice Return user limit is set or zero.
     */
    function hasUserLimit() external view returns (bool);

    /**
     * @notice Get reward tokens
     */
    function rewardToken() external view returns (address);
}



