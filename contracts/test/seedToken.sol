// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


/// @title StorageTokenContract contract interface
interface IStorageTokenContract {
    function transferToken(IERC20 tokenAddress, address contractAddr) external returns (uint256 balance);

    function safeApproves(address _aTokenContract, address _bTokenContract) external;
}

/// @title UniswapV2Factory contract interface
interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

/// @title PancakeRouter01 contract interface
interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

/// @title PancakeRouter02 and PancakeRouter01 contract interface
interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

/// @title WerewolfKill token contract
/// @author Long
/// @notice This contract is the WerewolfKill token contract
contract seedToken is IERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event SwapAndLiquify(uint256 tokensSwapped, uint256 usdtReceived, uint256 tokensIntoLiqudity);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public _blackList;
    bool takeFee = true;

    /// @dev buy
    // 1% foundation fee
    uint256 public _foundationFee = 10;

    /// @dev sell
    // 1% burn
    uint256 public _burnFee = 10;
    uint256 public _burnAmount;
    // 3% designated account
    uint256 public _designatedFee = 30;

    /// @dev common cost
    // 1% return flow cell
    uint256 public _reflowFee = 10;

    //denominator
    uint256 public _denominatorOfFee = 1000;

    // Automatically inject the upper limit of the amount of liquidity
    uint256 public tokensSellToAddToLiquidityNum;
    // Specify the cost Num
    uint256 public specifyTheCostNum;

    IPancakeRouter02 public _uniswapV2Router;
    address public uniswapV2Pair;

    /// @dev main chain
    //address public pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    //IERC20 public husdtTokenAddress = IERC20(0x55d398326f99059fF775485246999027B3197955);

    /// @dev test chain
    address public pancakeRouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IERC20 public husdtTokenAddress = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    //token -> usdt
    address[]  path = new address[](2);
    address public designatedAccount;

    //Black hole address
    address private _burnAddress = 0x000000000000000000000000000000000000dEaD;

    /// @dev external contract
    address public stc;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */

    constructor(
        uint256 total_,
        uint256 addLpMax_,
        uint256 burnAmount_,
        uint256 designatedMax_,
        address designatedAccount_
    ) {
        /// @dev Token Information
        _name = "DEES";
        _symbol = "DEES";
        designatedAccount = designatedAccount_;
        _totalSupply = total_ * 10 ** decimals();
        _burnAmount = burnAmount_ * 10 ** decimals();

        /// @dev Additional Information
        tokensSellToAddToLiquidityNum = addLpMax_ * 10 ** decimals();
        specifyTheCostNum = designatedMax_ * 10 ** decimals();

        /// @dev Swap Information
        _uniswapV2Router = IPancakeRouter02(pancakeRouterAddress);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(husdtTokenAddress));
        path[0] = address(this);
        path[1] = address(husdtTokenAddress);

        /// @dev Other Information
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;

        /// @dev External contract Information
        stc = address(new storageTokenContract());

        _balances[_msgSender()] += _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0) && to != address(0), "ERC20: transfer the zero address");
        require(amount > 10000, "Transfer amount must be greater than 10000");
        require(!_blackList[from] && !_blackList[to], "Cannot be blacklisted");
        if (_allowances[stc][address(this)] <= _denominatorOfFee)
            IStorageTokenContract(stc).safeApproves(address(this), address(husdtTokenAddress));

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amount;
    }

        /// @dev User buys and sells
        if (from == uniswapV2Pair) {
            _tokenTransferBuy(from, to, amount);
        } else if (to == uniswapV2Pair) {
            _tokenTransferSell(from, to, amount);
        } else {
            _tokenTransfer(from, to, amount);
        }
    }

    /*
    * @dev Token transfer without loss
    */
    function _tokenTransfer(
        address from,
        address to,
        uint256 amount
    ) private {

        if (to == _burnAddress) {
            if (_totalSupply.sub(amount) >= _burnAmount) {
                _totalSupply -= amount;
            } else {
                revert("cannot be destroyed!");
            }
        }

        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    /**
    * @dev buy
    */
    function _tokenTransferBuy(
        address from,
        address to,
        uint256 amount
    ) private {
        // Check if the transaction originator is Excluded From Fee
        if (!_isExcludedFromFee[to]) {

            uint256 foundationFee_ = amount.div(_denominatorOfFee).mul(_foundationFee);
            uint256 reflowFee_ = amount.div(_denominatorOfFee).mul(_reflowFee);

            // The handling fee is transferred to the designated address
            _tokenTransfer(from, designatedAccount, foundationFee_);
            // Transfer to the token contract and wait for the injection of liquidity
            _tokenTransfer(from, address(this), reflowFee_);

            // The original amount minus the amount of destruction, and the rest is transferred to the user's address
            _tokenTransfer(from, to, amount.sub(foundationFee_ + reflowFee_));

        } else {
            _tokenTransfer(from, to, amount);
        }
    }

    /**
    * @dev Sell
    */
    function _tokenTransferSell(
        address from,
        address to,
        uint256 amount
    ) private {
        // Check if the transaction originator is Excluded From Fee
        if (!_isExcludedFromFee[from]) {

            /// @dev Satisfy the upper limit injection lp
            if (_balances[address(this)] >= tokensSellToAddToLiquidityNum) swapAndLiquify(husdtTokenAddress, true);

            /// @dev Transfer the corresponding token to the specified account
            if (_balances[stc] >= specifyTheCostNum) swapAndLiquify(IERC20(address(this)), false);

            /// @dev User transfer fee
            uint256 reflowFee_ = amount.div(_denominatorOfFee).mul(_reflowFee);
            uint256 designatedFee_ = amount.div(_denominatorOfFee).mul(_designatedFee);
            uint256 newAmount = 0;
            if (_totalSupply.sub(amount) > _burnAmount) {
                newAmount = amount.div(_denominatorOfFee).mul(_burnFee);
                // Transfer to black hole address
                _tokenTransfer(from, _burnAddress, newAmount);
            }
            // Transfer to the token contract and wait for the injection of liquidity
            _tokenTransfer(from, address(this), reflowFee_);
            // Transfer to the fund management contract and wait for lp dividends
            _tokenTransfer(from, stc, designatedFee_);

            // The original amount minus the amount of destruction, and the rest is transferred to the user's address
            _tokenTransfer(from, to, amount.sub(reflowFee_ + designatedFee_ + newAmount));

        } else {
            _tokenTransfer(from, to, amount);
        }
    }


    /**
    * @dev Swap and add lp
    */
    function swapAndLiquify(IERC20 tokenAddress, bool isAddlp) private {
        if (isAddlp) {
            uint256 tokenAmount = _balances[address(this)].div(2);
            uint256 initialBalance = husdtTokenAddress.balanceOf(address(this));
            // address(this) token -> address(stc) usdt -> address(this) usdt
            uint256 half = swapTokensForUsdt(tokenAddress, tokenAmount, address(this));

            uint256 newBalance = addLiquidityUSDT(initialBalance, half);

            emit SwapAndLiquify(tokenAmount, newBalance, half);
        } else {
            uint256 oldTokenAmount = _balances[address(this)];
            //token:address(stc) -> address(to)
            IStorageTokenContract(stc).transferToken(tokenAddress, address(this));
            swapTokensForUsdt(husdtTokenAddress, oldTokenAmount, designatedAccount);
        }
    }

    /**
    * @dev Swap token
    * @param tokenAmount Exact other half quantity
    * @return Amount of tokens injected into liquidity
    */
    function swapTokensForUsdt(
        IERC20 tokenAddress,
        uint256 tokenAmount,
        address to
    ) private returns (uint256){
        uint256 tokenAmountTwo = _balances[address(this)].sub(tokenAmount);

        _approve(address(this), pancakeRouterAddress, tokenAmountTwo);

        //token:address(this) token -> address(uniswapV2Pair)
        //usdt:address(uniswapV2Pair) token -> address(to)
        _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmountTwo,
            0, // accept any amount of usdt
            path,
            address(stc),
            block.timestamp
        );

        //usdt:address(stc) -> address(to)
        IStorageTokenContract(stc).transferToken(tokenAddress, to);

        return tokenAmountTwo;
    }

    /**
    * @dev inject liquidity
    * @param initialBalance Amount of usdt before swap
    * @param half Increase the number of lp tokens
    * @return The amount of usdt in this transaction
    */
    function addLiquidityUSDT(uint256 initialBalance, uint256 half) private returns (uint256){
        uint256 usdtAmount = (husdtTokenAddress.balanceOf(address(this))).sub(initialBalance);

        uint256[] memory tokenAmount = _uniswapV2Router.getAmountsOut(half, path);

        _approve(address(this), pancakeRouterAddress, tokenAmount[0]);
        husdtTokenAddress.safeApprove(pancakeRouterAddress, tokenAmount[1]);

        //token:address(this) -> address(uniswapV2Pair)
        //usdt:address(this) -> address(uniswapV2Pair)
        _uniswapV2Router.addLiquidity(
            path[0],
            path[1],
            tokenAmount[0],
            tokenAmount[1],
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
        return usdtAmount;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
    }

    receive() external payable {}

    /* ========== RESTRICTED FUNCTIONS ========== */

    /**
    * @dev Set black
    * @param accounts Account list
    * @param state Account state
    */
    function setBlack(address[] memory accounts, bool state) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _blackList[accounts[i]] = state;
        }
    }

    /**
    * @dev Set excludedFromFee
    * @param accounts Account list
    * @param state Account state
    */
    function setExcludedFromFee(address[] memory accounts, bool state) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = state;
        }
    }

    /**
    * @dev Set the storageTokenContract contract address
    * @param newStc New storageTokenContract contract address
    */
    function setStc(address newStc) public onlyOwner {
        stc = newStc;
    }

    /**
    * @dev Set liquidity pool address
    * @param router New router
    */
    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }

    /**
    * @dev Set up a new dividendFee
    * @param newFoundationFee New foundation fee
    * @param newBurnFee New burn fee
    * @param newDesignatedFee New designated fee
    * @param newReflowFee New reflow fee
    */
    function setAllFee(
        uint256 newFoundationFee,
        uint256 newBurnFee,
        uint256 newDesignatedFee,
        uint256 newReflowFee
    ) public onlyOwner {
        if (newFoundationFee != 0) _foundationFee = newFoundationFee;

        if (newBurnFee != 0) _burnFee = newBurnFee;

        if (newDesignatedFee != 0) _designatedFee = newDesignatedFee;

        if (newReflowFee != 0) _reflowFee = newReflowFee;
    }

    /**
    * @dev Set TokensSellToAddToLiquidityNum
     * @param newANum new tokensSellToAddToLiquidityNum(decimal!!)
     * @param newBNum new lpDividendsStartToRewardNum(decimal!!)
     */
    function setTokensSellToAddToLiquidityNum(uint256 newANum, uint256 newBNum) public onlyOwner {
        if (newANum != 0) tokensSellToAddToLiquidityNum = newANum * 10 ** decimals();

        if (newBNum != 0) specifyTheCostNum = newBNum * 10 ** decimals();
    }

    /**
    * @dev claim Tokens
    * @param token Token address(address(0) == ETH)
    * @param amount Claim amount
    */
    function claimTokens(
        address token,
        uint256 amount
    ) public onlyOwner {
        if (amount > 0) {
            if (token == address(0)) {
                payable(owner()).transfer(amount);
            } else {
                IERC20(token).safeTransfer(owner(), amount);
            }
        }
    }

    /**
    * @dev Start transaction destruction
    */
    function burnTokens() public onlyOwner {
        takeFee = true;
    }

    /* ========== USER ADD LP ========== */

    /**
    * @dev Get the added liquidity ratio
    * @param tokenOrUsdt Token selection
    *        -true:Enter the number of tokens to get the number of usdt
    *        -false:Enter the number of usdt to get the number of tokens
    * @param tokenAmount Token amount
    */
    function getAmountInOrOut(bool tokenOrUsdt, uint256 tokenAmount) public view returns (uint256 rAmount){

        if (tokenOrUsdt) {
            rAmount = _uniswapV2Router.getAmountsOut(tokenAmount, path)[1];
        } else {
            rAmount = _uniswapV2Router.getAmountsIn(tokenAmount, path)[0];
        }
    }

    /**
    * @dev user inject liquidity(approve usdt in advance)
    * @param tokenAmount The number of tokens to be exchanged
    * @param usdtAmount Amount of usdt to be exchanged
    */
    function userAddLiquidityUSDT(uint256 tokenAmount, uint256 usdtAmount) public nonReentrant {
        require(tokenAmount > 1000 || usdtAmount > 1000, "too few");

        _approve(_msgSender(), address(this), tokenAmount);
        _transfer(_msgSender(), address(this), tokenAmount);
        husdtTokenAddress.safeTransferFrom(_msgSender(), address(this), usdtAmount);

        _approve(address(this), pancakeRouterAddress, tokenAmount);
        husdtTokenAddress.safeApprove(pancakeRouterAddress, usdtAmount);

        _uniswapV2Router.addLiquidity(
            path[0],
            path[1],
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            _msgSender(),
            block.timestamp
        );

    }
}

/// @title Usdt distribution contract
/// @author Long
/// @notice This contract is only used for Usdt transfer
contract storageTokenContract is Ownable {
    using SafeERC20 for IERC20;

    function safeApproves(address _aTokenContract, address _bTokenContract) external {
        IERC20(_aTokenContract).safeApprove(owner(), ~uint256(0));
        IERC20(_bTokenContract).safeApprove(owner(), ~uint256(0));
    }

    /**
    * @dev Transfer all tokens to contractAddr address
    * @param tokenAddress Token address
    * @param contractAddr Payee address
    */
    function transferToken(IERC20 tokenAddress, address contractAddr) external onlyOwner returns (uint256 balance) {
        balance = tokenAddress.balanceOf(address(this));
        tokenAddress.safeTransfer(contractAddr, balance);
    }
}