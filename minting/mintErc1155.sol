// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract NFTee is ERC1155 {

    constructor() ERC1155("1155NFT") {}
    uint public tokenId;

    function mintNFT(address _to) public payable {
        tokenId++;
        _mint(_to, tokenId, 1, "");
    }
}