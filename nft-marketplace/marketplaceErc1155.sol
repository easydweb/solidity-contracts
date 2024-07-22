// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract NftMarketplace is ERC1155URIStorage, ERC1155Holder {
    
    address payable owner;

    constructor() ERC1155("") {
        owner = payable(msg.sender);
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;

    struct nft {
        uint256 tokenId;
        address payable owner;
        address payable creator;
        uint256 price;
        uint256 supply;
        uint256 supplyleft;
        string category;
    }

    event nftCreated(
        uint256 indexed tokenId,
        address owner,
        address creator,
        uint256 price,
        uint256 supply,
        uint256 supplyleft
    );

    mapping(uint256 => nft) idTonft;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, ERC1155Holder)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function createToken(
        string memory tokenURI,
        uint256 supply,
        uint256 price,
        string memory category
    ) public payable {
        _tokenId.increment();
        uint256 currentToken = _tokenId.current();
        _mint(msg.sender, currentToken, supply, "");
        _setURI(currentToken, tokenURI);
        createnft(currentToken, supply, price, category);
    }

    function createnft(
        uint256 tokenId,
        uint256 supply,
        uint256 price,
        string memory category
    ) private {
        idTonft[tokenId] = nft(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            supply,
            supply,
            category
        );

        _safeTransferFrom(msg.sender, address(this), tokenId, supply, "");

        emit nftCreated(
            tokenId,
            address(this),
            msg.sender,
            price,
            supply,
            supply
        );
    }

    function buy(uint256 tokenId) public payable {
        uint256 price = idTonft[tokenId].price;
        require(msg.value == price);
        require(idTonft[tokenId].supplyleft >= idTonft[tokenId].supply);
        idTonft[tokenId].owner = payable(msg.sender);
        idTonft[tokenId].supplyleft--;

        _safeTransferFrom(address(this), msg.sender, tokenId, 1, "");

        uint256 fee = price/100;
        uint256 remaining = price - fee;

        payable(idTonft[tokenId].creator).transfer(remaining);
        payable(owner).transfer(fee);
    }

    function fetchStore() public view returns (nft[] memory) {
        uint counter = 0;
        uint length;

        for (uint i = 0; i < _tokenId.current(); i++) {
            if (idTonft[i+1].supplyleft > 0) {
                length++;
            }
        }

        nft[] memory unsoldBooks = new nft[](length);
        for (uint i = 0; i < _tokenId.current(); i++) {
            if (idTonft[i+1].supplyleft > 0) {
                uint currentId = i+1;
                nft storage currentItem = idTonft[currentId];
                unsoldBooks[counter] = currentItem;
                counter++;
            }
        }
        return unsoldBooks;
    }

    function fetchInventory() public view returns (nft[] memory) {
            uint counter = 0;
            uint length ;

            for (uint i = 0; i < _tokenId.current(); i++) {
                if (idTonft[i+1].owner == msg.sender) {
                    length++;
                }
            }

            nft[] memory myBooks = new nft[](length);
            for (uint i = 0; i < _tokenId.current(); i++) {
                if (idTonft[i+1].owner == msg.sender) {
                    uint currentId = i+1;
                    nft storage currentItem = idTonft[currentId];
                    myBooks[counter] = currentItem;
                    counter++;
                }
            }
            return myBooks;
    }

    function fetchMyListings() public view returns (nft[] memory) {
        uint counter = 0;
        uint length;

        for (uint i = 0; i < _tokenId.current(); i++) {
            if (idTonft[i+1].creator == msg.sender) {
                length++;
            }
        }

        nft[] memory myListedBooks = new nft[](length);
        for (uint i = 0; i < _tokenId.current(); i++) {
            if (idTonft[i+1].creator == msg.sender) {
                uint currentId = i+1;
                nft storage currentItem = idTonft[currentId];
                myListedBooks[counter] = currentItem;
                counter++;
            }
        }
        return myListedBooks;
    }
}