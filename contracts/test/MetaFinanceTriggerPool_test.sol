// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "../events/MfiTriggerEvents.sol";
import "../storages/MfiTriggerStorages.sol";
import "../utils/MfiAccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MetaFinanceTriggerPool is MfiEvents, MfiStorages, MfiAccessControl, Pausable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Metadata;

    // ==================== PRIVATE ====================
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    uint256 private  _tTotal = 1 * 10 ** 50;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private  _taxFee = 100;
    uint256 private  _previousTaxFee = 100;



    constructor ()  {

        //        MAX = ~uint256(0);
        //        _tTotal = 10 * 10 ** 30;
        //        _rTotal = (MAX - (MAX % _tTotal));
        //        _taxFee = 100;
        //        _previousTaxFee = 100;

        _rOwned[address(this)] = _rTotal;
        _isExcludedFromFee[address(this)] = true;
        _isExcluded[address(this)] = true;

        _tOwned[address(this)] = tokenFromReflection(_rOwned[address(this)]);
    }

    /**
    * @dev 用户质押cake
    * @param amount_ 用户质押数量
    */
    function userDeposit(uint256 amount_) external nonReentrant {
        require(amount_ > 10000, "MFTP:E1");

        updateMiningPool(smartChefArray);

        cakeTokenAddress.safeTransferFrom(_msgSender(), address(this), amount_);
        takenTransfer(address(this), _msgSender(), amount_);
        userPledgeAmount[_msgSender()] += amount_;
        totalPledgeAmount = cakeTokenAddress.balanceOf(address(this));

        reinvest();

        emit UserPledgeCake(_msgSender(), amount_, block.timestamp);
    }

    /**
    * @dev 计算质押金额
    *
    *
    */
    function calculateThePledgeAmount(uint256 amount_) private {
        for (uint256 i; i < smartChefArray.length; i++) {
            storageQuantity[smartChefArray[i]] = (amount_.mul(storageProportion[smartChefArray[i]])).div(proportion);
        }
    }

    /**
    * @dev 上传矿池比例
    *
    *
    */
    function uploadMiningPool(uint256[] calldata storageProportion_, ISmartChefInitializable[] calldata smartChefArray_) public {
        require(storageProportion_.length == smartChefArray_.length, "MFTP:E2");
        smartChefArray = smartChefArray_;
        for (uint256 i; i < smartChefArray_.length; i++) {
            storageProportion[smartChefArray_[i]] = storageProportion_[i];
        }
    }

    modifier BeforeStaking(ISmartChefInitializable[] memory smartChefArray_){
        updateMiningPool(smartChefArray_);
        _;
        reinvest();
    }


    /**
    * @dev 更新矿池
    *
    *
    */
    function updateMiningPool(ISmartChefInitializable[] memory smartChefArray_) public {
        //if (totalPledgeAmount != 0) {
            for (uint256 i; i < smartChefArray_.length; i++) {
                address s = (smartChefArray_[i].rewardToken());
                smartChefArray_[i].withdraw(IERC20Metadata(s).balanceOf((address(smartChefArray_[i]))));
                address[] memory path = new address[](2);
                path[0] = smartChefArray_[i].rewardToken();
                path[1] = address(cakeTokenAddress);
                swapTokensForUsdt(IERC20Metadata(path[0]), path);
            }
        //}
    }

    /**
    * @dev 复投
    *
    *
    *
    */
    function reinvest() public {
        calculateThePledgeAmount(totalPledgeAmount);
        if (totalPledgeAmount != 0) {
            for (uint256 i; i < smartChefArray.length; i++) {
                smartChefArray[i].deposit(storageQuantity[smartChefArray[i]]);
            }
        }
    }

    /**
    * @dev Swap token
    * @param tokenAddress 奖励token地址
    * @param path 代币路径
    */
    function swapTokensForUsdt(
        IERC20Metadata tokenAddress,
        address[] memory path
    ) private {
        uint256 tokenAmount = tokenAddress.balanceOf(address(this));

        if (tokenAddress.allowance(address(this), address(pancakeRouterAddress)) < tokenAmount) {
            tokenAddress.safeApprove(address(pancakeRouterAddress), 0);
            tokenAddress.safeApprove(address(pancakeRouterAddress), ~uint256(0));
        }

        //token:address(this) token -> address(uniswapV2Pair)
        //usdt:address(uniswapV2Pair) token -> address(this)
        pancakeRouterAddress.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of usdt
            path,
            address(this),
            block.timestamp + 10
        );
    }

    // ==================== INTERNAL ====================
    /**
    * @dev 内部资金转账
    * @param from 转账人地址
    * @param to 收款人地址
    * @param amount 转账数量
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

    /**
    * @dev 查询用户当前本金数量
    * @param account 账户地址
    */
    function rewardBalanceOf(address account) external view returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function tokenFromReflection(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256/*, uint256*/) {
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

    /**
    * @dev claim Tokens
    * @param token Token address(address(0) == ETH)
    * @param amount Claim amount
    */
    function claimTokens(
        address token,
        uint256 amount
    ) public  {
        if (amount > 0) {
            if (token == address(0)) {
                payable(_msgSender()).transfer(amount);
            } else {
                IERC20Metadata(token).safeTransfer(_msgSender(), amount);
            }
        }
    }

    receive() external payable {}
}
