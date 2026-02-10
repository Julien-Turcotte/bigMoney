#!/bin/bash

# MiniUniswap DEX Setup Script

echo "🦄 MiniUniswap DEX Setup Script"
echo "================================"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 16+ first."
    exit 1
fi

echo "✓ Node.js version: $(node --version)"
echo ""

# Install root dependencies
echo "📦 Installing smart contract dependencies..."
npm install
if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi
echo "✓ Smart contract dependencies installed"
echo ""

# Install frontend dependencies  
echo "📦 Installing frontend dependencies..."
cd frontend
npm install
if [ $? -ne 0 ]; then
    echo "❌ Failed to install frontend dependencies"
    exit 1
fi
cd ..
echo "✓ Frontend dependencies installed"
echo ""

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Start Hardhat node:       npx hardhat node"
echo "2. Deploy contracts:         npx hardhat run scripts/deploy.js --network localhost"
echo "3. Start frontend:           cd frontend && npm run dev"
echo ""
echo "Make sure to:"
echo "- Configure MetaMask with Hardhat network (RPC: http://127.0.0.1:8545, Chain ID: 1337)"
echo "- Import a test account from Hardhat node"
echo ""
echo "Happy trading! 🚀"
