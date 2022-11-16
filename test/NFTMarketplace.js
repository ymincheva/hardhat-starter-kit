const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('NFTMarketplace', function () {
  let NFTMarketplace, nFTMarketplace, nftContractAddress, ownerSigner, secondNFTSigner;

  before(async function () {
    /* deploy the NFTMarketplace contract */
    NFTMarketplace = await ethers.getContractFactory('NFTMarketplace');
    nFTMarketplace = await NNFTMarketplace.deploy();
    await nft.deployed();
    nftContractAddress = nft.address;
    /* Get users */
    [ownerSigner, secondNFTSigner, ...otherSigners] = await ethers.getSigners();
  });
});
