// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _collectionIds;

    address payable owner;

    mapping(uint256 => Collection) private collectionLedger;

    struct Collection {
        uint256 collectionId;
        string seller;
    }

    event CollectionCreated(uint256 indexed collectionId, string seller);

    constructor() ERC721("Metaverse Tokens", "METT") {
        owner = payable(msg.sender);
    }

    function createMarketItem(string memory collection) private {
        require(bytes(collection).length != 0, "Collection cannot be empty");

        _collectionIds.increment();
        uint256 newCollectionId = _collectionIds.current();

        collectionLedger[newCollectionId] = Collection(
            newCollectionId,
            collection
        );

        emit CollectionCreated(newCollectionId, collection);
    }
}
