// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import '@openzeppelin/contracts/utils/Counters.sol';
import './MarketItem.sol';

contract NFTMarketplace {
    MarketItem private marketItem;
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

    constructor(address _marketItemAddress) {
        marketItem = MarketItem(_marketItemAddress);
    }

    function createCollection(string memory collection) private {
        require(bytes(collection).length != 0, 'Collection cannot be empty');

        _collectionIds.increment();
        uint256 newCollectionId = _collectionIds.current();

        collectionLedger[newCollectionId] = Collection(newCollectionId, collection);

        emit CollectionCreated(newCollectionId, collection);
    }

    function createMarketItem(
        uint256 collectionId,
        uint256 price,
        string memory uri
    ) private {
        require(price > 0, 'Price must be at least 1 wei');

        uint256 tokenId = marketItem.safeMintTest(msg.sender, uri);

        nftLedger[tokenId] = MarketNft(tokenId, price, collectionId, false);

        emit MarketNftCreated(tokenId, price, collectionId, false);
    }

    function buyItem(uint256 tokenId) public payable {
        uint256 price = nftLedger[tokenId].price;

        require(
            msg.value == price,
            'Please submit the asking price in order to complete the purchase'
        );

        nftLedger[tokenId].forSale = true;
        //  _transfer(address(this), msg.sender, tokenId);
    }

    function listOfItemsByUserId(address to) public {}

    /*     function withdrawAmount() external {
        IERC721 nft = IERC721(msg.sender);

        uint256 proceeds = nftLedger[msg.sender];
        if (proceeds <= 0) {
            //  revert NoProceeds();
      }
        nftLedger[msg.sender] = 0;

       (bool success, ) = payable(msg.sender).call{ value: proceeds }('');
        require(success, 'Transfer failed');
    }  */

    /*    function createMarketItem(
        uint256 tokenId,
        uint256 collectionId,
        uint256 price
    ) private {
        require(price > 0, "Price must be at least 1 wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        idToMarketNft[tokenId] = MarketNft(tokenId, collectionId, price, false);

        _transfer(msg.sender, address(this), tokenId);
        emit MarketNftCreated(tokenId, collectionId, price, false);
    } */

    /*    function createMarketSale(uint256 tokenId) public payable {
        uint256 price = idToMarketNft[tokenId].price;
        address seller = idToMarketNft[tokenId].seller;
        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );
        idToMarketNft[tokenId].owner = payable(msg.sender);
        idToMarketNft[tokenId].sold = true;
        idToMarketNft[tokenId].seller = payable(address(0));
        _itemsSold.increment();
        _transfer(address(this), msg.sender, tokenId);
        payable(owner).transfer(listingPrice);
        payable(seller).transfer(msg.value);
    } */
}
