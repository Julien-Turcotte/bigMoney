# MiniUniswap DEX

A decentralized exchange (DEX) web application built with React and Solidity that allows users to swap ERC-20 tokens and provide liquidity using an Automated Market Maker (AMM) with the constant product formula (x*y=k).

## Features

✨ **Core Functionality:**
- 🔗 **Wallet Connection**: Connect with MetaMask
- 💱 **Token Swapping**: Swap ERC-20 tokens with slippage protection
- 💧 **Liquidity Pools**: Add and remove liquidity
- 🪙 **LP Tokens**: Receive LP tokens representing pool shares
- 💰 **Fee Distribution**: 0.3% trading fees automatically distributed to liquidity providers
- 📊 **AMM Algorithm**: Uses constant product formula (x*y=k)

## Project Structure

```
bigMoney/
├── contracts/              # Solidity smart contracts
│   ├── MiniUniswap.sol    # Main DEX contract with AMM logic
│   └── TestToken.sol      # ERC20 test token
├── scripts/               # Deployment scripts
│   └── deploy.js          # Contract deployment script
├── frontend/              # React frontend application
│   ├── src/
│   │   ├── components/
│   │   │   ├── SwapComponent.jsx      # Token swap interface
│   │   │   └── LiquidityComponent.jsx # Liquidity management
│   │   ├── utils/
│   │   │   ├── web3.js           # Web3/ethers.js utilities
│   │   │   ├── MiniUniswap.json  # DEX contract ABI
│   │   │   ├── TestToken.json    # Token contract ABI
│   │   │   └── deployments.json  # Deployed contract addresses
│   │   ├── App.jsx
│   │   ├── App.css
│   │   └── main.jsx
│   ├── index.html
│   ├── vite.config.js
│   └── package.json
├── hardhat.config.js      # Hardhat configuration
├── package.json
└── README.md
```

## Technology Stack

**Smart Contracts:**
- Solidity 0.8.20
- OpenZeppelin Contracts
- Hardhat

**Frontend:**
- React 19
- Ethers.js v6
- Vite

## Setup & Installation

### Prerequisites
- Node.js (v16 or higher)
- MetaMask browser extension
- Git

### Installation Steps

1. **Clone the repository:**
```bash
git clone https://github.com/Julien-Turcotte/bigMoney.git
cd bigMoney
```

2. **Install smart contract dependencies:**
```bash
npm install
```

3. **Install frontend dependencies:**
```bash
cd frontend
npm install
```

## Smart Contracts

### MiniUniswap Contract

The main DEX contract implements:
- **Liquidity Management**: Add/remove liquidity with proper ratio calculation
- **Token Swapping**: Swap tokens using AMM formula
- **LP Tokens**: ERC20 tokens representing liquidity provider shares
- **Fee System**: 0.3% trading fee on all swaps
- **Slippage Protection**: Minimum amount parameters for all trades

**Key Functions:**
- `addLiquidity(amount0Desired, amount1Desired, amount0Min, amount1Min)`
- `removeLiquidity(liquidity, amount0Min, amount1Min)`
- `swap(tokenIn, amountIn, amountOutMin)`
- `getAmountOut(amountIn, reserveIn, reserveOut)`

### TestToken Contract

Simple ERC20 token for testing:
- Standard ERC20 implementation
- Mint function for easy testing

## Deployment

### Local Development (Hardhat Network)

1. **Start a local Hardhat node:**
```bash
npx hardhat node
```

2. **Deploy contracts** (in a new terminal):
```bash
npx hardhat run scripts/deploy.js --network localhost
```

This will:
- Deploy two test tokens (Token A and Token B)
- Deploy the MiniUniswap DEX contract
- Save deployment addresses to `frontend/src/utils/deployments.json`

3. **Configure MetaMask:**
- Add Hardhat network: RPC URL `http://127.0.0.1:8545`, Chain ID `1337`
- Import test accounts from Hardhat node output

4. **Start the frontend:**
```bash
cd frontend
npm run dev
```

5. **Access the application:**
Open your browser to `http://localhost:3000`

### Testnet Deployment

To deploy to a testnet (e.g., Sepolia):

1. **Update `hardhat.config.js`** with testnet configuration
2. **Set up environment variables** (private key, RPC URL)
3. **Deploy:**
```bash
npx hardhat run scripts/deploy.js --network sepolia
```

## Usage Guide

### Connecting Wallet
1. Click "Connect Wallet" button
2. Approve MetaMask connection request
3. Ensure you're on the correct network (Chain ID 1337 for local)

### Swapping Tokens

1. Navigate to the **Swap** tab
2. Select the token you want to swap from
3. Enter the amount
4. Select the token you want to receive
5. Set slippage tolerance (0.1% - 2.0%)
6. Click **Swap** and confirm the transaction

**Note:** The first swap will require token approval.

### Providing Liquidity

#### Add Liquidity:
1. Navigate to the **Liquidity** tab
2. Click **Add Liquidity**
3. Enter amount for Token A
4. Token B amount will auto-calculate to maintain pool ratio
5. Set slippage tolerance
6. Click **Add Liquidity** and confirm transactions
   - Approve Token A (first time)
   - Approve Token B (first time)
   - Add liquidity transaction

You'll receive LP tokens representing your share of the pool.

#### Remove Liquidity:
1. Navigate to **Liquidity** tab
2. Click **Remove Liquidity**
3. Enter LP token amount to burn
4. Set slippage tolerance
5. Click **Remove Liquidity** and confirm transaction

You'll receive both tokens back proportional to your LP share.

### Fee Distribution

- **0.3% fee** on every swap
- Fees automatically added to liquidity pool reserves
- All LP token holders benefit proportionally
- Fees compound over time as trading volume increases

## AMM Algorithm (x*y=k)

The DEX uses the constant product formula:

```
x * y = k
```

Where:
- `x` = reserve of token A
- `y` = reserve of token B  
- `k` = constant

**Price Calculation:**
```
price = reserveOut / reserveIn
```

**Swap Output (with 0.3% fee):**
```
amountOut = (amountIn * 997 * reserveOut) / (reserveIn * 1000 + amountIn * 997)
```

## Security Considerations

✅ **Implemented Protections:**
- ReentrancyGuard on all state-changing functions
- Slippage protection with minimum amount parameters
- Safe math operations (Solidity 0.8.x)
- Proper allowance checks before transfers

⚠️ **Important Notes:**
- This is a **demonstration project** for educational purposes
- Not audited for production use
- Use testnet tokens for testing
- Always test thoroughly before mainnet deployment

## Testing

To test the smart contracts:

```bash
npx hardhat test
```

(Note: Test files would need to be created)

## Troubleshooting

**MetaMask Connection Issues:**
- Ensure MetaMask is installed and unlocked
- Check you're on the correct network
- Try refreshing the page

**Transaction Failures:**
- Check you have sufficient token balance
- Ensure you have enough ETH for gas fees
- Increase slippage tolerance if price is volatile
- Check token allowances

**Build Issues:**
- Clear cache: `rm -rf node_modules package-lock.json && npm install`
- Ensure Node.js version is 16 or higher

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

ISC

## Acknowledgments

- Inspired by Uniswap V2
- Built with OpenZeppelin contracts
- Uses Hardhat development environment