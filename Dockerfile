# Foundry Development Environment
# 这个 Dockerfile 提供完整的 Solidity 智能合约开发环境

FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.foundry/bin:${PATH}"
ENV RUST_BACKTRACE=1

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 安装 Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# 安装 Foundry
RUN curl -L https://foundry.paradigm.xyz | bash
RUN ~/.foundry/bin/foundryup

# 验证安装
RUN forge --version && cast --version && anvil --version

# 设置工作目录
WORKDIR /workspace

# 默认命令
CMD ["bash"]
