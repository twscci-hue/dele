#!/bin/bash
# tools/build.sh
# 本地编译脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== 三角洲清理工具编译脚本 ==="
echo ""

# 检查依赖
check_deps() {
    echo "[1/4] 检查依赖..."
    
    if ! command -v shc &> /dev/null; then
        echo "错误: 未安装 shc，请先安装："
        echo "  Ubuntu/Debian: sudo apt install shc"
        echo "  Arch: yay -S shc"
        exit 1
    fi
    
    echo "  ✓ shc 已安装"
}

# 混淆代码
obfuscate() {
    echo "[2/4] 混淆代码..."
    
    mkdir -p "$PROJECT_DIR/build"
    
    # 使用混淆脚本
    if [ -f "$SCRIPT_DIR/obfuscate.sh" ]; then
        bash "$SCRIPT_DIR/obfuscate.sh" "$PROJECT_DIR/dele.sh" "$PROJECT_DIR/build/dele_temp.sh"
    else
        # 如果混淆脚本不存在，直接复制
        cp "$PROJECT_DIR/dele.sh" "$PROJECT_DIR/build/dele_temp.sh"
        
        # 删除注释（保留 shebang）
        sed -i '2,$ s/#.*$//g' "$PROJECT_DIR/build/dele_temp.sh"
        
        # 删除空行
        sed -i '/^[[:space:]]*$/d' "$PROJECT_DIR/build/dele_temp.sh"
    fi
    
    echo "  ✓ 混淆完成"
}

# 编译二进制
compile() {
    echo "[3/4] 编译二进制..."
    
    shc -f "$PROJECT_DIR/build/dele_temp.sh" \
        -o "$PROJECT_DIR/build/dele" \
        -r
    
    # 清理临时文件
    rm -f "$PROJECT_DIR/build/dele_temp.sh"
    rm -f "$PROJECT_DIR/build/dele_temp.sh.x.c"
    
    echo "  ✓ 编译完成"
}

# 完成
finish() {
    echo "[4/4] 完成!"
    echo ""
    echo "输出文件: $PROJECT_DIR/build/dele"
    echo ""
    echo "使用方法:"
    echo "  chmod +x build/dele"
    echo "  su -c ./build/dele"
}

# 主流程
main() {
    check_deps
    obfuscate
    compile
    finish
}

main "$@"
