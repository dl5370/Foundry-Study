#!/bin/bash

# ===========================================
# 当前部署信息查询脚本
# 用法: ./tools/current-deployment.sh
# ===========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEPLOYED_FILE="$PROJECT_ROOT/.env.deployed"
LATEST_DEPLOYMENT="$PROJECT_ROOT/deployments/local/latest.json"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}📋 当前部署信息${NC}"
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

# 检查部署文件
if [ ! -f "$DEPLOYED_FILE" ]; then
    print_header
    print_error "未找到 .env.deployed 文件"
    echo ""
    echo "请先运行: ./deploy.sh local"
    exit 1
fi

# 加载部署信息
source "$DEPLOYED_FILE"

print_header
echo ""

# 网络信息
echo -e "${YELLOW}🌐 网络信息${NC}"
print_info "网络: $DEPLOYED_NETWORK"
print_info "RPC URL: $DEPLOYED_RPC_URL"
print_info "部署时间: $DEPLOYED_TIMESTAMP"
echo ""

# 合约地址
echo -e "${YELLOW}📦 合约地址${NC}"
echo "MultiSigWallet:"
echo "  $MULTISIG_ADDRESS"
echo ""
echo "MockERC20 (Token):"
echo "  $TOKEN_ADDRESS"
echo ""

# 所有者信息
echo -e "${YELLOW}👥 所有者信息${NC}"
print_info "Alice: $OWNER_ALICE"
print_info "Bob: $OWNER_BOB"
print_info "Carol: $OWNER_CAROL"
echo ""

# 合约配置
echo -e "${YELLOW}⚙️  合约配置${NC}"
print_info "所需签名数: $MULTISIG_REQUIRED_SIGNATURES of $MULTISIG_TOTAL_OWNERS"
print_info "代币初始供应: $TOKEN_INITIAL_SUPPLY"
echo ""

# 部署文件位置
echo -e "${YELLOW}📁 文件位置${NC}"
print_info "当前部署: deployments/local/latest.json"
print_info "完整记录: broadcast/DeployMultiSig.s.sol/31337/run-latest.json"
echo ""

print_success "所有信息已显示"
