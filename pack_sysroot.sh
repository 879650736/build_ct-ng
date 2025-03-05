#!/bin/bash

# 脚本名称: pack_sysroot.sh
# 功能: 打包 SYSROOT 目录为压缩文件
# 支持格式: .tar.xz (最佳压缩率)
# 保留权限、符号链接等元数据

# 默认配置
DEFAULT_SYSROOT="$HOME/x-tools/arm-unknown-linux-gnueabi/arm-unknown-linux-gnueabi/sysroot"
OUTPUT_NAME="sysroot_backup_$(date +%Y%m%d_%H%M%S).tar.xz"

# 使用方法
usage() {
  echo "用法: $0 [选项]"
  echo "选项:"
  echo "  -s <路径>   指定 SYSROOT 目录 (默认: $DEFAULT_SYSROOT)"
  echo "  -o <名称>   指定输出文件名 (默认: $OUTPUT_NAME)"
  echo "  -h          显示帮助信息"
  echo "示例:"
  echo "  $0 -s /path/to/sysroot -o my_sysroot.tar.xz"
  exit 1
}

# 解析参数
while getopts "s:o:h" opt; do
  case $opt in
    s) SYSROOT_DIR="$OPTARG" ;;
    o) OUTPUT_NAME="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

# 设置默认值
SYSROOT_DIR="${SYSROOT_DIR:-$DEFAULT_SYSROOT}"

# 检查目录是否存在
if [ ! -d "$SYSROOT_DIR" ]; then
  echo "[错误] SYSROOT 目录不存在: $SYSROOT_DIR"
  exit 1
fi

# 检查压缩工具
if ! command -v xz &> /dev/null; then
  echo "[错误] 需要 xz 压缩工具，请先安装: sudo apt install xz-utils"
  exit 1
fi

# 进度显示函数 (需要 pv 工具)
show_progress() {
  if command -v pv &> /dev/null; then
    tar cf - -C "$SYSROOT_DIR" . | pv -s $(du -sb "$SYSROOT_DIR" | awk '{print $1}') | xz -9 > "$OUTPUT_NAME"
  else
    echo "[信息] 未找到 pv 工具，正在静默压缩..."
    tar cJf "$OUTPUT_NAME" -C "$SYSROOT_DIR" .
  fi
}

# 开始打包
echo "正在打包 SYSROOT 目录: $SYSROOT_DIR"
echo "输出文件: $(pwd)/$OUTPUT_NAME"

if show_progress; then
  echo "[成功] 打包完成!"
  echo "文件大小: $(du -h "$OUTPUT_NAME" | cut -f1)"
else
  echo "[错误] 打包过程失败!"
  # 清理不完整文件
  [ -f "$OUTPUT_NAME" ] && rm -f "$OUTPUT_NAME"
  exit 1
fi
