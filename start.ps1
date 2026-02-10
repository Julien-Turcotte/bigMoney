# MiniUniswap DEX Startup Script for Windows
# This script starts the entire application stack

param(
    [switch]$SkipSetup,
    [switch]$SkipBrowser
)

Write-Host "🦄 MiniUniswap DEX Startup Script" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a port is in use
function Test-Port {
    param([int]$Port)
    $connection = Test-NetConnection -ComputerName localhost -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue
    return $connection
}

# Function to kill process on port
function Stop-ProcessOnPort {
    param([int]$Port)
    try {
        $connections = @(Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue)
        if ($connections) {
            $processIds = $connections | Select-Object -ExpandProperty OwningProcess -Unique
            foreach ($processId in $processIds) {
                Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
                Write-Host "✓ Stopped process $processId on port $Port" -ForegroundColor Yellow
            }
            Start-Sleep -Seconds 2
        }
    } catch {
        # Port not in use, continue
    }
}

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js version: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js is not installed. Please install Node.js 16+ first." -ForegroundColor Red
    Write-Host "Download from: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check if dependencies are installed
if (-not $SkipSetup) {
    if (-not (Test-Path "node_modules") -or -not (Test-Path "frontend/node_modules")) {
        Write-Host ""
        Write-Host "⚠️  Dependencies not found. Running setup..." -ForegroundColor Yellow
        Write-Host ""
        .\setup.ps1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Setup failed" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host ""
Write-Host "🚀 Starting MiniUniswap DEX..." -ForegroundColor Cyan
Write-Host ""

# Clean up any existing processes on ports
Write-Host "🧹 Cleaning up existing processes..." -ForegroundColor Yellow
Stop-ProcessOnPort -Port 8545  # Hardhat node
Stop-ProcessOnPort -Port 3000  # Frontend dev server
Stop-ProcessOnPort -Port 5173  # Vite alternative port

Write-Host ""
Write-Host "📡 Step 1: Starting Hardhat local blockchain..." -ForegroundColor Cyan

# Start Hardhat node in background
$hardhatJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    npx hardhat node
}

Write-Host "✓ Hardhat node starting (Job ID: $($hardhatJob.Id))..." -ForegroundColor Green
Write-Host "  Waiting for blockchain to be ready..." -ForegroundColor Gray

# Wait for Hardhat to be ready (check if port 8545 is listening)
$maxWaitTime = 30
$waited = 0
while (-not (Test-Port -Port 8545) -and $waited -lt $maxWaitTime) {
    Start-Sleep -Seconds 1
    $waited++
    Write-Host "." -NoNewline -ForegroundColor Gray
}
Write-Host ""

if ($waited -ge $maxWaitTime) {
    Write-Host "❌ Hardhat node failed to start" -ForegroundColor Red
    Stop-Job $hardhatJob
    Remove-Job $hardhatJob
    exit 1
}

Write-Host "✓ Blockchain ready on http://127.0.0.1:8545" -ForegroundColor Green
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "📝 Step 2: Deploying smart contracts..." -ForegroundColor Cyan

# Deploy contracts
npx hardhat run scripts/deploy.js --network localhost
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Contract deployment failed" -ForegroundColor Red
    Stop-Job $hardhatJob
    Remove-Job $hardhatJob
    exit 1
}

Write-Host "✓ Contracts deployed successfully" -ForegroundColor Green
Start-Sleep -Seconds 1

Write-Host ""
Write-Host "💰 Step 3: Distributing test tokens..." -ForegroundColor Cyan

# Distribute tokens to test accounts
npx hardhat run scripts/distribute-tokens.js --network localhost
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Token distribution had issues (this is optional)" -ForegroundColor Yellow
} else {
    Write-Host "✓ Test tokens distributed" -ForegroundColor Green
}

Start-Sleep -Seconds 1

Write-Host ""
Write-Host "🎨 Step 4: Starting frontend development server..." -ForegroundColor Cyan

# Start frontend in background
$frontendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD/frontend
    npm run dev
}

Write-Host "✓ Frontend starting (Job ID: $($frontendJob.Id))..." -ForegroundColor Green
Write-Host "  Waiting for dev server to be ready..." -ForegroundColor Gray

# Wait for frontend to be ready
$maxWaitTime = 30
$waited = 0
$frontendReady = $false

while (-not $frontendReady -and $waited -lt $maxWaitTime) {
    Start-Sleep -Seconds 1
    $waited++
    
    # Check both common Vite ports
    if ((Test-Port -Port 3000) -or (Test-Port -Port 5173)) {
        $frontendReady = $true
        break
    }
    
    Write-Host "." -NoNewline -ForegroundColor Gray
}
Write-Host ""

if (-not $frontendReady) {
    Write-Host "⚠️  Frontend may not be ready yet, but continuing..." -ForegroundColor Yellow
}

# Determine which port the frontend is running on
$frontendUrl = "http://localhost:5173"
if (Test-Port -Port 3000) {
    $frontendUrl = "http://localhost:3000"
}

Write-Host "✓ Frontend ready at $frontendUrl" -ForegroundColor Green

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ MiniUniswap DEX is now running!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📍 URLs:" -ForegroundColor Cyan
Write-Host "   Frontend:   $frontendUrl" -ForegroundColor White
Write-Host "   Blockchain: http://127.0.0.1:8545 (Chain ID: 1337)" -ForegroundColor White
Write-Host ""
Write-Host "📋 Active Jobs:" -ForegroundColor Cyan
Write-Host "   Hardhat Node: Job ID $($hardhatJob.Id)" -ForegroundColor White
Write-Host "   Frontend:     Job ID $($frontendJob.Id)" -ForegroundColor White
Write-Host ""
Write-Host "⚙️  Next Steps:" -ForegroundColor Cyan
Write-Host "1. Configure MetaMask:" -ForegroundColor White
Write-Host "   - Network Name: Hardhat Local" -ForegroundColor Gray
Write-Host "   - RPC URL: http://127.0.0.1:8545" -ForegroundColor Gray
Write-Host "   - Chain ID: 1337" -ForegroundColor Gray
Write-Host "   - Currency: ETH" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Import a test account:" -ForegroundColor White
Write-Host "   - Get private key from Hardhat node output above" -ForegroundColor Gray
Write-Host "   - Use MetaMask 'Import Account' feature" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Open the app in your browser:" -ForegroundColor White
Write-Host "   $frontendUrl" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor Cyan
Write-Host "   - View logs: Receive-Job -Id <JobId> -Keep" -ForegroundColor Gray
Write-Host "   - Stop all: Press Ctrl+C or run .\stop.ps1" -ForegroundColor Gray
Write-Host ""

# Open browser if not skipped
if (-not $SkipBrowser) {
    Write-Host "🌐 Opening browser..." -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    Start-Process $frontendUrl
}

Write-Host ""
Write-Host "Press Ctrl+C to stop all services..." -ForegroundColor Yellow
Write-Host ""

# Keep script running and show logs
try {
    while ($true) {
        Start-Sleep -Seconds 5
        
        # Check if jobs are still running
        $hardhatStatus = Get-Job -Id $hardhatJob.Id
        $frontendStatus = Get-Job -Id $frontendJob.Id
        
        if ($hardhatStatus.State -eq "Failed" -or $hardhatStatus.State -eq "Stopped") {
            Write-Host ""
            Write-Host "⚠️  Hardhat node stopped unexpectedly" -ForegroundColor Red
            break
        }
        
        if ($frontendStatus.State -eq "Failed" -or $frontendStatus.State -eq "Stopped") {
            Write-Host ""
            Write-Host "⚠️  Frontend stopped unexpectedly" -ForegroundColor Red
            break
        }
    }
} finally {
    Write-Host ""
    Write-Host "🛑 Stopping services..." -ForegroundColor Yellow
    
    # Stop jobs
    Stop-Job $hardhatJob -ErrorAction SilentlyContinue
    Stop-Job $frontendJob -ErrorAction SilentlyContinue
    Remove-Job $hardhatJob -ErrorAction SilentlyContinue
    Remove-Job $frontendJob -ErrorAction SilentlyContinue
    
    # Clean up ports
    Stop-ProcessOnPort -Port 8545
    Stop-ProcessOnPort -Port 3000
    Stop-ProcessOnPort -Port 5173
    
    Write-Host "✓ All services stopped" -ForegroundColor Green
    Write-Host ""
    Write-Host "Thank you for using MiniUniswap DEX! 🦄" -ForegroundColor Cyan
}
