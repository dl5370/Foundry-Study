// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MultiSigWallet.sol";

contract ERC20Mock {
    string public name = "MockToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
    }
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "insufficient");
        require(allowance[from][msg.sender] >= amount, "not allowed");
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract MultiSigWalletTest is Test {
    MultiSigWallet wallet;
    address[] owners;
    address alice = address(0x1);
    address bob = address(0x2);
    address carol = address(0x3);
    ERC20Mock token;

    function setUp() public {
        owners = new address[](3);
        owners[0] = alice;
        owners[1] = bob;
        owners[2] = carol;
        wallet = new MultiSigWallet(owners, 2);
        token = new ERC20Mock();
        token.mint(address(wallet), 1000 ether);
    }

    function testSubmitAndConfirmAndExecuteETH() public {
        vm.deal(address(wallet), 1 ether);
        vm.prank(alice);
        wallet.submitTransaction(address(0), bob, 0.5 ether, "");
        vm.prank(bob);
        wallet.confirmTransaction(0);
        vm.prank(alice);
        wallet.confirmTransaction(0);
        uint256 before = bob.balance;
        vm.prank(alice);
        wallet.executeTransaction(0);
        assertEq(bob.balance, before + 0.5 ether);
        (, , , , bool executed, uint numConf) = wallet.getTransaction(0);
        assertTrue(executed);
        assertEq(numConf, 2);
    }

    function testSubmitAndConfirmAndExecuteERC20() public {
        vm.prank(alice);
        wallet.submitTransaction(address(token), bob, 100 ether, "");
        vm.prank(bob);
        wallet.confirmTransaction(0);
        vm.prank(alice);
        wallet.confirmTransaction(0);
        uint256 before = token.balanceOf(bob);
        vm.prank(bob);
        wallet.executeTransaction(0);
        assertEq(token.balanceOf(bob), before + 100 ether);
        (, , , , bool executed, uint numConf) = wallet.getTransaction(0);
        assertTrue(executed);
        assertEq(numConf, 2);
    }

    function testRevokeConfirmation() public {
        vm.prank(alice);
        wallet.submitTransaction(address(0), bob, 0.1 ether, "");
        vm.prank(alice);
        wallet.confirmTransaction(0);
        vm.prank(alice);
        wallet.revokeConfirmation(0);
        (, , , , , uint numConf) = wallet.getTransaction(0);
        assertEq(numConf, 0);
    }

    function test_Revert_When_ExecuteWithoutEnoughConfirm() public {
        vm.deal(address(wallet), 1 ether);
        vm.prank(alice);
        wallet.submitTransaction(address(0), bob, 0.5 ether, "");
        vm.prank(alice);
        wallet.confirmTransaction(0);
        // only 1 confirmation, expect revert when executing
        vm.expectRevert(bytes("cannot execute tx"));
        vm.prank(alice);
        wallet.executeTransaction(0);
    }
}
