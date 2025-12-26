// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
    }

    function test_InitialValue() public {
        assertEq(counter.number(), 0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);

        counter.increment();
        assertEq(counter.number(), 2);
    }

    function test_Decrement() public {
        counter.setNumber(5);
        counter.decrement();
        assertEq(counter.number(), 4);
    }

    function test_SetNumber() public {
        counter.setNumber(100);
        assertEq(counter.number(), 100);
    }

    function test_DecrementFromZero_Reverts() public {
        vm.expectRevert("Number cannot be negative");
        counter.decrement();
    }

    function testFuzz_Increment(uint256 x) public {
        vm.assume(x < type(uint256).max);
        counter.setNumber(x);
        counter.increment();
        assertEq(counter.number(), x + 1);
    }

    function testFuzz_Decrement(uint256 x) public {
        vm.assume(x > 0 && x < type(uint256).max);
        counter.setNumber(x);
        counter.decrement();
        assertEq(counter.number(), x - 1);
    }
}
