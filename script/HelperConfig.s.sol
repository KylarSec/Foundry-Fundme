// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

import {MockPricefeed} from "../test/Mock/CustomPriceFeed.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 31337) {
            activeNetworkConfig = getorCreateAnvilEthConfig();
        } else {
            revert("Unsupported chain");
        }
    }

    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 3000e8;

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getorCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // Deploy the mockPriceFeed
        // Return the mockPriceFeed address
        vm.startBroadcast();
        MockPricefeed mockPricefeed = new MockPricefeed(DECIMAL, INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPricefeed)
        });
        return anvilConfig;
    }
}
