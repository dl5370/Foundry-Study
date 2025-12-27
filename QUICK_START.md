# Foundry 快速开始指南

## ✅ 已完成的配置

你的 F### 📝 基本命令

编译合约：
```bash
forge build
```

运行所有测试：
```bash
forge test
```

运行特定测试：
```bash
forge test --match-test test_Increment
```

显示气体报告：
```bash
forge test --gas-report
```

使用 Fuzz 测试：
```bash
forge test --match-test testFuzz
```经初始化完成，包含：

- `src/` - 智能合约源代码（Counter.sol）
- `test/` - 测试文件（Counter.t.sol）
- `script/` - 部署脚本（Deploy.s.sol）
- `foundry.toml` - Foundry 配置文件
- `package.json` - NPM 配置文件

## 🔧 环境配置

### 1. 下载 forge-std 库

forge 编译完成后，进入项目目录：

```bash
cd /Users/dulu/IdeaProjects/git5370/Foundry-Study
forge install foundry-rs/forge-std
```

### 2. 配置环境变量

复制 `.env.example` 为 `.env` 并填入你的实际信息：

```bash
cp .env.example .env
# 然后编辑 .env 文件，填入：
# - ALCHEMY_API_KEY
# - PRIVATE_KEY（仅用于测试）
# - ETHERSCAN_API_KEY（可选）
```

## 📝 基本命令

编译合约：
```bash
forge build
```

运行测试：
```bash
forge test
```

显示气体报告：
```bash
forge test --gas-report
```

本地开发（启动 Anvil 节点）：
```bash
anvil
```

在另一个终端部署到本地网络：
```bash
forge script script/Deploy.s.sol:Deploy --rpc-url localhost --broadcast
```

## 🚀 部署到测试网（Sepolia）

1. 设置环境变量
2. 运行部署脚本：
```bash
forge script script/Deploy.s.sol:Deploy --rpc-url sepolia --broadcast --verify
```

## 📚 文件说明

### src/Counter.sol
- 简单的计数器合约示例
- 包含基本的增加、减少和设置函数
- 有事件日志

### test/Counter.t.sol
- 完整的测试套件
- 包含单元测试和 Fuzz 测试
- 演示了错误处理测试

### script/Deploy.s.sol
- 部署脚本示例
- 支持本地和公网部署
- 使用环境变量读取私钥

## ⚙️ Foundry PATH 配置

PATH 已配置到：
```
/Users/dulu/Downloads/foundry-master/target/release
```

如果 `forge` 命令不工作，请运行：
```bash
source ~/.zshrc
```

或重新启动你的 shell。

## 💡 下一步

1. ✅ 等待 forge 编译完成
2. ✅ 运行 `forge install` 下载依赖
3. ✅ 运行 `forge test` 验证环境
4. ✅ 开始编写你的智能合约！

## 🔗 有用链接

- [Foundry Book](https://book.getfoundry.sh/)
- [Forge-std Library](https://github.com/foundry-rs/forge-std)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)

---

**项目根目录**：`/Users/dulu/IdeaProjects/git5370/Foundry-Study`
**Foundry 源码**：`/Users/dulu/Downloads/foundry-master`
