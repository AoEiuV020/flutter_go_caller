#!/bin/bash
. "$(dirname $0)/env.sh"
# 检查 ROOT 环境变量是否已定义
echo "ROOT: $ROOT"
if [ -z "$ROOT" ]; then
  echo "请定义 ROOT 环境变量！"
  exit 1
fi

# 获取当前系统架构
get_current_arch() {
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS
        case "$(uname -m)" in
            "x86_64") echo "amd64" ;;
            "arm64") echo "arm64" ;;
            *) echo "amd64" ;;  # 默认
        esac
    else
        # Linux
        case "$(uname -m)" in
            "x86_64") echo "amd64" ;;
            "aarch64") echo "arm64" ;;
            "arm64") echo "arm64" ;;
            *) echo "amd64" ;;  # 默认
        esac
    fi
}

# 显示使用帮助
show_help() {
    echo ""
    echo "使用方法:"
    echo "  $0 [ARCH] [COMMAND...]"
    echo ""
    echo "参数:"
    echo "  ARCH           指定目标架构 (amd64 或 arm64)"
    echo "                 默认使用当前系统架构: $(get_current_arch)"
    echo ""
    echo "示例:"
    echo "  $0                           # 使用当前系统架构"
    echo "  $0 amd64                     # 使用 amd64 架构"
    echo "  $0 arm64                     # 使用 arm64 架构"
    echo "  $0 amd64 bash                # 使用 amd64 架构并启动 bash"
    echo ""
}

# 解析命令行参数
PLATFORM_ARCH=""
DOCKER_ARGS=()

# 检查帮助参数
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_help
    exit 0
fi

# 解析参数
if [[ $# -gt 0 ]]; then
    # 检查第一个参数是否是架构
    if [[ "$1" == "amd64" ]] || [[ "$1" == "arm64" ]]; then
        PLATFORM_ARCH="$1"
        shift
        DOCKER_ARGS=("$@")
    else
        # 第一个参数不是架构，把所有参数都当作 Docker 命令
        DOCKER_ARGS=("$@")
    fi
fi

# 如果没有指定架构，使用当前系统架构
if [ -z "$PLATFORM_ARCH" ]; then
    PLATFORM_ARCH=$(get_current_arch)
fi

# 验证架构参数
if [[ "$PLATFORM_ARCH" != "amd64" && "$PLATFORM_ARCH" != "arm64" ]]; then
    echo "错误：不支持的架构 '$PLATFORM_ARCH'，仅支持 amd64 或 arm64"
    exit 1
fi

echo "使用架构: $PLATFORM_ARCH"

# 设置 Docker 平台参数
DOCKER_PLATFORM="linux/$PLATFORM_ARCH"

# 给容器指定一个名字（包含架构信息）
CONTAINER_NAME="go-dev-$PLATFORM_ARCH"

# 获取容器状态
CONTAINER_STATUS=$(docker container inspect -f '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null >&2 || echo "not_exist")

case "$CONTAINER_STATUS" in
  "not_exist")
    echo "容器 '$CONTAINER_NAME' 不存在，正在创建并启动..."
    ;;
  *)
    echo "删除已存在的容器 '$CONTAINER_NAME'..."
    docker rm -f "$CONTAINER_NAME"
    ;;
esac

# 构建镜像名称（包含架构信息）
IMAGE_NAME="docker-build-$PLATFORM_ARCH"

# 直接从 Dockerfile 构建并运行容器
echo "正在为 $DOCKER_PLATFORM 平台构建镜像..."
docker build --platform="$DOCKER_PLATFORM" -t "$IMAGE_NAME" -f "$ROOT/script/docker/u2004.Dockerfile" "$ROOT/script/docker" && \
echo "正在启动容器..." && \
docker run -i --rm --name "$CONTAINER_NAME" \
           --platform="$DOCKER_PLATFORM" \
           --privileged=True \
           -v "$ROOT:/workspace" \
           "$IMAGE_NAME" "${DOCKER_ARGS[@]}"
if [ $? -ne 0 ]; then
  echo "错误：容器运行失败"
  exit 1
fi

echo "docker 打包成功完成"
