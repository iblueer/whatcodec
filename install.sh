#!/usr/bin/env zsh

# whatcodec 安装脚本
# 将 whatcodec 工具安装到系统路径并添加到 zsh 配置

set -e

SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
ZSH_CONFIG="$HOME/.zshrc"

echo "📦 安装 whatcodec 工具..."

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

echo "✅ 安装完成！"
echo ""
echo "使用方法："
echo "   whatcodec video.mp4               # 分析本地文件"
echo "   whatcodec http://example.com/video.flv  # 分析网络视频"
echo "   whatcodec --direct http://...     # 直接分析（不下载）"
echo "   whatcodec --keep http://...       # 保留临时文件"
echo ""
echo "重新加载 shell 配置以使用新安装的工具："
echo "   source ~/.zshrc"