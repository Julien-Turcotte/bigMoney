# Troubleshooting Guide

Solutions to common issues when developing and using MiniUniswap DEX.

## Table of Contents

- [Wallet Connection Issues](#wallet-connection-issues)
- [Transaction Failures](#transaction-failures)
- [Smart Contract Issues](#smart-contract-issues)
- [Frontend Issues](#frontend-issues)
- [Network Issues](#network-issues)
- [Build and Installation Issues](#build-and-installation-issues)

---

## Wallet Connection Issues

### MetaMask Not Detected

**Symptom:** "MetaMask not installed" error

**Solutions:**
1. Install MetaMask browser extension from https://metamask.io/
2. Refresh the page after installation
3. Check if using supported browser (Chrome, Firefox, Edge, Brave)
4. Disable conflicting extensions

**Code Check:**
```javascript
if (typeof window.ethereum === 'undefined') {
  console.error('MetaMask not detected');
}
```

### Connection Rejected

**Symptom:** "User rejected the request"

**Solutions:**
1. Click "Connect Wallet" again
2. In MetaMask, approve the connection request
3. Check MetaMask is unlocked
4. Try clearing MetaMask cache

### Wrong Network

**Symptom:** Connected but can't interact with contracts

**Solutions:**
1. Check MetaMask network (should match deployment)
2. For local development: 
   - Network Name: Hardhat Local
   - RPC URL: http://127.0.0.1:8545
   - Chain ID: 1337
3. For testnet, select correct network from dropdown

**Add Network in MetaMask:**
```
Settings → Networks → Add Network → Add a network manually
```

### Account Switched Mid-Session

**Symptom:** Balances showing zero after switching accounts

**Solution:** Refresh the page or disconnect and reconnect wallet

---

## Transaction Failures

### "Transaction Underpriced"

**Symptom:** Transaction fails with gas price error

**Solutions:**
1. Increase gas price in MetaMask (Advanced)
2. Wait for network congestion to clear
3. For local development, restart Hardhat node

### "Nonce Too High"

**Symptom:** Can't send transactions, nonce mismatch

**Solutions:**
1. **Best Fix:** Clear activity data in MetaMask
   - Settings → Advanced → Clear activity tab data
2. Restart Hardhat node (for local dev)
3. Wait for pending transactions to confirm

### "Insufficient Funds"

**Symptom:** Transaction fails due to lack of ETH

**Solutions:**
1. Check ETH balance (need for gas fees)
2. For local: Import account from Hardhat node
3. For testnet: Get ETH from faucet
4. Reduce transaction amount
5. Lower gas limit if too high

### "Slippage Too High"

**Symptom:** "Slippage too high" error when swapping

**Solutions:**
1. Increase slippage tolerance (try 1% or 2%)
2. Reduce swap amount (less price impact)
3. Wait for price to stabilize
4. Add more liquidity to pool

**Example:**
```javascript
// Increase slippage from 0.5% to 1%
setSlippage(1.0);
```

### "Insufficient Liquidity"

**Symptom:** Can't swap, "Insufficient liquidity" error

**Solutions:**
1. Add liquidity to the pool first
2. Check pool has both tokens
3. Verify contract addresses are correct
4. Restart local node if using localhost

### "Execution Reverted"

**Symptom:** Generic transaction failure

**Common Causes:**
1. Token not approved
2. Insufficient balance
3. Slippage exceeded
4. Pool reserves are zero
5. Invalid amount (e.g., zero or negative)

**Solutions:**
1. Check error message for specific issue
2. Approve tokens before swapping
3. Verify balances
4. Add liquidity if pool is empty

---

## Smart Contract Issues

### Contracts Not Deployed

**Symptom:** "Contract not found" or calls fail

**Solutions:**
1. Deploy contracts: `npx hardhat run scripts/deploy.js --network localhost`
2. Check `deployments.json` has correct addresses
3. Verify Hardhat node is running
4. Restart Hardhat node and redeploy

### Contract Addresses Don't Match

**Symptom:** Transactions sent to wrong contract

**Solutions:**
1. Check `frontend/src/utils/deployments.json`
2. Redeploy contracts if addresses don't match
3. Clear browser cache
4. Restart frontend dev server

### "Invalid Token" Error

**Symptom:** Swap fails with invalid token error

**Solutions:**
1. Verify token addresses in deployments.json
2. Check using correct tokens for the pool
3. Redeploy if token addresses changed

### No Test Tokens

**Symptom:** Token balance is zero

**Solutions:**
1. Run distribute script: 
   ```bash
   npx hardhat run scripts/distribute-tokens.js --network localhost
   ```
2. Or manually mint tokens:
   ```bash
   npx hardhat console --network localhost
   ```
   ```javascript
   const token = await ethers.getContractAt("TestToken", "TOKEN_ADDRESS");
   await token.mint("YOUR_ADDRESS", ethers.parseEther("1000"));
   ```

---

## Frontend Issues

### "Cannot Read Properties of Undefined"

**Symptom:** JavaScript errors in console

**Solutions:**
1. Check wallet is connected
2. Verify contracts are deployed
3. Check deployments.json exists and has addresses
4. Add null checks:
   ```javascript
   if (!account) return;
   if (!contracts.dex) return;
   ```

### Output Amount Shows "0.0"

**Symptom:** Swap output not calculating

**Solutions:**
1. Check pool has liquidity
2. Verify getAmountOut is working:
   ```javascript
   const output = await dex.getAmountOut(input, reserve0, reserve1);
   console.log("Output:", ethers.formatEther(output));
   ```
3. Check reserves are > 0
4. Wait for debounce (500ms)

### Balance Not Updating

**Symptom:** Balance doesn't change after transaction

**Solutions:**
1. Wait for transaction confirmation
2. Manually refresh balance:
   ```javascript
   await loadBalance();
   ```
3. Reload page
4. Check transaction was successful on Etherscan

### "MAX" Button Not Working

**Symptom:** Clicking MAX doesn't set full balance

**Solutions:**
1. Check balance is loaded:
   ```javascript
   console.log("Balance:", balance);
   ```
2. Verify balance state is updated
3. Check input accepts the value

### UI Not Responsive

**Symptom:** Clicks not registering, UI frozen

**Solutions:**
1. Check browser console for errors
2. Verify no infinite loops
3. Check MetaMask isn't blocking
4. Refresh page
5. Clear browser cache

---

## Network Issues

### "Network Error" or "Failed to Fetch"

**Symptom:** Can't connect to blockchain

**Solutions:**
1. Check Hardhat node is running (local)
2. Verify RPC URL is correct
3. Check internet connection
4. Try different RPC provider
5. Check firewall isn't blocking

### RPC Rate Limit Exceeded

**Symptom:** "429 Too Many Requests"

**Solutions:**
1. Use your own RPC endpoint (Infura/Alchemy)
2. Add delays between requests
3. Cache data when possible
4. Use WebSocket instead of HTTP

### Hardhat Node Crashes

**Symptom:** Local network stops responding

**Solutions:**
1. Restart node: Stop (Ctrl+C) and run `npx hardhat node`
2. Clear cache: `rm -rf cache artifacts`
3. Redeploy contracts
4. Clear MetaMask activity data

### Chain ID Mismatch

**Symptom:** "Chain ID mismatch" error

**Solutions:**
1. Check MetaMask network matches deployment
2. Verify chainId in code:
   ```javascript
   const network = await provider.getNetwork();
   console.log("Chain ID:", network.chainId);
   ```
3. Update hardhat.config.js if needed

---

## Build and Installation Issues

### "Cannot Find Module"

**Symptom:** Import errors

**Solutions:**
1. Install dependencies:
   ```bash
   npm install
   ```
2. Check package.json has all dependencies
3. Delete node_modules and reinstall:
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

### Vite Build Fails

**Symptom:** `npm run build` errors

**Solutions:**
1. Check Node.js version (16+):
   ```bash
   node --version
   ```
2. Clear Vite cache:
   ```bash
   rm -rf node_modules/.vite
   ```
3. Update dependencies:
   ```bash
   npm update
   ```

### Hardhat Compilation Errors

**Symptom:** `npx hardhat compile` fails

**Solutions:**
1. Check Solidity version matches
2. Install OpenZeppelin:
   ```bash
   npm install @openzeppelin/contracts
   ```
3. Clear cache:
   ```bash
   npx hardhat clean
   ```
4. Check imports are correct

### "Cannot Download Solidity Compiler"

**Symptom:** Hardhat can't download compiler

**Solutions:**
1. Check internet connection
2. Use VPN if blocked
3. Install solc locally:
   ```bash
   npm install solc@0.8.20
   ```
4. Wait and retry (server might be down)

---

## Gas and Performance Issues

### High Gas Costs

**Symptom:** Transactions too expensive

**Solutions:**
1. Wait for lower gas prices
2. Use L2 network (Polygon, Arbitrum)
3. Batch transactions if possible
4. Optimize contract calls

### Slow Transaction Confirmation

**Symptom:** Transaction pending for long time

**Solutions:**
1. Check gas price is competitive
2. Use "Fast" gas option in MetaMask
3. Speed up transaction in MetaMask
4. For local: Check node is auto-mining

### Out of Gas

**Symptom:** "Out of gas" error

**Solutions:**
1. Increase gas limit in MetaMask
2. Check transaction isn't failing for other reasons
3. Simplify transaction if possible

---

## Data Issues

### Reserves Showing Zero

**Symptom:** Pool reserves are 0

**Solutions:**
1. Add initial liquidity to pool
2. Check getReserves is working:
   ```javascript
   const [r0, r1] = await dex.getReserves();
   console.log("Reserves:", r0, r1);
   ```
3. Verify contract address is correct

### LP Token Balance Not Showing

**Symptom:** LP balance is 0 after adding liquidity

**Solutions:**
1. Wait for transaction confirmation
2. Check transaction succeeded
3. Refresh balance:
   ```javascript
   const balance = await dex.balanceOf(account);
   ```
4. Verify LP tokens were minted (check transaction logs)

---

## Development Issues

### Hot Reload Not Working

**Symptom:** Changes not reflecting in browser

**Solutions:**
1. Check Vite dev server is running
2. Save file (Ctrl+S / Cmd+S)
3. Manually refresh browser
4. Restart dev server

### ESLint Errors

**Symptom:** Linting errors in code

**Solutions:**
1. Fix errors shown
2. Disable rule temporarily:
   ```javascript
   /* eslint-disable-next-line */
   ```
3. Update .eslintrc if needed

### Git Issues

**Symptom:** Can't push/pull

**Solutions:**
1. Check .gitignore includes:
   ```
   node_modules/
   .env
   cache/
   artifacts/
   ```
2. Don't commit large files
3. Use Git LFS for large files if needed

---

## Getting More Help

### Debug Checklist

When asking for help, provide:
- [ ] Error message (exact text)
- [ ] What you were trying to do
- [ ] Network (local/testnet/mainnet)
- [ ] Browser console logs
- [ ] Transaction hash (if applicable)
- [ ] Node.js and npm versions

### Useful Commands

```bash
# Check versions
node --version
npm --version
npx hardhat --version

# Clean and rebuild
rm -rf node_modules package-lock.json
npm install
npx hardhat clean
npx hardhat compile

# Reset everything (local)
# Stop hardhat node
rm -rf cache artifacts
npx hardhat node  # restart
# Redeploy contracts
# Clear MetaMask activity data
```

### Logging for Debug

Add detailed logging:

```javascript
console.log("Account:", account);
console.log("Balance:", balance);
console.log("Reserves:", reserves);
console.log("Amount in:", amountIn);
console.log("Amount out:", amountOut);

try {
  const tx = await contract.swap(...);
  console.log("Transaction:", tx.hash);
  const receipt = await tx.wait();
  console.log("Receipt:", receipt);
} catch (error) {
  console.error("Full error:", error);
  console.error("Error message:", error.message);
  console.error("Error code:", error.code);
}
```

### Resources

- [Hardhat Documentation](https://hardhat.org/docs)
- [Ethers.js Docs](https://docs.ethers.org/)
- [MetaMask Support](https://support.metamask.io/)
- [OpenZeppelin Forum](https://forum.openzeppelin.com/)
- [Ethereum Stack Exchange](https://ethereum.stackexchange.com/)

---

## Still Having Issues?

1. Check [Architecture docs](./ARCHITECTURE.md) for system understanding
2. Review [API docs](./API.md) for contract functions
3. Read [Quick Start](./QUICKSTART.md) again
4. Search existing GitHub issues
5. Open a new issue with detailed information

Remember: Most issues are configuration problems. Double-check addresses, networks, and dependencies!
