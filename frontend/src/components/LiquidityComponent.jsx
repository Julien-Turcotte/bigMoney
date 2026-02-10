import React, { useState, useEffect } from 'react';
import {
  getDexContract,
  getTokenContract,
  parseTokenAmount,
  formatTokenAmount,
  calculateMinimumAmount
} from '../utils/web3';
import deployments from '../utils/deployments.json';

const LiquidityComponent = ({ account }) => {
  const [tab, setTab] = useState('add'); // 'add' or 'remove'
  const [amount0, setAmount0] = useState('');
  const [amount1, setAmount1] = useState('');
  const [lpAmount, setLpAmount] = useState('');
  const [slippage, setSlippage] = useState(0.5);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [reserves, setReserves] = useState({ reserve0: '0', reserve1: '0' });
  const [lpBalance, setLpBalance] = useState('0');
  const [token0Balance, setToken0Balance] = useState('0');
  const [token1Balance, setToken1Balance] = useState('0');

  useEffect(() => {
    if (account) {
      loadData();
    }
  }, [account]);

  const loadData = async () => {
    try {
      const dexContract = await getDexContract();
      const token0Contract = await getTokenContract(deployments.tokenA);
      const token1Contract = await getTokenContract(deployments.tokenB);

      // Get reserves
      const [r0, r1] = await dexContract.getReserves();
      setReserves({
        reserve0: formatTokenAmount(r0),
        reserve1: formatTokenAmount(r1)
      });

      // Get balances
      const lpBal = await dexContract.balanceOf(account);
      setLpBalance(formatTokenAmount(lpBal));

      const t0Bal = await token0Contract.balanceOf(account);
      setToken0Balance(formatTokenAmount(t0Bal));

      const t1Bal = await token1Contract.balanceOf(account);
      setToken1Balance(formatTokenAmount(t1Bal));
    } catch (err) {
      console.error('Error loading data:', err);
    }
  };

  const calculateToken1Amount = () => {
    if (!amount0 || parseFloat(amount0) <= 0) {
      setAmount1('');
      return;
    }

    const r0 = parseFloat(reserves.reserve0);
    const r1 = parseFloat(reserves.reserve1);

    if (r0 > 0 && r1 > 0) {
      const calculatedAmount1 = (parseFloat(amount0) * r1) / r0;
      setAmount1(calculatedAmount1.toFixed(6));
    }
  };

  useEffect(() => {
    if (tab === 'add' && amount0) {
      calculateToken1Amount();
    }
  }, [amount0, reserves, tab]);

  const handleAddLiquidity = async () => {
    setError('');
    setSuccess('');
    setLoading(true);

    try {
      if (!amount0 || !amount1 || parseFloat(amount0) <= 0 || parseFloat(amount1) <= 0) {
        throw new Error('Please enter valid amounts');
      }

      if (parseFloat(amount0) > parseFloat(token0Balance)) {
        throw new Error('Insufficient Token A balance');
      }

      if (parseFloat(amount1) > parseFloat(token1Balance)) {
        throw new Error('Insufficient Token B balance');
      }

      const dexContract = await getDexContract();
      const token0Contract = await getTokenContract(deployments.tokenA);
      const token1Contract = await getTokenContract(deployments.tokenB);

      const amt0 = parseTokenAmount(amount0);
      const amt1 = parseTokenAmount(amount1);
      const amt0Min = calculateMinimumAmount(amt0, slippage);
      const amt1Min = calculateMinimumAmount(amt1, slippage);

      // Approve tokens
      const allowance0 = await token0Contract.allowance(account, deployments.dex);
      if (allowance0 < amt0) {
        const approve0Tx = await token0Contract.approve(deployments.dex, amt0);
        await approve0Tx.wait();
      }

      const allowance1 = await token1Contract.allowance(account, deployments.dex);
      if (allowance1 < amt1) {
        const approve1Tx = await token1Contract.approve(deployments.dex, amt1);
        await approve1Tx.wait();
      }

      // Add liquidity
      const tx = await dexContract.addLiquidity(amt0, amt1, amt0Min, amt1Min);
      await tx.wait();

      setSuccess('Liquidity added successfully!');
      setAmount0('');
      setAmount1('');
      loadData();
    } catch (err) {
      setError(err.message || 'Failed to add liquidity');
    } finally {
      setLoading(false);
    }
  };

  const handleRemoveLiquidity = async () => {
    setError('');
    setSuccess('');
    setLoading(true);

    try {
      if (!lpAmount || parseFloat(lpAmount) <= 0) {
        throw new Error('Please enter a valid LP amount');
      }

      if (parseFloat(lpAmount) > parseFloat(lpBalance)) {
        throw new Error('Insufficient LP token balance');
      }

      const dexContract = await getDexContract();
      const lpAmt = parseTokenAmount(lpAmount);

      // Calculate minimum amounts (with slippage)
      const totalSupply = await dexContract.totalSupply();
      const [r0, r1] = await dexContract.getReserves();
      
      const amount0Expected = (lpAmt * r0) / totalSupply;
      const amount1Expected = (lpAmt * r1) / totalSupply;
      
      const amount0Min = calculateMinimumAmount(amount0Expected, slippage);
      const amount1Min = calculateMinimumAmount(amount1Expected, slippage);

      // Remove liquidity
      const tx = await dexContract.removeLiquidity(lpAmt, amount0Min, amount1Min);
      await tx.wait();

      setSuccess('Liquidity removed successfully!');
      setLpAmount('');
      loadData();
    } catch (err) {
      setError(err.message || 'Failed to remove liquidity');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="card">
      <h2>Liquidity Pool</h2>

      <div className="pool-info">
        <div className="pool-info-item">
          <h3>Token A Reserve</h3>
          <p>{parseFloat(reserves.reserve0).toFixed(2)}</p>
        </div>
        <div className="pool-info-item">
          <h3>Token B Reserve</h3>
          <p>{parseFloat(reserves.reserve1).toFixed(2)}</p>
        </div>
        <div className="pool-info-item">
          <h3>Your LP Tokens</h3>
          <p>{parseFloat(lpBalance).toFixed(4)}</p>
        </div>
      </div>

      {error && <div className="error">{error}</div>}
      {success && <div className="success">{success}</div>}

      <div className="tabs" style={{ marginTop: '20px' }}>
        <button
          className={`tab-button ${tab === 'add' ? 'active' : ''}`}
          onClick={() => setTab('add')}
        >
          Add Liquidity
        </button>
        <button
          className={`tab-button ${tab === 'remove' ? 'active' : ''}`}
          onClick={() => setTab('remove')}
        >
          Remove Liquidity
        </button>
      </div>

      {tab === 'add' ? (
        <>
          <div className="input-group">
            <label>Token A Amount (Balance: {parseFloat(token0Balance).toFixed(4)})</label>
            <div className="input-wrapper">
              <input
                type="number"
                value={amount0}
                onChange={(e) => setAmount0(e.target.value)}
                placeholder="0.0"
                disabled={loading}
              />
              <button 
                className="max-button" 
                onClick={() => setAmount0(token0Balance)}
                disabled={loading}
              >
                MAX
              </button>
            </div>
          </div>

          <div className="input-group">
            <label>Token B Amount (Balance: {parseFloat(token1Balance).toFixed(4)})</label>
            <div className="input-wrapper">
              <input
                type="number"
                value={amount1}
                onChange={(e) => setAmount1(e.target.value)}
                placeholder="0.0"
                disabled={loading}
              />
            </div>
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
            onClick={handleAddLiquidity}
            disabled={loading || !amount0 || !amount1 || !account}
          >
            {loading ? 'Adding Liquidity...' : 'Add Liquidity'}
          </button>
        </>
      ) : (
        <>
          <div className="input-group">
            <label>LP Token Amount (Balance: {parseFloat(lpBalance).toFixed(4)})</label>
            <div className="input-wrapper">
              <input
                type="number"
                value={lpAmount}
                onChange={(e) => setLpAmount(e.target.value)}
                placeholder="0.0"
                disabled={loading}
              />
              <button 
                className="max-button" 
                onClick={() => setLpAmount(lpBalance)}
                disabled={loading}
              >
                MAX
              </button>
            </div>
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
            onClick={handleRemoveLiquidity}
            disabled={loading || !lpAmount || !account}
          >
            {loading ? 'Removing Liquidity...' : 'Remove Liquidity'}
          </button>
        </>
      )}
    </div>
  );
};

export default LiquidityComponent;
