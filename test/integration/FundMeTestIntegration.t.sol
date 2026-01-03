// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";

contract InteractionTest is Test {
    FundMe public fm;
    DeployFundMe deployfm;

    uint256 public constant FUND_VALUE = 0.1 ether;
    uint256 public constant STARTING_BALANCE = 10 ether;

    address mockUser = makeAddr("mockUser");

    function setUp() external {
        deployfm = new DeployFundMe();
        fm = deployfm.run();
        vm.deal(mockUser, STARTING_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        uint256 preUserBalance = address(mockUser).balance;
        // console.log(preUserBalance);
        uint256 preOwnerBalance = address(fm.get_Owner()).balance;
        // console.log(preOwnerBalance);

        // This is for running forked tests!
        uint256 originalFundMeBalance = address(fm).balance;
        // console.log(originalFundMeBalance);

        // Using vm.prank to simulate funding from the mockUser address
        vm.prank(mockUser);
        fm.fund{value: FUND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fm));

        uint256 afterUserBalance = address(mockUser).balance;
        // console.log(afterUserBalance);
        uint256 afterOwnerBalance = address(fm.get_Owner()).balance;
        // console.log(afterOwnerBalance);

        assertEq(address(fm).balance, 0);
        assertEq(afterUserBalance + FUND_VALUE, preUserBalance);
        assertEq(
            preOwnerBalance + FUND_VALUE + originalFundMeBalance,
            afterOwnerBalance
        );
    }
}
