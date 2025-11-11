#!/usr/bin/bash

# 更新pkgconfig文件的安装目录（支持递归）
update_pkgconfig_prefix()
{
    local filePath="$1"
    local prefixDir="$2"
    local oldPrefix="$3"

    # 遍历目录下所有文件和子目录
    for file in "$filePath"/*; do
        [ ! -e "$file" ] && continue  # 空目录跳过

        if [ -d "$file" ]; then
            # 递归处理子目录（排除 . 和 ..）
            if [[ "$file" != "$filePath/." && "$file" != "$filePath/.." ]]; then
                update_pkgconfig_prefix "$file" "$prefixDir" "$oldPrefix"
            fi
        elif [[ "$file" == *.pc ]]; then
            echo "🔄 Processing: $file"
            # 全局替换所有出现的旧路径为新前缀
            sed -i "s|$oldPrefix|$prefixDir|g" "$file"
        fi
    done
}

# 主程序
workdir=$(cd "$(dirname "$0")" && pwd)
newPrefix="$workdir"
pcDir="$workdir/lib/pkgconfig"

# 自动从第一个 .pc 文件中提取 oldPrefix
first_pc=$(find "$pcDir" -name "*.pc" -print -quit)

if [ -z "$first_pc" ]; then
    echo "❌ 未找到任何 .pc 文件在: $pcDir"
    exit 1
fi

oldPrefix=$(grep -oP '^prefix=\K.*' "$first_pc" | head -1)

if [ -z "$oldPrefix" ]; then
    echo "❌ 无法从 $first_pc 中提取 prefix 值"
    exit 1
fi

echo "🔍 检测到旧前缀: $oldPrefix"
echo "🎯 将替换为新前缀: $newPrefix"
echo "----------------------------------------"

# 执行递归替换
update_pkgconfig_prefix "$pcDir" "$newPrefix" "$oldPrefix"

echo "✅ 所有 .pc 文件已成功更新。"
