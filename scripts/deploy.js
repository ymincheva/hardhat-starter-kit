const hre = require('hardhat');

async function main() {
  const MarketItem = await hre.ethers.getContractFactory('MarketItem');
  const marketItem = await MarketItem.deploy();

  await marketItem.deployed();

  console.log(`Contract is deployed to marketItem ${marketItem.address}`);

  const NFTMarketplace = await hre.ethers.getContractFactory('NFTMarketplace');
  const nftMarketplace = await NFTMarketplace.deploy(marketItem.address);

  await nftMarketplace.deployed();

  console.log(`Contract is deployed to ${nftMarketplace.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
