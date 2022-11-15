// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import '@openzeppelin/contracts/utils/Counters.sol';
import './MarketItem.sol';

contract NFTMarketplace {
    MarketItem private marketItem;
    using Counters for Counters.Counter;
    Counters.Counter private _collectionIds;
    uint256 public LISTING_FEE = 0.0001 ether;
    address payable private _marketOwner;

    mapping(uint256 => Collection) public collectionLedger;
    mapping(uint256 => MarketNft) public nftLedger;
    mapping(address => uint256) private credits;

    struct Collection {
        uint256 collectionId;
        string seller;
    }

    struct MarketNft {
        uint256 tokenId;
        uint256 collectionId;
        uint256 price;
        bool forSale;
    }

    event CollectionCreated(uint256 indexed collectionId, string seller);

    event MarketNftCreated(
        uint256 indexed tokenId,
        uint256 collectionId,
        uint256 price,
        bool forSale
    );

    constructor(address _marketItemAddress) {
        marketItem = MarketItem(_marketItemAddress);
        _marketOwner = payable(msg.sender);
    }

    function createCollection(string memory collection) public payable {
        require(bytes(collection).length != 0, 'Collection cannot be empty');

        _collectionIds.increment();
        uint256 newCollectionId = _collectionIds.current();

        collectionLedger[newCollectionId] = Collection(newCollectionId, collection);

        emit CollectionCreated(newCollectionId, collection);
    }

    function createMarketItem(uint256 _collectionId, string memory _uri) private {
        uint256 tokenId = marketItem.safeMint(msg.sender, _uri);

        nftLedger[tokenId] = MarketNft(tokenId, 0, _collectionId, false);

        emit MarketNftCreated(tokenId, 0, _collectionId, false);
    }

    function setApproval(address _marketplaceContract) public {
        marketItem.setApprovalForAll(_marketplaceContract, true);
    }

    function listItem(uint256 _tokenId, uint256 _price) private {
        // - approval
        nftLedger[_tokenId].forSale = true;
        nftLedger[_tokenId].price = _price;
    }

    function buyItem(uint256 _tokenId) public payable {
        uint256 price = nftLedger[_tokenId].price;

        require(
            msg.value == price,
            'Please submit the asking price in order to complete the purchase'
        );

        nftLedger[_tokenId].forSale = false;
        marketItem.transferFrom(marketItem.ownerOf(_tokenId), msg.sender, _tokenId);

        payable(msg.sender).transfer(msg.value);
        _marketOwner.transfer(LISTING_FEE);

        _allowForPull(marketItem.ownerOf(_tokenId), (msg.value - LISTING_FEE));
    }

    function listOfItemsByUserId(address _to) public {}

    function _allowForPull(address receiver, uint256 amount) private {
        credits[receiver] += amount;
    }

    function withdrawCredits() public {
        uint256 amount = credits[msg.sender];

        require(amount > 0, 'There are no credits in this recipient address');
        require(address(this).balance >= amount, 'There are no credits in this contract address');

        credits[msg.sender] = 0;

        payable(msg.sender).transfer(amount);
    }
}
