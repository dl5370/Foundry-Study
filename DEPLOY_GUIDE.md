# 🚀 快速部署指南

本项目提供了**三种一键部署方式**，选择最适合您的方式即可。

## ✨ 最推荐：使用部署脚本（deploy.sh）

如果您已经在本地安装了 Foundry，这是最快最简单的方式。

### 📦 前置条件

- 本地已安装 Foundry：
  ```bash
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```

### 🚀 一键部署

```bash
# 进入项目目录
cd Foundry-Study

# 执行一键部署脚本（推荐）
./deploy.sh

# 或者使用 Makefile
make deploy
```

**这个命令会自动:**
1. ✅ 检查 Foundry 是否安装
2. ✅ 安装项目依赖
3. ✅ 编译智能合约
4. ✅ 运行所有测试
5. ✅ 启动本地 Anvil 节点
6. ✅ 部署合约到本地节点
7. ✅ 显示部署信息和下一步操作

### 📋 部署脚本用法

```bash
# 完整的本地部署（默认）
./deploy.sh local

# 仅运行测试
./deploy.sh test

# 仅编译合约
./deploy.sh build

# 清理所有生成的文件
./deploy.sh clean
```

---

## 🐳 Docker 方式（推荐团队开发）

如果您想要一致的开发环境，使用 Docker。

### 前置条件

- 安装 Docker Desktop：
  - [macOS/Windows](https://www.docker.com/products/docker-desktop)
  - [Linux](https://docs.docker.com/engine/install/)

### 部署步骤

```bash
# 方式 1：使用 Makefile（推荐）
make docker-deploy

# 方式 2：使用 Docker Compose
docker-compose up --build

# 方式 3：单独构建和运行
docker build -t foundry-study .
docker run -it --rm -v $(pwd):/workspace foundry-study
```

### 在容器中运行命令

```bash
# 进入容器
docker-compose run foundry-dev bash

# 或者直接运行命令
docker-compose run foundry-dev forge build
docker-compose run foundry-dev forge test
docker-compose run foundry-dev forge script script/DeployMultiSig.s.sol --rpc-url http://anvil:8545 --broadcast
```

---

## 🛠️ Makefile 命令速查

快速查看所有可用命令：

```bash
make help
```

### 常用命令

```bash
# 开发命令
make install       # 安装依赖
make build         # 编译合约
make test          # 运行测试
make format        # 代码格式化
make clean         # 清理文件

# 部署命令
make deploy        # 一键部署（推荐）
make deploy-local  # 部署到本地
make deploy-sepolia # 部署到 Sepolia 测试网

# 分析命令
make gas-report    # 生成气体报告
make coverage      # 测试覆盖率
make security      # 安全检查
```

---

## 📝 配置环境变量

在部署到测试网之前，需要配置环境变量来存储敏感信息（API Key、私钥等）。

### 第一次配置

```bash
# 1. 从模板创建配置文件
cp .env.example .env

# 2. 编辑 .env 文件（使用你喜欢的编辑器）
nano .env

# 3. 填入以下信息：
#    - ALCHEMY_API_KEY: 从 https://www.alchemy.com/ 获取
#    - PRIVATE_KEY: 你的钱包私钥（不含 0x 前缀）
#    - ETHERSCAN_API_KEY: 从 https://etherscan.io/myapikey 获取（可选，用于合约验证）
```

### 自动配置（推荐）

如果 `.env` 文件不存在，`deploy.sh` 会自动提示你创建：

```bash
./deploy.sh sepolia

# 脚本会提示：
# 是否从 .env.example 创建 .env 文件? (y/n): y
# .env 文件已创建
# 请编辑 .env 文件，填入你的实际配置：
#   ALCHEMY_API_KEY - Alchemy API 密钥
#   PRIVATE_KEY - 部署账户私钥
#   ETHERSCAN_API_KEY - Etherscan API 密钥（用于验证合约）
```

### 安全提示

⚠️ **重要安全措施**：

- ✅ `.env` 文件已在 `.gitignore` 中，**不会被提交到 git**
- ✅ **永远不要在版本控制中提交真实的私钥和 API Key**
- ✅ 使用**测试网账户**进行开发，不要使用主网账户
- ✅ 定期**轮换 API Key**
- ✅ 对于生产环境，考虑使用**硬件钱包**

### 各配置项说明

| 配置项 | 说明 | 获取方式 |
|--------|------|---------|
| `ALCHEMY_API_KEY` | 以太坊网络 RPC 访问密钥 | https://www.alchemy.com/ |
| `PRIVATE_KEY` | 部署账户的私钥 | MetaMask、Hardhat 等钱包导出 |
| `ETHERSCAN_API_KEY` | 合约验证密钥（可选） | https://etherscan.io/myapikey |
| `OPTIMIZER_ENABLED` | 是否启用 Solidity 优化器 | true/false |
| `OPTIMIZER_RUNS` | 优化运行次数 | 200（默认） |

---



## 🌐 部署到测试网（Sepolia）

### 前置条件

1. ✅ 已配置 `.env` 文件（参见上面的"配置环境变量"章节）
2. ✅ 获取 Alchemy API Key：https://www.alchemy.com/
3. ✅ 生成私钥并获取测试网 ETH：https://sepoliafaucet.com/

### 一键部署（推荐）

使用 `deploy.sh` 脚本自动完成所有步骤：

```bash
# 使用 deploy.sh（会自动检查 .env 配置）
./deploy.sh sepolia

# 脚本会自动：
# 1. ✅ 检查 .env 文件是否存在
# 2. ✅ 验证必需的环境变量（ALCHEMY_API_KEY, PRIVATE_KEY）
# 3. ✅ 编译合约
# 4. ✅ 运行测试确保代码正常
# 5. ✅ 部署到 Sepolia 测试网
# 6. ✅ 自动验证合约（如果配置了 ETHERSCAN_API_KEY）
```

### 使用 Makefile

```bash
# 更简洁的方式
make deploy-sepolia
```

### 手动部署

如果你想手动控制部署流程：

```bash
# 1. 加载环境变量
source .env

# 2. 检查 .env 中的变量是否正确
echo $ALCHEMY_API_KEY
echo $PRIVATE_KEY

# 3. 部署并验证
forge script script/DeployMultiSig.s.sol:DeployMultiSig \
  --rpc-url sepolia \
  --broadcast \
  --verify \
  --private-key $PRIVATE_KEY
```

### 部署后

部署完成后，你可以：

```bash
# 查看部署记录
cat broadcast/DeployMultiSig.s.sol/11155111/run-latest.json

# 在 Sepolia Etherscan 上查看合约
# https://sepolia.etherscan.io/address/<CONTRACT_ADDRESS>

# 与合约交互
cast call <CONTRACT_ADDRESS> "getOwners()(address[])" --rpc-url sepolia
```

---

## ✅ 验证部署

### 查看部署结果

部署成功后，部署信息会保存在：
```
broadcast/DeployMultiSig.s.sol/31337/run-latest.json
```

### 与合约交互

```bash
# 查询账户余额
cast balance <ADDRESS>

# 调用合约函数
cast call <CONTRACT_ADDRESS> "functionName()(uint256)"

# 发送交易
cast send <CONTRACT_ADDRESS> "functionName(uint256)" 100 \
  --private-key <PRIVATE_KEY>
```

---

## 🌐 使用 Web3 dApp 交互

部署完成后，可以使用交互式 Web3 应用：

```bash
# 打开 Web3 dApp
open docs/MultiSigWallet_Web3.html

# 或者使用模拟器
open docs/MultiSigWallet_Simulator.html
```

---

## 🚨 常见问题

### 问题 1：端口 8545 已被占用
```bash
# 查看占用端口的进程
lsof -i :8545

# 杀死进程
kill -9 <PID>

# 或者使用脚本自动清理
./deploy.sh clean
```

### 问题 2：权限不足错误
```bash
# 确保脚本有执行权限
chmod +x deploy.sh
chmod +x Makefile
```

### 问题 3：Foundry 不在 PATH 中
```bash
# 重新安装 Foundry
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc  # 或 ~/.zshrc

# 验证安装
foundryup
forge --version
```

### 问题 4：Docker 构建失败
```bash
# 清理 Docker 缓存
docker system prune -a

# 重新构建
docker build --no-cache -t foundry-study .
```

---

## 📚 更多资源

- 📖 [Foundry 官方文档](https://book.getfoundry.sh/)
- 🔗 [Forge-std 库](https://github.com/foundry-rs/forge-std)
- 🛡️ [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
- 💻 [Solidity 文档](https://docs.soliditylang.org/)

---

## 🎯 下一步

部署完成后，您可以：

1. ✅ 修改 `src/` 中的智能合约
2. ✅ 添加测试到 `test/` 目录
3. ✅ 运行 `make test` 验证代码
4. ✅ 使用 Web3 dApp 与合约交互
5. ✅ 部署到其他网络

---

**祝您开发愉快！如有问题，请查阅官方文档或提交 Issue。** 🚀