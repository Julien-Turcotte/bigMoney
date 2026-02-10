# 🦄 MiniUniswap DEX

A decentralized exchange (DEX) built with React and Solidity that allows users to swap ERC-20 tokens and provide liquidity using an Automated Market Maker (AMM) with the constant product formula (x*y=k).

## Features

- 🔗 **Wallet Connection** with MetaMask
- 💱 **Token Swapping** with slippage protection
- 💧 **Liquidity Pools** - Add and remove liquidity
- 🪙 **LP Tokens** - Receive tokens representing pool shares
- 💰 **Fee Distribution** - 0.3% trading fees to liquidity providers
- 📊 **AMM Algorithm** - Constant product formula (x*y=k)

## Quick Start

### Option 1: Automated Startup (Recommended for Windows)

**Windows (PowerShell):**
```powershell
# Clone and setup
git clone https://github.com/Julien-Turcotte/bigMoney.git
cd bigMoney

# One command to start everything!
.\start.ps1
```

The `start.ps1` script will:
- ✅ Install dependencies (if needed)
- ✅ Start local blockchain
- ✅ Deploy smart contracts
- ✅ Distribute test tokens
- ✅ Start frontend
- ✅ Open browser automatically

To stop all services: `.\stop.ps1` or press `Ctrl+C`

### Option 2: Manual Setup

**Linux/Mac:**
```bash
# Clone and setup
git clone https://github.com/Julien-Turcotte/bigMoney.git
cd bigMoney
./setup.sh

# Start local blockchain (Terminal 1)
npx hardhat node

# Deploy contracts (Terminal 2)
npx hardhat run scripts/deploy.js --network localhost

# Distribute test tokens (Terminal 2)
npx hardhat run scripts/distribute-tokens.js --network localhost

# Start frontend (Terminal 3)
cd frontend
npm run dev
```

**Windows (PowerShell):**
```powershell
# Setup only
.\setup.ps1

# Then follow the manual steps above
```

Then open `http://localhost:3000` or `http://localhost:5173` and connect MetaMask!

## Documentation

- 📖 [Quick Start Guide](./docs/QUICKSTART.md) - Get up and running in 5 minutes
- 🪟 [Windows Guide](./docs/WINDOWS.md) - Complete Windows setup with PowerShell scripts
- 🏗️ [Architecture](./docs/ARCHITECTURE.md) - System design and contracts
- 📚 [API Reference](./docs/API.md) - Smart contract functions
- 🎨 [Frontend Guide](./docs/FRONTEND.md) - React app development
- 🔧 [Deployment Guide](./docs/DEPLOYMENT.md) - Deploy to testnet/mainnet
- ❓ [Troubleshooting](./docs/TROUBLESHOOTING.md) - Common issues and solutions

## Technology Stack

**Smart Contracts:** Solidity 0.8.20, OpenZeppelin, Hardhat  
**Frontend:** React 19, Ethers.js v6, Vite

## Project Structure

```
bigMoney/
├── contracts/          # Solidity smart contracts
├── scripts/           # Deployment and utility scripts
├── frontend/          # React frontend application
├── docs/              # Documentation
└── README.md
```

## Security Notice

⚠️ **This is a demonstration project for educational purposes.**
- Not audited for production use
- Use testnet tokens for testing
- Always test thoroughly before mainnet deployment

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

ISC

## Support

For detailed setup instructions, see the [Quick Start Guide](./docs/QUICKSTART.md).

For issues and questions, please open an issue on GitHub.

---

Built with ❤️ using Uniswap V2 principles
