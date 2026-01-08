# Foundry Development Environment
# 这个 Dockerfile 提供完整的 Solidity 智能合约开发环境

FROM alpine:latest

# 设置环境变量
ENV PATH="/root/.foundry/bin:${PATH}"
ENV RUST_BACKTRACE=1

# 安装系统依赖
RUN apk add --no-cache \
    curl \
    wget \
    git \
    build-base \
    pkgconfig \
    openssl-dev \
    bash \
    ca-certificates

# 安装 Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 安装 Foundry
RUN curl -L https://foundry.paradigm.xyz | bash && \
    /root/.foundry/bin/foundryup

# 验证安装
RUN forge --version && cast --version && anvil --version

# 设置工作目录
WORKDIR /workspace

# 复制项目文件
COPY . .

# 安装依赖并编译（如果存在）
RUN if [ -f "foundry.toml" ]; then \
        forge install --no-commit || true && \
        forge build || true; \
    fi

# 默认命令
CMD ["bash"]
