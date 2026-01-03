#!/usr/bin/env zsh

# whatcodec GUI Wrapper
# 修复环境变量 + 支持双击打开选文件

# 1. 修复 PATH，确保能找到 homebrew 安装的工具
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# 2. 检查参数。如果为空（直接双击打开），则弹出文件选择框
if [[ $# -eq 0 ]]; then
  echo "👉 未检测到拖拽文件，尝试打开文件选择窗口..."
  if command -v osascript >/dev/null; then
    # 使用 AppleScript 弹出文件选择框
    # 注意：这里类型限制稍微放宽，避免某些文件选不中
    TARGET_FILE=$(osascript -e 'try' -e 'POSIX path of (choose file with prompt "请选择要分析的视频文件：")' -e 'end try' 2>/dev/null)
    
    if [[ -n "$TARGET_FILE" ]]; then
      echo "✅ 已选择文件：$TARGET_FILE"
      # 将选中的文件重置为脚本参数
      set -- "$TARGET_FILE"
    else
      echo "❌ 未选择文件。"
      echo "💡 提示："
      echo "1. 将视频文件直接 **拖拽** 到 App 图标上打开。"
      echo "2. 或者双击打开 App 后，在弹窗中选择文件。"
      exit 0
    fi
  else
    echo "❌ 无法调用 osascript 弹出文件选择框。"
    exit 1
  fi
fi

# ==========================================
# 下面是 whatcodec 的核心逻辑
# ==========================================

whatcodec() {
  local input=""
  local direct_mode=false
  local keep_mode=false

  for arg in "$@"; do
    case "$arg" in
      --direct) direct_mode=true ;;
      --keep) keep_mode=true ;;
      http*) input="$arg" ;;
      /*|./*|*.flv|*.mp4|*.m3u8) input="$arg" ;;
      *) 
        # 尝试作为文件路径处理（兼容带空格的路径等）
        if [[ -f "$arg" ]]; then
             input="$arg"
        else
             echo "❗ 未识别的参数：$arg" 
        fi
        ;;
    esac
  done

  if [[ -z "$input" ]]; then
    echo "❌ 缺少输入路径或URL"
    return 1
  fi

  if [[ -f "$input" && "$direct_mode" = false ]]; then
    echo "📁 分析本地文件：$input"
    local codec_name
    codec_name=$(ffprobe -v error -select_streams v:0 \
      -show_entries stream=codec_name \
      -of default=nokey=1:noprint_wrappers=1 "$input")

    if [[ -n "$codec_name" && "$codec_name" != "unknown" ]]; then
      local readable=""
      case "$codec_name" in
        h264) readable="AVC (H.264)" ;;
        hevc) readable="HEVC (H.265)" ;;
        mpeg4) readable="MPEG-4 Part 2" ;;
        vp9) readable="Google VP9" ;;
        av1) readable="AV1" ;;
        *) readable="Unknown Format" ;;
      esac
      echo "🎞️ 编码类型：$readable（codec_name=$codec_name）"
    else
      # codec_name=unknown，尝试读取 FLV codec_id
      local ext="${input##*.}"
      if [[ "$ext" == "flv" ]]; then
        local tag=$(ffprobe -v error -show_entries stream=codec_tag \
          -of default=noprint_wrappers=1:nokey=1 "$input" | head -n 1)
        tag=${tag#0x}
        tag=${tag:l}
        local id=$((16#$tag))
        case $id in
          2) echo "🎞️ 编码类型：Sorenson H.263（codec_id=$id）" ;;
          3) echo "🎞️ 编码类型：Screen video（codec_id=$id）" ;;
          4) echo "🎞️ 编码类型：On2 VP6（codec_id=$id）" ;;
          5) echo "🎞️ 编码类型：On2 VP6 with alpha（codec_id=$id）" ;;
          6) echo "🎞️ 编码类型：Screen video v2（codec_id=$id）" ;;
          7) echo "🎞️ 编码类型：AVC (H.264)（codec_id=$id）" ;;
          12) echo "🎞️ 编码类型：HEVC (H.265)（codec_id=$id）" ;;
          *) echo "🎞️ 编码类型未知（codec_id=$id）" ;;
        esac
      else
        echo "❓ 无法识别编码类型（codec_name=unknown）"
      fi
    fi
    return
  fi

  if $direct_mode; then
    echo "📡 直接分析 URL：$input"
    ffprobe -v error -select_streams v:0 \
      -show_entries stream=codec_name \
      -of default=nokey=1:noprint_wrappers=1 "$input"
    return
  fi

  local ts=$(date +%Y%m%d%H%M%S)
  local tmpfile="./temp_whatcodec_$ts.flv"
  echo "⬇️ 下载视频：$input"
  curl --silent --max-time 15 --location --output "$tmpfile" "$input"

  if [[ ! -s "$tmpfile" ]]; then
    echo "❌ 下载失败或文件为空"
    $keep_mode || rm -f "$tmpfile"
    return 1
  fi

  whatcodec "$tmpfile"
  $keep_mode || rm -f "$tmpfile"
}

# 3. 执行主逻辑
whatcodec "$@"
