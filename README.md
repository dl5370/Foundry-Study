# Foundry Web3 Development Environment

这是一个完整的 Foundry Web3 开发环境，用于智能合约的开发、测试和部署。

## 🎮 交互式模拟器

在浏览器中实时体验多签钱包的完整流程：
- ✅ 模拟交易提交
- ✅ 多人签名确认
- ✅ 阈值达成事件通知
- ✅ 交易执行
- 📝 实时事件日志

### 如何打开模拟器

**方式 1：克隆到本地后双击文件**
```bash
# 克隆仓库
git clone <your-repo-url>
cd Foundry-Study

# 在 Finder 中找到 docs/MultiSigWallet_Simulator.html 文件，双击即可在浏览器中打开
```

**方式 2：使用命令行打开**
```bash
# macOS
open docs/MultiSigWallet_Simulator.html

# Linux
xdg-open docs/MultiSigWallet_Simulator.html

# Windows
start docs/MultiSigWallet_Simulator.html
```

**方式 3：拖放到浏览器**
- 直接将 `docs/MultiSigWallet_Simulator.html` 文件拖到浏览器窗口中

> **注意**：模拟器是纯静态 HTML 文件，无需安装依赖或启动服务器，下载后即可直接在浏览器中打开使用。

## 目录结构

```
foundry-web3-study/
├── src/                           # 智能合约源代码
├── test/                          # 测试文件
├── script/                        # 部署脚本
│   └── DeployMultiSig.s.sol      # 多签钱包部署脚本
├── lib/                           # 依赖库
├── docs/                          # 文档和前端
│   ├── MultiSigWallet_Simulator.html      # 模拟器
│   └── MultiSigWallet_Web3.html           # Web3 dApp（实时合约交互）
├── .github/
│   └── workflows/
│       └── foundry.yml            # GitHub Actions CI/CD 配置
├── Dockerfile                     # Docker 开发环境
├── docker-compose.yml             # Docker Compose 编排
├── foundry.toml                   # Foundry 配置文件
├── package.json                   # Node.js 项目配置
└── README.md                      # 项目文档
```

## 🚀 快速开始（三种方式）

选择最适合你的方式开始开发：

### 方式 1️⃣：GitHub Codespaces（推荐新人，零配置）

最简单的方式，无需安装任何东西！

1. 在本仓库首页点击 `Code` 按钮
2. 点击 `Codespaces` 选项卡
3. 点击 `Create codespace on feature/realCallSol`
4. 等待环境初始化（约 2 分钟）
5. 在终端中运行：

```bash
# 编译合约
forge build

# 运行测试
forge test

# 启动本地区块链
anvil
```

**优点**：✅ 零配置 | ✅ 浏览器中开发 | ✅ 免费额度充足

---

### 方式 2️⃣：Docker（推荐团队开发）

需要安装 Docker 和 Docker Compose，但完全避免本地环境配置。

**安装 Docker**（如果还没有）：
- [Docker Desktop - macOS/Windows](https://www.docker.com/products/docker-desktop)
- [Docker - Linux](https://docs.docker.com/engine/install/)

**启动开发环境**：

```bash
# 选项 A：仅启动开发容器
docker-compose run foundry-dev bash

# 选项 B：同时启动开发容器和 Anvil 区块链节点
docker-compose up
```

**在容器中运行命令**：

```bash
# 编译合约
forge build

# 运行测试
forge test

# 部署到 Anvil（如果启用了 anvil 服务）
forge script script/DeployMultiSig.s.sol --rpc-url http://anvil:8545 --broadcast
```

**优点**：✅ 一致的开发环境 | ✅ 适合团队 | ✅ 易于扩展

---

### 方式 3️⃣：本地安装（高级开发者）

需要在本地安装 Rust 和 Foundry。

#### 1. 安装 Foundry

如果还没有安装 Foundry，请运行：

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

#### 2. 安装依赖

```bash
forge install
```

#### 3. 编译合约

```bash
forge build
```

#### 4. 运行测试

```bash
# 运行所有测试
forge test

# 运行特定测试文件
forge test --match-path test/Counter.t.sol

# 显示气体报告
forge test --gas-report

# Fuzz 测试（模糊测试）
forge test --match-test testFuzz
```

#### 5. 本地开发（可选）

启动本地 Anvil 节点：

```bash
anvil
```

在另一个终端部署合约：

```bash
forge script script/DeployMultiSig.s.sol --rpc-url localhost --broadcast
```

#### 6. 部署到测试网

设置环境变量（Sepolia 示例）：

```bash
export ALCHEMY_API_KEY="your_alchemy_api_key"
export PRIVATE_KEY="your_private_key"
```

部署合约：

```bash
forge script script/Deploy.s.sol:Deploy --rpc-url sepolia --broadcast --verify
```

---

## 📋 CI/CD 自动化

本项目配置了 **GitHub Actions**，会自动在以下情况运行：

- 💾 **推送代码** - 自动运行测试和编译
- 📝 **提交 PR** - 自动验证代码质量
- ✅ **检查内容**：
  - 编译合约
  - 运行测试
  - 检查代码格式
  - 验证部署脚本

你可以在 **Actions** 标签页查看执行结果。

## 项目文件说明

### src/Counter.sol
示例智能合约，演示基本的合约编写：
- ✅ 状态变量管理
- ✅ 事件触发
- ✅ 访问控制修饰符示例
- ✅ 函数实现最佳实践

### test/Counter.t.sol
完整的测试套件，包括：
- ✅ 单元测试
- ✅ 异常处理测试
- ✅ Fuzz 测试（模糊测试）

### src/MultiSigWallet.sol
多签钱包智能合约，支持 ETH 和 ERC20：
- ✅ M-of-N 多签架构（可配置阈值）
- ✅ ETH 和 ERC20 代币转账支持
- ✅ 交易提交、确认、撤销、执行完整流程
- ✅ 透明的确认状态查询
- ✅ 阈值达成事件通知机制

### test/MultiSigWallet.t.sol
多签钱包核心功能测试：
- ✅ ETH 转账测试
- ✅ ERC20 转账测试
- ✅ 确认撤销测试
- ✅ 权限控制测试

### test/MultiSigWallet.demo.t.sol
完整的端对端演示测试，展示：
- ✅ 多签钱包的完整工作流程
- ✅ 从铸币到执行的全过程
- ✅ 通知机制的实际应用

### script/Deploy.s.sol
部署脚本示例：
- ✅ 支持本地 Anvil 部署
- ✅ 支持公共测试网部署
- ✅ 支持主网部署（需谨慎）

## 多签钱包流程图

### 交易执行流程

下图展示了多签钱包的完整交易流程（GitHub 原生支持）：

```mermaid
sequenceDiagram
    participant Alice
    participant Bob
    participant Carol
    participant Wallet
    participant Token
    participant David

    rect rgb(200, 240, 200)
    Note over Alice,David: Init: Create Wallet (3 owners, 2-of-3)
    Alice->>Wallet: new MultiSigWallet([A,B,C], 2)
    end

    rect rgb(200, 240, 200)
    Note over Alice,Token: Step 1: Mint Token
    Alice->>Token: mint(wallet, 1000 MTK)
    Token->>Token: balanceOf[wallet] = 1000
    end

    rect rgb(200, 240, 200)
    Note over Alice,Wallet: Step 2: Alice Submit Transaction
    Alice->>Wallet: submitTransaction(MTK, David, 100)
    Note over Wallet: txId=0<br/>numConfirmations=0<br/>executed=false
    end

    rect rgb(200, 240, 200)
    Note over Bob,Wallet: Step 3: Bob Confirms (1/2)
    Bob->>Wallet: confirmTransaction(0)
    Note over Wallet: numConfirmations=1<br/>Need 1 more
    end

    rect rgb(240, 200, 200)
    Note over Carol,Wallet: Step 4: Carol Confirms (2/2) ⭐ THRESHOLD!
    Carol->>Wallet: confirmTransaction(0)
    Note over Wallet: numConfirmations=2<br/>Threshold Reached!<br/>Event: ConfirmationThresholdReached
    Wallet-->>Carol: ✅ Confirmed (2/2)
    end

    rect rgb(200, 200, 240)
    Note over Alice,Wallet: Step 5: Check If Ready
    Alice->>Wallet: isTransactionReady(0)
    Wallet-->>Alice: true
    end

    rect rgb(200, 240, 200)
    Note over Alice,David: Step 6: Execute Transaction
    Alice->>Wallet: executeTransaction(0)
    Wallet->>Token: transfer(100 to David)
    Token->>David: Receive 100 MTK
    Note over Wallet: executed=true
    Wallet-->>Alice: ✅ Success
    end

    rect rgb(240, 240, 200)
    Note over Alice,David: Final State
    Note over Wallet: Wallet: 900 MTK
    Note over David: David: 100 MTK
    Note over Wallet: TX 0: executed ✓
    end
```

**流程说明：**
1. **初始化** - 创建 3 个所有者的钱包，设置 2/3 的签名阈值
2. **铸币** - 为钱包铸造 1000 MTK 代币
3. **提交交易** - Alice 提交转账 100 MTK 给 David 的交易（txId=0）
4. **Bob 确认** - 第一个确认者签名（1/2）
5. **Carol 确认** - 第二个确认者签名，达到阈值（2/2） ⭐ **触发通知事件**
6. **检查就绪状态** - `isTransactionReady()` 返回 `true`，交易已准备好执行
7. **执行交易** - Alice 执行交易，完成转账给 David
8. **最终状态** - 交易已执行，余额更新完成（Wallet: 900 MTK, David: 100 MTK）

## 常用命令

```bash
# 编译
forge build

# 测试
forge test
forge test -v                    # 详细输出
forge test --gas-report         # 显示气体使用情况

# 部署
forge create src/Counter.sol:Counter --rpc-url <RPC_URL> --private-key <PRIVATE_KEY>

# 格式化代码
forge fmt

# 查看合约 ABI
forge inspect Counter abi

# 本地开发
anvil                            # 启动本地节点
cast send <ADDRESS> <FUNCTION>   # 调用函数
cast call <ADDRESS> <FUNCTION>   # 读取状态
```

## Foundry 特性

- 🔥 **Solidity 原生开发** - 用 Solidity 编写测试
- ⚡ **快速编译** - 极快的编译速度
- 🧪 **强大的测试框架** - 支持单元测试、集成测试、Fuzz 测试
- 📊 **气体分析** - 详细的气体使用报告
- 🚀 **脚本和模拟** - 灵活的部署和交互脚本
- 📝 **Cheatcodes** - 强大的测试 cheatcodes

## 有用的资源

- [Foundry 官方文档](https://book.getfoundry.sh/)
- [Forge-std 库](https://github.com/foundry-rs/forge-std)
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
- [Solidity 文档](https://docs.soliditylang.org/)

## 注意事项

⚠️ **安全提示**：
- 永远不要在版本控制中提交私钥
- 在主网部署前充分测试
- 使用 `.env` 文件管理敏感信息
- 部署前进行代码审计

## 许可证

MIT
