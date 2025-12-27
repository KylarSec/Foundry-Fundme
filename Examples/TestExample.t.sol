// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Explicitly telling where Test.sol lives because it isn't in Test Folder.
import {Test, console} from "../lib/forge-std/src/Test.sol";

contract TestExample is Test {
    uint256 favNumber = 0;
    bool greatCourse = false;

    function setUp() external {
        favNumber = 1337;
        greatCourse = true;
        console.log("This will be printed first!");
    }

    function testDemo() public {
        assertEq(favNumber, 1337);
        assertEq(greatCourse, true);
        console.log("This will be printed second");
    }

    function testFailingDemo() public {
        assertEq(favNumber, 999); // This will fail, showing assertion errors
    }
}
