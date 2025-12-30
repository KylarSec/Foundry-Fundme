// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Import Chainlink price feed interface
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// Import the PriceConverter Library
import {PriceConverter} from "./PriceConverter.sol";

/**
 * FundMe contract
 * - Accepts ETH from users
 * - Converts ETH value to USD using Chainlink
 * - Enforces a minimum USD amount
 */
contract FundMe {
    // Declared a custom error
    error FundMe__NotOwner();

    AggregatorV3Interface private s_pricefeed;

    // state variable owner with the contract deployer's address
    address public immutable i_owner;

    // set the contract's owner immediately after deployment
    constructor(address dataFeed) {
        i_owner = msg.sender;
        s_pricefeed = AggregatorV3Interface(dataFeed);
    }

    // Modifier to check only owner with custom error.
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    // Minimum funding amount in USD
    // Scaled to 18 decimals so it matches ETH math
    uint256 public constant MINIMUM_USD = 5 * 1e18;

    // List of addresses that have funded the contract
    address[] private s_funders;

    // Tracks total ETH contributed by each address
    mapping(address => uint256) private s_addressToFundedAccount;

    // Tracks how many times each address has funded
    mapping(address => uint256) private contributionCount;

    /**
     * Allows users to send ETH to the contract
     * - msg.value is the ETH sent (in wei)
     * - Converted to USD using the PriceConverter library
     * - Reverts if the USD value is below minimumUSD
     */
    // ETH amount → pass to library → library asks Chainlink → converts to USD → returns number → require checks it
    function fund() public payable {
        require(
            PriceConverter.getConversionRate(msg.value, s_pricefeed) >=
                MINIMUM_USD,
            "Didn't Send enough ETH"
        );

        // add addresses to the array who sends money to the contract.
        // The msg.sender global variable refers to the address that initiates the transaction.
        s_funders.push(msg.sender);

        /**
         * Mapping associates each funder's address with the total amount they have contributed.
         * When a new amount is sent, we can add it to the user's total contribution
         */
        s_addressToFundedAccount[msg.sender] += msg.value;

        // Count everytime a user funds
        contributionCount[msg.sender] += 1;
    }

    // withdraw ETH While clearing records.
    function withdraw() external onlyOwner {
        /**
         *starts at index 0
         *runs until it reaches the end of the funders array
         *increments fundersIndex by 1 each iteration
         */
        for (
            uint256 fundersIndex = 0;
            fundersIndex < s_funders.length;
            fundersIndex++
        ) {
            // Get the funder's address at the current index.
            address funder = s_funders[fundersIndex];

            // Reset the total amount funded by this address to zero.
            s_addressToFundedAccount[funder] = 0;

            // Reset the number of contributions made by this address
            contributionCount[funder] = 0;
        }

        // Reset the funders array by Creating a new array with length 0.
        s_funders = new address[](0);

        // the current contract sends the Ether amount to the msg.sender with call
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Call Failed");
    }

    // Get the version of the price feed contract
    function GetVersion() external view returns (uint256) {
        return s_pricefeed.version();
    }

    function GetPrice() external view returns (uint256) {
        return PriceConverter.getPrice(s_pricefeed);
    }

    // receive() is called when the contract receives ETH
    // and msg.data is empty.
    // It forwards the ETH to the Fund() function.
    receive() external payable {
        fund();
    }

    // fallback() is called when the contract receives ETH
    // and msg.data is NOT empty or when no function matches.
    // It also forwards the ETH to the fund() function.
    fallback() external payable {
        fund();
    }

    /**Getter Functions */

    function getAddressToAmountFunded(
        address funderAddress
    ) public view returns (uint256) {
        return s_addressToFundedAccount[funderAddress];
    }

    function getFunders(uint256 index) public view returns (address) {
        return s_funders[index];
    }
}
