// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fm;

    function setUp() external {
        fm = new FundMe();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fm.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fm.i_owner());
        console.log(msg.sender);
        assertEq(fm.i_owner(), msg.sender);
    }
}
