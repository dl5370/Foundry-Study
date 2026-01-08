# 🔄 持久部署管理指南

本指南说明如何使用新的持久部署系统来保存和管理合约部署记录。

---

## 📋 核心概念

### **持久部署的优势**

- ✅ **自动保存** - 每次部署都自动保存部署记录
- ✅ **历史追踪** - 保留所有部署的时间戳版本
- ✅ **快速切换** - 无需重新部署，快速加载历史版本
- ✅ **自动更新** - `.env.deployed` 自动更新，网页自动读取

### **文件结构**

```
your-project/
├── deployments/              ← 持久部署目录
│   └── local/
│       ├── latest.json       ← 最新部署（当前活跃）
│       └── history/          ← 历史部署存档
│           ├── 20250109-143022.json
│           ├── 20250109-140015.json
│           └── ...
├── .env.deployed            ← 当前部署的环境变量（自动生成）
├── broadcast/               ← Foundry 临时部署记录（每次部署覆盖）
└── tools/                   ← 部署管理工具脚本
    ├── current-deployment.sh
    ├── list-deployments.sh
    └── load-deployment.sh
```

---

## 🚀 **快速开始**

### **第一次部署**

```bash
# 部署合约（自动保存到持久化目录）
./deploy.sh local

# 输出会显示：
# ✅ 已保存部署到: deployments/local/latest.json
# ✅ 已创建历史记录: deployments/local/history/20250109-143022.json
# ✅ 已更新 .env.deployed
#
# 📦 已部署的合约:
#   MultiSigWallet: 0x5fbdb2315678afecb367f032d93f642f64180aa3
#   MockERC20: 0xe7f1725e7734ce288f8367e1bb143e90bb3f0512
```

### **查看当前部署**

```bash
./tools/current-deployment.sh

# 输出：
# ════════════════════════════════════════
# 📋 当前部署信息
# ════════════════════════════════════════
#
# 🌐 网络信息
# ℹ️  网络: local
# ℹ️  RPC URL: http://localhost:8545
# ℹ️  部署时间: 2025-01-09T14:30:22Z
#
# 📦 合约地址
# MultiSigWallet:
#   0x5fbdb2315678afecb367f032d93f642f64180aa3
#
# MockERC20 (Token):
#   0xe7f1725e7734ce288f8367e1bb143e90bb3f0512
# ...
```

### **查看部署历史**

```bash
./tools/list-deployments.sh

# 输出：
# ════════════════════════════════════════
# 📋 部署历史列表
# ════════════════════════════════════════
#
# ⭐ 当前部署 (latest)
#   deployments/local/latest.json - 2345 bytes
#   MultiSigWallet: 0x5fbdb...
#   MockERC20: 0xe7f1...
#
# 📚 历史部署 (共 3 个)
#   20250109-143022.json  -  2345 bytes
#   20250109-140015.json  -  2345 bytes
#   20250109-135010.json  -  2345 bytes
```

---

## 🔄 **常见场景**

### **场景 1：再次进入项目**

```bash
# 1. 启动本地节点
./deploy.sh local

# 2. 打开网页（合约地址自动加载）
open http://localhost:8080/MultiSigWallet_Web3.html

# ✅ 完成！网页会自动从 .env.deployed 读取合约地址
```

### **场景 2：需要恢复之前的部署**

```bash
# 1. 查看历史部署
./tools/list-deployments.sh

# 2. 加载特定的历史版本
./tools/load-deployment.sh 20250109-140015.json

# 3. 更新 .env.deployed
# ✅ 完成！网页刷新后会使用旧地址

# 4. 注意：旧合约仍在 Anvil 上，可以继续使用
```

### **场景 3：对比多个部署**

```bash
# 方式 1：临时查看不同部署的地址
./tools/load-deployment.sh 20250109-140015.json
./tools/current-deployment.sh

# 方式 2：查看所有部署信息
./tools/list-deployments.sh

# 查看具体部署文件
cat deployments/local/history/20250109-140015.json | jq '.transactions[] | {name: .contractName, address: .contractAddress}'
```

---

## 📊 **.env.deployed 文件说明**

该文件自动生成，无需手动编辑。内容包括：

```bash
# 当前活跃网络
DEPLOYED_NETWORK=local

# RPC 连接信息
DEPLOYED_RPC_URL=http://localhost:8545

# 合约地址（最重要的！）
MULTISIG_ADDRESS=0x5fbdb...
TOKEN_ADDRESS=0xe7f1...

# 部署时间戳
DEPLOYED_TIMESTAMP=2025-01-09T14:30:22Z
DEPLOYED_BLOCK=0

# 所有者地址（固定不变）
OWNER_ALICE=0xf39Fd...
OWNER_BOB=0x70997...
OWNER_CAROL=0x3C44C...

# 合约配置（固定不变）
MULTISIG_REQUIRED_SIGNATURES=2
MULTISIG_TOTAL_OWNERS=3
TOKEN_INITIAL_SUPPLY=1000
```

---

## 🛠️ **进阶用法**

### **从 .env.deployed 读取值**

在 shell 脚本中：
```bash
source .env.deployed

echo "当前合约地址: $MULTISIG_ADDRESS"
echo "部署时间: $DEPLOYED_TIMESTAMP"
```

### **从 JSON 提取原始信息**

```bash
# 查看最新部署的完整交易信息
jq '.' deployments/local/latest.json

# 只查看合约地址
jq '.transactions[] | select(.contractName) | {name: .contractName, address: .contractAddress}' deployments/local/latest.json

# 查看部署信息汇总
jq '.summary' deployments/local/latest.json
```

### **自动化加载特定部署**

```bash
# 创建脚本：load-yesterday.sh
#!/bin/bash
YESTERDAY=$(find deployments/local/history -name "*.json" | sort -r | head -2 | tail -1 | xargs basename)
./tools/load-deployment.sh "$YESTERDAY"
```

---

## ✅ **检查清单**

部署后确认以下各项：

- [ ] `./tools/current-deployment.sh` 显示正确的合约地址
- [ ] `.env.deployed` 文件存在并包含合约地址
- [ ] `deployments/local/latest.json` 存在
- [ ] `deployments/local/history/` 目录包含时间戳版本
- [ ] 网页刷新后自动显示新合约地址

---

## 🔐 **安全提示**

⚠️ **重要**：

- `.env.deployed` 被 `.gitignore` 忽略，不会被提交到 git
- 不要手动编辑 `.env.deployed`（由 `deploy.sh` 自动维护）
- `deployments/` 目录可以提交到 git（因为不含敏感信息）
- 每个部署记录都是只读的历史快照

---

## 📞 **常见问题**

### **Q: 如何手动切换到旧部署？**

```bash
./tools/load-deployment.sh <timestamp>.json
# 然后刷新网页
```

### **Q: 如何删除历史部署？**

```bash
# 删除特定版本（不推荐）
rm deployments/local/history/20250109-135010.json

# 清空所有历史（保留最新）
rm deployments/local/history/*
```

### **Q: 为什么有两个部署文件？**

- `broadcast/` - Foundry 的临时文件（每次部署覆盖）
- `deployments/` - 我们的持久文件（保留历史）

### **Q: 网页仍显示旧地址？**

```bash
# 方案 1：硬刷新网页
Cmd+Shift+R (Mac) 或 Ctrl+Shift+R (Windows)

# 方案 2：查看当前部署
./tools/current-deployment.sh

# 方案 3：重新加载部署
./tools/load-deployment.sh <filename>
./tools/current-deployment.sh
```

---

## 🎯 **工作流总结**

```
第一次：./deploy.sh local
        ↓
查看：./tools/current-deployment.sh
        ↓
使用：打开网页，自动加载地址
        ↓
        ↓
下次：./deploy.sh local
        ↓
新部署自动保存，.env.deployed 自动更新
        ↓
网页刷新，自动显示新地址
        ↓
        ↓
需要旧部署？./tools/load-deployment.sh <timestamp>
        ↓
.env.deployed 更新，网页刷新
        ↓
完成！
```

---

**就是这样！🎉 持久部署系统已就绪，自动管理所有部署记录。**
