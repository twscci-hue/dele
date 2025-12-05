#!/bin/bash
# tools/obfuscate.sh
# 脚本混淆工具

set -e

INPUT_FILE="$1"
OUTPUT_FILE="${2:-obfuscated.sh}"

if [ -z "$INPUT_FILE" ]; then
    echo "用法: $0 <输入文件> [输出文件]"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "错误: 输入文件不存在: $INPUT_FILE"
    exit 1
fi

echo "=== 脚本混淆工具 ==="
echo "输入文件: $INPUT_FILE"
echo "输出文件: $OUTPUT_FILE"
echo ""

# 复制原文件
cp "$INPUT_FILE" "$OUTPUT_FILE"

echo "[1/3] 删除注释和空行..."
# 保存 shebang（如果存在）
SHEBANG=""
if head -1 "$INPUT_FILE" | grep -q '^#!/'; then
    SHEBANG=$(head -1 "$INPUT_FILE")
fi

# 删除以 # 开头的纯注释行（不包括 shebang）
sed -i '/^#!/!{/^[[:space:]]*#/d}' "$OUTPUT_FILE"

# 如果没有 shebang 但需要保留第一行为空，则跳过；否则添加 shebang
if [ -n "$SHEBANG" ]; then
    # 确保 shebang 在第一行
    if ! head -1 "$OUTPUT_FILE" | grep -q '^#!/'; then
        sed -i "1i\\$SHEBANG" "$OUTPUT_FILE"
    fi
fi

# 删除空行
sed -i '/^[[:space:]]*$/d' "$OUTPUT_FILE"

echo "[2/3] 混淆变量名..."
# 定义变量名混淆映射
declare -A VAR_MAP=(
    ["CURRENT_VERSION"]="_v1"
    ["VERSION_CHECK_URL"]="_v2"
    ["TECH_SUPPORT"]="_v3"
    ["RED"]="_c1"
    ["GREEN"]="_c2"
    ["YELLOW"]="_c3"
    ["BLUE"]="_c4"
    ["PURPLE"]="_c5"
    ["CYAN"]="_c6"
    ["WHITE"]="_c7"
    ["NC"]="_c8"
    ["CURRENT_TIME"]="_t1"
    ["DEVICE_MODEL"]="_d1"
    ["ANDROID_VERSION"]="_a1"
    ["IS_ROOT"]="_r1"
    ["SCRIPT_PATH"]="_p1"
    ["SELF_DESTRUCT_MODE"]="_s1"
    ["INPUT_ERROR_COUNT"]="_e1"
    ["MAX_INPUT_ERRORS"]="_e2"
)

# 执行替换（仅替换完整单词）
for var in "${!VAR_MAP[@]}"; do
    sed -i "s/\b$var\b/${VAR_MAP[$var]}/g" "$OUTPUT_FILE"
done

echo "[3/3] 混淆函数名..."
# 定义函数名混淆映射
declare -A FUNC_MAP=(
    ["execute_immediate_destruct"]="_f1"
    ["handle_exit"]="_f2"
    ["advanced_self_destruct"]="_f3"
    ["version_compare"]="_f4"
    ["check_version"]="_f5"
    ["show_header"]="_f6"
    ["show_menu"]="_f7"
    ["menu_option_1"]="_f8"
    ["menu_option_2"]="_f9"
    ["menu_option_3"]="_f10"
    ["menu_option_4"]="_f11"
    ["menu_option_5"]="_f12"
    ["handle_user_input"]="_f13"
)

# 执行函数名替换
for func in "${!FUNC_MAP[@]}"; do
    sed -i "s/\b$func\b/${FUNC_MAP[$func]}/g" "$OUTPUT_FILE"
done

echo ""
echo "✓ 混淆完成"
echo "输出文件: $OUTPUT_FILE"
