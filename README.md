# whatcodec

一个简单的视频编码格式检测工具，支持本地文件和网络URL。

## 功能特性

- 🎞️ 检测各种视频编码格式（H.264、H.265、VP9、AV1等）
- 📁 支持本地文件分析
- 🌐 支持网络URL下载并分析
- 📡 支持直接分析URL（不下载文件）
- 🔍 特别支持FLV格式的codec_id识别

## 依赖要求

- `ffprobe` (通过 ffmpeg 提供)
- `curl`

## 安装

1. 克隆项目：
```bash
git clone <repository-url> ~/Github/whatcodec
cd ~/Github/whatcodec
```

2. 运行安装脚本：

**选项 A：安装 macOS App（推荐）**
默认情况下，脚本会自动构建并将 App 安装到 `~/Applications/WhatCodec.app`。
```bash
./install.sh
```
*需要系统中安装 [Platypus](https://sveinbjorn.org/platypus) 应用。*

**选项 B：仅安装命令行工具 (CLI)**
如果你只想要终端命令 `whatcodec`：
```bash
./install.sh --cli
source ~/.zshrc
```

## macOS App 使用方法

安装完成后，你可以在 Launchpad 或 `~/Applications` 中找到 **WhatCodec**。

- **拖拽分析**：直接将视频文件拖拽到 App 图标上。
- **双击运行**：双击打开 App，在弹出的文件选择窗口中选取视频文件。
- **结果显示**：分析结果将显示在弹出的文本窗口中。

### 手动构建 App

如果你想手动构建或查看构建脚本，可以使用根目录下的 `build_app.sh`：
```bash
./build_app.sh
```
生成的 App 将位于 `build/WhatCodec.app`。
此脚本会自动调用 Platypus 命令行工具（支持自动识别 App 包内 CLI），无需繁琐的手动配置。

## 命令行 (CLI) 使用方法

### 基本用法

```bash
# 分析本地文件
whatcodec video.mp4

# 分析网络视频（会下载临时文件）
whatcodec http://example.com/video.flv

# 直接分析URL（不下载文件）
whatcodec --direct http://example.com/video.m3u8

# 保留临时下载文件
whatcodec --keep http://example.com/video.flv
```

### 参数说明

- `--direct`: 直接分析URL，不下载文件到本地
- `--keep`: 保留下载的临时文件（用于调试）

### 支持的文件格式

- MP4, FLV, M3U8等常见视频格式
- 本地文件路径（绝对路径或相对路径）
- HTTP/HTTPS URL

### 输出示例

```bash
$ whatcodec video.mp4
📁 分析本地文件：video.mp4
🎞️ 编码类型：AVC (H.264)（codec_name=h264）

$ whatcodec http://example.com/stream.flv
⬇️ 下载视频：http://example.com/stream.flv
📁 分析本地文件：./temp_whatcodec_20231201120000.flv
🎞️ 编码类型：AVC (H.264)（codec_id=7）
```

## 卸载

删除安装的文件：
```bash
rm ~/.local/bin/whatcodec
```

如需要，从 `~/.zshrc` 中移除添加的PATH配置。

## 从原 .zshrc 迁移

如果你之前在 `.zshrc` 中有 `whatcodec` 函数，安装此工具后可以将原函数代码删除。新工具提供相同的功能但作为独立的可执行程序。