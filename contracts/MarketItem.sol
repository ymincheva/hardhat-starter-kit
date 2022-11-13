// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract MarketItem {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function safeMint(
        address to,
        uint256 tokenId,
        uint256 collectionId,
        string memory uri
    ) private {
        //NFTMarketplace nFtMarketplace = NFTMarketplace(addr);
        // nFtMarketplace.safeMint(address, tokenId, collectionId, uri);
    }

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
