// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTee is ERC721 {

    constructor() ERC721("NFT", "test") {}
    uint public tokenId;

    function mintNFT(address _to) public payable {
        tokenId++;
        _mint(_to, tokenId);
    }
}