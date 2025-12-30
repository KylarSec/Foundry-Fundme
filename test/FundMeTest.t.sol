// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../src/FundMe.sol";

import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    address user1 = makeAddr("user1");

    uint256 constant FUND_VALUE = 1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    FundMe fm;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fm = deployFundMe.run();
        vm.deal(user1, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fm.MINIMUM_USD(), 5e18);
    }

    function test_FundFailswithoutSuffucientEth() public {
        vm.expectRevert();
        fm.fund();
    }

    function test_FundPasswhenSufficientEth() public {
        fm.fund{value: 6e18}();
    }

    // function test_OwnerIsDeployer() public {
    //     //address(this) -> address of this contract
    //     assertEq(fm.i_owner(), address(this));
    // }

    function test_OwnerIsMsgSender() public {
        assertEq(fm.i_owner(), msg.sender);
    }

    function test_CheckPriceFeedVersion() public {
        if (block.chainid == 11155111) {
            uint256 version = fm.GetVersion();
            assertEq(version, 4);
        } else if (block.chainid == 31337) {
            uint256 version = fm.GetVersion();
            assertEq(version, 4);
        }
    }

    function testFundUpdatesFundData() public {
        vm.prank(user1); //The next Transaction will be sent by user1
        fm.fund{value: FUND_VALUE}();
        uint256 amountFunded = fm.getAddressToAmountFunded(user1);
        assertEq(amountFunded, FUND_VALUE);
    }

    function testWithdrawFailsIfNotOwner() public {
        vm.expectRevert();
        fm.withdraw();
    }

    function testOnlyOwnerCanWithdraw() public {
        address owner = fm.i_owner();

        vm.prank(owner);
        fm.withdraw();
    }

    function testBalanceZeroAfterWithdrawByOwner() public {
        address owner = fm.i_owner();
        vm.prank(owner);
        fm.withdraw();

        //assert balance is zero
        assertEq(address(fm).balance, 0);
    }
}
