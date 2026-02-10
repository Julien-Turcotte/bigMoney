# MiniUniswap DEX Setup Script for Windows
# This script installs all dependencies for the project

Write-Host "🦄 MiniUniswap DEX Setup Script" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js version: $nodeVersion" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Node.js is not installed. Please install Node.js 16+ first." -ForegroundColor Red
    Write-Host "Download from: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Install root dependencies
Write-Host "📦 Installing smart contract dependencies..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Smart contract dependencies installed" -ForegroundColor Green
Write-Host ""

# Install frontend dependencies
Write-Host "📦 Installing frontend dependencies..." -ForegroundColor Yellow
Set-Location frontend
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install frontend dependencies" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Set-Location ..
Write-Host "✓ Frontend dependencies installed" -ForegroundColor Green
Write-Host ""

Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Start the full application:  .\start.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Or manually:" -ForegroundColor Cyan
Write-Host "1. Start Hardhat node:         npx hardhat node" -ForegroundColor White
Write-Host "2. Deploy contracts:           npx hardhat run scripts/deploy.js --network localhost" -ForegroundColor White
Write-Host "3. Distribute tokens:          npx hardhat run scripts/distribute-tokens.js --network localhost" -ForegroundColor White
Write-Host "4. Start frontend:             cd frontend; npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "Make sure to:" -ForegroundColor Yellow
Write-Host "- Configure MetaMask with Hardhat network (RPC: http://127.0.0.1:8545, Chain ID: 1337)" -ForegroundColor White
Write-Host "- Import a test account from Hardhat node" -ForegroundColor White
Write-Host ""
Write-Host "Happy trading! 🚀" -ForegroundColor Green
