import React, { useState, useEffect } from 'react';
import './App.css';
import SwapComponent from './components/SwapComponent';
import LiquidityComponent from './components/LiquidityComponent';
import { connectWallet, getProvider } from './utils/web3';

function App() {
  const [account, setAccount] = useState('');
  const [activeTab, setActiveTab] = useState('swap');
  const [chainId, setChainId] = useState(null);

  useEffect(() => {
    checkConnection();
    setupListeners();
  }, []);

  const setupListeners = () => {
    if (typeof window.ethereum !== 'undefined') {
      window.ethereum.on('accountsChanged', (accounts) => {
        if (accounts.length > 0) {
          setAccount(accounts[0]);
        } else {
          setAccount('');
        }
      });

      window.ethereum.on('chainChanged', () => {
        window.location.reload();
      });
    }
  };

  const checkConnection = async () => {
    try {
      if (typeof window.ethereum !== 'undefined') {
        const provider = getProvider();
        const accounts = await provider.send('eth_accounts', []);
        if (accounts.length > 0) {
          setAccount(accounts[0]);
        }
        
        const network = await provider.getNetwork();
        setChainId(Number(network.chainId));
      }
    } catch (error) {
      console.error('Error checking connection:', error);
    }
  };

  const handleConnectWallet = async () => {
    try {
      const address = await connectWallet();
      setAccount(address);
      
      const provider = getProvider();
      const network = await provider.getNetwork();
      setChainId(Number(network.chainId));
    } catch (error) {
      console.error('Error connecting wallet:', error);
      alert('Failed to connect wallet. Please make sure MetaMask is installed.');
    }
  };

  const formatAddress = (address) => {
    if (!address) return '';
    return `${address.substring(0, 6)}...${address.substring(address.length - 4)}`;
  };

  return (
    <div className="container">
      <div className="header">
        <h1>🦄 MiniUniswap DEX</h1>
        <div className="wallet-section">
          {account ? (
            <>
              <div className="wallet-address">
                {formatAddress(account)}
              </div>
              <div className="wallet-address">
                Chain: {chainId || 'Unknown'}
              </div>
            </>
          ) : (
            <button onClick={handleConnectWallet}>
              Connect Wallet
            </button>
          )}
        </div>
      </div>

      {!account ? (
        <div className="card">
          <div style={{ textAlign: 'center', padding: '40px' }}>
            <h2>Welcome to MiniUniswap DEX</h2>
            <p style={{ marginBottom: '20px', color: '#666' }}>
              Connect your MetaMask wallet to start trading and providing liquidity.
            </p>
            <button onClick={handleConnectWallet}>
              Connect Wallet
            </button>
          </div>
        </div>
      ) : (
        <>
          <div className="tabs">
            <button
              className={`tab-button ${activeTab === 'swap' ? 'active' : ''}`}
              onClick={() => setActiveTab('swap')}
            >
              💱 Swap
            </button>
            <button
              className={`tab-button ${activeTab === 'liquidity' ? 'active' : ''}`}
              onClick={() => setActiveTab('liquidity')}
            >
              💧 Liquidity
            </button>
          </div>

          {activeTab === 'swap' ? (
            <SwapComponent account={account} />
          ) : (
            <LiquidityComponent account={account} />
          )}
        </>
      )}

      <div style={{ textAlign: 'center', marginTop: '20px', color: 'white' }}>
        <p>
          <strong>MiniUniswap DEX</strong> - A decentralized exchange using AMM (x*y=k)
        </p>
        <p style={{ fontSize: '14px', opacity: 0.8 }}>
          Features: Token Swapping • Liquidity Pools • LP Tokens • Fee Distribution
        </p>
      </div>
    </div>
  );
}

export default App;
