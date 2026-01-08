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

## 🌐 部署到测试网（Sepolia）

### 前置条件

1. 获取 Alchemy API Key：https://www.alchemy.com/
2. 生成私钥（确保账户有测试网 ETH）

### 部署步骤

```bash
# 方式 1：使用 Makefile
export PRIVATE_KEY="your_private_key"
export ALCHEMY_API_KEY="your_alchemy_api_key"
make deploy-sepolia

# 方式 2：直接使用 forge 命令
forge script script/Deploy.s.sol:Deploy \
  --rpc-url sepolia \
  --broadcast \
  --verify \
  --private-key $PRIVATE_KEY
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