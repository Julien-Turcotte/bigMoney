# API Reference

Complete reference for MiniUniswap smart contract functions.

## MiniUniswap Contract

### State Variables

#### token0
```solidity
IERC20 public immutable token0;
```
The first token in the pair (immutable).

#### token1
```solidity
IERC20 public immutable token1;
```
The second token in the pair (immutable).

#### reserve0
```solidity
uint256 public reserve0;
```
Current reserve of token0 in the pool.

#### reserve1
```solidity
uint256 public reserve1;
```
Current reserve of token1 in the pool.

#### FEE_PERCENT
```solidity
uint256 public constant FEE_PERCENT = 3;
```
Trading fee numerator (0.3% = 3/1000).

#### FEE_DENOMINATOR
```solidity
uint256 public constant FEE_DENOMINATOR = 1000;
```
Trading fee denominator (0.3% = 3/1000).

---

### Public Functions

#### addLiquidity
```solidity
function addLiquidity(
    uint256 amount0Desired,
    uint256 amount1Desired,
    uint256 amount0Min,
    uint256 amount1Min
) external nonReentrant returns (uint256 liquidity)
```

Adds liquidity to the pool and mints LP tokens.

**Parameters:**
- `amount0Desired`: Desired amount of token0 to add
- `amount1Desired`: Desired amount of token1 to add
- `amount0Min`: Minimum amount of token0 (slippage protection)
- `amount1Min`: Minimum amount of token1 (slippage protection)

**Returns:**
- `liquidity`: Amount of LP tokens minted

**Requirements:**
- Amounts must be greater than 0
- Caller must have sufficient token balances
- Caller must have approved this contract to spend tokens
- If pool has existing liquidity, amounts must respect the current ratio

**Effects:**
- Transfers tokens from caller to contract
- Mints LP tokens to caller
- Updates reserves

**Events:**
```solidity
emit LiquidityAdded(msg.sender, amount0, amount1, liquidity);
```

**Example:**
```javascript
// Add 100 Token A and 100 Token B (first time)
const tx = await dexContract.addLiquidity(
  ethers.parseEther("100"),  // amount0Desired
  ethers.parseEther("100"),  // amount1Desired  
  ethers.parseEther("99"),   // amount0Min (1% slippage)
  ethers.parseEther("99")    // amount1Min (1% slippage)
);
await tx.wait();
```

---

#### removeLiquidity
```solidity
function removeLiquidity(
    uint256 liquidity,
    uint256 amount0Min,
    uint256 amount1Min
) external nonReentrant returns (uint256 amount0, uint256 amount1)
```

Removes liquidity from the pool and burns LP tokens.

**Parameters:**
- `liquidity`: Amount of LP tokens to burn
- `amount0Min`: Minimum amount of token0 to receive (slippage protection)
- `amount1Min`: Minimum amount of token1 to receive (slippage protection)

**Returns:**
- `amount0`: Amount of token0 received
- `amount1`: Amount of token1 received

**Requirements:**
- Liquidity amount must be greater than 0
- Caller must have sufficient LP token balance
- Output amounts must meet minimum requirements

**Effects:**
- Burns LP tokens from caller
- Transfers tokens to caller
- Updates reserves

**Events:**
```solidity
emit LiquidityRemoved(msg.sender, amount0, amount1, liquidity);
```

**Example:**
```javascript
// Remove 50 LP tokens
const tx = await dexContract.removeLiquidity(
  ethers.parseEther("50"),   // liquidity
  ethers.parseEther("49"),   // amount0Min (2% slippage)
  ethers.parseEther("49")    // amount1Min (2% slippage)
);
await tx.wait();
```

---

#### swap
```solidity
function swap(
    address tokenIn,
    uint256 amountIn,
    uint256 amountOutMin
) external nonReentrant returns (uint256 amountOut)
```

Swaps tokens using the constant product AMM formula.

**Parameters:**
- `tokenIn`: Address of the input token (must be token0 or token1)
- `amountIn`: Amount of input token
- `amountOutMin`: Minimum amount of output token (slippage protection)

**Returns:**
- `amountOut`: Amount of output token received

**Requirements:**
- Amount must be greater than 0
- Token address must be valid (token0 or token1)
- Caller must have sufficient input token balance
- Caller must have approved this contract to spend input token
- Output amount must meet minimum requirement

**Effects:**
- Transfers input token from caller to contract
- Transfers output token from contract to caller
- Updates reserves
- 0.3% fee automatically applied and kept in reserves

**Events:**
```solidity
emit Swap(msg.sender, tokenIn, outputToken, amountIn, amountOut);
```

**Example:**
```javascript
// Swap 10 Token A for Token B
const tx = await dexContract.swap(
  tokenAAddress,              // tokenIn
  ethers.parseEther("10"),    // amountIn
  ethers.parseEther("9.5")    // amountOutMin (5% slippage)
);
await tx.wait();
```

---

#### getAmountOut
```solidity
function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
) public pure returns (uint256 amountOut)
```

Calculates output amount for a given input, including 0.3% fee.

**Parameters:**
- `amountIn`: Input token amount
- `reserveIn`: Reserve of input token
- `reserveOut`: Reserve of output token

**Returns:**
- `amountOut`: Calculated output amount (after fee)

**Requirements:**
- Amount must be greater than 0
- Both reserves must be greater than 0

**Formula:**
```
amountInWithFee = amountIn * 997
numerator = amountInWithFee * reserveOut
denominator = (reserveIn * 1000) + amountInWithFee
amountOut = numerator / denominator
```

**Example:**
```javascript
// Calculate output for swapping 10 tokens
const reserves = await dexContract.getReserves();
const amountOut = await dexContract.getAmountOut(
  ethers.parseEther("10"),  // amountIn
  reserves[0],              // reserveIn
  reserves[1]               // reserveOut
);
console.log("Will receive:", ethers.formatEther(amountOut));
```

---

#### getReserves
```solidity
function getReserves() external view returns (uint256, uint256)
```

Returns current reserves of both tokens.

**Returns:**
- First value: reserve0 (token0 balance)
- Second value: reserve1 (token1 balance)

**Example:**
```javascript
const [reserve0, reserve1] = await dexContract.getReserves();
console.log("Token A reserve:", ethers.formatEther(reserve0));
console.log("Token B reserve:", ethers.formatEther(reserve1));
```

---

### Inherited ERC20 Functions

MiniUniswap inherits from OpenZeppelin's ERC20 implementation, providing standard LP token functionality:

#### balanceOf
```solidity
function balanceOf(address account) public view returns (uint256)
```
Returns LP token balance of an account.

#### totalSupply
```solidity
function totalSupply() public view returns (uint256)
```
Returns total supply of LP tokens.

#### transfer
```solidity
function transfer(address to, uint256 amount) public returns (bool)
```
Transfers LP tokens to another address.

#### approve
```solidity
function approve(address spender, uint256 amount) public returns (bool)
```
Approves an address to spend LP tokens.

#### allowance
```solidity
function allowance(address owner, address spender) public view returns (uint256)
```
Returns the amount of LP tokens approved for spending.

---

### Events

#### LiquidityAdded
```solidity
event LiquidityAdded(
    address indexed provider,
    uint256 amount0,
    uint256 amount1,
    uint256 liquidity
);
```
Emitted when liquidity is added to the pool.

#### LiquidityRemoved
```solidity
event LiquidityRemoved(
    address indexed provider,
    uint256 amount0,
    uint256 amount1,
    uint256 liquidity
);
```
Emitted when liquidity is removed from the pool.

#### Swap
```solidity
event Swap(
    address indexed user,
    address tokenIn,
    address tokenOut,
    uint256 amountIn,
    uint256 amountOut
);
```
Emitted when tokens are swapped.

---

## TestToken Contract

### Functions

#### constructor
```solidity
constructor(
    string memory name,
    string memory symbol,
    uint256 initialSupply
)
```
Creates a new test token with initial supply minted to deployer.

#### mint
```solidity
function mint(address to, uint256 amount) public
```
Mints new tokens to specified address (public for testing).

**Example:**
```javascript
// Mint 1000 tokens to an address
const tx = await tokenContract.mint(
  userAddress,
  ethers.parseEther("1000")
);
await tx.wait();
```

---

## Frontend Web3 Utilities

### connectWallet
```javascript
async function connectWallet(): Promise<string>
```
Connects to MetaMask and returns the connected account address.

**Returns:** Connected wallet address

**Throws:** Error if MetaMask not installed or connection rejected

---

### getDexContract
```javascript
async function getDexContract(): Promise<Contract>
```
Returns an ethers.js Contract instance for the DEX.

**Returns:** DEX contract instance with signer

---

### getTokenContract
```javascript
async function getTokenContract(tokenAddress: string): Promise<Contract>
```
Returns an ethers.js Contract instance for a token.

**Parameters:**
- `tokenAddress`: Address of the token contract

**Returns:** Token contract instance with signer

---

### parseTokenAmount
```javascript
function parseTokenAmount(amount: string, decimals: number = 18): bigint
```
Converts human-readable amount to wei.

**Parameters:**
- `amount`: Amount as string (e.g., "10.5")
- `decimals`: Token decimals (default: 18)

**Returns:** Amount in wei as BigInt

---

### formatTokenAmount
```javascript
function formatTokenAmount(amount: bigint, decimals: number = 18): string
```
Converts wei amount to human-readable string.

**Parameters:**
- `amount`: Amount in wei as BigInt
- `decimals`: Token decimals (default: 18)

**Returns:** Formatted amount as string

---

### calculateMinimumAmount
```javascript
function calculateMinimumAmount(amount: bigint, slippagePercent: number): bigint
```
Calculates minimum amount with slippage tolerance.

**Parameters:**
- `amount`: Original amount
- `slippagePercent`: Slippage percentage (e.g., 0.5 for 0.5%)

**Returns:** Minimum amount after slippage

**Example:**
```javascript
const amount = ethers.parseEther("100");
const minAmount = calculateMinimumAmount(amount, 0.5); // 99.5 ETH
```

---

## Error Messages

Common error messages and their meanings:

| Error | Meaning |
|-------|---------|
| `Invalid token addresses` | Token addresses cannot be zero or identical |
| `Invalid amounts` | Amounts must be greater than zero |
| `Insufficient token0 amount` | Output doesn't meet minimum requirement |
| `Insufficient token1 amount` | Output doesn't meet minimum requirement |
| `Invalid liquidity amount` | LP amount must be greater than zero |
| `Insufficient LP balance` | Caller doesn't have enough LP tokens |
| `Invalid token` | Token address is not token0 or token1 |
| `Slippage too high` | Output less than amountOutMin |
| `Insufficient output amount` | Calculated output is zero or negative |
| `Insufficient liquidity` | Pool reserves are zero |
| `Insufficient liquidity minted` | LP tokens to mint would be zero |

---

## Gas Usage

Approximate gas costs for operations (on Ethereum mainnet):

| Operation | Gas Cost | Notes |
|-----------|----------|-------|
| Token Approval | ~50,000 | One-time per token |
| Swap | ~100,000-150,000 | First swap costs more |
| Add Liquidity | ~150,000-200,000 | Includes LP token minting |
| Remove Liquidity | ~100,000-150,000 | Includes LP token burning |

*Note: Costs vary based on network conditions and state changes*

---

## Best Practices

### Always Check Slippage
```javascript
// Calculate expected output
const expectedOut = await dex.getAmountOut(amountIn, reserveIn, reserveOut);

// Apply slippage tolerance (e.g., 0.5%)
const minOut = calculateMinimumAmount(expectedOut, 0.5);

// Execute swap with protection
await dex.swap(tokenIn, amountIn, minOut);
```

### Always Approve Before Trading
```javascript
// Check current allowance
const allowance = await token.allowance(userAddress, dexAddress);

// Approve if needed
if (allowance < amountIn) {
  const approveTx = await token.approve(dexAddress, amountIn);
  await approveTx.wait();
}

// Now safe to swap
await dex.swap(tokenIn, amountIn, minOut);
```

### Handle Errors Gracefully
```javascript
try {
  const tx = await dex.swap(tokenIn, amountIn, minOut);
  await tx.wait();
  console.log("Swap successful!");
} catch (error) {
  if (error.message.includes("Slippage too high")) {
    console.log("Try increasing slippage tolerance");
  } else if (error.message.includes("Insufficient")) {
    console.log("Check your token balance");
  } else {
    console.error("Swap failed:", error.message);
  }
}
```

---

## Additional Resources

- [Solidity Documentation](https://docs.soliditylang.org/)
- [Ethers.js v6 Documentation](https://docs.ethers.org/v6/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Uniswap V2 Documentation](https://docs.uniswap.org/contracts/v2/overview)
