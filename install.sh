#!/usr/bin/env zsh

# whatcodec 安装脚本
# 将 whatcodec 工具安装到系统路径并添加到 zsh 配置

set -e

SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
# 解析参数
INSTALL_CLI=false
if [[ "$1" == "--cli" ]]; then
    INSTALL_CLI=true
fi

# 检查依赖
echo "🔍 检查依赖工具..."
missing_deps=()

if ! command -v ffprobe >/dev/null 2>&1; then
    missing_deps+=("ffprobe (ffmpeg)")
fi

if ! command -v curl >/dev/null 2>&1; then
    missing_deps+=("curl")
fi

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "❌ 缺少以下依赖工具："
    for dep in "${missing_deps[@]}"; do
        echo "   - $dep"
    done
    echo ""
    echo "请安装缺少的依赖："
    echo "   brew install ffmpeg curl"
    exit 1
fi

if [[ "$INSTALL_CLI" == true ]]; then
    # === CLI 安装逻辑 ===
    INSTALL_DIR="$HOME/.local/bin"
    ZSH_CONFIG="$HOME/.zshrc"

    echo "📦 安装 whatcodec CLI 工具..."

    # 确保 ~/.local/bin 目录存在
    mkdir -p "$INSTALL_DIR"

    # 复制脚本到安装目录
    cp "$SCRIPT_DIR/whatcodec" "$INSTALL_DIR/whatcodec"
    chmod +x "$INSTALL_DIR/whatcodec"

    # 检查 PATH 是否已包含 ~/.local/bin
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        echo "📝 添加 ~/.local/bin 到 PATH..."

        # 检查 .zshrc 是否已有相关配置
        if ! grep -q "export PATH.*\.local/bin" "$ZSH_CONFIG" 2>/dev/null; then
            echo "" >> "$ZSH_CONFIG"
            echo "# whatcodec 工具路径" >> "$ZSH_CONFIG"
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$ZSH_CONFIG"
            echo "✅ 已添加路径配置到 ~/.zshrc"
        else
            echo "ℹ️  PATH 配置已存在"
        fi
    fi

    echo "✅ CLI 安装完成！"
    echo ""
    echo "使用方法："
    echo "   whatcodec video.mp4               # 分析本地文件"
    echo "   rehash; whatcodec ...             # 刷新 hash 或重新打开终端"

else
    # === App 安装逻辑 (默认) ===
    APP_NAME="WhatCodec"
    BUILD_SCRIPT="$SCRIPT_DIR/build_app.sh"
    BUILD_OUTPUT="$SCRIPT_DIR/build/$APP_NAME.app"
    INSTALL_APP_DIR="$HOME/Applications"
    TARGET_APP="$INSTALL_APP_DIR/$APP_NAME.app"

    echo "🏗️  准备构建 macOS App..."
    
    # 检查构建脚本权限
    if [[ ! -x "$BUILD_SCRIPT" ]]; then
        chmod +x "$BUILD_SCRIPT"
    fi

    # 执行构建
    "$BUILD_SCRIPT"
    
    if [[ $? -ne 0 ]]; then
        echo "❌ 构建失败！请检查上方错误信息。"
        exit 1
    fi

    echo "📦 安装 App 到 $INSTALL_APP_DIR ..."
    mkdir -p "$INSTALL_APP_DIR"

    # 删除旧版本 (如果在)
    if [[ -d "$TARGET_APP" ]]; then
        echo "   🗑️  移除旧版本..."
        rm -rf "$TARGET_APP"
    fi

    # 移动新版本
    echo "   🚚 复制 App..."
    cp -R "$BUILD_OUTPUT" "$INSTALL_APP_DIR/"

    echo "✅ App 安装完成！"
    echo "   位于: $TARGET_APP"
    echo "   你可以直接双击运行，或拖拽文件到图标上。"
    echo ""
    echo "💡 提示: 如果想安装命令行版本，请运行: ./install.sh --cli"
fi