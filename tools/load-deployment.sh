#!/bin/bash

# ===========================================
# 加载历史部署脚本
# 用法: ./tools/load-deployment.sh <filename>
# 示例: ./tools/load-deployment.sh 20250109-143022.json
# ===========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HISTORY_DIR="$PROJECT_ROOT/deployments/local/history"
LATEST_FILE="$PROJECT_ROOT/deployments/local/latest.json"
DEPLOYED_FILE="$PROJECT_ROOT/.env.deployed"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}📋 加载历史部署${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header
echo ""

# 检查参数
if [ -z "$1" ]; then
    print_error "请指定要加载的部署文件"
    echo ""
    print_info "用法: ./tools/load-deployment.sh <filename>"
    echo ""
    print_info "可用的部署文件:"
    ./tools/list-deployments.sh | grep "  20"
    exit 1
fi

FILENAME="$1"
SOURCE_FILE="$HISTORY_DIR/$FILENAME"

# 检查文件是否存在
if [ ! -f "$SOURCE_FILE" ]; then
    print_error "部署文件不存在: $FILENAME"
    echo ""
    print_info "可用的部署文件:"
    ls -1 "$HISTORY_DIR" 2>/dev/null | grep "\.json$" || print_info "暂无历史部署"
    exit 1
fi

# 备份当前部署
if [ -f "$LATEST_FILE" ]; then
    BACKUP_FILE="$HISTORY_DIR/.latest.backup.json"
    cp "$LATEST_FILE" "$BACKUP_FILE"
    print_info "已备份当前部署到: .latest.backup.json"
fi

# 加载旧部署
cp "$SOURCE_FILE" "$LATEST_FILE"
print_success "已加载部署: $FILENAME"
echo ""

# 提取地址信息
MULTISIG=$(jq -r '.transactions[] | select(.contractName=="MultiSigWallet") | .contractAddress' "$LATEST_FILE" 2>/dev/null | head -1)
TOKEN=$(jq -r '.transactions[] | select(.contractName=="MockERC20") | .contractAddress' "$LATEST_FILE" 2>/dev/null | head -1)

# 更新 .env.deployed
cat > "$DEPLOYED_FILE" << EOF
# =========================================
# 当前活跃部署的合约地址
# 加载时间: $(date '+%Y-%m-%dT%H:%M:%SZ')
# =========================================

DEPLOYED_NETWORK=local
DEPLOYED_RPC_URL=http://localhost:8545

MULTISIG_ADDRESS=$MULTISIG
TOKEN_ADDRESS=$TOKEN

DEPLOYED_TIMESTAMP=$(date '+%Y-%m-%dT%H:%M:%SZ')

OWNER_ALICE=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
OWNER_BOB=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
OWNER_CAROL=0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC

MULTISIG_REQUIRED_SIGNATURES=2
MULTISIG_TOTAL_OWNERS=3
TOKEN_INITIAL_SUPPLY=1000
EOF

print_success "已更新 .env.deployed"
echo ""

# 显示加载的部署信息
echo -e "${CYAN}📦 加载的合约地址${NC}"
echo "MultiSigWallet: $MULTISIG"
echo "MockERC20: $TOKEN"
echo ""

print_info "请刷新浏览器以加载新的合约地址"
print_info "或运行: ./tools/current-deployment.sh 查看详细信息"
