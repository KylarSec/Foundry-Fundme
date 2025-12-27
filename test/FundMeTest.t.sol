// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fm;

    function setUp() external {
        //us -> FundMeTest -> FundMe
        fm = new FundMe();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fm.MINIMUM_USD(), 5e18);
    }

    /**
     *The test is testOwnerisDeployer because this test contract will deploy the
     * FundeMe contract so this test contract will be the owner.
     */
    function test_OwnerIsDeployer() public {
        //address(this) -> address of this contract
        assertEq(fm.i_owner(), address(this));
    }

    function test_CheckPriceFeedVersion() public {
        uint256 version = fm.GetVersion();
        assertEq(version, 4);
    }
}
