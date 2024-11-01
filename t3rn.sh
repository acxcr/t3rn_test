#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/t3rn.sh"
LOGFILE="$HOME/executor/executor.log"
EXECUTOR_DIR="$HOME/executor"
IMAGE_NAME="executor-image"
CONTAINER_NAME="executor-container"
EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/v0.21.11/executor-linux-v0.21.11.tar.gz"

# 检查是否以 root 用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 用户权限运行。"
    exit 1
fi

# 下载并构建 Docker 镜像
build_docker_image() {
    echo "正在下载并构建 Docker 镜像..."
    cat <<EOF > Dockerfile
FROM alpine:latest

RUN apk add --no-cache bash curl

WORKDIR /app

COPY executor.sh .

RUN chmod +x executor.sh

CMD ["./executor.sh"]
EOF

    echo "构建 Docker 镜像..."
    docker build -t $IMAGE_NAME .
}

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1) 执行脚本"
        echo "2) 查看日志"
        echo "3) 删除节点"
        echo "4) 重启节点（领水后用）"
        echo "5) 退出"
        
        read -p "请输入你的选择 [1-5]: " choice
        
        case $choice in
            1)
                execute_script
                ;;
            2)
                view_logs
                ;;
            3)
                delete_node
                ;;
            4)
                restart_node
                ;;
            5)
                echo "退出脚本。"
                exit 0
                ;;
            *)
                echo "无效的选择，请重新输入。"
                ;;
        esac
    done
}

# 执行脚本函数
function execute_script() {
    # 下载文件
    echo "正在下载 executor-linux-v0.21.11.tar.gz..."
    wget $EXECUTOR_URL -O executor-linux.tar.gz

    # 检查下载是否成功
    if [ $? -eq 0 ]; then
        echo "下载成功。"
    else
        echo "下载失败，请检查网络连接或下载地址。"
        exit 1
    fi

    # 解压文件到当前目录
    echo "正在解压文件..."
    tar -xvzf executor-linux.tar.gz
    rm executor-linux.tar.gz  # 删除压缩文件

    # 检查解压后的文件名是否包含 'executor'
    if [ ! -d "executor" ]; then
        echo "未找到包含 'executor' 的文件或目录，可能文件名不正确。"
        exit 1
    fi

    build_docker_image

    # 启动 Docker 容器
    echo "正在启动 Docker 容器..."
    docker run -d --name $CONTAINER_NAME $IMAGE_NAME

    echo "操作完成。"
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
}

# 查看日志函数
function view_logs() {
    if [ -f "$LOGFILE" ]; then
        echo "实时显示日志文件内容（按 Ctrl+C 退出）："
        tail -f "$LOGFILE"  # 使用 tail -f 实时跟踪日志文件
    else
        echo "日志文件不存在。"
    fi
}

# 删除节点函数
function delete_node() {
    echo "正在停止节点进程..."
    
    # 停止 Docker 容器
    if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
        echo "节点容器已删除。"
    else
        echo "节点容器未运行或不存在。"
    fi

    # 删除节点目录
    if [ -d "$EXECUTOR_DIR" ]; then
        echo "正在删除节点目录..."
        rm -rf "$EXECUTOR_DIR"
        echo "节点目录已删除。"
    else
        echo "节点目录不存在，可能已被删除。"
    fi

    echo "节点删除操作完成。"
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
}

# 重启节点函数
function restart_node() {
    echo "正在重启节点进程..."
    delete_node
    execute_script
}

# 启动主菜单
main_menu
