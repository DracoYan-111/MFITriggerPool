// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract MfiEvents {
    /*
     * @dev 用户质押事件
     * @param _userAddress 用户地址
     * @param _pledgeAmount 用户质押数量
     * @param _timestamp 质押时间
     */
    event UserPledgeCake(address _userAddress, uint256 _pledgeAmount, uint256 _timestamp);

    /*
     * @dev 用户提现事件
     * @param _userAddress 用户地址
     * @param _withdrawAmount 用户提现数量
     * @param _timestamp 质押时间
     */
    event UserWithdrawCake(address _userAddress, uint256 _withdrawAmount, uint256 _timestamp);

    /*
     * @dev 用户领取事件
     * @param _userAddress 用户地址
     * @param _withdrawAmount 用户提现数量
     * @param _timestamp 质押时间
     */
    event UserReceiveCake(address _userAddress, uint256 _receiveAmount, uint256 _timestamp);

}
