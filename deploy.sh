#!/bin/bash

# Foundry 项目一键部署脚本
# 支持本地开发和测试网部署

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "🚀 Foundry 项目一键部署脚本"
    echo "=================================================="
    echo -e "${NC}"
}

# 检查依赖
check_dependencies() {
    print_info "检查依赖..."

    if ! command -v forge &> /dev/null; then
        print_error "Foundry 未安装！请先安装 Foundry："
        echo "curl -L https://foundry.paradigm.xyz | bash"
        echo "foundryup"
        exit 1
    fi

    print_success "Foundry 已安装: $(forge --version | head -n1)"
}

# 安装项目依赖
install_dependencies() {
    print_info "安装项目依赖..."

    if [ ! -d "lib/forge-std" ]; then
        print_info "安装 forge-std..."
        forge install foundry-rs/forge-std --no-commit
    fi

    print_success "依赖安装完成"
}

# 编译合约
compile_contracts() {
    print_info "编译智能合约..."

    forge build

    if [ $? -eq 0 ]; then
        print_success "合约编译成功"
    else
        print_error "合约编译失败"
        exit 1
    fi
}

# 运行测试
run_tests() {
    print_info "运行测试..."

    forge test -v

    if [ $? -eq 0 ]; then
        print_success "所有测试通过"
    else
        print_error "测试失败"
        exit 1
    fi
}

# 启动本地节点
start_local_node() {
    print_info "检查本地 Anvil 节点..."

    # 检查端口 8545 是否被占用
    if lsof -Pi :8545 -sTCP:LISTEN -t >/dev/null ; then
        print_warning "端口 8545 已被占用，尝试使用现有节点"
        return 0
    fi

    print_info "启动 Anvil 本地节点..."
    anvil --host 0.0.0.0 --port 8545 &
    ANVIL_PID=$!

    # 等待节点启动
    sleep 3

    if kill -0 $ANVIL_PID 2>/dev/null; then
        print_success "Anvil 节点已启动 (PID: $ANVIL_PID)"
        echo $ANVIL_PID > .anvil.pid
        return 0
    else
        print_error "Anvil 节点启动失败"
        exit 1
    fi
}

# 部署到本地
deploy_local() {
    print_info "部署到本地 Anvil 节点..."

    # 检查部署脚本是否存在
    if [ -f "script/DeployMultiSig.s.sol" ]; then
        DEPLOY_SCRIPT="script/DeployMultiSig.s.sol"
        CONTRACT_NAME="DeployMultiSig"
    elif [ -f "script/Deploy.s.sol" ]; then
        DEPLOY_SCRIPT="script/Deploy.s.sol"
        CONTRACT_NAME="Deploy"
    else
        print_error "未找到部署脚本"
        exit 1
    fi

    print_info "使用部署脚本: $DEPLOY_SCRIPT"

    forge script $DEPLOY_SCRIPT:$CONTRACT_NAME \
        --rpc-url http://localhost:8545 \
        --broadcast \
        --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

    if [ $? -eq 0 ]; then
        print_success "本地部署成功！"
        print_info "合约已部署到本地 Anvil 节点 (http://localhost:8545)"
    else
        print_error "本地部署失败"
        exit 1
    fi
}

# 显示部署信息
show_deployment_info() {
    print_header
    print_success "🎉 部署完成！"
    echo ""
    print_info "📋 部署信息："
    echo "  • 网络: 本地 Anvil 节点"
    echo "  • RPC URL: http://localhost:8545"
    echo "  • Chain ID: 31337"
    echo ""
    print_info "📁 重要文件："
    echo "  • 部署记录: broadcast/"
    echo "  • 合约 ABI: out/"
    echo "  • 源代码: src/"
    echo ""
    print_info "🔧 常用命令："
    echo "  • 查看合约: cast call <CONTRACT_ADDRESS> <FUNCTION>"
    echo "  • 发送交易: cast send <CONTRACT_ADDRESS> <FUNCTION> --private-key <KEY>"
    echo "  • 停止节点: kill \$(cat .anvil.pid) 2>/dev/null || true"
    echo ""
    print_info "🌐 Web3 dApp："
    echo "  • 打开 docs/MultiSigWallet_Web3.html 与合约交互"
    echo "  • 或者运行模拟器: open docs/MultiSigWallet_Simulator.html"
}

# 清理函数
cleanup() {
    if [ -f ".anvil.pid" ]; then
        ANVIL_PID=$(cat .anvil.pid)
        if kill -0 $ANVIL_PID 2>/dev/null; then
            print_info "停止 Anvil 节点..."
            kill $ANVIL_PID
            rm -f .anvil.pid
        fi
    fi
}

# 主函数
main() {
    print_header

    # 设置清理陷阱
    trap cleanup EXIT

    # 检查参数
    case "${1:-local}" in
        "local")
            print_info "模式: 本地部署"
            check_dependencies
            install_dependencies
            compile_contracts
            run_tests
            start_local_node
            deploy_local
            show_deployment_info
            ;;
        "test")
            print_info "模式: 仅测试"
            check_dependencies
            install_dependencies
            compile_contracts
            run_tests
            print_success "测试完成！"
            ;;
        "build")
            print_info "模式: 仅编译"
            check_dependencies
            install_dependencies
            compile_contracts
            print_success "编译完成！"
            ;;
        "clean")
            print_info "清理项目..."
            forge clean
            rm -rf broadcast/
            rm -f .anvil.pid
            print_success "清理完成！"
            ;;
        *)
            echo "用法: $0 [local|test|build|clean]"
            echo ""
            echo "选项:"
            echo "  local  - 完整的本地部署 (默认)"
            echo "  test   - 仅运行测试"
            echo "  build  - 仅编译合约"
            echo "  clean  - 清理项目文件"
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"