const { time, loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs');
const { expect } = require('chai');
const { expectRevert } = require('@openzeppelin/test-helpers');

describe('NFTMarketplace', function () {
  const uri1 =
    'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/1.json';
  const uri2 =
    'https://gateway.pinata.cloud/ipfs/QmYWjgERZxTsQaERz9aYTBQeS2FgTdAvnZMzV58FnkGrcs/2.json';

  async function deploy() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    console.log('Deploying contracts with the account:', owner.address);
    console.log('Account balance:', (await owner.getBalance()).toString());

    const MarketItem = await hre.ethers.getContractFactory('MarketItem');
    const marketItem = await MarketItem.deploy();

    const NFTMarketplace = await ethers.getContractFactory('NFTMarketplace');
    const nftMarketplace = await NFTMarketplace.deploy(marketItem.address);

    return { nftMarketplace, marketItem, owner, addr1, addr2 };
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

      await nftMarketplace.createMarketItem(1, uri1);
      const nftLedger = await nftMarketplace.nftLedger(0);

      expect(await nftLedger.collectionId).to.equal(1);
    });
    it('Should set nft forbidden for sale ', async function () {
      const { nftMarketplace } = await loadFixture(deploy);

      await nftMarketplace.createMarketItem(1, uri1);
      const nftLedger = await nftMarketplace.nftLedger(0);

      expect(await nftLedger.forSale).to.equal(false);
    });
    it('Should set the right price ', async function () {
      const { nftMarketplace } = await loadFixture(deploy);

      await nftMarketplace.createMarketItem(1, uri1);
      const nftLedger = await nftMarketplace.nftLedger(0);

      expect(await nftLedger.price).to.equal(0);
    });
    it('Should set the right token id  ', async function () {
      const { nftMarketplace, marketItem, owner } = await loadFixture(deploy);

      await nftMarketplace.createMarketItem(1, uri1);

      const nftLedger = await nftMarketplace.nftLedger(0);
      expect(nftLedger.tokenId).to.equal(0);
    });

    it('NFT is minted successfully', async function () {
      const { marketItem, owner, addr1 } = await loadFixture(deploy);
      expect(await marketItem.balanceOf(owner.address)).to.equal(0);

      await marketItem.connect(owner).safeMint(addr1.address, uri1);
      expect(await marketItem.balanceOf(owner.address)).to.equal(0);
    });

    it('uri is set sucessfully', async function () {
      const { marketItem, owner, addr1 } = await loadFixture(deploy);

      await marketItem.connect(owner).safeMint(addr1.address, uri1);
      expect(await marketItem.tokenURI(0)).to.equal(uri1);
    });
  });

  describe('setApproval', function () {
    it('NFT is approved', async function () {
      const { nftMarketplace, marketItem, addr1 } = await loadFixture(deploy);

      await marketItem.safeMint(addr1.address, uri1);
      await marketItem.connect(addr1).approve(nftMarketplace.address, 0);
      expect(await marketItem.getApproved(0)).to.equal(nftMarketplace.address);
    });
  });

  describe('listItem', function () {
    it('Token cannot be empty', async function () {
      const { nftMarketplace, owner } = await loadFixture(deploy);

      const token = '';
      expect(nftMarketplace.connect(owner).listItem(token, 4000000)).to.be.revertedWith(
        'Token cannot be empty',
      );
    });

    it('The price of NFT must be greater than 0', async function () {
      const { nftMarketplace, owner } = await loadFixture(deploy);

      const price = 0;
      expect(nftMarketplace.connect(owner).listItem(0, price)).to.be.revertedWith(
        'The price of NFT must be greater than 0',
      );
    });

    it('Should set the right price ', async function () {
      const { marketItem, nftMarketplace, addr1 } = await loadFixture(deploy);

      const price = 400000000000000;
      await nftMarketplace.connect(addr1).createMarketItem(1, uri1);
      await marketItem.safeMint(addr1.address, uri1);
      await marketItem.connect(addr1).approve(nftMarketplace.address, 0);
      await nftMarketplace.listItem(0, price);
      const nftLedger = await nftMarketplace.nftLedger(0);

      expect(await nftLedger.price).to.equal(price);
    });

    it('Should set nft for sale ', async function () {
      const { marketItem, nftMarketplace, addr1 } = await loadFixture(deploy);

      const price = 400000000000000;
      await nftMarketplace.connect(addr1).createMarketItem(1, uri1);
      await marketItem.safeMint(addr1.address, uri1);
      await marketItem.connect(addr1).approve(nftMarketplace.address, 0);
      await nftMarketplace.listItem(0, price);
      const nftLedger = await nftMarketplace.nftLedger(0);

      expect(await nftLedger.forSale).to.equal(true);
    });
  });

  describe('Buy nft item', function () {
    it('Buy token cannot be empty', async function () {
      const { nftMarketplace, owner } = await loadFixture(deploy);

      const token = '';
      expect(nftMarketplace.connect(owner).buyItem(token)).to.be.revertedWith(
        'Buy token cannot be empty',
      );
    });

    it('Should set the right token id ', async function () {
      const { nftMarketplace, owner } = await loadFixture(deploy);

      const token = await nftMarketplace.nftLedger(0);
      expect(nftMarketplace.connect(owner).buyItem(token)).to.be.revertedWith(
        'Should set the right token id ',
      );
    });

    it('Should nft be available for sale ', async function () {
      const { nftMarketplace, owner } = await loadFixture(deploy);

      const nftLedger = await nftMarketplace.nftLedger(0);
      expect(nftLedger.forSale).to.equal(false);
    });

    it('Should item be approved', async function () {
      const { nftMarketplace, marketItem } = await loadFixture(deploy);

      await nftMarketplace.createMarketItem(1, uri1);

      await marketItem.approve(nftMarketplace.address, 0);

      expect(await marketItem.getApproved(0)).to.equal(nftMarketplace.address);
    });

    it('Should transfer token to the right address', async function () {
      const { nftMarketplace, marketItem, owner, addr1, addr2 } = await loadFixture(deploy);
      const price = 4000;
      await nftMarketplace.connect(addr1).createMarketItem(1, uri1);
      await marketItem.safeMint(addr1.address, uri1);
      await marketItem.connect(addr1).approve(nftMarketplace.address, 0);

      await nftMarketplace.connect(owner).listItem(0, price);
      await nftMarketplace.connect(addr2).buyItem(0, { value: ethers.utils.parseEther('1.0') });

      expect(await marketItem.ownerOf(0)).to.equal(addr2.address);
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

      await expect(nftMarketplace.createMarketItem(1, uri1))
        .to.emit(nftMarketplace, 'MarketNftCreated')
        .withArgs(anyValue, 1, anyValue, anyValue);
    });
  });
});
