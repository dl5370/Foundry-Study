// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Counter} from "../src/Counter.sol";

contract Deploy is Script {
    function run() public {
        // 从环境变量中获取私钥
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerKey);
        
        Counter counter = new Counter();
        
        vm.stopBroadcast();
        
        // 输出部署信息
        console.log("Counter deployed at:", address(counter));
    }
}
