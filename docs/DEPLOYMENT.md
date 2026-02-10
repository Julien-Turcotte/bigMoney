# Deployment Guide

Complete guide for deploying MiniUniswap DEX to different networks.

## Prerequisites

- Node.js v16+ installed
- Git installed
- Account with ETH for gas fees (testnet or mainnet)
- Private key or mnemonic for deployment account

## Local Deployment

### Step 1: Start Hardhat Node

```bash
npx hardhat node
```

This starts a local Ethereum node with:
- 20 pre-funded accounts (10,000 ETH each)
- Auto-mining (instant transactions)
- RPC: http://127.0.0.1:8545
- Chain ID: 1337

**Keep this terminal running!**

### Step 2: Deploy Contracts

In a new terminal:

```bash
npx hardhat run scripts/deploy.js --network localhost
```

Output:
```
Deploying contracts...
TokenA deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
TokenB deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
MiniUniswap DEX deployed to: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0

Deployment complete!
Deployment info saved to frontend/src/utils/deployments.json
```

### Step 3: Distribute Test Tokens

```bash
npx hardhat run scripts/distribute-tokens.js --network localhost
```

This sends tokens to test accounts.

### Step 4: Start Frontend

```bash
cd frontend
npm run dev
```

Access at: http://localhost:3000

---

## Testnet Deployment

### Supported Testnets

- **Sepolia**: Recommended (most active)
- **Goerli**: Deprecated (being phased out)
- **Mumbai**: Polygon testnet

### Step 1: Get Testnet ETH

**Sepolia Faucets:**
- https://sepoliafaucet.com/
- https://www.infura.io/faucet/sepolia
- https://faucet.quicknode.com/ethereum/sepolia

### Step 2: Setup Environment Variables

Create `.env` file in project root:

```bash
PRIVATE_KEY=your_private_key_here
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
ETHERSCAN_API_KEY=your_etherscan_api_key
```

**Get API Keys:**
- Infura: https://www.infura.io/
- Alchemy: https://www.alchemy.com/
- Etherscan: https://etherscan.io/apis

### Step 3: Update Hardhat Config

Edit `hardhat.config.js`:

```javascript
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";

export default {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 11155111
    },
    mumbai: {
      url: process.env.MUMBAI_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 80001
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};
```

### Step 4: Install dotenv

```bash
npm install --save-dev dotenv
```

### Step 5: Deploy to Testnet

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

Wait for deployment (can take 1-2 minutes).

### Step 6: Verify Contracts

```bash
npx hardhat verify --network sepolia DEPLOYED_CONTRACT_ADDRESS
```

Verification makes your contract code public on Etherscan.

### Step 7: Update Frontend

The deployment script automatically updates `frontend/src/utils/deployments.json`.

Verify the addresses:
```json
{
  "tokenA": "0x...",
  "tokenB": "0x...",
  "dex": "0x...",
  "network": "sepolia",
  "chainId": 11155111
}
```

### Step 8: Configure MetaMask

1. Add Sepolia network to MetaMask
2. Switch to Sepolia network
3. Import your deployment account (has test ETH)

### Step 9: Test on Testnet

1. Start frontend: `cd frontend && npm run dev`
2. Connect wallet to Sepolia
3. Get test tokens from faucet if needed
4. Test all DEX functionality

---

## Mainnet Deployment

⚠️ **WARNING: Deploy to mainnet at your own risk!**

### Security Checklist

Before mainnet deployment:

- [ ] Complete professional security audit
- [ ] Test extensively on testnet
- [ ] Have bug bounty program
- [ ] Implement emergency pause mechanism
- [ ] Use multisig for admin functions
- [ ] Have insurance/backup plan
- [ ] Monitor for unusual activity
- [ ] Prepare incident response plan

### Recommended Changes for Production

1. **Add Access Control**
```solidity
import "@openzeppelin/contracts/access/Ownable.sol";

contract MiniUniswap is ERC20, ReentrancyGuard, Ownable {
    bool public paused = false;
    
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }
    
    function pause() external onlyOwner {
        paused = true;
    }
}
```

2. **Add Emergency Withdrawal**
```solidity
function emergencyWithdraw(address token, uint256 amount) external onlyOwner {
    require(paused, "Must be paused");
    IERC20(token).transfer(owner(), amount);
}
```

3. **Implement Timelock**
```solidity
uint256 public constant TIMELOCK_DURATION = 2 days;
```

4. **Add Circuit Breakers**
```solidity
require(amount <= maxTradeSize, "Trade too large");
require(priceImpact <= maxPriceImpact, "Price impact too high");
```

### Mainnet Deployment Steps

1. **Setup Mainnet Config**

```javascript
mainnet: {
  url: process.env.MAINNET_RPC_URL,
  accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
  chainId: 1,
  gasPrice: "auto"
}
```

2. **Estimate Gas Costs**

```bash
# Check current gas prices
https://etherscan.io/gastracker

# Estimate deployment cost
# ~2-3M gas total
# At 50 gwei: ~0.15 ETH
# At 100 gwei: ~0.3 ETH
```

3. **Deploy**

```bash
npx hardhat run scripts/deploy.js --network mainnet
```

4. **Verify on Etherscan**

```bash
npx hardhat verify --network mainnet DEPLOYED_ADDRESS
```

5. **Initial Liquidity**

Add substantial initial liquidity to reduce price impact:

```javascript
// Add $10,000+ of liquidity
await dex.addLiquidity(
  ethers.parseEther("10000"),  // 10k Token A
  ethers.parseEther("10000"),  // 10k Token B
  ethers.parseEther("9900"),   // 1% slippage
  ethers.parseEther("9900")
);
```

6. **Monitor**

- Watch transactions on Etherscan
- Monitor for unusual activity
- Track TVL and volume
- Set up alerts for large trades

---

## Alternative Networks

### Polygon

Advantages:
- Low gas fees
- Fast transactions
- EVM compatible

Config:
```javascript
polygon: {
  url: "https://polygon-rpc.com/",
  accounts: [process.env.PRIVATE_KEY],
  chainId: 137
}
```

### Arbitrum

Advantages:
- Ethereum L2
- Lower gas costs
- Ethereum security

Config:
```javascript
arbitrum: {
  url: "https://arb1.arbitrum.io/rpc",
  accounts: [process.env.PRIVATE_KEY],
  chainId: 42161
}
```

### Optimism

Advantages:
- Ethereum L2
- Low fees
- Fast finality

Config:
```javascript
optimism: {
  url: "https://mainnet.optimism.io",
  accounts: [process.env.PRIVATE_KEY],
  chainId: 10
}
```

---

## Frontend Deployment

### Option 1: Vercel (Recommended)

1. Push code to GitHub
2. Go to https://vercel.com/
3. Import GitHub repository
4. Configure build settings:
   - Framework: Vite
   - Root Directory: frontend
   - Build Command: `npm run build`
   - Output Directory: `dist`
5. Add environment variables if needed
6. Deploy!

### Option 2: Netlify

1. Push code to GitHub
2. Go to https://www.netlify.com/
3. New site from Git
4. Configure:
   - Build command: `cd frontend && npm run build`
   - Publish directory: `frontend/dist`
5. Deploy

### Option 3: GitHub Pages

```bash
cd frontend
npm run build
npm install -g gh-pages
gh-pages -d dist
```

Access at: `https://username.github.io/bigMoney/`

### Option 4: IPFS (Fully Decentralized)

```bash
# Install IPFS
npm install -g ipfs

# Build
cd frontend && npm run build

# Add to IPFS
ipfs add -r dist/

# Pin on Pinata/Infura
```

---

## Post-Deployment

### Monitoring

1. **Track Contract Interactions**
   - Use Etherscan API
   - Monitor events
   - Track gas usage

2. **Set Up Alerts**
   - Large transactions
   - Unusual patterns
   - Contract errors

3. **Analytics**
   - TVL tracking
   - Volume metrics
   - User analytics

### Maintenance

1. **Keep Dependencies Updated**
```bash
npm audit
npm update
```

2. **Monitor Gas Prices**
   - Adjust if needed
   - Provide gas estimates

3. **User Support**
   - Documentation
   - FAQ
   - Discord/Telegram community

### Upgrades

Since contracts are immutable:
1. Deploy new version
2. Migrate liquidity
3. Update frontend
4. Communicate with users

---

## Cost Estimation

### Deployment Costs

| Network | Deployment | Add Liquidity | Total |
|---------|-----------|---------------|-------|
| Hardhat | Free | Free | Free |
| Sepolia | Free (testnet ETH) | Free | Free |
| Mainnet (50 gwei) | ~0.15 ETH (~$300) | 0.01 ETH (~$20) | ~$320 |
| Polygon | <$1 | <$0.10 | <$2 |
| Arbitrum | ~$5-10 | ~$1 | ~$6-11 |

### Operational Costs

- Frontend hosting: Free (Vercel/Netlify)
- RPC calls: Free (public RPCs) or ~$50/month (dedicated)
- Monitoring: Free (basic) or ~$20/month (advanced)

---

## Rollback Plan

If issues arise:

1. **Pause contract** (if implemented)
2. **Remove liquidity** from pools
3. **Deploy fixed version**
4. **Migrate users** to new contract
5. **Refund gas** if necessary

---

## Checklist

Before going live:

- [ ] Contracts tested extensively
- [ ] Security audit completed (for mainnet)
- [ ] Frontend tested on testnet
- [ ] Documentation complete
- [ ] Emergency procedures defined
- [ ] Monitoring setup
- [ ] User support channels ready
- [ ] Legal considerations addressed
- [ ] Marketing plan ready
- [ ] Sufficient gas for deployment

---

## Support

For deployment issues:
- Check [Troubleshooting Guide](./TROUBLESHOOTING.md)
- Review Hardhat documentation
- Ask in community forums

For security concerns:
- Get professional audit
- Review OpenZeppelin best practices
- Join security communities
