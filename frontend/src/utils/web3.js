import { ethers } from 'ethers';
import MiniUniswapABI from './MiniUniswap.json';
import TestTokenABI from './TestToken.json';
import deployments from './deployments.json';

// Get provider and signer
export const getProvider = () => {
  if (typeof window.ethereum !== 'undefined') {
    return new ethers.BrowserProvider(window.ethereum);
  }
  throw new Error('MetaMask not installed');
};

export const getSigner = async () => {
  const provider = getProvider();
  return await provider.getSigner();
};

// Contract instances
export const getDexContract = async () => {
  const signer = await getSigner();
  return new ethers.Contract(deployments.dex, MiniUniswapABI, signer);
};

export const getTokenContract = async (tokenAddress) => {
  const signer = await getSigner();
  return new ethers.Contract(tokenAddress, TestTokenABI, signer);
};

// Wallet connection
export const connectWallet = async () => {
  try {
    const provider = getProvider();
    const accounts = await provider.send('eth_requestAccounts', []);
    return accounts[0];
  } catch (error) {
    console.error('Error connecting wallet:', error);
    throw error;
  }
};

// Get account balance
export const getBalance = async (address) => {
  const provider = getProvider();
  const balance = await provider.getBalance(address);
  return ethers.formatEther(balance);
};

// Format token amount
export const formatTokenAmount = (amount, decimals = 18) => {
  return ethers.formatUnits(amount, decimals);
};

// Parse token amount
export const parseTokenAmount = (amount, decimals = 18) => {
  return ethers.parseUnits(amount.toString(), decimals);
};

// Calculate slippage
export const calculateMinimumAmount = (amount, slippagePercent) => {
  const slippageFactor = (100 - slippagePercent) / 100;
  return (BigInt(amount) * BigInt(Math.floor(slippageFactor * 100))) / BigInt(100);
};

export default {
  getProvider,
  getSigner,
  getDexContract,
  getTokenContract,
  connectWallet,
  getBalance,
  formatTokenAmount,
  parseTokenAmount,
  calculateMinimumAmount
};
