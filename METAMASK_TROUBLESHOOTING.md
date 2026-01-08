# MetaMask 连接故障排除指南

## 问题诊断

如果您遇到 "未检测到 MetaMask 钱包扩展" 错误，但 MetaMask 插件实际上已安装，这通常是由以下原因引起的：

### 🔍 根本原因分析

**错误信息**: `window.ethereum: undefined`
**HTTP 错误**: `net::ERR_CONNECTION_CLOSED` 在加载 ethers.js 库时
**原因**: Chrome 浏览器阻止了网站对 MetaMask 扩展的访问权限

---

## 🛠️ 快速修复步骤（推荐）

### 第 1 步：运行系统诊断

1. 打开 `MultiSigWallet_Web3.html`
2. 查看事件日志（页面底部）
3. **点击「🔧 运行诊断」按钮**
4. 查看诊断结果

**正常输出示例**:
```
✅ ethers.js 库已加载
✅ window.ethereum 对象已检测到
```

**问题输出示例**:
```
❌ ethers.js 库未加载（将尝试备用 CDN）
❌ window.ethereum 未检测到 - Chrome 可能阻止了 MetaMask 访问
```

---

### 第 2 步：允许网站访问 MetaMask（解决方案 A - 推荐）

#### 在 Chrome 中：

1. **打开网页** - 访问 `MultiSigWallet_Web3.html`
2. **点击地址栏右侧的锁图标** 🔒
   ```
   地址栏右侧通常显示: 🔒 | 🔊 | 🧩 | ...
   ```
3. **选择选项**（取决于您的 Chrome 版本）：

   **选项 A**（较新版本）:
   - 点击「网站设置」或「此网站的设置」
   - 找到「扩展程序访问权限」
   - 点击 MetaMask 旁边的下拉菜单
   - 选择「允许此网站」或「启用」

   **选项 B**（较旧版本）:
   - 点击「权限」或「隐私设置」
   - 找到「扩展程序」或「插件」
   - 确保 MetaMask 设置为"允许"

4. **刷新页面** - 按 `F5` 或 `Cmd+R`
5. **测试连接** - 点击「连接 MetaMask」按钮

---

### 第 3 步：高级重试选项

如果第 2 步未能解决问题，尝试以下操作：

#### 选项 1：手动重检 MetaMask
1. 点击「🔄 重新检查 MetaMask」按钮
2. 页面将尝试 5 次检测（间隔：0ms、500ms、1000ms、2000ms、3000ms）
3. 查看事件日志中的重试进度

#### 选项 2：清除浏览器缓存
1. 按 `Cmd+Shift+Delete`（Mac）或 `Ctrl+Shift+Delete`（Windows）
2. 选择时间范围：「过去 1 小时」
3. 勾选：
   - ☑️ Cookie 和其他网站数据
   - ☑️ 缓存的图片和文件
4. 点击「清除数据」
5. 关闭 Chrome 所有窗口
6. 重新打开 Chrome
7. 重新打开 `MultiSigWallet_Web3.html`

#### 选项 3：重启 MetaMask 扩展
1. 打开 `chrome://extensions/`
2. 找到 MetaMask
3. 点击右下角的「卸载」
4. 刷新页面
5. 重新安装 MetaMask（或从侧边栏启用）
6. 点击「🔄 重新检查 MetaMask」

#### 选项 4：检查其他扩展冲突
1. 打开 `chrome://extensions/`
2. 临时禁用其他扩展（特别是其他钱包或广告拦截器）
3. 刷新 `MultiSigWallet_Web3.html` 页面
4. 测试连接

---

## 📋 检查清单

在继续之前，请确认以下各项：

- [ ] MetaMask 已安装（检查：`chrome://extensions/`）
- [ ] MetaMask 已启用（确保没有灰色显示）
- [ ] 可以点击 MetaMask 图标打开钱包
- [ ] 钱包显示正确的账户和余额
- [ ] Anvil 本地节点仍在运行（检查：`lsof -i :8545`）
- [ ] 网页已用新代码重新加载（按 `Cmd+Shift+R` 硬刷新）

---

## 🔧 技术细节

### 改进的代码功能

#### 1. 双 CDN 支持（备用 CDN）
```javascript
// 主 CDN: cdn.ethers.io
// 备用 CDN: cdn.jsdelivr.net

// 如果主 CDN 失败，自动加载备用 CDN
```

#### 2. 智能诊断系统
- **运行 > 2 次的初始化检测**（0ms、500ms、1000ms）
- **手动重试 > 5 次检测**（0ms、500ms、1000ms、2000ms、3000ms）
- **详细的诊断日志**显示所有问题和解决方案

#### 3. 改进的 connectWallet() 函数
- 自动加载 ethers.js 库检查
- 错误代码识别（-32001, -32002, -32603）
- 自动加载合约（连接后）
- MetaMask 锁定/未初始化检测

---

## 📲 常见错误消息及解决方案

### 错误 1: "未检测到 MetaMask 钱包扩展"

**原因**: Chrome 阻止了网站访问

**解决方案**:
1. ✅ 允许网站访问 MetaMask（参见第 2 步）
2. ✅ 清除浏览器缓存
3. ✅ 重新启动 MetaMask 扩展

---

### 错误 2: "net::ERR_CONNECTION_CLOSED"

**原因**:
- ethers.js 库加载失败
- 与上述原因相同（Chrome 权限阻止）

**解决方案**:
1. 网页将自动尝试备用 CDN
2. 如果仍失败，清除缓存并重启浏览器

---

### 错误 3: "用户拒绝了连接请求"

**原因**: 您点击了 MetaMask 弹窗中的"取消"

**解决方案**:
1. 点击「连接 MetaMask」按钮
2. 在 MetaMask 弹窗中点击"连接"（不是"取消"）

---

### 错误 4: "MetaMask 繁忙"

**原因**: MetaMask 正在处理其他请求

**解决方案**:
1. 等待片刻
2. 重试连接

---

## 🐛 调试技巧

### 打开浏览器开发者工具
1. 按 `F12`（或 `Cmd+Option+I` 在 Mac 上）
2. 点击「Console」标签
3. 查看错误消息和日志

**关键日志信息**:
```javascript
// 检查 window.ethereum
window.ethereum

// 检查 ethers.js
typeof ethers

// 检查 MetaMask 是否已锁定
window.ethereum.isConnected()
```

### 查看网络错误
1. 打开开发者工具
2. 点击「Network」标签
3. 查找以下资源：
   - `ethers-5.7.2.umd.min.js` - 应该是绿色（200）
   - 任何其他红色（失败）的请求

---

## ✅ 测试连接

连接成功后，您应该看到：

```
✅ 已连接
📍 账户地址: 0x...
🌐 网络: localhost (Chain ID: 31337)
```

以及：

```
✅ 已自动填充合约地址
  - MultiSigWallet: 0x5FbDB2315678afecb367f032d93F642f64180aa3
  - MockERC20: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
```

---

## 📞 需要帮助？

如果仍然无法连接：

1. 检查 Anvil 节点是否运行：
   ```bash
   lsof -i :8545
   ps aux | grep anvil
   ```

2. 查看 MetaMask 是否连接到 localhost:8545：
   - 打开 MetaMask
   - 检查网络选择器
   - 应该显示"localhost 8545"（或自定义 RPC）

3. 验证合约地址是否正确：
   ```bash
   # 查看部署记录
   cat broadcast/DeployMultiSig.s.sol/31337/run-latest.json | grep '"address"'
   ```

4. 在开发者工具控制台中运行诊断：
   ```javascript
   // 在控制台中粘贴并执行
   runDiagnostics()
   ```

---

## 🎉 成功标志

✅ **完整的成功连接流程**:

1. 页面加载
2. 日志显示：`✅ 检测到 MetaMask 扩展`
3. 合约地址自动填充
4. 点击「连接 MetaMask」
5. MetaMask 弹窗出现
6. 选择账户并点击"连接"
7. 页面显示：
   - ✅ 已连接
   - 账户地址
   - 网络信息
   - 合约已加载
8. 可以与合约交互

---

## 📚 更多信息

- [MetaMask 官方文档](https://docs.metamask.io/)
- [ethers.js v5.7 文档](https://docs.ethers.org/v5/)
- [Foundry 文档](https://book.getfoundry.sh/)
- [Anvil 文档](https://book.getfoundry.sh/anvil/)
