# Windows Setup Guide for MiniUniswap DEX

This guide is specifically for Windows users who want to run the MiniUniswap DEX locally.

## Prerequisites

Before you begin, ensure you have:

1. **Node.js v16 or higher**
   - Download from: https://nodejs.org/
   - Choose the LTS (Long Term Support) version
   - Verify installation: Open PowerShell and run `node --version`

2. **Git**
   - Download from: https://git-scm.com/download/win
   - Install with default settings
   - Verify installation: Open PowerShell and run `git --version`

3. **MetaMask Browser Extension**
   - Install from: https://metamask.io/
   - Available for Chrome, Firefox, Brave, and Edge

## Quick Start (Automated - Recommended)

The easiest way to get started on Windows is to use the automated PowerShell scripts.

### 1. Clone the Repository

Open PowerShell and run:

```powershell
git clone https://github.com/Julien-Turcotte/bigMoney.git
cd bigMoney
```

### 2. Run the Startup Script

```powershell
.\start.ps1
```

This single command will:
- ✅ Check if Node.js is installed
- ✅ Install all dependencies (if needed)
- ✅ Start a local blockchain on port 8545
- ✅ Deploy smart contracts
- ✅ Distribute test tokens to accounts
- ✅ Start the frontend development server
- ✅ Open your browser to the application

**That's it!** The application should now be running.

### 3. Configure MetaMask

While the services are starting, configure MetaMask:

1. Open MetaMask extension
2. Click the network dropdown (top center)
3. Click "Add Network" → "Add a network manually"
4. Enter the following details:
   - **Network Name**: `Hardhat Local`
   - **RPC URL**: `http://127.0.0.1:8545`
   - **Chain ID**: `1337`
   - **Currency Symbol**: `ETH`
5. Click "Save"

### 4. Import a Test Account

1. Look at the PowerShell window where you ran `.\start.ps1`
2. Find the "Account #0" section with a private key
3. Copy the private key (starts with `0x`)
4. In MetaMask, click the account icon → "Import Account"
5. Paste the private key and click "Import"
6. You should now see 10,000 ETH (minus a bit for gas)

### 5. Start Using the DEX

The browser should open automatically to `http://localhost:5173` or `http://localhost:3000`.

1. Click "Connect Wallet"
2. Select MetaMask and approve the connection
3. Start swapping tokens or adding liquidity!

### 6. Stopping the Application

When you're done, you can stop all services:

**Option 1:** In the PowerShell window where `start.ps1` is running, press `Ctrl+C`

**Option 2:** Open a new PowerShell window in the project directory and run:
```powershell
.\stop.ps1
```

## Manual Setup (Alternative)

If you prefer more control or want to run each component separately:

### Step 1: Install Dependencies

```powershell
# Run the setup script
.\setup.ps1
```

Or manually:
```powershell
# Install smart contract dependencies
npm install

# Install frontend dependencies
cd frontend
npm install
cd ..
```

### Step 2: Start Blockchain (Terminal 1)

Open a PowerShell window:

```powershell
npx hardhat node
```

**Keep this window open!** You'll see 20 test accounts with their private keys.

### Step 3: Deploy Contracts (Terminal 2)

Open a new PowerShell window:

```powershell
npx hardhat run scripts/deploy.js --network localhost
```

You should see output showing the deployed contract addresses.

### Step 4: Distribute Tokens (Terminal 2)

In the same PowerShell window:

```powershell
npx hardhat run scripts/distribute-tokens.js --network localhost
```

This distributes test tokens to the first 10 accounts.

### Step 5: Start Frontend (Terminal 3)

Open a third PowerShell window:

```powershell
cd frontend
npm run dev
```

The frontend will start on `http://localhost:5173` or `http://localhost:3000`.

## Troubleshooting

### "Execution Policy" Error

If you see an error about execution policy when running `.ps1` scripts:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then try running the script again.

### "Cannot find module" Error

Make sure you've installed dependencies:

```powershell
.\setup.ps1
```

### "Port already in use" Error

If you see errors about ports 8545, 3000, or 5173 being in use:

1. Stop any running services:
   ```powershell
   .\stop.ps1
   ```

2. Or manually find and kill the process:
   ```powershell
   # Find process on port 8545
   Get-NetTCPConnection -LocalPort 8545 | Select-Object -ExpandProperty OwningProcess
   
   # Kill the process (replace <PID> with the process ID)
   Stop-Process -Id <PID> -Force
   ```

### MetaMask "Nonce too high" Error

This happens when you restart the blockchain but MetaMask still has old transaction history:

1. Open MetaMask
2. Go to Settings → Advanced
3. Click "Clear activity tab data"
4. Try your transaction again

### Changes Not Reflecting in Frontend

The frontend uses Vite with hot module reload, but sometimes you need to:

1. Press `Ctrl+C` in the frontend terminal
2. Run `npm run dev` again
3. Hard refresh your browser (Ctrl+F5)

### Blockchain State Reset

Each time you restart the Hardhat node (`npx hardhat node`), the blockchain state resets. You'll need to:

1. Redeploy contracts
2. Clear MetaMask activity data
3. Reimport accounts if needed

## Tips for Windows Users

1. **Use Windows Terminal**: Windows Terminal (available from Microsoft Store) provides a better PowerShell experience with tabs and better colors.

2. **Keep Scripts Running**: The `start.ps1` script runs multiple services in the background. You can view logs at any time by keeping the PowerShell window open.

3. **Administrative Rights**: You don't need administrator rights to run the DEX, but some antivirus software may flag Node.js processes. Add exceptions if needed.

4. **WSL Alternative**: If you prefer, you can also run this project in WSL (Windows Subsystem for Linux) using the Linux instructions.

5. **File Paths**: PowerShell uses backslashes (`\`) for paths, but forward slashes (`/`) also work in most cases.

## Common PowerShell Commands

```powershell
# List files in current directory
ls

# Change directory
cd folder-name

# Go up one directory
cd ..

# View file contents
Get-Content filename.txt

# Clear screen
cls

# Stop a running command
Ctrl+C
```

## Development Workflow on Windows

### Making Contract Changes

1. Stop all services (Ctrl+C or `.\stop.ps1`)
2. Edit contract files in `contracts/` directory
3. Restart everything: `.\start.ps1`
4. Clear MetaMask activity data
5. Refresh your browser

### Making Frontend Changes

1. Edit files in `frontend/src/`
2. Vite will automatically reload the page
3. No need to restart the server

## Getting Help

- **Documentation**: See the `docs/` folder for detailed guides
- **Issues**: Check existing issues or open a new one on GitHub
- **Common Problems**: See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

## Next Steps

Once you have the DEX running:

1. Try swapping tokens
2. Add liquidity to the pool
3. Remove liquidity and see the fees you earned
4. Experiment with different amounts to see price impact
5. Deploy to a testnet (Sepolia, Goerli)

## Security Note

⚠️ **This is a development environment for learning purposes.**

- Never use real mainnet Ether or tokens
- The test accounts and private keys are publicly known
- Always use testnets for learning
- Get your code audited before deploying to mainnet

---

Happy trading on Windows! 🦄💰

If you have any issues with these scripts, please open an issue on GitHub.
