import React, { useState, useEffect } from 'react';
import {
  getDexContract,
  getTokenContract,
  parseTokenAmount,
  formatTokenAmount,
  calculateMinimumAmount
} from '../utils/web3';
import deployments from '../utils/deployments.json';

const SwapComponent = ({ account }) => {
  const [fromToken, setFromToken] = useState(deployments.tokenA);
  const [toToken, setToToken] = useState(deployments.tokenB);
  const [fromAmount, setFromAmount] = useState('');
  const [toAmount, setToAmount] = useState('');
  const [slippage, setSlippage] = useState(0.5);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [balance, setBalance] = useState('0');

  useEffect(() => {
    if (account && fromToken) {
      loadBalance();
    }
  }, [account, fromToken]);

  const loadBalance = async () => {
    try {
      const tokenContract = await getTokenContract(fromToken);
      const bal = await tokenContract.balanceOf(account);
      setBalance(formatTokenAmount(bal));
    } catch (err) {
      console.error('Error loading balance:', err);
    }
  };

  const calculateOutputAmount = async () => {
    if (!fromAmount || parseFloat(fromAmount) <= 0) {
      setToAmount('');
      return;
    }

    try {
      const dexContract = await getDexContract();
      const reserves = await dexContract.getReserves();
      
      const isToken0 = fromToken.toLowerCase() === deployments.tokenA.toLowerCase();
      const reserveIn = isToken0 ? reserves[0] : reserves[1];
      const reserveOut = isToken0 ? reserves[1] : reserves[0];

      const amountIn = parseTokenAmount(fromAmount);
      const amountOut = await dexContract.getAmountOut(amountIn, reserveIn, reserveOut);
      
      setToAmount(formatTokenAmount(amountOut));
    } catch (err) {
      console.error('Error calculating output:', err);
      setToAmount('0');
    }
  };

  useEffect(() => {
    const timer = setTimeout(() => {
      if (fromAmount) {
        calculateOutputAmount();
      }
    }, 500);
    return () => clearTimeout(timer);
  }, [fromAmount, fromToken, toToken, account]);

  const handleSwap = async () => {
    setError('');
    setSuccess('');
    setLoading(true);

    try {
      // Validate inputs
      if (!fromAmount || parseFloat(fromAmount) <= 0) {
        throw new Error('Please enter a valid amount');
      }

      if (parseFloat(fromAmount) > parseFloat(balance)) {
        throw new Error('Insufficient balance');
      }

      const dexContract = await getDexContract();
      const tokenContract = await getTokenContract(fromToken);
      
      const amountIn = parseTokenAmount(fromAmount);
      const amountOutMin = calculateMinimumAmount(
        parseTokenAmount(toAmount),
        slippage
      );

      // Approve tokens
      const allowance = await tokenContract.allowance(account, deployments.dex);
      if (allowance < amountIn) {
        const approveTx = await tokenContract.approve(deployments.dex, amountIn);
        await approveTx.wait();
      }

      // Execute swap
      const swapTx = await dexContract.swap(fromToken, amountIn, amountOutMin);
      await swapTx.wait();

      setSuccess('Swap successful!');
      setFromAmount('');
      setToAmount('');
      loadBalance();
    } catch (err) {
      setError(err.message || 'Swap failed');
    } finally {
      setLoading(false);
    }
  };

  const switchTokens = () => {
    setFromToken(toToken);
    setToToken(fromToken);
    setFromAmount(toAmount);
    setToAmount('');
  };

  const setMaxAmount = () => {
    setFromAmount(balance);
  };

  return (
    <div className="card">
      <h2>Swap Tokens</h2>
      
      {error && <div className="error">{error}</div>}
      {success && <div className="success">{success}</div>}

      <div className="input-group">
        <label>From</label>
        <select 
          value={fromToken} 
          onChange={(e) => setFromToken(e.target.value)}
          disabled={loading}
        >
          <option value={deployments.tokenA}>Token A</option>
          <option value={deployments.tokenB}>Token B</option>
        </select>
      </div>

      <div className="input-group">
        <label>Amount (Balance: {parseFloat(balance).toFixed(4)})</label>
        <div className="input-wrapper">
          <input
            type="number"
            value={fromAmount}
            onChange={(e) => setFromAmount(e.target.value)}
            placeholder="0.0"
            disabled={loading}
          />
          <button className="max-button" onClick={setMaxAmount} disabled={loading}>
            MAX
          </button>
        </div>
      </div>

      <div style={{ textAlign: 'center', margin: '10px 0' }}>
        <button onClick={switchTokens} disabled={loading}>
          ⇅ Switch
        </button>
      </div>

      <div className="input-group">
        <label>To</label>
        <select 
          value={toToken} 
          onChange={(e) => setToToken(e.target.value)}
          disabled={loading}
        >
          <option value={deployments.tokenA}>Token A</option>
          <option value={deployments.tokenB}>Token B</option>
        </select>
      </div>

      <div className="input-group">
        <label>You will receive (estimated)</label>
        <input
          type="text"
          value={toAmount ? parseFloat(toAmount).toFixed(6) : '0.0'}
          readOnly
          disabled
        />
      </div>

      <div className="slippage-section">
        <label>Slippage Tolerance</label>
        <div className="slippage-options">
          {[0.1, 0.5, 1.0, 2.0].map((value) => (
            <div
              key={value}
              className={`slippage-option ${slippage === value ? 'active' : ''}`}
              onClick={() => setSlippage(value)}
            >
              {value}%
            </div>
          ))}
        </div>
      </div>

      <button 
        className="submit-button"
        onClick={handleSwap}
        disabled={loading || !fromAmount || !account}
      >
        {loading ? 'Swapping...' : 'Swap'}
      </button>
    </div>
  );
};

export default SwapComponent;
