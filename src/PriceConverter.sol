// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * Network: Sepolia
 * Aggregator: ETH/USD
 * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
 */

// Import Chainlink price feed interface
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * PriceConverter library
 * - Reads ETH/USD price from Chainlink
 * - Performs ETH <-> USD conversions
 * - Designed specifically for ETH/USD
 */
library PriceConverter {
    /**
     * Reads ETH/USD price from Chainlink
     * - Chainlink returns price with 8 decimals
     * - We convert it to 18 decimals so it matches ETH math
     */
    function getPrice() internal view returns (uint256) {
        AggregatorV3Interface dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // Get latest price data
        (, int256 answer,,,) = dataFeed.latestRoundData();

        // Ensure the price is positive before converting to uint
        require(answer > 0, "Invalid Price");

        // Convert price from 8 decimals to 18 decimals
        return uint256(answer) * 1e10;
    }

    /**
     * Converts ETH amount to USD value
     * - ethAmount is usually msg.value(wei)
     * - Returns USD value with 18 decimals
     */
    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        // GetETH price in USD (18 decimals)
        uint256 ethPrice = getPrice();

        // ETH --> USD conversion
        uint256 ethAmountinUsd = (ethPrice * ethAmount) / 1e18;

        return ethAmountinUsd;
    }
}
