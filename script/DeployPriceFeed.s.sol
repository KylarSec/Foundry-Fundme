// SPDX-License-Identifier: MIT

// Depoloy a Mock Feed Manually if Want.
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

import {MockPricefeed} from "../test/Mock/CustomPriceFeed.sol";

contract DeployPriceFeed is Script {
    uint8 public constant DECIMAL = 8;

    int256 public constant INITIAL_PRICE = 3000e8;

    function run() external returns (MockPricefeed) {
        vm.startBroadcast();
        MockPricefeed pricefeed = new MockPricefeed(DECIMAL, INITIAL_PRICE);
        vm.stopBroadcast();
        return pricefeed;
    }
}
