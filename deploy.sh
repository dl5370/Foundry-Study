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

# 加载环境变量
load_env() {
    local env_file=".env"

    if [ -f "$env_file" ]; then
        print_info "加载环境变量从 $env_file"
        set -a  # 自动导出所有变量
        source "$env_file"
        set +a
        return 0
    else
        return 1
    fi
}

# 检查 .env 文件
check_env_file() {
    if [ ! -f ".env" ]; then
        print_warning ".env 文件不存在"

        if [ -f ".env.example" ]; then
            print_info "发现 .env.example 模板文件"
            echo ""
            read -p "是否从 .env.example 创建 .env 文件? (y/n): " -n 1 -r
            echo ""

            if [[ $REPLY =~ ^[Yy]$ ]]; then
                cp .env.example .env
                print_success ".env 文件已创建"
                print_warning "请编辑 .env 文件，填入你的实际配置："
                echo "  ALCHEMY_API_KEY - Alchemy API 密钥"
                echo "  PRIVATE_KEY - 部署账户私钥"
                echo "  ETHERSCAN_API_KEY - Etherscan API 密钥（用于验证合约）"
                echo ""
                echo "编辑命令："
                echo "  nano .env    # 或使用你喜欢的编辑器"
                echo ""
                exit 1
            else
                print_error "需要 .env 文件才能继续"
                exit 1
            fi
        else
            print_error "未找到 .env.example 模板文件"
            exit 1
        fi
    fi
}

# 验证环境变量
validate_env_vars() {
    local required_vars=("$@")
    local missing_vars=()

    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done

    if [ ${#missing_vars[@]} -gt 0 ]; then
        print_error "缺少必需的环境变量："
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        echo ""
        print_info "请编辑 .env 文件并填入这些变量的值"
        exit 1
    fi

    print_success "环境变量验证通过"
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

# 保存部署记录到持久化目录
save_deployment_record() {
    local network=$1
    local source_file="broadcast/DeployMultiSig.s.sol/31337/run-latest.json"
    local deploy_dir="deployments/$network"
    local latest_file="$deploy_dir/latest.json"
    local timestamp=$(date '+%Y%m%d-%H%M%S')
    local history_dir="$deploy_dir/history"
    local history_file="$history_dir/$timestamp.json"

    # 创建目录
    mkdir -p "$history_dir"

    # 复制到最新部署
    cp "$source_file" "$latest_file"
    print_success "已保存部署到: $latest_file"

    # 创建历史副本
    cp "$source_file" "$history_file"
    print_info "已创建历史记录: $history_file"

    # 提取合约地址
    local multisig_addr=$(jq -r '.transactions[] | select(.contractName=="MultiSigWallet") | .contractAddress' "$latest_file" | head -1)
    local token_addr=$(jq -r '.transactions[] | select(.contractName=="MockERC20") | .contractAddress' "$latest_file" | head -1)
    local block_num=$(jq -r '.transactions[0].blockNumber' "$latest_file" 2>/dev/null || echo "0")

    # 生成 .env.deployed 文件
    cat > .env.deployed << EOF
# =========================================
# 当前活跃部署的合约地址
# 由 deploy.sh 自动生成
# 生成时间: $(date '+%Y-%m-%dT%H:%M:%SZ')
# =========================================

DEPLOYED_NETWORK=$network
DEPLOYED_RPC_URL=http://localhost:8545

MULTISIG_ADDRESS=$multisig_addr
TOKEN_ADDRESS=$token_addr

DEPLOYED_TIMESTAMP=$(date '+%Y-%m-%dT%H:%M:%SZ')
DEPLOYED_BLOCK=$block_num

OWNER_ALICE=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
OWNER_BOB=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
OWNER_CAROL=0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC

MULTISIG_REQUIRED_SIGNATURES=2
MULTISIG_TOTAL_OWNERS=3
TOKEN_INITIAL_SUPPLY=1000
EOF

    print_success "已更新 .env.deployed"
    echo ""
    echo "📦 已部署的合约:"
    echo "  MultiSigWallet: $multisig_addr"
    echo "  MockERC20: $token_addr"
    echo ""
    echo "💾 文件位置:"
    echo "  当前部署: deployments/$network/latest.json"
    echo "  历史记录: deployments/$network/history/$timestamp.json"
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

        # 保存部署记录到持久化目录
        echo ""
        save_deployment_record "local"
    else
        print_error "本地部署失败"
        exit 1
    fi
}

# 部署到 Sepolia 测试网
deploy_sepolia() {
    print_info "部署到 Sepolia 测试网..."

    # 检查并加载 .env
    check_env_file
    load_env

    # 验证必需的环境变量
    validate_env_vars "ALCHEMY_API_KEY" "PRIVATE_KEY"

    # 检查部署脚本
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
    print_info "目标网络: Sepolia Testnet"
    echo ""
    print_warning "请确认："
    echo "  1. 你的账户有足够的 Sepolia 测试网 ETH"
    echo "  2. PRIVATE_KEY 对应的账户是你想要使用的"
    echo "  3. 部署将消耗真实的测试网 gas"
    echo ""
    read -p "继续部署到 Sepolia? (y/n): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "已取消部署"
        exit 0
    fi

    print_info "开始部署..."

    # 使用 --verify 自动验证合约（如果设置了 ETHERSCAN_API_KEY）
    local verify_flag=""
    if [ -n "$ETHERSCAN_API_KEY" ]; then
        verify_flag="--verify"
        print_info "将自动验证合约（Etherscan API Key 已设置）"
    fi

    forge script $DEPLOY_SCRIPT:$CONTRACT_NAME \
        --rpc-url sepolia \
        --broadcast \
        --private-key $PRIVATE_KEY \
        $verify_flag

    if [ $? -eq 0 ]; then
        print_success "Sepolia 部署成功！"
        print_info "部署信息已保存到: broadcast/"
        echo ""
        print_info "查看你的合约："
        echo "  Sepolia Etherscan: https://sepolia.etherscan.io/"
        echo "  部署记录: broadcast/$CONTRACT_NAME.s.sol/11155111/run-latest.json"
    else
        print_error "Sepolia 部署失败"
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

    # 设置清理陷阱（仅对本地部署）
    if [ "${1:-local}" == "local" ]; then
        trap cleanup EXIT
    fi

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
        "sepolia")
            print_info "模式: Sepolia 测试网部署"
            check_dependencies
            install_dependencies
            compile_contracts
            run_tests
            deploy_sepolia
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
            echo "用法: $0 [local|sepolia|test|build|clean]"
            echo ""
            echo "选项:"
            echo "  local   - 完整的本地部署 (默认)"
            echo "  sepolia - 部署到 Sepolia 测试网"
            echo "  test    - 仅运行测试"
            echo "  build   - 仅编译合约"
            echo "  clean   - 清理项目文件"
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"