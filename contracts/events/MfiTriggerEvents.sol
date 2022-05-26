// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

contract MfiTriggerEvents {
    /**
    * @dev User pledge event
    * @param _user User address
    * @param _tokenAddress Token address
    * @param _pledgeAmount User pledge amount
    * @param _blockTimestamp pledge time
    */
    event UserPledgeCake(
        address indexed _user,
        address _tokenAddress,
        uint256 _pledgeAmount,
        uint256 _blockTimestamp
    );

    /**
    * @dev User withdrawal event
    * @param _user User address
    * @param _tokenAddress Token address
    * @param _withdrawAmount User withdrawal amount
    * @param _interestTokenAddress Interest token address
    * @param _interestAmount User interest amount
    * @param _blockTimestamp pledge time
    */
    event UserWithdrawCake(
        address indexed _user,
        address _tokenAddress,
        uint256 _withdrawAmount,
        address _interestTokenAddress,
        uint256 _interestAmount,
        uint256 _blockTimestamp
    );

    /**
    * @dev User pick up event
    * @param _user User address
    * @param _tokenAddress Token address
    * @param _receiveAmount User withdrawal amount
    * @param _blockTimestamp pledge time
    */
    event UserReceiveCake(
        address indexed _user,
        address _tokenAddress,
        uint256 _receiveAmount,
        uint256 _blockTimestamp
    );

}
