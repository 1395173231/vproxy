#!/bin/bash

# 获取命令行参数，代表代理端口
PROXY_PORT=$1

# 如果没有提供端口，打印错误并退出
if [ -z "$PROXY_PORT" ]; then
  echo "Usage: $0 <proxy_port>"
  exit 1
fi

# 使用curl通过指定的代理服务器测试连接
if curl -x socks5://127.0.0.1:${PROXY_PORT} -m 2 http://ip.sb --silent --fail
then
  echo "Proxy is up and running on port ${PROXY_PORT}."
  exit 0
else
  echo "Proxy is down or not responding on port ${PROXY_PORT}."
  exit 1
fi
