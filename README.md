# 🦄 Mini-Uniswap: Decentralized Exchange Web App

A non-custodial decentralized exchange (DEX) that allows users to swap ERC-20 tokens, provide liquidity, and earn fees using an Automated Market Maker (AMM) model.

## 1. Overview

The Mini-Uniswap web app is a decentralized exchange where users maintain full control of their funds at all times via their wallet (MetaMask). All core logic runs on Ethereum smart contracts, while the web interface serves as a clean, user-friendly gateway to the blockchain.

## 2. Core Features

### 🔁 Token Swapping

Users can swap between two ERC-20 tokens without relying on an order book.

**How it works:**
- Uses the constant product formula: `x * y = k`
- Prices are determined automatically by token reserves
- Trades incur a small fee (e.g. 0.3%) that goes to liquidity providers

**UI Elements:**
- Token selector (From / To)
- Amount input
- Live price quote
- Slippage tolerance setting
- "Swap" button with transaction confirmation

### 💧 Liquidity Pools

Each token pair has a pool funded by users.

**User actions:**
- Add liquidity by depositing equal value of two tokens
- Remove liquidity at any time
- Receive LP tokens representing pool ownership

**UI Elements:**
- Pool list (TVL, volume, fees)
- Add / Remove liquidity forms
- User's LP token balance
- Share of pool (%)

### 🪙 Liquidity Provider Rewards

Liquidity providers earn:
- A portion of swap fees
- Increased token amounts when withdrawing (fees accumulate in pool)

**Displayed info:**
- Fees earned (estimated)
- Pool APY (optional but impressive)
- Historical earnings chart (optional)

### 🔐 Wallet Integration

The app integrates directly with Web3 wallets.

**Supported:**
- MetaMask (required)
- WalletConnect (optional)

**Capabilities:**
- Connect / disconnect wallet
- Detect network (Ethereum / Sepolia)
- Prompt network switch if needed
- Read balances & allowances

## 3. Smart Contract Architecture

### 🧩 Contracts

#### 1. Factory Contract

Responsible for creating and tracking pools.

**Responsibilities:**
- Create new liquidity pools
- Store pool addresses
- Prevent duplicate token pairs

#### 2. Pair (Pool) Contract

One contract per token pair.

**Responsibilities:**
- Store token reserves
- Execute swaps
- Mint / burn LP tokens
- Collect fees

**Key functions:**
- `swap()`
- `addLiquidity()`
- `removeLiquidity()`
- `getReserves()`

#### 3. LP Token (ERC-20)

Represents ownership in a liquidity pool.
- Minted when liquidity is added
- Burned when liquidity is removed

## 4. Pricing & Fees Logic

### 🧮 AMM Formula

```
(x + Δx)(y − Δy) = k
```

Where:
- `x, y` = token reserves
- `Δx` = input amount
- `Δy` = output amount

### 💸 Fees

- 0.3% fee per swap
- Fee stays in pool
- Automatically distributed to LPs

### 📉 Slippage Protection

Users can:
- Set max slippage %
- Transactions revert if price moves too much

## 5. Web App Pages

### 🏠 Home / Swap Page
- Swap tokens
- View exchange rate
- Confirm transaction

### 💧 Pools Page
- View all liquidity pools
- Add liquidity
- Remove liquidity
- See pool statistics

### 👤 Dashboard (Optional)
- Wallet balance
- Active LP positions
- Fees earned
- Transaction history

## 6. Frontend Tech Stack

- **React / Next.js** - UI framework
- **Ethers.js** - Ethereum interaction
- **Tailwind CSS** - Styling
- **Web3Modal** - Wallet connection
- **Chart.js / Recharts** - Data visualization

## 7. Backend / Indexing (Optional but Advanced)

For performance & analytics:

**The Graph:**
- Index swaps, liquidity events
- Display historical data without heavy RPC calls

## 8. Security Considerations

- ✅ Reentrancy protection
- ✅ Safe math (Solidity ≥0.8)
- ✅ Checks-Effects-Interactions pattern
- ✅ Slippage validation
- ✅ Deadline enforcement

## 9. User Flow Example

1. User connects wallet
2. Selects Token A → Token B
3. Enters amount
4. Sees estimated output & fee
5. Confirms swap in MetaMask
6. Transaction executes on-chain
7. UI updates balances

## 10. Why This Project Is Impressive

✅ Demonstrates DeFi fundamentals  
✅ Shows smart contract architecture  
✅ Uses real economic models  
✅ Frontend + blockchain integration  
✅ Easy to extend (DAO, staking, L2)

## 11. Possible Extensions

- 🔄 Limit orders
- 🗳️ Governance token
- 🌐 Layer-2 support (Polygon)
- ⚡ Flash swap demo
- 📊 Impermanent loss calculator

---

## Getting Started

### Prerequisites
- Node.js (v16+)
- MetaMask wallet
- Ethereum testnet tokens (Sepolia)

### Installation

```bash
# Clone the repository
git clone https://github.com/Julien-Turcotte/bigMoney.git
cd bigMoney

# Install dependencies
npm install

# Start development server
npm run dev
```

### Configuration

1. Connect MetaMask to Sepolia testnet
2. Get testnet tokens from a faucet
3. Start swapping and providing liquidity!

---

## License

MIT License - see LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.