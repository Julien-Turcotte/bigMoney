// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title MiniUniswap
 * @dev A minimal Uniswap-like DEX with constant product AMM (x * y = k)
 * Includes liquidity pools, LP tokens, and fee distribution
 */
contract MiniUniswap is ERC20, ReentrancyGuard {
    // Trading fee: 0.3% (30 basis points)
    uint256 public constant FEE_PERCENT = 3;
    uint256 public constant FEE_DENOMINATOR = 1000;

    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint256 public reserve0;
    uint256 public reserve1;

    event LiquidityAdded(
        address indexed provider,
        uint256 amount0,
        uint256 amount1,
        uint256 liquidity
    );

    event LiquidityRemoved(
        address indexed provider,
        uint256 amount0,
        uint256 amount1,
        uint256 liquidity
    );

    event Swap(
        address indexed user,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    constructor(
        address _token0,
        address _token1
    ) ERC20("MiniUniswap LP Token", "MINI-LP") {
        require(_token0 != address(0) && _token1 != address(0), "Invalid token addresses");
        require(_token0 != _token1, "Identical tokens");
        
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    /**
     * @dev Add liquidity to the pool
     * @param amount0Desired Desired amount of token0 to add
     * @param amount1Desired Desired amount of token1 to add
     * @param amount0Min Minimum amount of token0 (slippage protection)
     * @param amount1Min Minimum amount of token1 (slippage protection)
     * @return liquidity Amount of LP tokens minted
     */
    function addLiquidity(
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 amount0Min,
        uint256 amount1Min
    ) external nonReentrant returns (uint256 liquidity) {
        require(amount0Desired > 0 && amount1Desired > 0, "Invalid amounts");

        uint256 amount0;
        uint256 amount1;

        if (reserve0 == 0 && reserve1 == 0) {
            // First liquidity provider
            amount0 = amount0Desired;
            amount1 = amount1Desired;
        } else {
            // Subsequent liquidity providers must maintain ratio
            uint256 amount1Optimal = (amount0Desired * reserve1) / reserve0;
            if (amount1Optimal <= amount1Desired) {
                require(amount1Optimal >= amount1Min, "Insufficient token1 amount");
                amount0 = amount0Desired;
                amount1 = amount1Optimal;
            } else {
                uint256 amount0Optimal = (amount1Desired * reserve0) / reserve1;
                require(amount0Optimal <= amount0Desired, "Amount0 exceeded");
                require(amount0Optimal >= amount0Min, "Insufficient token0 amount");
                amount0 = amount0Optimal;
                amount1 = amount1Desired;
            }
        }

        // Transfer tokens from user
        token0.transferFrom(msg.sender, address(this), amount0);
        token1.transferFrom(msg.sender, address(this), amount1);

        // Mint LP tokens
        uint256 totalSupply = totalSupply();
        if (totalSupply == 0) {
            // First liquidity: mint sqrt(x*y) LP tokens
            liquidity = sqrt(amount0 * amount1);
            require(liquidity > 0, "Insufficient liquidity minted");
        } else {
            // Subsequent liquidity: maintain proportional LP tokens
            liquidity = min(
                (amount0 * totalSupply) / reserve0,
                (amount1 * totalSupply) / reserve1
            );
        }

        require(liquidity > 0, "Insufficient liquidity minted");
        _mint(msg.sender, liquidity);

        // Update reserves
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));

        emit LiquidityAdded(msg.sender, amount0, amount1, liquidity);
    }

    /**
     * @dev Remove liquidity from the pool
     * @param liquidity Amount of LP tokens to burn
     * @param amount0Min Minimum amount of token0 to receive
     * @param amount1Min Minimum amount of token1 to receive
     * @return amount0 Amount of token0 received
     * @return amount1 Amount of token1 received
     */
    function removeLiquidity(
        uint256 liquidity,
        uint256 amount0Min,
        uint256 amount1Min
    ) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        require(liquidity > 0, "Invalid liquidity amount");
        require(balanceOf(msg.sender) >= liquidity, "Insufficient LP balance");

        uint256 totalSupply = totalSupply();
        
        // Calculate token amounts proportional to LP tokens
        amount0 = (liquidity * reserve0) / totalSupply;
        amount1 = (liquidity * reserve1) / totalSupply;

        require(amount0 >= amount0Min, "Insufficient token0 amount");
        require(amount1 >= amount1Min, "Insufficient token1 amount");

        // Burn LP tokens
        _burn(msg.sender, liquidity);

        // Transfer tokens to user
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);

        // Update reserves
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));

        emit LiquidityRemoved(msg.sender, amount0, amount1, liquidity);
    }

    /**
     * @dev Swap tokens using constant product formula (x * y = k)
     * @param tokenIn Address of input token
     * @param amountIn Amount of input token
     * @param amountOutMin Minimum amount of output token (slippage protection)
     * @return amountOut Amount of output token received
     */
    function swap(
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin
    ) external nonReentrant returns (uint256 amountOut) {
        require(amountIn > 0, "Invalid input amount");
        require(
            tokenIn == address(token0) || tokenIn == address(token1),
            "Invalid token"
        );

        bool isToken0 = tokenIn == address(token0);
        (IERC20 inputToken, IERC20 outputToken, uint256 reserveIn, uint256 reserveOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        // Calculate output amount with fee
        amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
        require(amountOut >= amountOutMin, "Slippage too high");
        require(amountOut > 0, "Insufficient output amount");

        // Transfer input token from user
        inputToken.transferFrom(msg.sender, address(this), amountIn);

        // Transfer output token to user
        outputToken.transfer(msg.sender, amountOut);

        // Update reserves
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));

        emit Swap(
            msg.sender,
            tokenIn,
            address(outputToken),
            amountIn,
            amountOut
        );
    }

    /**
     * @dev Calculate output amount based on constant product formula
     * Includes 0.3% fee that goes to liquidity providers
     * @param amountIn Input amount
     * @param reserveIn Reserve of input token
     * @param reserveOut Reserve of output token
     * @return amountOut Output amount after fee
     */
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure returns (uint256 amountOut) {
        require(amountIn > 0, "Invalid input amount");
        require(reserveIn > 0 && reserveOut > 0, "Insufficient liquidity");

        // Apply 0.3% fee to input amount
        uint256 amountInWithFee = amountIn * (FEE_DENOMINATOR - FEE_PERCENT);
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * FEE_DENOMINATOR) + amountInWithFee;
        
        amountOut = numerator / denominator;
    }

    /**
     * @dev Get current reserves
     */
    function getReserves() external view returns (uint256, uint256) {
        return (reserve0, reserve1);
    }

    /**
     * @dev Calculate square root (Babylonian method)
     */
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /**
     * @dev Return minimum of two numbers
     */
    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x < y ? x : y;
    }
}
