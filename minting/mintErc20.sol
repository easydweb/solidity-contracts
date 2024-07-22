// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract mintToken is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20("test", "t") {}

    function mintTo(address _user) public {
        _mint(_user, 100 * 10 ** 18);
    }
}