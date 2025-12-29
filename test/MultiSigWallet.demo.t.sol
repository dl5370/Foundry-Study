// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
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

contract MultiSigWalletDemoTest is Test {
    MultiSigWallet wallet;
    ERC20Mock token;
    address alice = address(0x1);
    address bob = address(0x2);
    address carol = address(0x3);
    address david = address(0x4); // receiver

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = alice;
        owners[1] = bob;
        owners[2] = carol;
        wallet = new MultiSigWallet(owners, 2); // 需要2个签名
        token = new ERC20Mock();
        
        console.log("Init MultiSigWallet");
        console.log("Wallet address:", address(wallet));
        console.log("Token address:", address(token));
        console.log("Owner 1 (Alice):", alice);
        console.log("Owner 2 (Bob):", bob);
        console.log("Owner 3 (Carol):", carol);
        console.log("Receiver (David):", david);
        console.log("Required: 2 of 3 signatures");
    }

    function test_Demo_Complete_MultiSig_Flow() public {
        // ========== 第1步：铸造 Token 到钱包 ==========
        console.log("Step 1: Mint Token");
        uint256 mintAmount = 1000 ether;
        token.mint(address(wallet), mintAmount);
        console.log("Minted amount:", mintAmount / 1e18, "MTK");
        console.log("Wallet balance:", token.balanceOf(address(wallet)) / 1e18, "MTK");

        // ========== 第2步：Alice 提交转账交易 ==========
        console.log("Step 2: Alice Submit Transaction");
        uint256 transferAmount = 100 ether;
        vm.prank(alice);
        wallet.submitTransaction(address(token), david, transferAmount, "");
        console.log("Alice submitted TX 0");
        console.log("Token:", address(token));
        console.log("To:", david);
        console.log("Amount:", transferAmount / 1e18, "MTK");
        
        (address tkn, address to, uint256 value, , bool executed, uint256 numConf) = wallet.getTransaction(0);
        console.log("TX 0 status - Confirmations:", numConf);
        console.log("TX 0 status - Executed:", executed);
        console.log("Confirmed owners:");
        address[] memory confirmed = wallet.getConfirmations(0);
        if (confirmed.length == 0) {
            console.log("  (none)");
        } else {
            for (uint i = 0; i < confirmed.length; i++) {
                console.log("  ", confirmed[i]);
            }
        }

        // ========== 第3步：Bob 确认交易 ==========
        console.log("Step 3: Bob Confirms TX 0");
        vm.prank(bob);
        wallet.confirmTransaction(0);
        console.log("Bob confirmed");
        
        (, , , , executed, numConf) = wallet.getTransaction(0);
        console.log("TX 0 status - Confirmations:", numConf);
        console.log("TX 0 status - Executed:", executed);
        console.log("Confirmed owners:");
        confirmed = wallet.getConfirmations(0);
        if (confirmed.length == 0) {
            console.log("  (none)");
        } else {
            for (uint i = 0; i < confirmed.length; i++) {
                console.log("  ", confirmed[i]);
            }
        }

        // ========== 第4步：Carol 确认交易 ==========
        console.log("Step 4: Carol Confirms TX 0");
        vm.prank(carol);
        wallet.confirmTransaction(0);
        console.log("Carol confirmed");
        
        (, , , , executed, numConf) = wallet.getTransaction(0);
        console.log("TX 0 status - Confirmations:", numConf);
        console.log("TX 0 status - Executed:", executed);
        console.log("Confirmed owners:");
        confirmed = wallet.getConfirmations(0);
        if (confirmed.length == 0) {
            console.log("  (none)");
        } else {
            for (uint i = 0; i < confirmed.length; i++) {
                console.log("  ", confirmed[i]);
            }
        }
        
        // 新增：检查交易是否已准备好执行
        bool isReady = wallet.isTransactionReady(0);
        if (isReady) {
            console.log("=== NOTIFICATION: TX 0 is READY for execution! ===");
        }

        // ========== 第5步：Alice 执行交易 ==========
        console.log("Step 5: Alice Executes TX 0");
        uint256 davidBalanceBefore = token.balanceOf(david);
        uint256 walletBalanceBefore = token.balanceOf(address(wallet));
        
        // 新增：Alice 先检查交易是否已准备好
        bool isReadyBeforeExecution = wallet.isTransactionReady(0);
        console.log("Is TX 0 ready to execute?", isReadyBeforeExecution);
        
        vm.prank(alice);
        wallet.executeTransaction(0);
        console.log("Alice executed");
        
        uint256 davidBalanceAfter = token.balanceOf(david);
        uint256 walletBalanceAfter = token.balanceOf(address(wallet));
        
        console.log("Result:");
        console.log("David balance before:", davidBalanceBefore / 1e18, "MTK");
        console.log("David balance after:", davidBalanceAfter / 1e18, "MTK");
        console.log("Wallet balance before:", walletBalanceBefore / 1e18, "MTK");
        console.log("Wallet balance after:", walletBalanceAfter / 1e18, "MTK");
        
        (, , , , executed, numConf) = wallet.getTransaction(0);
        console.log("Final TX 0 status - Confirmations:", numConf);
        console.log("Final TX 0 status - Executed:", executed);
        
        // Verify
        assertEq(davidBalanceAfter, davidBalanceBefore + transferAmount);
        assertEq(walletBalanceAfter, walletBalanceBefore - transferAmount);
        assertTrue(executed);
        
        console.log("Demo completed successfully!");
    }
}
