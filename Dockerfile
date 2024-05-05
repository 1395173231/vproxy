# 使用 Debian 最新的稳定版本作为基础镜像
FROM debian:bullseye-slim

# 设置工作目录
WORKDIR /app

# 更新软件包列表并安装必需的包
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    jq \
    && rm -rf /var/lib/apt/lists/*

# 根据系统架构自动选择最新的 GitHub 文件，忽略 .sha256 文件
RUN ARCH=$(dpkg --print-architecture) && \
    ARCH_MUSL="$(case ${ARCH} in \
        amd64) echo x86_64-unknown-linux-musl ;; \
        arm64) echo aarch64-unknown-linux-musl ;; \
        armhf) echo arm-unknown-linux-musleabihf ;; \
        *) echo ${ARCH} ;; \
    esac)" && \
    LATEST_URL=$(curl -s "https://api.github.com/repos/gngpp/vproxy/releases/latest" | jq -r ".assets[] | select(.name | test(\"${ARCH_MUSL}\"))| select( .name | endswith(\".tar.gz\")) | .browser_download_url") && \
    curl -L ${LATEST_URL} | tar -xz

COPY check_proxy.sh /usr/local/bin/check_proxy.sh
RUN chmod +x /usr/local/bin/check_proxy.sh

ARG SUBNET
# 设置环境变量 VPROXY_PORT，用于定义运行端口，默认1888
ENV VPROXY_PORT=1888
ENV SUBNET=2001:470:1::/48

# 配置容器启动时执行的命令，使用环境变量中的端口
ENTRYPOINT  ./vproxy run --bind=0.0.0.0:${VPROXY_PORT} -i ${SUBNET} socks5  
