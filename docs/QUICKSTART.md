# Quick Start Guide

This guide will help you get the MiniUniswap DEX up and running in minutes.

## Prerequisites Check

Before starting, ensure you have:
- ✅ Node.js v16+ installed
- ✅ MetaMask browser extension installed
- ✅ Git installed

## Step 1: Clone and Setup

```bash
# Clone the repository
git clone https://github.com/Julien-Turcotte/bigMoney.git
cd bigMoney

# Run the setup script (installs all dependencies)
./setup.sh
```

Or manually:
```bash
# Install smart contract dependencies
npm install

# Install frontend dependencies
cd frontend && npm install && cd ..
```

## Step 2: Start Local Blockchain

Open a terminal and start the Hardhat local blockchain:

```bash
npx hardhat node
```

**Keep this terminal running!** You'll see:
- 20 test accounts with 10,000 ETH each
- Their private keys (for importing into MetaMask)
- The local RPC URL: `http://127.0.0.1:8545`

## Step 3: Deploy Smart Contracts

Open a **new terminal** and deploy the contracts:

```bash
npx hardhat run scripts/deploy.js --network localhost
```

You should see:
```
Deploying contracts...
TokenA deployed to: 0x...
TokenB deployed to: 0x...
MiniUniswap DEX deployed to: 0x...
Deployment complete!
```

## Step 4: Configure MetaMask

### Add Hardhat Network:
1. Open MetaMask
2. Click network dropdown → "Add Network" → "Add a network manually"
3. Fill in:
   - **Network Name**: Hardhat Local
   - **RPC URL**: `http://127.0.0.1:8545`
   - **Chain ID**: `1337`
   - **Currency Symbol**: ETH
4. Click "Save"

### Import Test Account:
1. In MetaMask, click account icon → "Import Account"
2. Copy a private key from the Hardhat node terminal (the first account is the deployer)
3. Paste and import
4. You should see 10,000 ETH (minus gas from deployment if using account #0)

## Step 5: Get Test Tokens

The deployer account (#0) owns all the initial test tokens. You need to send some to your MetaMask account:

**Option A: Use Hardhat Console**
```bash
npx hardhat console --network localhost
```

Then in the console:
```javascript
const TestToken = await ethers.getContractFactory("TestToken");
const tokenA = await TestToken.attach("TOKEN_A_ADDRESS"); // From deployments.json
const tokenB = await TestToken.attach("TOKEN_B_ADDRESS"); // From deployments.json

// Send tokens to your address
await tokenA.transfer("YOUR_METAMASK_ADDRESS", ethers.parseEther("1000"));
await tokenB.transfer("YOUR_METAMASK_ADDRESS", ethers.parseEther("1000"));
```

**Option B: Use Deployment Script**
Or create a token distribution script.

## Step 6: Start Frontend

Open a **new terminal** and start the React app:

```bash
cd frontend
npm run dev
```

The application will open at `http://localhost:3000`

## Step 7: Use the DEX

### Connect Wallet:
1. Click "Connect Wallet"
2. Select MetaMask and approve

### First-Time Setup - Add Initial Liquidity:
Before swapping, the pool needs liquidity:

1. Go to **Liquidity** tab
2. Click **Add Liquidity**
3. Enter amounts (e.g., 100 Token A and 100 Token B)
4. Click **Add Liquidity**
5. Approve both tokens in MetaMask
6. Confirm the add liquidity transaction
7. You'll receive LP tokens!

### Swap Tokens:
1. Go to **Swap** tab
2. Select "Token A" to swap
3. Enter amount (e.g., 10)
4. Token B amount will be calculated automatically
5. Set slippage tolerance (0.5% is good)
6. Click **Swap**
7. Approve token (first time only)
8. Confirm swap transaction

### Remove Liquidity:
1. Go to **Liquidity** tab
2. Click **Remove Liquidity**
3. Enter LP token amount
4. Click **Remove Liquidity**
5. Confirm transaction
6. You'll receive both tokens back!

## Common Issues

### "Cannot connect to network"
- Make sure Hardhat node is running
- Check MetaMask is on "Hardhat Local" network

### "Insufficient balance"
- Make sure you transferred test tokens to your address
- Check you're using the correct account

### "Transaction failed"
- Increase gas limit in MetaMask
- Check slippage tolerance
- Ensure pool has liquidity (for swaps)

### "Nonce too high" error
- Go to MetaMask Settings → Advanced → Clear Activity Tab Data
- This resets the transaction history

## Development Workflow

### Making Changes to Smart Contracts:
1. Edit contract files in `contracts/`
2. Stop Hardhat node (Ctrl+C)
3. Restart: `npx hardhat node`
4. Redeploy: `npx hardhat run scripts/deploy.js --network localhost`
5. Clear MetaMask activity data (Settings → Advanced → Clear Activity Tab Data)
6. Refresh browser

### Making Changes to Frontend:
1. Edit files in `frontend/src/`
2. Vite will hot-reload automatically
3. Refresh browser if needed

## Testing the AMM

Try these scenarios to see the AMM in action:

### Price Impact:
1. Add liquidity: 1000 A + 1000 B
2. Swap 10 A → should get ~9.97 B (0.3% fee)
3. Swap 100 A → will get less B per A (higher price impact)
4. Swap 500 A → even more price impact!

### Liquidity Provider Fees:
1. Add 1000 A + 1000 B liquidity
2. Note your LP token balance
3. Have another account swap tokens (generates fees)
4. Remove your liquidity
5. You'll get back more than you put in! (fees earned)

### Slippage Protection:
1. Try swapping with 0.1% slippage on a large trade
2. Transaction may fail if price moves too much
3. Increase slippage to make it work

## Next Steps

- Deploy to a testnet (Sepolia, Goerli)
- Add more token pairs
- Implement token creation UI
- Add price charts
- Add transaction history

## Support

Having issues? Check:
- All terminals are running (Hardhat node, frontend dev server)
- MetaMask is configured correctly
- You have test tokens in your account
- The deployment addresses in `deployments.json` match your MetaMask network

Happy trading! 🦄💰
