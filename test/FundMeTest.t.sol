// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../src/FundMe.sol";

import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    uint256 constant FUND_VALUE = 1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    FundMe fm;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fm = deployFundMe.run();
        vm.deal(user1, STARTING_BALANCE);
        vm.deal(user2, STARTING_BALANCE);
        vm.deal(user3, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fm.MINIMUM_USD(), 5e18);
    }

    function test_FundFails_without_SuffucientEth() public {
        vm.expectRevert();
        fm.fund();
    }

    function test_FundPass_when_SufficientEth() public {
        fm.fund{value: FUND_VALUE}();
    }

    function test_OwnerIsDeployer() public {
        address deployer = makeAddr("deployer");

        vm.prank(deployer);
        FundMe newFundMe = new FundMe(address(deployer));
        assertEq(newFundMe.get_Owner(), deployer);
    }

    function test_CheckPriceFeedVersion() public view {
        if (block.chainid == 11155111) {
            uint256 version = fm.GetVersion();
            assertEq(version, 4);
        } else if (block.chainid == 31337) {
            uint256 version = fm.GetVersion();
            assertEq(version, 4);
        }
    }

    /**
     * 1. user1 funds the contract
     * 2. Assert the funding actually worked
     * 3. Then run the test
     */
    modifier fundedbyuser1() {
        vm.prank(user1); //The next Transaction will be sent by user1
        fm.fund{value: FUND_VALUE}();
        assert(address(fm).balance > 0);
        _;
    }

    function testFundUpdates_FundData() public fundedbyuser1 {
        uint256 amountFunded = fm.getAddressToAmountFunded(user1);
        assertEq(amountFunded, FUND_VALUE);
    }

    function testWithdraw_Fails_If_NotOwner() public {
        vm.expectRevert();
        fm.withdraw();
    }

    function testOnly_Owner_Can_Withdraw() public {
        address owner = fm.get_Owner();

        vm.prank(owner);
        fm.withdraw();
    }

    function test_Only_Owner_Can_Withdraw() public fundedbyuser1 {
        vm.expectRevert();
        vm.prank(user1);
        fm.withdraw();
    }

    function testWithdraw_Reverts_If_NotOwner() public fundedbyuser1 {
        vm.expectRevert();
        vm.prank(user1);
        fm.withdraw();
    }

    function testBalance_Zero_After_Withdraw_ByOwner() public {
        address owner = fm.get_Owner();
        vm.prank(owner);
        fm.withdraw();

        //assert balance is zero
        assertEq(address(fm).balance, 0);
    }

    function testFund_Adds_Funder_To_Array_Of_funders() public fundedbyuser1 {
        address funder = fm.getFunders(0);
        assertEq(funder, user1);
    }

    function testFund_Adds_Multiple_Funder_To_Array_Of_funders()
        public
        fundedbyuser1
    {
        vm.prank(user2);
        fm.fund{value: FUND_VALUE}();
        vm.prank(user3);
        fm.fund{value: FUND_VALUE}();

        address funder1 = fm.getFunders(0);
        assertEq(funder1, user1);

        address funder2 = fm.getFunders(1);
        assertEq(funder2, user2);

        address funder3 = fm.getFunders(2);
        assertEq(funder3, user3);
    }

    function testTrack_of_Fund_By_address() public fundedbyuser1 {
        uint256 amount = fm.getAddressToAmountFunded(user1);
        assertEq(amount, FUND_VALUE);
    }

    function testAmount_Increase_on_each_Fund_By_same_User()
        public
        fundedbyuser1
    {
        // Funding again to check increase in fund
        vm.prank(user1);
        fm.fund{value: FUND_VALUE}();

        uint256 expected_amount = 2 * FUND_VALUE;
        assertEq(fm.getAddressToAmountFunded(user1), expected_amount);
    }

    function test_withdrawFromASingleFnuder() public fundedbyuser1 {
        // 1. Arrange
        uint256 startingFundMeBalance = address(fm).balance;
        // console.log(startingFundMeBalance);
        uint256 startingOwnerBalance = fm.get_Owner().balance;
        // console.log(startingOwnerBalance);

        // 2. Act
        vm.prank(fm.get_Owner());
        fm.withdraw();

        // 3. Assert
        uint256 endingFundMeBalance = address(fm).balance;
        // console.log(endingFundMeBalance);
        uint256 endingOwnerBalance = fm.get_Owner().balance;
        // console.log(endingOwnerBalance);
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public {
        // 1. SETUP - multiple funders
        address OWNER = fm.get_Owner();
        uint160 numberOfFunders = 10;
        for (uint160 i = 1; i < numberOfFunders + 1; i++) {
            /**
             * hoax(addr, amount) = Give this address ETH and make it the caller.
             * vm.deal(addr, amount)
             * vm.prank(addr)
             */
            hoax(address(i), FUND_VALUE);
            fm.fund{value: FUND_VALUE}();
        }

        // 2. Arrange - Snapshot balance
        uint256 startingFundMeBalance = address(fm).balance;
        uint256 startingOwnerBalance = OWNER.balance;

        // 3. Act - Withdraw as owner
        vm.prank(OWNER);
        fm.withdraw();

        // 4. Assertions
        assertEq(address(fm).balance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, OWNER.balance);
        assertEq(
            numberOfFunders * FUND_VALUE,
            OWNER.balance - startingOwnerBalance
        );
    }
}
