# Frontend Development Guide

Guide for understanding and extending the MiniUniswap frontend.

## Tech Stack

- **React 19**: UI framework
- **Vite 7**: Build tool and dev server
- **Ethers.js v6**: Ethereum library
- **CSS3**: Styling (no frameworks)

## Project Structure

```
frontend/
├── src/
│   ├── components/
│   │   ├── SwapComponent.jsx       # Token swap interface
│   │   └── LiquidityComponent.jsx  # Liquidity management
│   ├── utils/
│   │   ├── web3.js                 # Web3 utilities
│   │   ├── MiniUniswap.json        # DEX contract ABI
│   │   ├── TestToken.json          # Token contract ABI
│   │   └── deployments.json        # Contract addresses
│   ├── App.jsx                     # Main application
│   ├── App.css                     # Global styles
│   └── main.jsx                    # Entry point
├── index.html                      # HTML template
├── vite.config.js                  # Vite configuration
└── package.json
```

## Setup

### Install Dependencies
```bash
cd frontend
npm install
```

### Start Development Server
```bash
npm run dev
```

### Build for Production
```bash
npm run build
```

### Preview Production Build
```bash
npm run preview
```

## Core Components

### App.jsx

Main application component that handles:
- Wallet connection state
- Tab navigation (Swap/Liquidity)
- Network detection
- MetaMask event listeners

**Key Features:**
```javascript
const [account, setAccount] = useState('');
const [activeTab, setActiveTab] = useState('swap');
const [chainId, setChainId] = useState(null);
```

**Event Listeners:**
```javascript
window.ethereum.on('accountsChanged', (accounts) => {
  setAccount(accounts[0] || '');
});

window.ethereum.on('chainChanged', () => {
  window.location.reload();
});
```

### SwapComponent.jsx

Handles token swapping functionality:

**State Management:**
```javascript
const [fromToken, setFromToken] = useState(tokenA);
const [toToken, setToToken] = useState(tokenB);
const [fromAmount, setFromAmount] = useState('');
const [toAmount, setToAmount] = useState('');
const [slippage, setSlippage] = useState(0.5);
```

**Key Functions:**
- `calculateOutputAmount()`: Calculates swap output
- `handleSwap()`: Executes the swap transaction
- `switchTokens()`: Switches from/to tokens
- `setMaxAmount()`: Sets input to user's full balance

**User Flow:**
1. Select input token and enter amount
2. Output amount auto-calculates (debounced 500ms)
3. Select slippage tolerance
4. Click Swap
5. Approve token (if needed)
6. Confirm swap transaction

### LiquidityComponent.jsx

Handles liquidity management:

**Two Tabs:**
1. **Add Liquidity**: Add tokens to pool
2. **Remove Liquidity**: Remove LP tokens

**State Management:**
```javascript
const [tab, setTab] = useState('add');
const [amount0, setAmount0] = useState('');
const [amount1, setAmount1] = useState('');
const [lpAmount, setLpAmount] = useState('');
const [reserves, setReserves] = useState({});
```

**Auto-Calculation:**
When adding liquidity, amount1 auto-calculates to maintain pool ratio:
```javascript
const calculatedAmount1 = (amount0 * reserve1) / reserve0;
```

## Web3 Integration

### Connection Flow

```javascript
// 1. Check if MetaMask is installed
if (typeof window.ethereum !== 'undefined') {
  // 2. Get provider
  const provider = new ethers.BrowserProvider(window.ethereum);
  
  // 3. Request account access
  await provider.send('eth_requestAccounts', []);
  
  // 4. Get signer
  const signer = await provider.getSigner();
  
  // 5. Create contract instance
  const contract = new ethers.Contract(address, abi, signer);
}
```

### Transaction Flow

**Read Operations (No gas):**
```javascript
// Get reserves
const [reserve0, reserve1] = await dexContract.getReserves();

// Get balance
const balance = await tokenContract.balanceOf(address);

// Calculate output
const output = await dexContract.getAmountOut(input, resIn, resOut);
```

**Write Operations (Requires gas):**
```javascript
// 1. Send transaction
const tx = await contract.functionName(params);

// 2. Wait for confirmation
const receipt = await tx.wait();

// 3. Transaction confirmed
console.log("Success! Block:", receipt.blockNumber);
```

### Error Handling

```javascript
try {
  const tx = await contract.swap(...);
  await tx.wait();
  setSuccess("Swap successful!");
} catch (error) {
  // User rejected transaction
  if (error.code === 'ACTION_REJECTED') {
    setError("Transaction cancelled");
  }
  // Insufficient funds
  else if (error.message.includes('insufficient funds')) {
    setError("Insufficient ETH for gas");
  }
  // Contract error
  else {
    setError(error.message);
  }
}
```

## Styling

### Design System

**Colors:**
```css
--primary: #667eea;
--primary-dark: #5568d3;
--background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
--white: #ffffff;
--gray-light: #f7f7f7;
--gray-medium: #e0e0e0;
--gray-dark: #666;
```

**Components:**
- Cards: White background, rounded corners, shadow
- Buttons: Primary color, hover effects, disabled states
- Inputs: Border on focus, consistent padding
- Responsive: Mobile-friendly breakpoints

### Responsive Design

```css
@media (max-width: 768px) {
  .header {
    flex-direction: column;
  }
  
  .wallet-address {
    font-size: 12px;
  }
}
```

## State Management

### Local State Strategy

Each component manages its own state:
- UI state (loading, errors)
- Form inputs (amounts, selections)
- Blockchain data (balances, reserves)

### Data Loading Pattern

```javascript
useEffect(() => {
  if (account) {
    loadData();
  }
}, [account]);

const loadData = async () => {
  try {
    const balance = await getBalance();
    const reserves = await getReserves();
    setState({ balance, reserves });
  } catch (error) {
    console.error(error);
  }
};
```

### Auto-Update Pattern

```javascript
// Debounced calculation
useEffect(() => {
  const timer = setTimeout(() => {
    if (amount) {
      calculateOutput();
    }
  }, 500); // Wait 500ms after user stops typing
  
  return () => clearTimeout(timer);
}, [amount]);
```

## Adding New Features

### Add a New Token Pair

1. Deploy new DEX contract for the pair
2. Update `deployments.json`:
```json
{
  "pools": [
    {
      "name": "A-B Pool",
      "dex": "0x...",
      "token0": "0x...",
      "token1": "0x..."
    },
    {
      "name": "C-D Pool",
      "dex": "0x...",
      "token0": "0x...",
      "token1": "0x..."
    }
  ]
}
```

3. Add pool selector in UI:
```javascript
const [selectedPool, setSelectedPool] = useState(0);
const pool = deployments.pools[selectedPool];
```

### Add Transaction History

1. Listen to contract events:
```javascript
const filter = dexContract.filters.Swap(account);
const events = await dexContract.queryFilter(filter);

const swaps = events.map(event => ({
  tokenIn: event.args.tokenIn,
  tokenOut: event.args.tokenOut,
  amountIn: event.args.amountIn,
  amountOut: event.args.amountOut,
  timestamp: event.blockNumber
}));
```

2. Create HistoryComponent:
```javascript
function HistoryComponent({ swaps }) {
  return (
    <div className="history">
      {swaps.map((swap, i) => (
        <div key={i} className="swap-item">
          {/* Display swap details */}
        </div>
      ))}
    </div>
  );
}
```

### Add Price Charts

Use a charting library like Chart.js or Recharts:

```javascript
import { LineChart, Line } from 'recharts';

function PriceChart({ reserves }) {
  const price = reserves[1] / reserves[0];
  
  return (
    <LineChart data={priceHistory}>
      <Line dataKey="price" />
    </LineChart>
  );
}
```

## Performance Optimization

### Debouncing User Input

```javascript
const [inputValue, setInputValue] = useState('');
const [debouncedValue, setDebouncedValue] = useState('');

useEffect(() => {
  const timer = setTimeout(() => {
    setDebouncedValue(inputValue);
  }, 500);
  
  return () => clearTimeout(timer);
}, [inputValue]);

// Use debouncedValue for calculations
useEffect(() => {
  if (debouncedValue) {
    calculate(debouncedValue);
  }
}, [debouncedValue]);
```

### Memoization

```javascript
import { useMemo } from 'react';

const expensiveCalculation = useMemo(() => {
  return complexCalculation(data);
}, [data]);
```

### Lazy Loading

```javascript
import { lazy, Suspense } from 'react';

const ChartComponent = lazy(() => import('./ChartComponent'));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <ChartComponent />
    </Suspense>
  );
}
```

## Testing

### Component Testing

```javascript
import { render, screen } from '@testing-library/react';
import SwapComponent from './SwapComponent';

test('renders swap button', () => {
  render(<SwapComponent />);
  const button = screen.getByText(/swap/i);
  expect(button).toBeInTheDocument();
});
```

### Integration Testing

```javascript
test('swap flow', async () => {
  render(<App />);
  
  // Connect wallet
  fireEvent.click(screen.getByText('Connect Wallet'));
  
  // Enter amount
  fireEvent.change(screen.getByPlaceholderText('0.0'), {
    target: { value: '10' }
  });
  
  // Click swap
  fireEvent.click(screen.getByText('Swap'));
  
  // Wait for success
  await waitFor(() => {
    expect(screen.getByText(/successful/i)).toBeInTheDocument();
  });
});
```

## Debugging

### Console Logging

```javascript
// Log transaction details
console.log('Transaction hash:', tx.hash);
console.log('Gas used:', receipt.gasUsed.toString());
console.log('Block number:', receipt.blockNumber);
```

### MetaMask Debugging

1. Open MetaMask
2. Settings → Advanced → Show test networks
3. Settings → Advanced → Clear activity tab data (reset nonce)

### Network Debugging

1. Check network in MetaMask matches expected chainId
2. Verify contract addresses in deployments.json
3. Check RPC connection: `await provider.getNetwork()`

## Common Issues

### "Nonce too high"
**Solution:** Clear MetaMask activity data

### "Transaction underpriced"
**Solution:** Increase gas price or wait

### "Cannot read properties of undefined"
**Solution:** Check wallet is connected and contracts are deployed

### Vite build errors
**Solution:** 
```bash
rm -rf node_modules package-lock.json
npm install
```

## Deployment

### Build for Production

```bash
cd frontend
npm run build
```

Output in `dist/` directory.

### Deploy to Vercel

```bash
npm install -g vercel
vercel
```

### Deploy to GitHub Pages

```bash
npm run build
npm install -g gh-pages
gh-pages -d dist
```

### Environment Variables

Create `.env` for configuration:
```
VITE_DEX_ADDRESS=0x...
VITE_TOKEN_A_ADDRESS=0x...
VITE_TOKEN_B_ADDRESS=0x...
VITE_CHAIN_ID=1337
```

Access in code:
```javascript
const dexAddress = import.meta.env.VITE_DEX_ADDRESS;
```

## Best Practices

✅ **Do:**
- Always check wallet connection before transactions
- Show loading states during async operations
- Display clear error messages
- Validate user input
- Use debouncing for calculations
- Handle all error cases

❌ **Don't:**
- Store private keys in frontend code
- Skip error handling
- Make excessive RPC calls
- Trust user input without validation
- Forget to update UI after transactions

## Resources

- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vitejs.dev/)
- [Ethers.js v6 Docs](https://docs.ethers.org/v6/)
- [MetaMask Documentation](https://docs.metamask.io/)
