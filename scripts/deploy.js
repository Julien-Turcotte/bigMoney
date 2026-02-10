import hre from "hardhat";
import fs from "fs";

async function main() {
  console.log("Deploying contracts...");

  // Deploy test tokens
  const TestToken = await hre.ethers.getContractFactory("TestToken");
  
  console.log("Deploying TokenA...");
  const tokenA = await TestToken.deploy("Token A", "TKA", 1000000);
  await tokenA.waitForDeployment();
  const tokenAAddress = await tokenA.getAddress();
  console.log("TokenA deployed to:", tokenAAddress);

  console.log("Deploying TokenB...");
  const tokenB = await TestToken.deploy("Token B", "TKB", 1000000);
  await tokenB.waitForDeployment();
  const tokenBAddress = await tokenB.getAddress();
  console.log("TokenB deployed to:", tokenBAddress);

  // Deploy DEX
  console.log("Deploying MiniUniswap DEX...");
  const MiniUniswap = await hre.ethers.getContractFactory("MiniUniswap");
  const dex = await MiniUniswap.deploy(tokenAAddress, tokenBAddress);
  await dex.waitForDeployment();
  const dexAddress = await dex.getAddress();
  console.log("MiniUniswap DEX deployed to:", dexAddress);

  // Save deployment addresses
  const deploymentInfo = {
    tokenA: tokenAAddress,
    tokenB: tokenBAddress,
    dex: dexAddress,
    network: hre.network.name,
    chainId: hre.network.config.chainId
  };

  fs.writeFileSync(
    "./frontend/src/utils/deployments.json",
    JSON.stringify(deploymentInfo, null, 2)
  );

  console.log("\nDeployment complete!");
  console.log("Deployment info saved to frontend/src/utils/deployments.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
