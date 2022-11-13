// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import 'hardhat/console.sol';

contract NFTMarketplace is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _collectionIds;

    mapping(uint256 => Collection) private collectionLedger;
    struct Collection {
        uint256 collectionId;
        string seller;
    }
    event CollectionCreated(uint256 indexed collectionId, string seller);

    mapping(uint256 => MarketNft) private nftLedger;
    struct MarketNft {
        uint256 tokenId;
        uint256 collectionId;
        uint256 price;
        bool forSale;
    }
    event MarketNftCreated(
        uint256 indexed tokenId,
        uint256 collectionId,
        uint256 price,
        bool forSale
    );

    constructor() ERC721('NFTMarketplace', 'METT') {}

    function createCollection(string memory collection) private {
        require(bytes(collection).length != 0, 'Collection cannot be empty');

        _collectionIds.increment();
        uint256 newCollectionId = _collectionIds.current();

        collectionLedger[newCollectionId] = Collection(newCollectionId, collection);

        emit CollectionCreated(newCollectionId, collection);
    }

    function createMarketItem(
        uint256 tokenId,
        uint256 collectionId,
        uint256 price
    ) private {
        require(price > 0, 'Price must be at least 1 wei');

        nftLedger[tokenId] = MarketNft(tokenId, price, collectionId, false);
        _transfer(msg.sender, address(this), tokenId);
        emit MarketNftCreated(tokenId, price, collectionId, false);
    }

    function createMarketSale(uint256 tokenId) public payable {
        uint256 price = nftLedger[tokenId].price;

        require(
            msg.value == price,
            'Please submit the asking price in order to complete the purchase'
        );

        nftLedger[tokenId].forSale = true;
        _transfer(address(this), msg.sender, tokenId);
    }

    function safeMint(
        address to,
        uint256 tokenId,
        string memory uri
    ) public onlyOwner {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function doSomething() public {}
}
