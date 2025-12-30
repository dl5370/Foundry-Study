// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract DeployMultiSig is Script {
    function run() public {
        // 使用 Anvil 的默认账户作为部署者
        uint256 deployerKey = vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));

        vm.startBroadcast(deployerKey);

        // 1. 定义三个所有者地址（使用 Anvil 的默认账户）
        address[] memory owners = new address[](3);
        owners[0] = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Anvil 账户 #0 (Alice)
        owners[1] = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8; // Anvil 账户 #1 (Bob)
        owners[2] = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC; // Anvil 账户 #2 (Carol)

        // 2. 部署 MultiSigWallet (需要 2/3 签名)
        MultiSigWallet wallet = new MultiSigWallet(owners, 2);
        console.log("MultiSigWallet deployed at:", address(wallet));
        console.log("Required signatures: 2 of 3");
        console.log("Owner 1 (Alice):", owners[0]);
        console.log("Owner 2 (Bob):", owners[1]);
        console.log("Owner 3 (Carol):", owners[2]);

        // 3. 部署 MockERC20 代币
        MockERC20 token = new MockERC20();
        console.log("MockERC20 deployed at:", address(token));

        // 4. 给钱包铸造 1000 个代币
        uint256 initialAmount = 1000 ether;
        token.mint(address(wallet), initialAmount);
        console.log("Minted to wallet:", initialAmount / 1e18, "MTK");
        console.log("Wallet token balance:", token.balanceOf(address(wallet)) / 1e18, "MTK");

        vm.stopBroadcast();

        // 输出部署信息（方便前端使用）
        console.log("\n========== Deployment Summary ==========");
        console.log("Network: Localhost (Anvil)");
        console.log("MultiSigWallet:", address(wallet));
        console.log("MockERC20:", address(token));
        console.log("========================================");
    }
}
