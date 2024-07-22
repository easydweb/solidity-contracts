// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DataFeeds {
    AggregatorV3Interface internal priceFeed;

    // use the aggregator address specific to the 
    constructor(address _aggregatorAddress) {
        priceFeed = AggregatorV3Interface(_aggregatorAddress);
    }

   function calculate(uint _amount) public view returns (uint) {
        uint256 chainlinkDecimals = 10 ** 10;  // chainlink returns in 8 decimals, needs to add 10 more
        uint256 PriceInUsdt = uint256(getLatestPrice()) * chainlinkDecimals;
        uint256 usdtAmount = (_amount * PriceInUsdt) / 10**18;
        return usdtAmount;
   }

    function getLatestPrice() public view returns (int) {
        (,int price,,,) = priceFeed.latestRoundData();
        return price;
    }
}