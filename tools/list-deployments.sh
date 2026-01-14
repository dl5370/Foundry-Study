#!/bin/bash

# ===========================================
# 部署历史列表脚本
# 用法: ./tools/list-deployments.sh
# ===========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEPLOYMENTS_DIR="$PROJECT_ROOT/deployments/local/history"
CURRENT_DEPLOYMENT="$PROJECT_ROOT/deployments/local/latest.json"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}📋 部署历史列表${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header
echo ""

# 显示当前部署
if [ -f "$CURRENT_DEPLOYMENT" ]; then
    echo -e "${CYAN}⭐ 当前部署 (latest)${NC}"
    ls -lh "$CURRENT_DEPLOYMENT" | awk '{print "  " $9 " - " $5 " bytes"}'

    # 提取合约地址
    MULTISIG=$(jq -r '.transactions[] | select(.contractName=="MultiSigWallet") | .contractAddress' "$CURRENT_DEPLOYMENT" 2>/dev/null | head -1)
    TOKEN=$(jq -r '.transactions[] | select(.contractName=="MockERC20") | .contractAddress' "$CURRENT_DEPLOYMENT" 2>/dev/null | head -1)

    echo "  MultiSigWallet: $MULTISIG"
    echo "  MockERC20: $TOKEN"
    echo ""
fi

# 显示历史部署
if [ -d "$DEPLOYMENTS_DIR" ]; then
    count=$(find "$DEPLOYMENTS_DIR" -name "*.json" 2>/dev/null | wc -l)

    if [ $count -gt 0 ]; then
        echo -e "${CYAN}📚 历史部署 (共 $count 个)${NC}"

        find "$DEPLOYMENTS_DIR" -name "*.json" -type f -exec ls -lh {} \; | \
            awk '{
                gsub(/.*\//, "", $9);
                printf "  %s  -  %s bytes\n", $9, $5
            }' | sort -r
        echo ""
    else
        print_info "暂无历史部署记录"
        echo ""
    fi
else
    print_info "历史部署目录不存在（首次部署时自动创建）"
    echo ""
fi

# 显示可用命令
echo -e "${YELLOW}📖 可用命令${NC}"
print_info "查看当前部署: ./tools/current-deployment.sh"
print_info "加载历史部署: ./tools/load-deployment.sh <filename>"
print_info "重新部署: ./deploy.sh local"
echo ""

print_success "列表显示完成"
