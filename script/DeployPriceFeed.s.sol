// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

import {Pricefeed} from "../src/PriceFeedContract/CustomPriceFeed.sol";

contract DeployPriceFeed is Script {
    function run() external returns (Pricefeed) {
        vm.startBroadcast();
        Pricefeed pricefeed = new Pricefeed(301157000000);
        vm.stopBroadcast();
        return pricefeed;
    }
}
