# 使用 Debian 最新的稳定版本作为基础镜像
FROM debian:bullseye-slim

# 设置工作目录
WORKDIR /app

# 更新软件包列表并安装必需的包
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    && rm -rf /var/lib/apt/lists/*

# 下载vproxy，并解压到/app
RUN curl -L "https://github.com/gngpp/vproxy/releases/download/v0.1.5/vproxy-0.1.5-x86_64-unknown-linux-musl.tar.gz" | tar -xz

COPY check_proxy.sh /usr/local/bin/check_proxy.sh
RUN chmod +x /usr/local/bin/check_proxy.sh

# 设置环境变量 VPROXY_PORT，用于定义运行端口，默认1888
ENV VPROXY_PORT=1888
ENV SUBNET=2001:470:7014::/48

# 配置容器启动时执行的命令，使用环境变量中的端口
ENTRYPOINT  ./vproxy run -B 0.0.0.0:${VPROXY_PORT} -i ${SUBNET}
