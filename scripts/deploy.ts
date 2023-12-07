import { ethers } from "hardhat";

async function main() {

  const whitelist = await ethers.deployContract("DynamicWhitelist", [["0x010149cBd3dC42860EA6901fa36328b2dfaFC3DA"]]);

  await whitelist.waitForDeployment();

  console.log("DynamicWhitelist deployed to:", await whitelist.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
