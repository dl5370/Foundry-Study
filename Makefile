# Foundry 项目 Makefile
# 提供常用的开发和部署命令

.PHONY: help install build test clean deploy-local deploy-sepolia format lint

# 默认目标
help:
	@echo "🚀 Foundry 项目管理命令"
	@echo ""
	@echo "📦 开发命令:"
	@echo "  make install      - 安装依赖"
	@echo "  make build        - 编译合约"
	@echo "  make test         - 运行测试"
	@echo "  make format       - 格式化代码"
	@echo "  make clean        - 清理构建文件"
	@echo ""
	@echo "🚀 部署命令:"
	@echo "  make deploy       - 一键本地部署 (推荐)"
	@echo "  make deploy-local - 部署到本地 Anvil"
	@echo "  make deploy-sepolia - 部署到 Sepolia 测试网"
	@echo ""
	@echo "🐳 Docker 命令:"
	@echo "  make docker-build - 构建 Docker 镜像"
	@echo "  make docker-run   - 运行 Docker 容器"
	@echo "  make docker-deploy - Docker 环境部署"
	@echo ""
	@echo "💡 提示: 运行 './deploy.sh' 获得最佳体验"

# 安装依赖
install:
	@echo "📦 安装项目依赖..."
	forge install

# 编译合约
build:
	@echo "🔨 编译智能合约..."
	forge build

# 运行测试
test:
	@echo "🧪 运行测试..."
	forge test -v

# 格式化代码
format:
	@echo "✨ 格式化代码..."
	forge fmt

# 清理构建文件
clean:
	@echo "🧹 清理构建文件..."
	forge clean
	rm -rf broadcast/
	rm -f .anvil.pid

# 一键部署（推荐）
deploy:
	@echo "🚀 执行一键部署..."
	./deploy.sh

# 部署到本地
deploy-local:
	@echo "🏠 部署到本地 Anvil..."
	./deploy.sh local

# 部署到 Sepolia 测试网
deploy-sepolia:
	@echo "🌐 部署到 Sepolia 测试网..."
	./deploy.sh sepolia

# Docker 构建
docker-build:
	@echo "🐳 构建 Docker 镜像..."
	docker build -t foundry-study .

# Docker 运行
docker-run:
	@echo "🐳 运行 Docker 容器..."
	docker run -it --rm \
		-v $(PWD):/workspace \
		-p 8545:8545 \
		foundry-study

# Docker 部署
docker-deploy:
	@echo "🐳 Docker 环境部署..."
	docker-compose up --build

# 启动本地节点
anvil:
	@echo "⚡ 启动 Anvil 本地节点..."
	anvil --host 0.0.0.0

# 气体报告
gas-report:
	@echo "⛽ 生成气体使用报告..."
	forge test --gas-report

# 覆盖率报告
coverage:
	@echo "📊 生成测试覆盖率报告..."
	forge coverage

# 安全检查 (需要安装 slither)
security:
	@echo "🔒 运行安全检查..."
	@if command -v slither >/dev/null 2>&1; then \
		slither .; \
	else \
		echo "⚠️  Slither 未安装，跳过安全检查"; \
		echo "安装命令: pip install slither-analyzer"; \
	fi