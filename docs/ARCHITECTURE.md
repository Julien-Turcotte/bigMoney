# Architecture Documentation

## Overview

MiniUniswap DEX is a decentralized exchange implementation that follows the Uniswap V2 model with an Automated Market Maker (AMM) design using the constant product formula.

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend (React)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  Swap UI     │  │ Liquidity UI │  │  Wallet UI   │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└────────────────────────┬────────────────────────────────┘
                         │ Ethers.js v6
┌────────────────────────┴────────────────────────────────┐
│                   Ethereum Network                       │
│  ┌──────────────────────────────────────────────────┐  │
│  │          MiniUniswap Smart Contract              │  │
│  │  - Liquidity Management (addLiquidity)           │  │
│  │  - Token Swapping (swap)                         │  │
│  │  - LP Token Minting/Burning                      │  │
│  │  - Fee Distribution (automatic)                  │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────┐  ┌──────────────┐                    │
│  │  Token A     │  │  Token B     │  (ERC20)           │
│  └──────────────┘  └──────────────┘                    │
└─────────────────────────────────────────────────────────┘
```

## Smart Contract Architecture

### MiniUniswap Contract

**Inheritance:**
```
ERC20 (OpenZeppelin)
  └── MiniUniswap
        └── ReentrancyGuard (OpenZeppelin)
```

**Core Components:**

1. **State Variables**
   - `token0`, `token1`: Immutable token addresses
   - `reserve0`, `reserve1`: Current token reserves
   - `FEE_PERCENT = 3`: 0.3% fee (3/1000)

2. **Liquidity Management**
   - Maintains constant product: `x * y = k`
   - Mints LP tokens proportional to liquidity share
   - Burns LP tokens to redeem proportional reserves

3. **Token Swapping**
   - Uses AMM formula for price calculation
   - Applies 0.3% fee to input amount
   - Validates slippage protection

4. **LP Token System**
   - Inherits from ERC20
   - Represents ownership share in pool
   - Transferable and tradable

### TestToken Contract

Simple ERC20 implementation for testing:
- Standard OpenZeppelin ERC20
- Public `mint` function for easy testing
- Initial supply minted to deployer

## AMM Algorithm Deep Dive

### Constant Product Formula

The core principle: `x * y = k` (constant)

Where:
- `x` = reserve of Token A
- `y` = reserve of Token B
- `k` = constant product

### Price Calculation

The price of Token A in terms of Token B:
```
price = reserveB / reserveA
```

As traders buy Token A:
- `reserveA` decreases
- `reserveB` increases
- Price of A increases (becomes more expensive)

### Swap Formula (with fee)

To calculate output amount for a swap:

```solidity
// Input amount after fee (0.3%)
amountInWithFee = amountIn * 997

// Calculate output using constant product
numerator = amountInWithFee * reserveOut
denominator = (reserveIn * 1000) + amountInWithFee

amountOut = numerator / denominator
```

**Example:**
- Pool: 1000 A, 1000 B (k = 1,000,000)
- Swap 10 A for B
- Amount after fee: 10 * 0.997 = 9.97 A
- Output: (9.97 * 1000) / (1000 + 9.97) = 9.87 B

### Price Impact

Large trades have higher price impact:

```
priceImpact = (amountIn / reserveIn) * 100%
```

- Small trade (1% of pool): ~1% price impact
- Large trade (10% of pool): ~10% price impact
- Very large trade (50% of pool): ~50% price impact

### Liquidity Provider Shares

LP tokens represent proportional ownership:

```
lpTokens = (amountAdded / totalReserve) * totalSupply
```

When removing liquidity:
```
amountReceived = (lpTokens / totalSupply) * reserve
```

## Fee Distribution Mechanism

**How It Works:**

1. **Swap Execution**
   - User swaps 100 Token A
   - 0.3% fee = 0.3 A kept in contract
   - 99.7 A used for swap calculation

2. **Fee Accumulation**
   - Fees stay in the contract as reserves
   - Increases reserve amounts without changing LP supply
   - `k` increases over time

3. **LP Token Value Growth**
   - More reserves with same LP token supply
   - Each LP token worth more over time
   - Passive income for liquidity providers

**Example:**
- Initial: 1000 A, 1000 B reserves, 1000 LP tokens
- After 100 swaps of 10 tokens each: ~3 tokens in fees
- New reserves: 1003 A, 1003 B
- LP token value increased by 0.3%

## Frontend Architecture

### Component Structure

```
App.jsx
├── Header (Wallet connection)
├── Tab Navigation
├── SwapComponent
│   ├── Token Selection
│   ├── Amount Input
│   ├── Slippage Control
│   └── Swap Button
└── LiquidityComponent
    ├── Pool Info Display
    ├── Add Liquidity Tab
    │   ├── Token A Input
    │   ├── Token B Input (auto-calculated)
    │   ├── Slippage Control
    │   └── Add Button
    └── Remove Liquidity Tab
        ├── LP Token Input
        ├── Expected Output Display
        └── Remove Button
```

### Web3 Integration Layer

**utils/web3.js** provides:

1. **Provider Management**
   - Browser provider (MetaMask)
   - Signer access
   - Network detection

2. **Contract Interaction**
   - Contract instance creation
   - Transaction handling
   - Event listening

3. **Helper Functions**
   - Token amount formatting
   - Slippage calculation
   - Balance queries

### State Management

Simple React state:
- Local component state for UI
- useEffect for blockchain data loading
- No external state management library needed

## Security Architecture

### Smart Contract Security

**ReentrancyGuard:**
```solidity
function swap() external nonReentrant { ... }
function addLiquidity() external nonReentrant { ... }
function removeLiquidity() external nonReentrant { ... }
```

**Slippage Protection:**
```solidity
require(amountOut >= amountOutMin, "Slippage too high");
require(amount0 >= amount0Min, "Insufficient token0");
require(amount1 >= amount1Min, "Insufficient token1");
```

**Safe Math:**
- Solidity 0.8.x automatic overflow checks
- Explicit checks for division by zero
- Proper ordering of operations

**Access Control:**
- No admin functions (fully decentralized)
- Permissionless (anyone can use)
- No pause functionality (always available)

### Frontend Security

**Wallet Security:**
- Never stores private keys
- Uses MetaMask for signing
- Read-only contract access for queries

**Input Validation:**
- Positive numbers only
- Balance checks before transactions
- Proper decimal handling

**Transaction Safety:**
- Approval flow (2-step for token spending)
- Transaction confirmation required
- Error handling and user feedback

## Scalability Considerations

### Current Limitations

1. **Single Pool**
   - Only supports one token pair
   - To support multiple pairs, deploy multiple contracts

2. **No Router**
   - Direct swaps only (A ↔ B)
   - No multi-hop swaps (A → B → C)

3. **Basic Price Oracle**
   - No TWAP (Time-Weighted Average Price)
   - Vulnerable to flash loan attacks (if on mainnet)

### Potential Improvements

1. **Factory Pattern**
   - Deploy multiple pools
   - Registry of all pools
   - Unified interface

2. **Router Contract**
   - Multi-hop swaps
   - Best price routing
   - Gas optimization

3. **Advanced Features**
   - Flash swaps
   - TWAP oracle
   - Concentrated liquidity (Uniswap V3 style)
   - Governance tokens

## Performance Optimization

### Smart Contract Gas Costs

**Typical Gas Usage:**
- Swap: ~100,000 - 150,000 gas
- Add Liquidity: ~150,000 - 200,000 gas
- Remove Liquidity: ~100,000 - 150,000 gas
- Approve Token: ~50,000 gas

**Optimizations:**
- Immutable variables for tokens
- Minimal storage reads/writes
- Efficient math operations
- No loops in core functions

### Frontend Performance

**Optimizations:**
- Vite for fast build times
- React 19 with automatic batching
- Lazy calculation of output amounts
- Debounced input handling (500ms)
- Minimal re-renders

## Testing Strategy

### Unit Tests (To Implement)

```javascript
describe("MiniUniswap", function() {
  it("Should add initial liquidity");
  it("Should maintain constant product on swaps");
  it("Should apply 0.3% fee correctly");
  it("Should prevent slippage exceeding tolerance");
  it("Should mint correct LP tokens");
  it("Should return correct amounts on liquidity removal");
});
```

### Integration Tests

- Full swap flow with approvals
- Add and remove liquidity cycle
- Multiple sequential swaps
- Price impact verification

### Frontend Tests

- Component rendering
- Wallet connection flow
- Transaction submission
- Error handling

## Deployment Strategy

### Local Development
1. Hardhat local node (instant mining)
2. Deploy contracts
3. Distribute test tokens
4. Start frontend

### Testnet
1. Configure network in hardhat.config.js
2. Fund deployer account with testnet ETH
3. Deploy contracts
4. Verify on Etherscan
5. Update frontend deployments.json

### Mainnet (Not Recommended Without Audit)
1. Full security audit required
2. Bug bounty program
3. Gradual rollout with limits
4. Emergency pause mechanism
5. Multisig control

## Monitoring and Maintenance

### Key Metrics to Monitor

- Total Value Locked (TVL)
- Daily trading volume
- Number of liquidity providers
- Average transaction size
- Gas costs
- Slippage rates

### Events for Tracking

```solidity
event LiquidityAdded(address provider, uint256 amount0, uint256 amount1, uint256 liquidity);
event LiquidityRemoved(address provider, uint256 amount0, uint256 amount1, uint256 liquidity);
event Swap(address user, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
```

## Comparison with Uniswap V2

### Similarities
- Constant product formula (x*y=k)
- 0.3% trading fee
- LP token system
- Permissionless

### Differences
- **No Factory**: Single pool vs multiple pools
- **No Router**: Direct swaps only
- **Simplified**: Educational implementation
- **No Flash Swaps**: Not implemented
- **No Price Oracle**: No TWAP mechanism

## Future Enhancements

### Phase 1: Multi-Pool Support
- Factory contract
- Pool registry
- Dynamic pool creation

### Phase 2: Advanced Features
- Router for multi-hop swaps
- Price oracle (TWAP)
- Flash swaps
- Governance

### Phase 3: UI/UX Improvements
- Price charts
- Transaction history
- Analytics dashboard
- Mobile responsive design
- Dark mode

## Glossary

- **AMM**: Automated Market Maker
- **LP**: Liquidity Provider
- **TVL**: Total Value Locked
- **Slippage**: Difference between expected and executed price
- **Impermanent Loss**: Temporary loss from price divergence
- **TWAP**: Time-Weighted Average Price
- **Flash Loan**: Uncollateralized loan within single transaction

## References

- [Uniswap V2 Whitepaper](https://uniswap.org/whitepaper.pdf)
- [Uniswap V2 Core](https://github.com/Uniswap/v2-core)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Ethers.js Documentation](https://docs.ethers.org/v6/)
