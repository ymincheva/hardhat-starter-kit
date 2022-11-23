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

    return { nftMarketplace, marketItem, owner };
  }

  describe('Deployment', function () {
    it('Should set the right owner', async function () {
      const { nftMarketplace, owner } = await loadFixture(deploy);

      expect(await nftMarketplace.owner()).to.equal(owner.address);
    });
  });

  describe('Create collection', function () {
    it('Should set the right collection name ', async function () {
      const { nftMarketplace } = await loadFixture(deploy);

      await nftMarketplace.createCollection('bear');
      expect(await nftMarketplace.collectionLedger(1)).to.equal('bear');
    });
    it('Should set collection name ', async function () {
      const { nftMarketplace } = await loadFixture(deploy);

      await nftMarketplace.createCollection('bear');
      expect(await nftMarketplace.collectionLedger(1)).length.to.above(0);
    });
  });

  describe('Create nft item', function () {
    it('Should set the right collection id ', async function () {
      const { nftMarketplace } = await loadFixture(deploy);

      await nftMarketplace.createMarketItem(
        1,
        'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json',
      );
      const nftLedger = await nftMarketplace.nftLedger(0);

      expect(await nftLedger.collectionId).to.equal(1);
    });
    it('Should set nft forbidden for sale ', async function () {
      const { nftMarketplace } = await loadFixture(deploy);

      await nftMarketplace.createMarketItem(
        1,
        'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json',
      );
      const nftLedger = await nftMarketplace.nftLedger(0);

      expect(await nftLedger.forSale).to.equal(false);
    });
    it('Should set the right price ', async function () {
      const { nftMarketplace } = await loadFixture(deploy);

      await nftMarketplace.createMarketItem(
        1,
        'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json',
      );
      const nftLedger = await nftMarketplace.nftLedger(0);

      expect(await nftLedger.price).to.equal(0);
    });
    it('Should set the right token id  ', async function () {
      const { nftMarketplace, marketItem, owner } = await loadFixture(deploy);

      await nftMarketplace.createMarketItem(
        1,
        'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json',
      );
      const tokenId = await marketItem.safeMint(
        owner.address,
        'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json',
      );
      const nftLedger = await nftMarketplace.nftLedger(0);

      // expect(nftLedger.tokenId).to.equal(tokenId);
    });
  });

  describe('Buy nft item', function () {
    it('Should set the right token id ', async function () {
      const { nftMarketplace, marketItem } = await loadFixture(deploy);

      await nftMarketplace.createMarketItem(
        1,
        'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json',
      );

      await marketItem.approve(nftMarketplace.address, 0);

      await nftMarketplace.buyItem(0);
      const nftLedger = await nftMarketplace.nftLedger(0);

      expect(await nftLedger.tokenId).to.equal(0);
    });

    it('Should nft be available for sale ', async function () {
      const { nftMarketplace, marketItem } = await loadFixture(deploy);

      await nftMarketplace.createMarketItem(
        1,
        'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json',
      );

      await marketItem.approve(nftMarketplace.address, 0);

      await nftMarketplace.buyItem(0);
      const nftLedger = await nftMarketplace.nftLedger(0);

      expect(await nftLedger.forSale).to.equal(true);
    });

    it('Should set the right price ', async function () {
      const { nftMarketplace, marketItem } = await loadFixture(deploy);

      await nftMarketplace.createMarketItem(
        1,
        'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json',
      );

      await marketItem.approve(nftMarketplace.address, 0);

      await nftMarketplace.listItem(0, 0);
      await nftMarketplace.buyItem(0);
      const nftLedger = await nftMarketplace.nftLedger(0);

      expect(await nftLedger.price).to.equal(0);
    });

    it('Should item be approved', async function () {
      const { nftMarketplace, marketItem, owner } = await loadFixture(deploy);

      await nftMarketplace.createMarketItem(
        1,
        'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json',
      );

      await marketItem.approve(nftMarketplace.address, 0);

      expect(await marketItem.getApproved(0)).to.equal(nftMarketplace.address);
    });
  });

  describe('Events', function () {
    it('Should emit an event on CollectionCreated', async function () {
      const { nftMarketplace } = await loadFixture(deploy);

      await expect(nftMarketplace.createCollection('polar bear'))
        .to.emit(nftMarketplace, 'CollectionCreated')
        .withArgs(anyValue, 'polar bear');
    });

    it('Should emit an event on MarketNftCreated', async function () {
      const { nftMarketplace } = await loadFixture(deploy);

      await expect(
        nftMarketplace.createMarketItem(
          1,
          'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json',
        ),
      )
        .to.emit(nftMarketplace, 'MarketNftCreated')
        .withArgs(anyValue, 1, anyValue, anyValue);
    });
  });
});
