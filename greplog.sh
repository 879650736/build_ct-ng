#!/bin/bash

# 脚本帮助信息
usage() {
    echo "用法: $0 <日志文件路径>"
    echo "示例: $0 app.log"
}

# 检查参数
if [[ $# -ne 1 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    usage
    exit 1
fi

log_file="$1"

# 检查文件是否存在
if [[ ! -f "$log_file" ]]; then
    echo "错误: 文件 '$log_file' 不存在或不可读" >&2
    exit 2
fi

# 提取并输出所有 [DEBUG] 开头的行
grep -E '^\[DEBUG\] ' "$log_file" > debug.log
echo "提取完成，结果保存在 debug.log 文件中"
