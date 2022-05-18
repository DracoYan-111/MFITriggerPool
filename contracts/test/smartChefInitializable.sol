// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../storages/MfiTriggerStorages.sol";


contract smartChefInitializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Metadata;

    address tokenAddress;
    constructor(address tokenAddress_){
        tokenAddress = tokenAddress_;
    }

    function rewardToken() external view returns (address){
        return tokenAddress;
    }

    function withdraw(uint256 _amount) external {
        IERC20Metadata(tokenAddress).safeTransfer(msg.sender, _amount);
    }

    function withdraws(uint256 _amount,address to) external {
        IERC20Metadata(tokenAddress).safeTransfer(to, _amount);
    }
}
