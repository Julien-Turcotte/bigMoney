import hre from "hardhat";
import deployments from "../frontend/src/utils/deployments.json" assert { type: "json" };

async function main() {
  // Get the deployer account
  const [deployer] = await hre.ethers.getSigners();
  
  console.log("Distributing test tokens from:", deployer.address);
  console.log("");

  // Get contract instances
  const TestToken = await hre.ethers.getContractFactory("TestToken");
  const tokenA = TestToken.attach(deployments.tokenA);
  const tokenB = TestToken.attach(deployments.tokenB);

  // Get all accounts
  const accounts = await hre.ethers.getSigners();
  
  // Amount to send to each account (1000 tokens)
  const amount = hre.ethers.parseEther("1000");

  console.log("Distributing 1000 Token A and 1000 Token B to each account...");
  console.log("");

  // Send tokens to accounts 1-9 (skip 0 as it's the deployer)
  for (let i = 1; i < Math.min(accounts.length, 10); i++) {
    const account = accounts[i];
    console.log(`Sending to account ${i} (${account.address})...`);
    
    try {
      await tokenA.transfer(account.address, amount);
      await tokenB.transfer(account.address, amount);
      console.log(`✓ Sent 1000 Token A and 1000 Token B`);
    } catch (error) {
      console.log(`✗ Failed:`, error.message);
    }
  }

  console.log("");
  console.log("Distribution complete!");
  console.log("");
  console.log("Balances:");
  for (let i = 0; i < Math.min(accounts.length, 10); i++) {
    const account = accounts[i];
    const balA = await tokenA.balanceOf(account.address);
    const balB = await tokenB.balanceOf(account.address);
    console.log(
      `Account ${i}: ${hre.ethers.formatEther(balA)} Token A, ${hre.ethers.formatEther(balB)} Token B`
    );
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
