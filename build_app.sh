#!/bin/bash

# whatcodec Platypus Build Script
# 自动使用 Platypus 命令行工具构建 macOS App

# 配置
APP_NAME="WhatCodec"
SCRIPT_PATH="whatcodec_gui.sh"
ICON_PATH="resources/AppIcon.icns"
OUTPUT_DIR="build"
OUTPUT_APP="$OUTPUT_DIR/$APP_NAME.app"

# Platypus 选项
INTERFACE="Text Window"
INTERPRETER="/bin/zsh"

# 检查 platypus 命令
PLATYPUS_CMD="platypus"
EXTRA_ARGS=""

if ! command -v platypus &> /dev/null; then
    # 尝试查找 App 包内的 CLI 工具
    DEFAULT_APP_PATH="/Applications/Platypus.app/Contents/Resources/platypus_clt"
    RES_PATH="/Applications/Platypus.app/Contents/Resources"
    
    if [ -x "$DEFAULT_APP_PATH" ]; then
        echo "⚠️  未在 PATH 中找到 'platypus'，尝试使用 App 包内版本..."
        PLATYPUS_CMD="$DEFAULT_APP_PATH"
        
        # 必须手动指定 ScriptExec 和 Nib 路径，因为没有安装到系统目录
        # 1. 解码 ScriptExec (它是 base64 编码的)
        SCRIPT_EXEC="build/ScriptExec"
        mkdir -p build
        if [ ! -f "$SCRIPT_EXEC" ]; then
            echo "   正在从 App 包解码 ScriptExec..."
            base64 -D -i "$RES_PATH/ScriptExec.b64" -o "$SCRIPT_EXEC"
            chmod +x "$SCRIPT_EXEC"
        fi
        
        # 2. 设置额外参数指向资源
        EXTRA_ARGS="--executable-path $SCRIPT_EXEC --nib-path $RES_PATH/MainMenu.nib"
        echo "   已配置临时运行环境。"
    else
        echo "❌ 错误: 未找到 'platypus' 命令行工具。"
        echo "ℹ️  请打开 Platypus 应用，在设置/首选项中安装命令行工具。"
        echo "   或者手动把 Platypus.app 放到 /Applications 目录。"
        exit 1
    fi
fi

# 确保脚本文件存在
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ 错误: 找不到脚本文件 '$SCRIPT_PATH'"
    exit 1
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

echo "📦 正在构建 $APP_NAME ..."
echo "   - 脚本: $SCRIPT_PATH"
echo "   - 图标: $ICON_PATH"
echo "   - 界面: $INTERFACE"
echo "   - 拖拽支持: 开启"

# 执行构建命令
# -D (--droppable): 开启拖拽支持
# -y (--overwrite): 覆盖已存在的文件
# -T (--uniform-type-identifiers): 指定接受的文件类型 (public.item 匹配所有文件)
$PLATYPUS_CMD $EXTRA_ARGS \
  --name "$APP_NAME" \
  --interface-type "$INTERFACE" \
  --interpreter "$INTERPRETER" \
  --app-icon "$ICON_PATH" \
  --droppable \
  --uniform-type-identifiers "public.item|public.folder|public.movie" \
  --overwrite \
  "$SCRIPT_PATH" \
  "$OUTPUT_APP"

if [ $? -eq 0 ]; then
    echo "✅ 构建成功!"
    echo "   应用路径: $OUTPUT_APP"
    echo "   你可以直接将文件拖拽到 App 图标上，或者双击运行。"
else
    echo "❌ 构建失败。"
    exit 1
fi
