// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MarketItem is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.025 ether;
    address payable owner;

    mapping(uint256 => MarketNft) private idToMarketNft;

    struct MarketNft {
        uint256 tokenId;
        uint256 collectionId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event MarketNftCreated(
        uint256 indexed tokenId,
        uint256 collectionId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    constructor() ERC721("MarketItem", "MTK") {
        owner = payable(msg.sender);
    }

    function createMarketItem(
        uint256 tokenId,
        uint256 collectionId,
        uint256 price
    ) private {
        require(price > 0, "Price must be at least 1 wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        idToMarketNft[tokenId] = MarketNft(
            tokenId,
            collectionId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        _transfer(msg.sender, address(this), tokenId);
        emit MarketNftCreated(
            tokenId,
            collectionId,
            msg.sender,
            address(this),
            price,
            false
        );
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketNft[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;
        MarketNft[] memory items = new MarketNft[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketNft[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                MarketNft storage currentItem = idToMarketNft[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function createMarketSale(uint256 tokenId) public payable {
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
    }

    function safeMint(
        address to,
        uint256 tokenId,
        uint256 collectionId,
        string memory uri
    ) public onlyOwner {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
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
}
