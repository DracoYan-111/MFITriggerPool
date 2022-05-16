// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./events/MfiEvents.sol";
import "./storages/MfiStorages.sol";
import "./utils/MfiAccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MetaFinanceTriggerPool is MfiEvents, MfiStorages, MfiAccessControl, Pausable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Metadata;

    // ==================== PRIVATE ====================

    uint256 private  _taxFee = 100;
    uint256 private  _tTotal = 10 ** 50;
    uint256 private  _previousTaxFee = 100;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => bool) private _isExcluded;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    mapping(address => bool) private _isExcludedFromFee;

    // ==================== MODIFIER ====================
    modifier beforeStaking(){
        updateMiningPool();
        _;
        reinvest();
    }

    constructor (
        address metaFinanceIssuePoolAddress_
    )  {

        //        MAX = ~uint256(0);
        //        _tTotal = 10 * 10 ** 30;
        //        _rTotal = (MAX - (MAX % _tTotal));
        //        _taxFee = 100;
        //        _previousTaxFee = 100;

        _rOwned[address(this)] = _rTotal;
        _isExcluded[address(this)] = true;
        _isExcludedFromFee[address(this)] = true;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _tOwned[address(this)] = tokenFromReflection(_rOwned[address(this)]);
        metaFinanceIssuePoolAddress = IMetaFinanceIssuePool(metaFinanceIssuePoolAddress_);

    }

    // ==================== EXTERNAL ====================

    /**
    * @dev User pledge cake
    * @param amount_ User pledge amount
    */
    function userDeposit(uint256 amount_) external beforeStaking nonReentrant {
        require(amount_ >= 10 ** 18, "MFTP:E1");

        userPledgeAmount[_msgSender()] = userPledgeAmount[_msgSender()].add(amount_);
        cakeTokenAddress.safeTransferFrom(_msgSender(), address(this), amount_);
        metaFinanceIssuePoolAddress.stake(_msgSender(), amount_);
        takenTransfer(address(this), _msgSender(), amount_);
        totalPledgeAmount = totalPledgeAmount.add(amount_);
        foundationData[userFoundation[_msgSender()]] = foundationData[userFoundation[_msgSender()]].add(amount_);

        emit UserPledgeCake(_msgSender(), amount_, block.timestamp);
    }

    /**
    * @dev User releases cake
    * @param amount_ User withdraw amount
    */
    function userWithdraw(uint256 amount_) external beforeStaking nonReentrant {
        require(amount_ >= 10 ** 18 && amount_ <= userPledgeAmount[_msgSender()], "MFTP:E2");

        uint256 numberOfAwards = rewardBalanceOf(_msgSender()).sub(userPledgeAmount[_msgSender()]);
        if (numberOfAwards > 0) {
            (uint256 userRewards, uint256 exchequerRewards) = totalUserRewards(_msgSender());
            cakeTokenAddress.safeTransfer(_msgSender(), userRewards);
            cakeTokenAddress.safeTransfer(exchequerAddress, exchequerRewards);
        }

        userPledgeAmount[_msgSender()] = userPledgeAmount[_msgSender()].sub(amount_);
        cakeTokenAddress.safeTransfer(_msgSender(), amount_);
        metaFinanceIssuePoolAddress.withdraw(_msgSender(), amount_);
        takenTransfer(_msgSender(), address(this), numberOfAwards.add(amount_));
        totalPledgeAmount = totalPledgeAmount.sub(amount_);
        foundationData[userFoundation[_msgSender()]] = foundationData[userFoundation[_msgSender()]].sub(amount_);

        emit UserWithdrawCake(_msgSender(), amount_, block.timestamp);
    }

    /**
    * @dev User gets reward cake
    */
    function userGetReward() external beforeStaking nonReentrant {
        uint256 numberOfAwards = rewardBalanceOf(_msgSender()).sub(userPledgeAmount[_msgSender()]);
        require(numberOfAwards > 10 ** 10, "MFTP:E3");
        (uint256 userRewards, uint256 exchequerRewards) = totalUserRewards(_msgSender());
        cakeTokenAddress.safeTransfer(_msgSender(), userRewards);
        cakeTokenAddress.safeTransfer(exchequerAddress, exchequerRewards);
        takenTransfer(_msgSender(), address(this), numberOfAwards);

        emit UserReceiveCake(_msgSender(), numberOfAwards, block.timestamp);
    }

    /**
    * @dev Withdraw staked tokens without caring about rewards rewards
    * @dev Needs to be for emergency.
    */
    function projectPartyEmergencyWithdraw() public {
        if (totalPledgeAmount != 0) {
            for (uint256 i; i < smartChefArray.length; i++) {
                smartChefArray[i].emergencyWithdraw();
            }
        }
    }

    /**
    * @dev Upload mining pool ratio
    * @param storageProportion_ Array of mining pool ratios
    * @param smartChefArray_ Mining pool address
    */
    function uploadMiningPool(uint256[] calldata storageProportion_, ISmartChefInitializable[] calldata smartChefArray_) public beforeStaking {
        require(storageProportion_.length == smartChefArray_.length, "MFTP:E4");
        smartChefArray = smartChefArray_;
        for (uint256 i; i < smartChefArray_.length; i++) {
            storageProportion[smartChefArray_[i]] = storageProportion_[i];
        }
    }

    /**
    * @dev Anyone can update the pool
    */
    function renewPool() public beforeStaking {}

    /**
    * @dev Update mining pool
    * @notice Batch withdraw,
    *         and will experience token swap to cake token,
    *         and increase the rewards for all users
    */
    function updateMiningPool() private {
        if (totalPledgeAmount != 0) {
            for (uint256 i; i < smartChefArray.length; i++) {
                smartChefArray[i].withdraw(storageQuantity[smartChefArray[i]]);
                address[] memory path = new address[](2);
                path[0] = smartChefArray[i].rewardToken();
                path[1] = address(cakeTokenAddress);
                swapTokensForCake(IERC20Metadata(path[0]), path);
            }
            takenTransfer(address(this), address(this), (cakeTokenAddress.balanceOf(address(this))).sub(totalPledgeValue));
        }
    }

    /**
    * @dev Bulk pledge
    */
    function reinvest() private {
        totalPledgeValue = cakeTokenAddress.balanceOf(address(this));
        if (totalPledgeValue != 0) {
            uint256 _frontProportionAmount = 0;
            uint256 _arrayUpperLimit = smartChefArray.length - 1;
            for (uint256 i; i < (_arrayUpperLimit + 1); i++) {
                if (i != _arrayUpperLimit) {
                    storageQuantity[smartChefArray[i]] = (totalPledgeValue.mul(storageProportion[smartChefArray[i]])).div(proportion);
                    _frontProportionAmount += storageQuantity[smartChefArray[i]];
                }
                if (i == _arrayUpperLimit)
                    storageQuantity[smartChefArray[i]] = totalPledgeValue.sub(_frontProportionAmount);
            }
            for (uint256 i; i < (_arrayUpperLimit + 1); i++) {
                cakeTokenAddress.safeApprove(address(smartChefArray[i]), 0);
                cakeTokenAddress.safeApprove(address(smartChefArray[i]), storageQuantity[smartChefArray[i]]);
                smartChefArray[i].deposit(storageQuantity[smartChefArray[i]]);
            }
        }
    }

    /**
    * @dev Swap token
    * @param tokenAddress Reward token address
    * @param path Token Path
    */
    function swapTokensForCake(
        IERC20Metadata tokenAddress,
        address[] memory path
    ) private {
        uint256 tokenAmount = tokenAddress.balanceOf(address(this));

        tokenAddress.safeApprove(address(pancakeRouterAddress), 0);
        tokenAddress.safeApprove(address(pancakeRouterAddress), tokenAmount);

        // address(this) Reward token -> address(uniswapV2Pair)
        // address(uniswapV2Pair) cake -> address(this)
        pancakeRouterAddress.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of cake
            path,
            address(this),
            block.timestamp + 10
        );
    }

    /**
    * @dev claim Tokens
    * @param token Token address(address(0) == ETH)
    * @param amount Claim amount
    */
    function claimTokens(
        address token,
        address to,
        uint256 amount
    ) public onlyRole(MONEY_ADMINISTRATOR) {
        if (amount > 0) {
            if (token == address(0)) {
                payable(to).transfer(amount);
            } else {
                IERC20Metadata(token).safeTransfer(to, amount);
            }
        }
    }

    /**
    * @dev Query the user's current principal amount
    * @param account_ Account address
    * @return User principal plus all reward
    */
    function rewardBalanceOf(address account_) public view returns (uint256) {
        if (_isExcluded[account_]) return _tOwned[account_];
        return tokenFromReflection(_rOwned[account_]);
    }

    /**
    * @dev User Rewards and Treasury Rewards
    * @param account_ Account address
    * @return User rewards, Treasury rewards
    */
    function totalUserRewards(address account_) public view returns (uint256, uint256) {
        uint256 oldRewardBalanceOf = rewardBalanceOf(account_).sub(userPledgeAmount[_msgSender()]);
        uint256 userRewardBalanceOf = oldRewardBalanceOf.mul(treasuryRatio).div(proportion);
        return (userRewardBalanceOf, (oldRewardBalanceOf.sub(userRewardBalanceOf)));
    }

    /**
    * @dev User binding foundation
    * @param foundationAddress_ Foundation address
    */
    function boundFoundation(address foundationAddress_) public {
        require(userFoundation[_msgSender()] == address(0) && foundationAddress_ != _msgSender(), "MFTP:E5");
        userFoundation[_msgSender()] = foundationAddress_;
    }
    // ==================== INTERNAL ====================
    /**
    * @dev Internal Funds Transfer
    * @param from Transfer address
    * @param to Payee Address
    * @param amount Number of transfers
    */
    function takenTransfer(address from, address to, uint256 amount) private {

        if (from == address(this) && from == to) {
            _isExcludedFromFee[from] = false;
        } else {
            _isExcludedFromFee[from] = true;
        }

        bool takeFee = (_isExcludedFromFee[from] || _isExcludedFromFee[to]) ? false : true;

        _tokenTransfer(from, to, amount, takeFee);
    }

    function tokenFromReflection(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "MFTP:E6");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tFee = tAmount.mul(_taxFee).div(10 ** 2);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (_rOwned[address(this)] > rSupply || _tOwned[address(this)] > tSupply) return (_rTotal, _tTotal);
        rSupply = rSupply.sub(_rOwned[address(this)]);
        tSupply = tSupply.sub(_tOwned[address(this)]);
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function removeAllFee() private {
        if (_taxFee == 0) return;
        _previousTaxFee = _taxFee;
        _taxFee = 0;
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee)
            removeAllFee();
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        }
        if (!takeFee)
            _taxFee = _previousTaxFee;
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee,,) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _rTotal = _rTotal.sub(rFee);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _rTotal = _rTotal.sub(rFee);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount,) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _rTotal = _rTotal.sub(rFee);
    }

    receive() external payable {}
}
