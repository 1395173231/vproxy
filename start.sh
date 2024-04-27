#!/bin/bash

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null
then
    echo "Docker could not be found, attempting to install."
    curl -fsSL https://test.docker.com -o test-docker.sh
    chmod +x test-docker.sh
    ./test-docker.sh || { echo "Docker installation failed"; exit 1; }
else
    echo "Docker is already installed."
fi

# 载入 .env 文件中定义的环境变量
if [ -f .env ]; then
    export $(cat .env | sed 's/#.*//g' | xargs) || { echo "Failed to export environment variables"; exit 1; }
fi

echo "SUBNET is set to $SUBNET"
sudo sysctl net.ipv6.ip_nonlocal_bind=1 || { echo "Failed to set IP non-local bind"; exit 1; }
sudo ip route add local $SUBNET dev lo 

docker compose up -d --build || { echo "Docker Compose failed to start"; exit 1; }
