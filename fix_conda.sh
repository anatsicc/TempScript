#!/bin/bash

# --- 1. 获取参数 ---
OLD_PATH=$1
NEW_PATH=$2

if [ -z "$OLD_PATH" ] || [ -z "$NEW_PATH" ]; then
    echo "使用方法: $0 <旧路径> <新路径>"
    echo "示例: $0 /old_path/ana(mini)conda3 /new_path/ana(mini)conda3"
    exit 1
fi

# --- 2. 指定要修改的脚本白名单 ---
TARGET_FILES=(
    "conda" 
    "pip" 
    "pip3" 
    "pytest" 
    "jupyter" 
    "ipython"
)

echo ">>> 目标旧路径: $OLD_PATH"
echo ">>> 替换为新路径: $NEW_PATH"

# 定义修复函数
# 参数 $1: 要处理的 bin 目录路径
fix_bin_dir() {
    local target_bin_dir="$1"
    # 如果目录不存在，直接返回
    for filename in "${TARGET_FILES[@]}"; do
        local file="$target_bin_dir/$filename"
        [ -f "$file" ] && {
            echo "    修改: $filename"
            sed -i "s|$OLD_PATH|$NEW_PATH|g" "$file"
        }
    done
}

# --- 修复 Base 环境 ---
echo "正在处理 Base 环境 bin 目录..."
fix_bin_dir "$NEW_PATH/bin"

# --- 修复所有虚拟环境 (envs) ---
echo "正在处理 envs 虚拟环境..."
for bin_dir in "$NEW_PATH/envs"/*/bin; do
    # 如果通配符找不到, 会直接把路径赋值给bin_dir
    [ ! -d "$bin_dir" ] && continue 
    echo "  扫描环境: $(basename "$(dirname "$bin_dir")")"
    fix_bin_dir "$bin_dir"
done

# --- 重新执行 conda init ---
echo "---------------------------------------"
CONDA_EXE="$NEW_PATH/bin/conda"

if [ -f "$CONDA_EXE" ]; then
    echo "正在执行 conda init bash..."
    "$CONDA_EXE" init bash
    echo "---------------------------------------"

    # 重新安装 openssl, 有个错误
    echo "正在重新安装base环境的openssl..."
    "$CONDA_EXE" install -y --force-reinstall openssl

    
    echo "---------------------------------------"
    echo "配置完成！"
    echo "提示: 请运行 'source ~/.bashrc' 使改动生效。"
else
    echo "错误: 未能在 $CONDA_EXE 找到 conda 程序，无法执行后续操作。"
fi
