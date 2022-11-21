// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import '@openzeppelin/contracts/utils/Counters.sol';
import './MarketItem.sol';

contract NFTMarketplace {
    MarketItem private marketItem;
    using Counters for Counters.Counter;
    Counters.Counter private _collectionIds;
    uint256 public LISTING_FEE = 0.0001 ether;
    address payable public owner;
    uint256[] public collectionIds;
    uint256[] public nftLedgerIds;
    uint256 public offerCount;

    mapping(uint256 => Offer) public offers;
    mapping(address => uint256) public userFunds;
    mapping(uint256 => Collection) public collectionLedger;
    mapping(uint256 => MarketNft) public nftLedger;
    mapping(address => uint256) private credits;

    struct Collection {
        string collectionName;
    }

    struct MarketNft {
        uint256 tokenId;
        uint256 collectionId;
        uint256 price;
        bool forSale;
    }

    struct Offer {
        uint256 offerId;
        uint256 id;
        address user;
        uint256 price;
        bool fulfilled;
        bool cancelled;
    }

    event OfferListed(
        uint256 offerId,
        uint256 id,
        address user,
        uint256 price,
        bool fulfilled,
        bool cancelled
    );

    event OfferFilled(uint256 offerId, uint256 id, address newOwner);
    event OfferCancelled(uint256 offerId, uint256 id, address owner);
    event ClaimFunds(address user, uint256 amount);

    event CollectionCreated(uint256 indexed collectionId, string collectionName);

    event MarketNftCreated(
        uint256 indexed tokenId,
        uint256 collectionId,
        uint256 price,
        bool forSale
    );

    constructor(address _marketItemAddress) {
        marketItem = MarketItem(_marketItemAddress);
        owner = payable(msg.sender);
    }

    modifier HasTransferApproval(uint256 _tokenId) {
        require(marketItem.getApproved(_tokenId) == address(this), 'Market is not approved');
        _;
    }

    modifier IsForSale(uint256 _tokenId) {
        require(!nftLedger[_tokenId].forSale, 'Item is already sold');
        _;
    }

    function createCollection(string memory _collectionName) external {
        require(bytes(_collectionName).length != 0, 'Collection cannot be empty');

        _collectionIds.increment();
        uint256 newCollectionId = _collectionIds.current();

        collectionLedger[newCollectionId] = Collection(_collectionName);

        collectionIds.push(newCollectionId);
        emit CollectionCreated(newCollectionId, _collectionName);
    }

    function createMarketItem(uint256 _collectionId, string memory _uri) external {
        uint256 tokenId = marketItem.safeMint(msg.sender, _uri);

        nftLedger[tokenId] = MarketNft(tokenId, _collectionId, 0, false);

        nftLedgerIds.push(tokenId);
        emit MarketNftCreated(tokenId, 0, _collectionId, false);
    }

    function setApproval(address _marketplaceContract, uint256 _tokenId) external {
        marketItem.approve(_marketplaceContract, _tokenId);
    }

    function listItem(uint256 _tokenId, uint256 _price) private {
        // - approval FE marketItem
        nftLedger[_tokenId].forSale = true;
        nftLedger[_tokenId].price = _price;
    }

    function buyItem(uint256 _tokenId)
        external
        payable
        IsForSale(_tokenId)
        HasTransferApproval(_tokenId)
    {
        uint256 price = nftLedger[_tokenId].price;

        require(msg.value >= price, 'Not enough funds sent');

        nftLedger[_tokenId].forSale = true;
        marketItem.transferFrom(marketItem.ownerOf(_tokenId), msg.sender, _tokenId);

        //  payable(msg.sender).transfer(msg.value);
        //   owner.transfer(LISTING_FEE);

        //  _allowForPull(marketItem.ownerOf(_tokenId), (msg.value - LISTING_FEE));
    }

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

    function cancelItem(uint256 _tokenId) public payable {
        uint256 price = nftLedger[_tokenId].price;

        require(
            msg.value == price,
            'Please submit the asking price in order to complete the purchase'
        );

        nftLedger[_tokenId].forSale = false;
        marketItem.transferFrom(msg.sender, marketItem.ownerOf(_tokenId), _tokenId);

        payable(marketItem.ownerOf(_tokenId)).transfer((msg.value + LISTING_FEE));
        _allowForPull(marketItem.ownerOf(_tokenId), (msg.value + LISTING_FEE));
    }

    function makeOffer(uint256 _id, uint256 _price) public {
        marketItem.transferFrom(msg.sender, address(this), _id);
        offerCount++;
        offers[offerCount] = Offer(offerCount, _id, msg.sender, _price, false, false);
        emit OfferListed(offerCount, _id, msg.sender, _price, false, false);
    }

    function fillOffer(uint256 _offerId) public payable {
        Offer storage _offer = offers[_offerId];
        require(_offer.offerId == _offerId, 'The offer must exist');
        require(_offer.user != msg.sender, 'The owner of the offer cannot fill it');
        require(!_offer.fulfilled, 'An offer cannot be fulfilled twice');
        require(!_offer.cancelled, 'A cancelled offer cannot be fulfilled');
        require(msg.value == _offer.price, 'The ETH amount should match with the NFT Price');
        marketItem.transferFrom(address(this), msg.sender, _offer.id);
        _offer.fulfilled = true;
        userFunds[_offer.user] += msg.value;
        emit OfferFilled(_offerId, _offer.id, msg.sender);
    }

    function cancelOffer(uint256 _offerId) public {
        Offer storage _offer = offers[_offerId];
        require(_offer.offerId == _offerId, 'The offer must exist');
        require(_offer.user == msg.sender, 'The offer can only be canceled by the owner');
        require(_offer.fulfilled == false, 'A fulfilled offer cannot be cancelled');
        require(_offer.cancelled == false, 'An offer cannot be cancelled twice');
        marketItem.transferFrom(address(this), msg.sender, _offer.id);
        _offer.cancelled = true;
        emit OfferCancelled(_offerId, _offer.id, msg.sender);
    }

    function claimFunds() public {
        require(userFunds[msg.sender] > 0, 'This user has no funds to be claimed');
        payable(msg.sender).transfer(userFunds[msg.sender]);
        emit ClaimFunds(msg.sender, userFunds[msg.sender]);
        userFunds[msg.sender] = 0;
    }
}
