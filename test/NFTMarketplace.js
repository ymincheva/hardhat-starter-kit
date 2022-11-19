const { time, loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs');
const { expect } = require('chai');
const { expectRevert } = require('@openzeppelin/test-helpers');

describe('NFTMarketplace', function () {
  async function deploy() {
    const [owner] = await ethers.getSigners();

    const MarketItem = await hre.ethers.getContractFactory('MarketItem');
    const marketItem = await MarketItem.deploy();

    const NFTMarketplace = await ethers.getContractFactory('NFTMarketplace');
    const nftMarketplace = await NFTMarketplace.deploy(marketItem.address);

    marketItem.safeMint(
      marketItem.address,
      'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json',
    );
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
      const { marketItem } = await loadFixture(deploy);

      //expect(await marketItem.ownerOf(1)).to.equal(marketItem.getApproved(1));
    });

    it('Transfers the ownership to this contract', async () => {
      const { nftMarketplace, marketItem } = await loadFixture(deploy);

      // const owner = await marketItem.ownerOf(2);
      // assert.equal(owner, nftMarketplace.address);
    });

    it('Creates an offer', async () => {
      const { nftMarketplace } = await loadFixture(deploy);

      const offer = await nftMarketplace.offers(1);

      expect(await offer.offerId.toNumber()).to.equal(0);
      expect(await offer.id.toNumber()).to.equal(0);
      // expect(await offer.user).to.equal(nftMarketplace.address);
      expect(await offer.price.toNumber()).to.equal(0);
      expect(await offer.fulfilled).to.equal(false);
      expect(await offer.cancelled).to.equal(false);
    });

    it('Emits an Event Offer', async () => {
      const { nftMarketplace, marketItem } = await loadFixture(deploy);

      //  await marketItem.approve(marketItem.address, 1);
      //  const result = await nftMarketplace.makeOffer(1, 20);

      /*
      expect(await offer.offerId.toNumber()).to.equal(0);
      expect(await offer.id.toNumber()).to.equal(0);
      // expect(await offer.user).to.equal(nftMarketplace.address);
      expect(await offer.price.toNumber()).to.equal(0);
      expect(await offer.fulfilled).to.equal(false);
      expect(await offer.cancelled).to.equal(false);
       */
    });
  });

  describe('Fill Offer', () => {
    it('fills the offer and emits Event', async () => {
      const { nftMarketplace, marketItem } = await loadFixture(deploy);

      //  const fillOffer = await nftMarketplace.fillOffer(1);
      //  const offer = await nftMarketplace.offers(1);
    });
  });

  describe('Events', function () {
    it('Should emit an event on CollectionCreated', async function () {
      const { nftMarketplace } = await loadFixture(deploy);

      await expect(nftMarketplace.createCollection('polar bear'))
        .to.emit(nftMarketplace, 'CollectionCreated')
        .withArgs(anyValue, 'polar bear');
    });
  });

  describe('Events', function () {
    it('Should emit an event on MarketNftCreated', async function () {
      const { nftMarketplace } = await loadFixture(deploy);

      await expect(
        nftMarketplace.createMarketItem(
          1,
          'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json',
        ),
      )
        .to.emit(nftMarketplace, 'MarketNftCreated')
        .withArgs(
          anyValue,
          'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json',
          anyValue,
        );
    });
  });
});
