const { time, loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs');
const { expect } = require('chai');
const { expectRevert } = require('@openzeppelin/test-helpers');

describe('NFTMarketplace', function () {
  let marketItemContract;

  async function deploy() {
    const [owner] = await ethers.getSigners();

    const MarketItem = await hre.ethers.getContractFactory('MarketItem');
    const marketItem = await MarketItem.deploy();

    const NFTMarketplace = await ethers.getContractFactory('NFTMarketplace');
    const nftMarketplace = await NFTMarketplace.deploy(marketItem.address);

    return { nftMarketplace, marketItem, owner };
  }

  describe('Deployment', function () {
    it('Should set the right owner', async function () {
      const { nftMarketplace, owner } = await loadFixture(deploy);

      expect(await nftMarketplace.owner()).to.equal(owner.address);
    });
  });

  describe('Make Offer', () => {
    it('NFT has to be approval', async () => {
      const { nftMarketplace, marketItem } = await loadFixture(deploy);
      //const event = result.logs[0].args;
      //  const tokenId = event.tokenId.toNumber();
      expect(await marketItem.ownerOf(1)).to.equal(marketItem.getApproved(1));
    });
  });
});
