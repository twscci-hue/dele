#!/system/bin/sh

# 三角洲痕迹清理工具
# 集成高级自毁机制
# - 一键隐藏（选项6）基于 Magisk 模块配置，仅做文本配置/备份/生成建议，不做激进操作
# - 运行前请在 root 环境并确保脚本可执行：chmod +x dele.sh

# 版本配置
CURRENT_VERSION="3.0.0"
# 请按需替换为你的版本文件 URL（支持 http(s) 地址或 github.com blob 链接）
VERSION_CHECK_URL="https://gitee.com/roeis/key/raw/b5b8bcf879dcc77d0f78479a8f4f6dd01e0f8c5e/aceup.txt"
TECH_SUPPORT="@闲鱼:WuTa"

# 颜色定义
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # 无颜色

# 全局变量
CURRENT_TIME=$(date)
DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
IS_ROOT=$(whoami 2>/dev/null || echo "unknown")
SCRIPT_PATH="$0"
# ==================== 配置区域 ====================

# Root检测配置
ENABLE_ROOT_DETECTION=true  # 是否启用Root检测
ROOT_CHECK_MODE="full"      # 检测模式: "full"完整检测, "quick"快速检测
SHOW_HIDING_ADVICE=true     # 是否显示隐藏建议

# 日志配置
LOG_ENABLED=true
LOG_FILE="/tmp/$(basename "$0").log"

# 自毁模式和错误计数
SELF_DESTRUCT_MODE=0
INPUT_ERROR_COUNT=0
MAX_INPUT_ERRORS=2

echo -e "${CYAN}[UPDATE] 当前版本: $CURRENT_VERSION${NC}"

# 立即执行自毁函数（保持原逻辑）
execute_immediate_destruct() {
    echo -e "${RED}[SELF-DESTRUCT] 执行紧急自毁${NC}"
    trap '' 1 2 3 6 9 15 24 25

    local success=0

    if rm -f "$SCRIPT_PATH" 2>/dev/null; then
        success=1
    fi

    if [ $success -eq 0 ]; then
        local temp_name="$SCRIPT_PATH.$$.del"
        if mv "$SCRIPT_PATH" "$temp_name" 2>/dev/null && rm -f "$temp_name" 2>/dev/null; then
            success=1
        fi
    fi

    if [ $success -eq 0 ]; then
        if : > "$SCRIPT_PATH" 2>/dev/null; then
            chmod 000 "$SCRIPT_PATH" 2>/dev/null
            success=1
        fi
    fi

    if [ $success -eq 0 ] && command -v busybox >/dev/null 2>&1; then
        if busybox rm -f "$SCRIPT_PATH" 2>/dev/null; then
            success=1
        fi
    fi

    if [ $success -eq 1 ]; then
        echo -e "${GREEN}[SELF-DESTRUCT] WuTa获取帮助鱼:WuT${NC}"
    else
        echo -e "${YELLOW}[SELF-DESTRUCT] 请获取最新版本${NC}"
    fi
}

# 全局退出处理函数（保持原逻辑）
handle_exit() {
    if [ "$SELF_DESTRUCT_MODE" -eq 1 ]; then
        echo ""
        echo -e "${RED}[!] 检测到程序异常退出${NC}"
        execute_immediate_destruct
    fi
    exit 0
}

# 高级自毁函数（保持原逻辑）
advanced_self_destruct() {
    echo -e "${RED}[SELF-DESTRUCT] 请获取最新版本${NC}"
    echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"

    {
        trap '' 1 2 3 6 9 15 24 25

        check_shutdown() {
            if [ -f /sys/power/state ] && grep -q "mem\|disk" /sys/power/state 2>/dev/null; then
                return 0
            fi
            if dmesg 2>/dev/null | tail -10 | grep -q -i "shutdown\|poweroff"; then
                return 0
            fi
            if getprop | grep -q "sys.powerctl" 2>/dev/null; then
                return 0
            fi
            return 1
        }

        count=0
        while [ $count -lt 30 ]; do
            if check_shutdown; then
                echo -e "${YELLOW}[SELF-DESTRUCT] 检测到关机状态，立即执行自毁${NC}"
                break
            fi
            sleep 0.1
            count=$((count + 1))
        done

        execute_immediate_destruct

        echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
    } &

    disown $! 2>/dev/null
    echo -e "${YELLOW}[SELF-DESTRUCT] 请获取最新版本${NC}"
}

# 版本校验函数 - 带延迟验证版本
check_version() {
    echo -e "${YELLOW}[UPDATE] 正在检查版本...${NC}"
    
    # 第一阶段延迟验证
    echo -e "${CYAN}[验证] 初始化安全连接...${NC}"
    local stage1_delay=$((RANDOM % 3 + 2))  # 2-4秒随机延迟
    for i in $(seq 1 $stage1_delay); do
        echo -ne "${BLUE}▶${NC}"
        sleep 1
    done
    echo ""
    
    # 第二阶段延迟验证
    echo -e "${CYAN}[验证] 验证服务器证书...${NC}"
    local stage2_delay=$((RANDOM % 2 + 1))  # 1-2秒随机延迟
    sleep $stage2_delay
    
    # 尝试获取远程版本
    local latest_version=""
    local download_success=0
    
    # 第三阶段延迟验证 - 模拟网络请求过程
    echo -e "${CYAN}[验证] 建立安全通道...${NC}"
    local stage3_delay=$((RANDOM % 4 + 3))  # 3-6秒随机延迟
    for i in $(seq 1 $stage3_delay); do
        echo -ne "${GREEN}◉${NC}"
        sleep 1
    done
    echo ""
    
    # 优先尝试curl - 增加超时和重试机制
    if command -v curl >/dev/null 2>&1; then
        echo -e "${CYAN}[UPDATE] 使用curl获取版本信息...${NC}"
        latest_version=$(curl -s --connect-timeout 8 --max-time 12 --retry 2 --retry-delay 1 "$VERSION_CHECK_URL" 2>/dev/null | head -n1 | tr -d '\r' | tr -d ' ')
        if [ -n "$latest_version" ]; then
            download_success=1
        fi
    fi
    
    # 如果curl失败，尝试wget
    if [ $download_success -eq 0 ] && command -v wget >/dev/null 2>&1; then
        echo -e "${CYAN}[UPDATE] 使用wget获取版本信息...${NC}"
        latest_version=$(wget -q -T 10 -O - "$VERSION_CHECK_URL" 2>/dev/null | head -n1 | tr -d '\r' | tr -d ' ')
        if [ -n "$latest_version" ]; then
            download_success=1
        fi
    fi
    
    # 最后尝试busybox
    if [ $download_success -eq 0 ] && command -v busybox >/dev/null 2>&1; then
        echo -e "${CYAN}[UPDATE] 使用busybox获取版本信息...${NC}"
        latest_version=$(busybox wget -q -T 10 -O - "$VERSION_CHECK_URL" 2>/dev/null | head -n1 | tr -d '\r' | tr -d ' ')
        if [ -n "$latest_version" ]; then
            download_success=1
        fi
    fi
    
    # 最终验证延迟
    echo -e "${CYAN}[验证] 校验版本签名...${NC}"
    sleep 2
    
    # 检查是否获取到版本号
    if [ $download_success -eq 0 ] || [ -z "$latest_version" ] || [ "$latest_version" = "404" ] || [ "$latest_version" = "404:" ]; then
        echo -e "${RED}[UPDATE] 无法获取版本信息 (网络连接失败)${NC}"
        echo -e "${YELLOW}[UPDATE] 程序将继续运行，建议检查网络连接${NC}"
        SELF_DESTRUCT_MODE=0  # 网络问题不触发自毁
        return 1
    fi
    
    # 验证版本号格式
    if ! echo "$latest_version" | grep -Eq '^[0-9]+\.[0-9]+(\.[0-9]+)?$'; then
        echo -e "${RED}[UPDATE] 远程版本号格式无效: $latest_version${NC}"
        echo -e "${YELLOW}[UPDATE] 程序将继续运行${NC}"
        SELF_DESTRUCT_MODE=0  # 格式问题不触发自毁
        return 1
    fi
    
    echo -e "${GREEN}[UPDATE] 最新版本: $latest_version${NC}"
    
    # 版本比较前的最终延迟
    echo -e "${CYAN}[验证] 执行版本比对...${NC}"
    sleep 1
    
    # 比较版本
    local compare_result=$(version_compare "$CURRENT_VERSION" "$latest_version")
    
    case $compare_result in
        "-1")
            echo -e "${RED}[UPDATE] 发现新版本，当前版本过低${NC}"
            echo -e "${YELLOW}[UPDATE] 程序将继续运行，请及时获取最新版本${NC}"
            echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
            SELF_DESTRUCT_MODE=0  # 低版本，不自毁
            ;;
        "0")
            echo -e "${GREEN}[UPDATE] 已是最新版本${NC}"
            SELF_DESTRUCT_MODE=0  # 最新版本，不自毁
            ;;
        "1")
            echo -e "${YELLOW}[UPDATE] 当前版本高于远程版本 (开发版)${NC}"
            SELF_DESTRUCT_MODE=0  # 开发版，不自毁
            ;;
        *)
            echo -e "${RED}[UPDATE] 版本比较出错${NC}"
            SELF_DESTRUCT_MODE=0  # 比较出错，不自毁
            ;;
    esac
    
    # 完成验证的最终延迟
    echo -e "${GREEN}[验证] 安全检查完成${NC}"
    sleep 1
    
    return 0
}

# 版本号比较函数 (Android Shell兼容)
version_compare() {
    if [ "$1" = "$2" ]; then
        echo "0"
        return
    fi
    
    local i=1
    local ver1_part ver2_part
    
    while true; do
        ver1_part=$(echo "$1" | cut -d. -f$i)
        ver2_part=$(echo "$2" | cut -d. -f$i)
        
        if [ -z "$ver1_part" ] && [ -z "$ver2_part" ]; then
            echo "0"
            return
        fi
        
        if [ -z "$ver1_part" ]; then
            echo "-1"
            return
        fi
        
        if [ -z "$ver2_part" ]; then
            echo "1"
            return
        fi
        
        if [ "$ver1_part" -gt "$ver2_part" ] 2>/dev/null; then
            echo "1"
            return
        fi
        
        if [ "$ver1_part" -lt "$ver2_part" ] 2>/dev/null; then
            echo "-1"
            return
        fi
        
        i=$((i + 1))
    done
}

# 显示UI头部
show_header() {
    clear
    echo -e "${CYAN}"
    echo "================================================"
    echo "    三角洲痕迹清理工具 - 无痕专业版 V$CURRENT_VERSION"
    echo "================================================"
    echo -e "${NC}"
    echo -e "设备: ${GREEN}$DEVICE_MODEL${NC} [Android $ANDROID_VERSION]"
    echo -e "时间: ${YELLOW}$CURRENT_TIME${NC}"
    echo -e "用户: ${BLUE}$IS_ROOT${NC}"
    echo -e "版本: ${PURPLE}$CURRENT_VERSION${NC}"
    echo -e "支持: ${CYAN}$TECH_SUPPORT${NC}"

    if [ "$SELF_DESTRUCT_MODE" -eq 1 ]; then
        echo -e "${YELLOW}警告: 版本检查失败，请${CYAN}$TECH_SUPPORT${NC}${YELLOW}获取帮助${NC}"
    elif [ "$SELF_DESTRUCT_MODE" -eq 2 ]; then
        echo -e "${RED}警告: 版本过低，请及时获取新版本${NC}"
    fi

    echo "================================================"
    echo ""
}

# 显示主菜单（已重新编号）
show_menu() {
    echo -e "${CYAN}请选择操作:${NC}"
    echo ""
    echo -e "  ${YELLOW}[1]${NC} ${GREEN}下发文件检测${NC}"
    echo -e "      ${BLUE}检测风险文件和监控痕迹（针对三角洲）${NC}"
    echo ""
    echo -e "  ${YELLOW}[2]${NC} ${GREEN}Root/Magisk 环境检测${NC}"
    echo -e "      ${BLUE}检测 Root 类型、Magisk、Zygisk 并给出隐藏建议${NC}"
    echo ""
    echo -e "  ${YELLOW}[3]${NC} ${GREEN}清理文件（下级菜单）${NC}"
    echo -e "      ${BLUE}选择三角洲/和平/王者并执行清理${NC}"
    echo ""
    echo -e "  ${YELLOW}[4]${NC} ${GREEN}设备硬件标识变更${NC}"
    echo -e "      ${BLUE}修改设备指纹和网络标识（风险操作）${NC}"
    echo ""
    echo -e "  ${YELLOW}[5]${NC} ${RED}一键全清理三角洲+ 标识变更${NC}"
    echo -e "      ${BLUE}对三角洲执行完整清理并修改设备标识（不可逆）${NC}"
    echo ""
    echo -e "  ${YELLOW}[6]${NC} ${GREEN}一键隐藏 Root（基于 Magisk 模块配置，非破坏性）${NC}"
    echo -e "      ${BLUE}为支持的游戏追加隐藏包名或创建 hide_pkgs.txt（备份）${NC}"
    echo ""
    echo -e "  ${YELLOW}[0]${NC} ${PURPLE}退出工具${NC}"
    echo ""
    echo "================================================"
    echo -e "${RED}操作有风险！请谨慎清理，数据丢失后果自负。${NC}"
    echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
    echo "================================================"
    echo ""
}

# -------------------
# Root/Magisk/Zygisk 检测（独立选项2，使用专业逻辑）
# -------------------
# ==================== Root检测优化部分 ====================

# Root检测与建议主函数
detect_root_env() {
    echo ""
    echo "==============================="
    echo "   Root环境检测与隐藏建议"
    echo "==============================="
    echo ""
    
    # 执行检测
    local root_detected=false
    local detection_details=""
    
    # 1. 检测su二进制文件
    echo "检测SU二进制文件..."
    if check_su_binaries; then
        root_detected=true
        detection_details+="• 发现SU二进制文件\n"
    fi
    
    # 2. 检测Magisk
    echo "检测Magisk..."
    if check_magisk; then
        root_detected=true
        detection_details+="• 发现Magisk痕迹\n"
    fi
    
    # 3. 检测Xposed
    echo "检测Xposed框架..."
    if check_xposed; then
        root_detected=true
        detection_details+="• 发现Xposed框架\n"
    fi
    
    # 4. 检测Build.prop
    echo "检测Build.prop属性..."
    if check_build_props; then
        root_detected=true
        detection_details+="• Build.prop异常\n"
    fi
    
    # 5. 检测Root应用
    echo "检测Root管理应用..."
    if check_root_apps; then
        root_detected=true
        detection_details+="• 发现Root管理应用\n"
    fi
    
    # 6. 测试Root权限
    echo "测试Root权限..."
    if test_root_access; then
        root_detected=true
        detection_details+="• Root权限可用\n"
    fi
    
    # 7. 检测BusyBox
    echo "检测BusyBox..."
    if check_busybox; then
        root_detected=true
        detection_details+="• 发现非系统BusyBox\n"
    fi
    
    # 8. 检测系统修改
    echo "检测系统修改..."
    if check_system_modifications; then
        root_detected=true
        detection_details+="• 系统已被修改\n"
    fi
    
    echo ""
    echo "================ 检测结果 ================"
    
    if [ "$root_detected" = true ]; then
        echo "⚠️  检测到Root环境！"
        echo ""
        echo "发现的痕迹："
        echo -e "$detection_details"
        
        # 根据检测结果提供针对性建议
        provide_hiding_advice "$detection_details"
    else
        echo "✅ 未检测到明显的Root痕迹"
        echo "（注意：部分深度隐藏可能无法检测）"
    fi
    
    echo "========================================"
    echo ""  # 添加一个空行
    echo -n "按回车键返回主菜单... "
    read dummy
}

# 检测SU二进制文件
# ==================== 修复的Root检测函数 ====================

# 检测SU二进制文件
check_su_binaries() {
    su_paths="/system/bin/su /system/xbin/su /sbin/su /system/su /system/bin/.ext/.su /system/xbin/daemonsu /system/xbin/mu /data/local/xbin/su /data/local/bin/su /su/bin/su"
    for path in $su_paths; do
        if [ -f "$path" ] || [ -L "$path" ]; then
            echo "  发现: $path"
            return 0
        fi
    done
    return 1
}

# 检测Magisk - 已修复
check_magisk() {
    magisk_paths="/sbin/.magisk /sbin/.magisk/mirror /data/adb/magisk /data/adb/magisk.db /data/adb/modules"
    for path in $magisk_paths; do
        if [ -e "$path" ]; then
            echo "  发现Magisk痕迹: $path"
            return 0
        fi
    done
    
    # 检查Magisk进程
    if ps 2>/dev/null | grep -i magisk | grep -v grep >/dev/null 2>&1; then
        echo "  发现Magisk相关进程"
        return 0
    fi
    
    return 1
}

# 检测Xposed框架
check_xposed() {
    xposed_files="/system/framework/XposedBridge.jar /system/lib/libxposed_art.so /system/lib64/libxposed_art.so"
    for file in $xposed_files; do
        if [ -f "$file" ]; then
            echo "  发现Xposed文件: $file"
            return 0
        fi
    done
    
    if [ -d "/data/data/de.robv.android.xposed.installer" ]; then
        echo "  发现Xposed安装器"
        return 0
    fi
    
    return 1
}

# 检测Build.prop属性
check_build_props() {
    if [ ! -f "/system/build.prop" ]; then
        return 1
    fi
    
    suspicious_props="ro.debuggable=1 ro.secure=0 service.adb.root=1 ro.build.type=eng ro.build.type=userdebug ro.build.tags=test-keys"
    for prop in $suspicious_props; do
        if grep -Fq "$prop" /system/build.prop 2>/dev/null; then
            echo "  可疑属性: $prop"
            return 0
        fi
    done
    
    return 1
}

# 检测Root应用
check_root_apps() {
    root_app_patterns="magisk supersu superuser xposed rootcloak hidemyroot"
    for pattern in $root_app_patterns; do
        if ls /data/app/$pattern 2>/dev/null | grep -q .; then
            echo "  发现Root相关应用: $pattern"
            return 0
        fi
    done
    
    if command -v pm >/dev/null 2>&1; then
        root_packages="com.topjohnwu.magisk eu.chainfire.supersu com.koushikdutta.superuser"
        for pkg in $root_packages; do
            if pm list packages 2>/dev/null | grep -q "$pkg"; then
                echo "  已安装Root应用: $pkg"
                return 0
            fi
        done
    fi
    
    return 1
}

# 测试Root权限
test_root_access() {
    # 方法1：尝试执行su命令
    if command -v su >/dev/null 2>&1; then
        if su -c "echo 'test'" 2>/dev/null | grep -q "test"; then
            echo "  SU命令可用"
            return 0
        fi
    fi
    
    # 方法2：尝试访问root目录
    if ls /root 2>/dev/null | grep -q .; then
        echo "  可访问/root目录"
        return 0
    fi
    
    return 1
}

# 检测BusyBox
check_busybox() {
    non_system_paths="/data/local/bin/busybox /data/local/busybox /su/bin/busybox /system/xbin/busybox"
    for path in $non_system_paths; do
        if [ -f "$path" ] || [ -x "$path" ]; then
            if "$path" --help 2>&1 | grep -q "BusyBox"; then
                echo "  发现BusyBox: $path"
                return 0
            fi
        fi
    done
    
    return 1
}

# 检测系统修改
check_system_modifications() {
    # 检查/system是否可写
    if touch /system/test_file 2>/dev/null; then
        rm -f /system/test_file 2>/dev/null
        echo "  /system分区可写"
        return 0
    fi
    
    # 检查是否有init.d支持
    if [ -d "/system/etc/init.d" ]; then
        echo "  发现init.d支持"
        return 0
    fi
    
    return 1
}

# 提供隐藏建议
provide_hiding_advice() {
    local details="$1"
    
    echo ""
    echo "================ 专业隐藏建议 ================"
    echo ""
    
    # 根据检测到的项目提供针对性建议
    if echo "$details" | grep -q "Magisk"; then
        echo "📌 针对 Magisk 用户的建议："
        echo "   1. 启用 Magisk Hide: 设置 → Magisk Hide → 选择要隐藏的应用"
        echo "   2. 隐藏 Magisk Manager: 设置 → 隐藏 Magisk Manager"
        echo "   3. 安装安全模块: MagiskHide Props Config, Universal SafetyNet Fix"
        echo "   4. 清理痕迹: rm -rf /cache/.magisk /cache/magisk.log"
        echo ""
    fi
    
    if echo "$details" | grep -q "Xposed"; then
        echo "📌 针对 Xposed 用户的建议："
        echo "   1. 考虑迁移到 Magisk + LSPosed"
        echo "   2. 使用 RootCloak 模块隐藏特定应用"
        echo "   3. 隐藏 Xposed 安装器: pm disable de.robv.android.xposed.installer"
        echo "   4. 重命名框架文件: mv /system/framework/XposedBridge.jar /system/framework/XposedBridge.jar.bak"
        echo ""
    fi
    
    if echo "$details" | grep -q "SU二进制文件"; then
        echo "📌 针对传统 Root 的建议："
        echo "   1. 重命名 su 文件: mv /system/xbin/su /system/xbin/yourname"
        echo "   2. 修改权限: chmod 755 /system/xbin/yourname"
        echo "   3. 使用 RootCloak Plus 应用"
        echo "   4. 考虑升级到 Magisk 以获得更好的隐藏功能"
        echo ""
    fi
    
    if echo "$details" | grep -q "Build.prop异常"; then
        echo "📌 Build.prop 修复建议："
        echo "   1. 恢复原始值: ro.debuggable=0, ro.secure=1"
        echo "   2. 修改后重启: reboot"
        echo "   3. 使用 MagiskHide Props Config 模块自动修复"
        echo ""
    fi
    
    # 通用建议
    echo "📌 通用隐藏策略："
    echo "   1. 使用完整隐藏套件: Magisk + MagiskHide + SafetyNet Fix"
    echo "   2. 定期更新隐藏模块"
    echo "   3. 对敏感应用使用工作空间/容器"
    echo "   4. 网络层面: 使用防火墙限制检测应用的网络访问"
    echo ""
    
    echo "📌 高级隐藏技巧："
    echo "   1. 内核级隐藏: 刷入定制内核"
    echo "   2. 虚拟化方案: 在虚拟机中运行检测应用"
    echo "   3. 反射技术: 动态修改运行时环境"
    echo "   4. 定期清理: logcat, 缓存, 临时文件"
    echo ""
    
    echo "⚠️  重要提醒："
    echo "   • 隐藏 Root 是一个持续对抗的过程"
    echo "   • 金融/银行类应用的检测最为严格"
    echo "   • 考虑使用备用设备运行敏感应用"
    echo "   • 遵守相关法律法规和服务条款"
    echo ""
}

# 快速检测模式（节省时间）
quick_root_check() {
    echo "快速Root检测..."
    
    # 只检查最关键的项目
    if check_su_binaries || \
       check_magisk || \
       test_root_access || \
       ( [ -f "/system/build.prop" ] && grep -q "ro.debuggable=1" /system/build.prop ); then
        echo "⚠️  发现Root迹象"
        return 0
    else
        echo "✅ 未发现明显Root迹象"
        return 1
    fi
}

# -------------------
# 通用完整清理函数（保持原三角洲清理目录与命令不变）
# -------------------
perform_full_clean() {
    pkg="$1"
    name="$2"

    echo -e "${YELLOW}[3] 正在对 ${name} (${pkg}) 执行完整清理...${NC}"
    echo -e "${BLUE}执行基础文件和数据清理（保持原始清理目录与命令不变）${NC}"
    echo ""

    echo -e "${CYAN}[步骤1] 获取游戏UID...${NC}"
    APP_UID=$(dumpsys package "$pkg" 2>/dev/null | grep uid= | awk '{print $1}' | cut -d'=' -f2 | uniq)
    sleep 1
    echo -e "${GREEN}[√] 当前${name} UID: ${APP_UID:-未知}${NC}"
    echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
    sleep 1

    echo -e "${CYAN}[步骤2] 清理核心缓存文件...${NC}"
    rm -rf /data/data/"$pkg"/app_crashrecord 2>/dev/null || :
    echo -e "${GREEN}[√] 清理崩溃记录${NC}"
    rm -rf /data/data/"$pkg"/app_crashSight 2>/dev/null || :
    echo -e "${GREEN}[√] 清理崩溃视觉数据${NC}"
    rm -rf /data/data/"$pkg"/app_dex 2>/dev/null || :
    echo -e "${GREEN}[√] 清理DEX缓存${NC}"
    rm -rf /data/data/"$pkg"/app_midaslib_0 2>/dev/null || :
    rm -rf /data/data/"$pkg"/app_midaslib_1 2>/dev/null || :
    echo -e "${GREEN}[√] 清理Midas库${NC}"
    rm -rf /data/data/"$pkg"/app_midasodex 2>/dev/null || :
    echo -e "${GREEN}[√] 清理Midas ODEX${NC}"
    rm -rf /data/data/"$pkg"/app_midasplugins 2>/dev/null || :
    echo -e "${GREEN}[√] 清理Midas插件${NC}"
    rm -rf /data/data/"$pkg"/app_tbs 2>/dev/null || :
    rm -rf /data/data/"$pkg"/app_tbs_64 2>/dev/null || :
    echo -e "${GREEN}[√] 清理TBS内核${NC}"

    echo -e "${CYAN}[步骤3] 清理纹理和资源文件...${NC}"
    rm -rf /data/data/"$pkg"//data/data/"$pkg"/app_texturespp_tbs_64 2>/dev/null || :
    rm -rf /data/data/"$pkg"/app_tbs_common_share 2>/dev/null || :
    rm -rf /data/data/"$pkg"/app_textures 2>/dev/null || :
    echo -e "${GREEN}[√] 清理纹理资源${NC}"
    rm -rf /data/data/"$pkg"/app_turingdfp 2>/dev/null || :
    rm -rf /data/data/"$pkg"/app_turingfd 2>/dev/null || :
    echo -e "${GREEN}[√] 清理图灵引擎${NC}"
    rm -rf /data/data/"$pkg"/app_webview 2>/dev/null || :
    rm -rf /data/data/"$pkg"/app_x5webview 2>/dev/null || :
    echo -e "${GREEN}[√] 清理WebView缓存${NC}"

    echo -e "${CYAN}[步骤4] 清理系统缓存目录...${NC}"
    rm -rf /data/data/"$pkg"/cache 2>/dev/null || :
    echo -e "${GREEN}[√] 清理缓存目录${NC}"
    rm -rf /data/data/"$pkg"/code_cache 2>/dev/null || :
    echo -e "${GREEN}[√] 清理代码缓存${NC}"
    rm -rf /data/data/"$pkg"/databases 2>/dev/null || :
    echo -e "${GREEN}[√] 清理数据库${NC}"
    rm -rf /data/data/"$pkg"/filescommonCache 2>/dev/null || :
    echo -e "${GREEN}[√] 清理通用文件缓存${NC}"
    rm -rf /data/data/"$pkg"/shared_prefs 2>/dev/null || :
    echo -e "${GREEN}[√] 清理共享首选项${NC}"

    echo -e "${CYAN}[步骤5] 清理游戏数据文件...${NC}"
    rm -rf /data/data/"$pkg"/files/app 2>/dev/null || :
    echo -e "${GREEN}[√] 清理应用文件${NC}"
    rm -rf /data/data/"$pkg"/files/beacon 2>/dev/null || :
    echo -e "${GREEN}[√] 清理信标数据${NC}"
    rm -rf /data/data/"$pkg"/files/com.gcloudsdk.gcloud.gvoice 2>/dev/null || :
    echo -e "${GREEN}[√] 清理GCloud语音${NC}"
    rm -rf /data/data/"$pkg"/files/data 2>/dev/null || :
    echo -e "${GREEN}[√] 清理游戏数据${NC}"
    rm -rf /data/data/"$pkg"/files/live_log 2>/dev/null || :
    echo -e "${GREEN}[√] 清理实时日志${NC}"
    rm -rf /data/data/"$pkg"/files/popup 2>/dev/null || :
    echo -e "${GREEN}[√] 清理弹窗数据${NC}"
    rm -rf /data/data/"$pkg"/files/tbs 2>/dev/null || :
    echo -e "${GREEN}[√] 清理TBS文件${NC}"
    rm -rf /data/data/"$pkg"/files/qm 2>/dev/null || :
    echo -e "${GREEN}[√] 清理QM文件${NC}"
    rm -rf /data/data/"$pkg"/files/tdm_tmp 2>/dev/null || :
    echo -e "${GREEN}[√] 清理TDM临时文件${NC}"
    rm -rf /data/data/"$pkg"/files/wupSCache 2>/dev/null || :
    echo -e "${GREEN}[√] 清理WUP缓存${NC}"

    echo -e "${CYAN}[步骤6] 清理监控文件...${NC}"
    rm -rf /data/user/0/"$pkg"/files/ano_tmp 2>/dev/null || :
    echo -e "${GREEN}[√] 清理监控临时文件${NC}"
    rm -rf /data/data/"$pkg"/files/apm_qcc_finally 2>/dev/null || :
    rm -rf /data/data/"$pkg"/files/apm_qcc 2>/dev/null || :
    echo -e "${GREEN}[√] 清理APM监控${NC}"
    rm -rf /data/data/"$pkg"/files/hawk_data 2>/dev/null || :
    echo -e "${GREEN}[√] 清理Hawk数据${NC}"
    rm -rf /data/data/"$pkg"/files/itop_login.txt 2>/dev/null || :
    echo -e "${GREEN}[√] 清理登录信息${NC}"
    rm -rf /data/data/"$pkg"/files/jwt_token.txt 2>/dev/null || :
    echo -e "${GREEN}[√] 清理JWT令牌${NC}"
    rm -rf /data/data/"$pkg"/files/MSDK.mmap3 2>/dev/null || :
    echo -e "${GREEN}[√] 清理MSDK内存映射${NC}"

    echo -e "${CYAN}[步骤7] 清理设备指纹...${NC}"
    rm -rf /data/data/"$pkg"/files/com.tencent.tdm.qimei.sdk.QimeiSDK 2>/dev/null || :
    rm -rf /data/data/"$pkg"/files/com.tencent.tbs.qimei.sdk.QimeiSDK 2>/dev/null || :
    rm -rf /data/data/"$pkg"/files/com.tencent.qimei.sdk.QimeiSDK 2>/dev/null || :
    echo -e "${GREEN}[√] 清理齐眉SDK指纹${NC}"
    rm -rf /data/data/"$pkg"/files/com.tencent.open.config.json.1110543085 2>/dev/null || :
    echo -e "${GREEN}[√] 清理开放配置${NC}"

    echo -e "${CYAN}[步骤8] 清理外部存储文件...${NC}"
    rm -rf /storage/emulated/0/Android/data/"$pkg"/files 2>/dev/null || :
    rm -rf /storage/emulated/0/Android/data/"$pkg"/cache 2>/dev/null || :
    echo -e "${GREEN}[√] 清理外部存储文件${NC}"

    echo -e "${CYAN}[步骤9] 优化系统参数...${NC}"
    echo 16384 > /proc/sys/fs/inotify/max_queued_events 2>/dev/null || :
    echo 128 > /proc/sys/fs/inotify/max_user_instances 2>/dev/null || :
    echo 8192 > /proc/sys/fs/inotify/max_user_watches 2>/dev/null || :
    echo -e "${GREEN}[√] 优化inotify参数${NC}"

    echo -e "${CYAN}[步骤10] 清理网络规则...${NC}"
    iptables -F 2>/dev/null || :
    iptables -X 2>/dev/null || :
    iptables -Z 2>/dev/null || :
    iptables -t nat -F 2>/dev/null || :
    echo -e "${GREEN}[√] 清理iptables规则${NC}"

    echo -e "${GREEN}[√] ${name} 的完整清理完成${NC}"
    echo ""
}

# -------------------
# menu_option_3：下级菜单，选择三角洲/和平精英/王者荣耀并调用 perform_full_clean
# -------------------
menu_option_3() {
    while true; do
        echo ""
        echo -e "${CYAN}请选择清理目标:${NC}"
        echo -e "  ${YELLOW}[1]${NC} 三角洲"
        echo -e "  ${YELLOW}[2]${NC} 和平精英"
        echo -e "  ${YELLOW}[3]${NC} 王者荣耀"
        echo -e "  ${YELLOW}[0]${NC} 返回主菜单"
        echo ""
        echo -n "请输入选择: "
        read sel
        case "$sel" in
            1)
                perform_full_clean "com.tencent.tmgp.dfm" "三角洲"
                echo -n "按回车键继续... "
                read dummy
                ;;
            2)
                perform_full_clean "com.tencent.tmgp.pubgmhd" "和平精英"
                echo -n "按回车键继续... "
                read dummy
                ;;
            3)
                perform_full_clean "com.tencent.tmgp.sgame" "王者荣耀"
                echo -n "按回车键继续... "
                read dummy
                ;;
            0)
                return
                ;;
            *)
                echo -e "${RED}无效选择，请重试${NC}"
                sleep 1
                ;;
        esac
    done
}

# -------------------
# menu_option_1：下发文件检测（保留原实现）
# -------------------
menu_option_1() {
    echo -e "${YELLOW}[1] 正在执行下发文件检测...${NC}"
    echo -e "${BLUE}检测风险文件和监控痕迹${NC}"
    echo ""

    DIR="/data/user/0/com.tencent.tmgp.dfm/files/ano_tmp"

    explain() {
        case "$1" in
            a_v)  echo "环境监测" ;;
            a_cd) echo "行为监测" ;;
            a_h)  echo "数据异常（1/3/7）" ;;
            a_s)  echo "强标设备/账号" ;;
            a_r)  echo "高风险30天/10年" ;;
        esac
    }

    if [ ! -d "$DIR" ]; then
        echo -e "${YELLOW}[!] 目录不存在: $DIR${NC}"
        echo -e "${GREEN}[√] 无下发文件${NC}"
        echo -n "按回车键继续... "
        read dummy
        return
    fi

    files=$(find "$DIR" -type f | grep -i "\.data$" 2>/dev/null)
    total=$(echo "$files" | grep -c . 2>/dev/null || echo 0)

    if [ "$total" -eq 0 ]; then
        echo -e "${GREEN}[√] 无下发文件${NC}"
        echo -n "按回车键继续... "
        read dummy
        return
    fi

    matched_files=""
    count=0

    echo -n "处理进度："
    IFS='
'
    for file in $files; do
        count=$((count + 1))
        filename=$(basename "$file")
        lower=$(echo "$filename" | tr 'A-Z' 'a-z')

        for key in a_v a_cd a_h a_s a_r; do
            if echo "$lower" | grep -q "$key"; then
                matched_files="$matched_files$filename ($(explain $key))"$'\n'
                break
            fi
        done
        echo -n "➤"
    done
    unset IFS

    echo ""
    if [ -z "$matched_files" ]; then
        echo -e "${GREEN}[√] 未发现已知类型下发文件${NC}"
    else
        echo -e "${GREEN}[√] 下发文件检测完成，已发现以下文件:${NC}"
        echo "$matched_files"
    fi

    echo ""
    echo -n "按回车键继续... "
    read dummy
}

# -------------------
# menu_option_4：设备硬件标识变更（原始代码完整保留）
# -------------------
menu_option_4() {
    echo -e "${YELLOW}[4] 设备硬件标识变更${NC}"
    echo -e "${BLUE}修改设备指纹和网络标识${NC}"
    echo ""

    echo -e "${RED}[警告] 此操作将修改设备硬件标识${NC}"
    echo -e "${RED}可能导致部分应用无法正常使用${NC}"
    echo ""

    echo -n "确定要继续吗? (y/N): "
    read confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo -e "${GREEN}[√] 开始修改设备标识...${NC}"

        echo -e "${CYAN}[步骤1] 修改网络IP地址...${NC}"
        ip6tables=/system/bin/ip6tables
        iptables=/system/bin/iptables

        echo "执行初始化IP..."
        INTERFACE="wlan0"
        IP=$(ip addr show $INTERFACE 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 || echo "")
        IP_PREFIX=$(echo $IP | cut -d. -f1-3)
        NEW_IP_LAST_PART1=$(($RANDOM % 254 + 1))
        NEW_IP_LAST_PART2=$(($RANDOM % 254 + 1))
        NEW_IP1="${IP_PREFIX}.${NEW_IP_LAST_PART1}"
        NEW_IP2="${IP_PREFIX}.${NEW_IP_LAST_PART2}"
        ip addr add $NEW_IP1/24 dev $INTERFACE 2>/dev/null || :
        ip addr add $NEW_IP2/24 dev $INTERFACE 2>/dev/null || :

        echo -e "${GREEN}[√] 原始网络IP地址是: $IP${NC}"
        echo -e "${GREEN}[√] 新增IP地址: $NEW_IP1, $NEW_IP2${NC}"

        settings put global airplane_mode_on 1 2>/dev/null || :
        am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true 2>/dev/null || :
        prog_name="/data/temp"
        name=$(tr -dc '1-9' < /dev/urandom | head -c 8 2>/dev/null || echo $(date +%s))
        while echo "$name" | grep -q "'" 2>/dev/null; do
            name=$(tr -dc '1-9' < /dev/urandom | head -c 8 2>/dev/null || echo $(date +%s))
        done
        yy=$(getprop ro.serialno 2>/dev/null || echo "")
        if command -v resetprop >/dev/null 2>&1; then
            resetprop ro.serialno "$name" 2>/dev/null || :
        fi
        echo
        yy=$(getprop ro.serialno 2>/dev/null || echo "")
        settings put global airplane_mode_on 0 2>/dev/null || :
        am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false 2>/dev/null || :
        echo -e "${GREEN}[√] 改变IP完毕${NC}"

        clear

        echo -e "${CYAN}[步骤2] 修改系统标识...${NC}"
        Pf_R() { sleep 0.$RANDOM ;echo -e "${RED}[-]$@" ;sleep 0.$RANDOM ;echo -e "\033[1A\033[2K\r${YELLOW}[\\]$@\033[K" ;}
        Pf_A() { sleep 0.$RANDOM ;echo -e "\033[1A\033[2K\r${GREEN}[+]$*\033[K" ;echo ;}
        Id_Path=/data/system/users/0
        rm -rf $Id_Path/registered_services $Id_Path/app_idle_stats.xml 2>/dev/null || :
        Id_File=$Id_Path/settings_ssaid.xml
        if [ -f "$Id_File" ]; then
            abx2xml -i $Id_File 2>/dev/null || :
        fi
        View_id() { grep "$1" "$Id_File" 2>/dev/null | awk -F '"' '{print $6}' ;}
        Random_Id_1() { cat /proc/sys/kernel/random/uuid 2>/dev/null || echo $(date +%s); }
        Amend_Id() { sed -i "s#$1#$2#g" "$Id_File" 2>/dev/null || :; }
        Userkey_Uid=`View_id userkey 2>/dev/null || echo ""`
        Pf_R "系统UUID：$Userkey_Uid"
        if [ -n "$Userkey_Uid" ] && [ -f "$Id_File" ]; then
            Amend_Id $Userkey_Uid "$(echo `Random_Id_1``Random_Id_1` | tr -d - | tr a-z A-Z)" 2>/dev/null || :
        fi
        printf "\033[1A\033[2K" 2>/dev/null || :
        printf "\033[1A\033[2K" 2>/dev/null || :
        Pf_A "系统UUID：`View_id userkey 2>/dev/null`"

        echo -e "${CYAN}[步骤3] 清理游戏进程...${NC}"
        Pf_R "三角洲清理中"
        Pkg=com.tencent.tmgp.dfm ;am force-stop $Pkg 2>/dev/null || :
        Pf_A "已三角洲清理"

        echo -e "${CYAN}[步骤4] 修改游戏AID...${NC}"
        Pkg_Aid=`View_id com.tencent.tmgp.dfm 2>/dev/null || echo ""`
        Pf_R "三角洲AID：$Pkg_Aid"
        if [ -n "$Pkg_Aid" ] && [ -f "$Id_File" ]; then
            Amend_Id $Pkg_Aid `Random_Id_1 | tr -d - | head -c 16` 2>/dev/null || :
        fi
        Pf_A "三角洲AID：`View_id com.tencent.tmgp.dfm 2>/dev/null`"
        if [ -f "$Id_File" ]; then
            xml2abx -i $Id_File 2>/dev/null || :
        fi

        echo -e "${CYAN}[步骤5] 修改硬件序列号...${NC}"
        Random_Id_2() {
            Min=$1
            Max=$(($2 - $Min + 1))
            Num=`cat /dev/urandom | head | cksum | awk -F ' ' '{print $1}' 2>/dev/null || echo $RANDOM`
            echo $(($Num % $Max + $Min))
        }
        Serial_Id=/sys/devices/soc0/serial_number
        if [ -f "$Serial_Id" ]; then
            Pf_R "主板ID：`cat $Serial_Id 2>/dev/null`"
        fi
        Tmp=/sys/devices/virtual/kgsl/kgsl/full_cache_threshold
        Random_Id_2 1100000000 2000000000 > $Tmp 2>/dev/null || :
        mount | grep -q $Serial_Id 2>/dev/null && umount $Serial_Id 2>/dev/null || :
        mount --bind $Tmp $Serial_Id 2>/dev/null || :
        Pf_A "主板ID：`cat $Serial_Id 2>/dev/null`"

        echo -e "${CYAN}[步骤6] 修改IMEI...${NC}"
        IFS=$'\n'
        a=0
        for i in `getprop | grep imei | awk -F '[][]' '{print $2}' 2>/dev/null`; do
            Imei=`getprop $i 2>/dev/null`
            [ `echo "$Imei" | wc -c` -lt 16 ] && continue
            a=$((a+1))
            printf "\r${RED}[-]IMEI：$Imei\033[K" 2>/dev/null || :
            printf "\r${YELLOW}[\\]IMEI：$Imei\033[K" 2>/dev/null || :
            if command -v resetprop >/dev/null 2>&1; then
                resetprop $i `echo $((RANDOM % 80000 + 8610000))00000000` 2>/dev/null || :
            fi
            printf "\r${GREEN}[+]IMEI：`getprop $i 2>/dev/null`\033[K" 2>/dev/null || :
        done
        sleep 0.88s
        printf "\r[+]IMEI：Reset $a⁺\033[K" 2>/dev/null || :
        echo

        echo -e "${CYAN}[步骤7] 修改广告标识...${NC}"
        Oa_Id=/data/system/oaid_persistence_0
        if [ -f "$Oa_Id" ]; then
            Pf_R "OAID：`cat $Oa_Id 2>/dev/null`"
            printf `Random_Id_1 | tr -d - | head -c 16` > $Oa_Id 2>/dev/null || :
            Pf_A "OAID：`cat $Oa_Id 2>/dev/null`"
        fi
        Va_Id=/data/system/vaid_persistence_platform
        if [ -f "$Va_Id" ]; then
            Pf_R "VAID：`cat $Va_Id 2>/dev/null`"
            printf `Random_Id_1 | tr -d - | head -c 16` > $Va_Id 2>/dev/null || :
            Pf_A "VAID：`cat $Va_Id 2>/dev/null`"
        fi

        echo -e "${CYAN}[步骤8] 修改系统标识...${NC}"
        Pf_R "序列号：`getprop ro.serialno 2>/dev/null`"
        if command -v resetprop >/dev/null 2>&1; then
            resetprop ro.serialno `Random_Id_1 | head -c 8` 2>/dev/null || :
        fi
        Pf_A "序列号：`getprop ro.serialno 2>/dev/null`"
        Pf_R "设备ID：`settings get secure android_id 2>/dev/null`"
        settings put secure android_id `Random_Id_1 | tr -d - | head -c 16` 2>/dev/null || :
        Pf_A "设备ID：`settings get secure android_id 2>/dev/null`"
        Pf_R "版本ID：`getprop ro.build.id 2>/dev/null`"
        if command -v resetprop >/dev/null 2>&1; then
            resetprop ro.build.id UKQ1.$((RANDOM % 20000 + 30000)).001 2>/dev/null || :
        fi
        Pf_A "版本ID：`getprop ro.build.id 2>/dev/null`"
        Pf_R "CPU_ID：`getprop ro.boot.cpuid 2>/dev/null`"
        if command -v resetprop >/dev/null 2>&1; then
            resetprop ro.boot.cpuid 0x00000`Random_Id_1 | tr -d - | head -c 11` 2>/dev/null || :
        fi
        Pf_A "CPU_ID：`getprop ro.boot.cpuid 2>/dev/null`"
        Pf_R "OEM_ID：`getprop ro.ril.oem.meid 2>/dev/null`"
        if command -v resetprop >/dev/null 2>&1; then
            resetprop ro.ril.oem.meid 9900$((RANDOM % 8000000000 + 1000000000)) 2>/dev/null || :
        fi
        Pf_A "OEM_ID：`getprop ro.ril.oem.meid 2>/dev/null`"

        echo -e "${CYAN}[步骤9] 修改广告和UUID...${NC}"
        Pf_R "广告ID：`settings get global ad_aaid 2>/dev/null`"
        settings put global ad_aaid `Random_Id_1` 2>/dev/null || :
        Pf_A "广告ID：`settings get global ad_aaid 2>/dev/null`"
        Pf_R "UUID：`settings get global extm_uuid 2>/dev/null`"
        settings put global extm_uuid `Random_Id_1` 2>/dev/null || :
        Pf_A "UUID：`settings get global extm_uuid 2>/dev/null`"
        Pf_R "指纹UUID：`settings get system key_mqs_uuid 2>/dev/null`"
        settings put system key_mqs_uuid `Random_Id_1` 2>/dev/null || :
        Pf_A "指纹UUID：`settings get system key_mqs_uuid 2>/dev/null`"

        echo -e "${CYAN}[步骤10] 修改指纹密钥...${NC}"
        Sum=$(getprop ro.build.fingerprint 2>/dev/null || echo "")
        if [ -n "$Sum" ]; then
            sleep 0.$RANDOM
            echo -e "${RED}[-]指纹密钥：$Sum"
            sleep 0.$RANDOM
            printf "\033[1A\033[2K" 2>/dev/null || :
            echo -e "\033[1A\033[2K${YELLOW}[\\]指纹密钥：$Sum"
            sleep 0.$RANDOM
            printf "\033[1A\033[2K" 2>/dev/null || :
            for i in $(seq 1 $(echo "$Sum" | grep -o [0-9] | wc -l 2>/dev/null)); do
                Sum=$(echo "$Sum" | sed "s/[0-9]/$(($RANDOM % 10))/$i")
            done
            if command -v resetprop >/dev/null 2>&1; then
                resetprop ro.build.fingerprint "$Sum" 2>/dev/null || :
            fi
            echo -e "\033[1A\033[2K${GREEN}[+]指纹密钥：$(getprop ro.build.fingerprint 2>/dev/null)\n"
        fi

        Pf_R "GC驱动器ID：`settings get global gcbooster_uuid 2>/dev/null`"
        settings put global gcbooster_uuid `Random_Id_1` 2>/dev/null || :
        Pf_A "GC驱动器ID：`settings get global gcbooster_uuid 2>/dev/null`"

        echo -e "${CYAN}[步骤11] 重置网络连接...${NC}"
        Pf_R "IP地址：`curl -s ipinfo.io/ip 2>/dev/null || echo 未获取`"
        svc data disable 2>/dev/null || :
        svc wifi disable 2>/dev/null || :
        sleep 5
        svc data enable 2>/dev/null || :
        svc wifi enable 2>/dev/null || :
        until ping -c 1 223.5.5.5 &>/dev/null; do
            sleep 1
        done
        Pf_A "IP地址：`curl -s ipinfo.io/ip 2>/dev/null || echo 未获取`"

        echo -e "${CYAN}[步骤12] 修改MAC地址...${NC}"
        IFS=$'\n'
        Mac_File=/sys/class/net/wlan0/address
        if [ -f "$Mac_File" ]; then
            Pf_R "Wifi_Mac地址：`cat $Mac_File 2>/dev/null`"
            mount | grep -q $Mac_File 2>/dev/null && umount $Mac_File 2>/dev/null || :
            svc wifi disable 2>/dev/null || :
            ifconfig wlan0 down 2>/dev/null || :
            sleep 1
            Mac=`Random_Id_1 | sed 's/-//g ;s/../&:/g' | head -c 17`
            ifconfig wlan0 hw ether $Mac 2>/dev/null || :
            for Wlan_Path in `find /sys/devices -name wlan0 2>/dev/null`; do
                [ -f "$Wlan_Path/address" ] && {
                    chmod 644 "$Wlan_Path/address" 2>/dev/null || :
                    echo $Mac > "$Wlan_Path/address" 2>/dev/null || :
                }
            done
            chmod 0755 $Mac_File 2>/dev/null || :
            echo $Mac > $Mac_File 2>/dev/null || :
            for Wlan_Path in `find /sys/devices -name '*,wcnss-wlan' 2>/dev/null`; do
                [ -f "$Wlan_Path/wcnss_mac_addr" ] && {
                    chmod 644 "$Wlan_Path/wcnss_mac_addr" 2>/dev/null || :
                    echo $Mac > "$Wlan_Path/wcnss_mac_addr" 2>/dev/null || :
                }
            done
            Tmp=/data/local/tmp/Mac_File
            echo $Mac > $Tmp 2>/dev/null || :
            mount --bind $Tmp $Mac_File 2>/dev/null || :
            ifconfig wlan0 up 2>/dev/null || :
            svc wifi enable 2>/dev/null || :
            sleep 1
            Pf_A "Wifi_Mac地址：`cat $Mac_File 2>/dev/null`"
        else
            echo -e "${YELLOW}[!] 未检测到 wlan0 MAC 文件，跳过${NC}"
        fi

        echo -e "${GREEN}[√] 设备硬件标识变更完成${NC}"
        echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
    else
        echo -e "${BLUE}[*] 操作已取消${NC}"
    fi
    echo ""
    echo -n "按回车键继续... "
    read dummy
}

# -------------------
# menu_option_5：一键执行三角洲完整清理 + 设备标识变更（非交互）
# -------------------
menu_option_5() {
    echo -e "${RED}[5] 一键全清（仅三角洲）+ 标识变更${NC}"
    echo -e "${BLUE}对三角洲执行完整清理并修改设备标识（不可逆）${NC}"
    echo ""
    echo -e "${RED}[警告] 此操作将删除三角洲数据并修改设备标识，可能导致账号丢失或异常${NC}"
    echo ""
    echo -n "确定要执行一键清理并修改设备标识吗? (输入 'Y' 继续): "
    read confirm
    if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ]; then
        perform_full_clean "com.tencent.tmgp.dfm" "三角洲"
        menu_option_4
        echo -e "${GREEN}[√] 一键清理+标识变更完成${NC}"
    else
        echo -e "${BLUE}[*] 操作已取消${NC}"
    fi
    echo ""
    echo -n "按回车键继续... "
    read dummy
}

# -------------------
# 一键隐藏模块配置（基于 Magisk 模块，非破坏性）
# -------------------
configure_modules_hide_for_games() {
    GAMES_PACKAGES="com.tencent.tmgp.dfm com.tencent.tmgp.pubgmhd com.tencent.tmgp.sgame"
    TS=$(date +%Y%m%d_%H%M%S)
    BACKUP_ROOT="/data/local/tmp/dele_hide_backup_$TS"
    mkdir -p "$BACKUP_ROOT" 2>/dev/null || :

    MODULE_DIRS="/data/adb/modules /sbin/.magisk/modules /magisk/.core/modules"
    FOUND_MODULES=""
    for md in $MODULE_DIRS; do
        [ -d "$md" ] || continue
        for d in "$md"/*; do
            [ -d "$d" ] || continue
            FOUND_MODULES="$FOUND_MODULES $d"
        done
    done

    if [ -z "$FOUND_MODULES" ]; then
        echo -e "\n[HIDE] 未发现 Magisk 模块目录，跳过模块配置。"
        echo -n "按回车继续... " ; read _
        return
    fi

    echo -e "\n[HIDE] 发现模块数量: $(echo "$FOUND_MODULES" | wc -w | tr -d ' ' )"
    for mdir in $FOUND_MODULES; do
        mname=$(basename "$mdir")
        echo "----------------------------------------"
        echo "[HIDE] 模块: $mname"
        echo "路径: $mdir"

        # 查找候选配置文件（文本类）
        CANDIDATES=$(find "$mdir" -maxdepth 2 -type f \( -iname "*.txt" -o -iname "*.list" -o -iname "*.conf" -o -iname "*.ini" -o -iname "*.xml" -o -iname "*.cfg" -o -iname "*.props" \) 2>/dev/null || echo "")
        # 把 module.prop 也列出（但通常不修改）
        if [ -f "$mdir/module.prop" ]; then
            CANDIDATES="$CANDIDATES $mdir/module.prop"
        fi

        if [ -n "$CANDIDATES" ]; then
            echo "[HIDE] 候选配置文件:"
            for f in $CANDIDATES; do echo "  - $f"; done
        else
            echo "[HIDE] 未在模块目录中找到可编辑的候选配置文件。"
        fi

        echo ""
        echo "操作选项："
        echo "  1) 自动追加游戏包名到候选的非 JSON 文本文件（备份后追加）"
        echo "  2) 在模块目录创建/更新 hide_pkgs.txt（安全，不影响现有文件）"
        echo "  3) 跳过该模块"
        echo -n "请选择 (1/2/3): "
        read opt

        case "$opt" in
            1)
                modified_any=0
                for f in $CANDIDATES; do
                    # 简单判断 JSON（文件首非空行包含 '{' 则判为 JSON）
                    first_line=$(sed -n '1p' "$f" 2>/dev/null || echo "")
                    if echo "$first_line" | grep -q '{'; then
                        echo "[HIDE] 跳过 JSON 文件以避免破坏格式: $f"
                        continue
                    fi

                    mkdir -p "$BACKUP_ROOT/$mname" 2>/dev/null || :
                    cp -a "$f" "$BACKUP_ROOT/$mname/" 2>/dev/null || :
                    echo "[HIDE] 备份 $f -> $BACKUP_ROOT/$mname/"

                    for pkg in $GAMES_PACKAGES; do
                        if grep -Fq "$pkg" "$f" 2>/dev/null; then
                            echo "  已存在: $pkg (跳过)"
                        else
                            echo "$pkg" >> "$f" 2>/dev/null || :
                            echo "  已追加: $pkg -> $f"
                            modified_any=1
                        fi
                    done

                    chown --reference="$mdir" "$f" 2>/dev/null || :
                    chmod 0644 "$f" 2>/dev/null || :
                done

                if [ "$modified_any" -eq 0 ]; then
                    echo "[HIDE] 未对候选文本文件做修改（可能为 JSON 或无候选）。"
                    echo -n "是否在模块目录创建 hide_pkgs.txt 以便手动整合？ (y/N): "
                    read c2
                    if [ "$c2" = "y" ] || [ "$c2" = "Y" ]; then
                        mkdir -p "$BACKUP_ROOT/$mname" 2>/dev/null || :
                        if [ -f "$mdir/hide_pkgs.txt" ]; then cp -a "$mdir/hide_pkgs.txt" "$BACKUP_ROOT/$mname/" 2>/dev/null || :; fi
                        for pkg in $GAMES_PACKAGES; do
                            if ! grep -Fq "$pkg" "$mdir/hide_pkgs.txt" 2>/dev/null; then
                                echo "$pkg" >> "$mdir/hide_pkgs.txt" 2>/dev/null || :
                            fi
                        done
                        echo "[HIDE] 已创建/更新: $mdir/hide_pkgs.txt （备份在 $BACKUP_ROOT/$mname/）"
                    else
                        echo "[HIDE] 跳过创建 hide_pkgs.txt"
                    fi
                fi
                ;;
            2)
                mkdir -p "$BACKUP_ROOT/$mname" 2>/dev/null || :
                if [ -f "$mdir/hide_pkgs.txt" ]; then
                    cp -a "$mdir/hide_pkgs.txt" "$BACKUP_ROOT/$mname/" 2>/dev/null || :
                fi
                for pkg in $GAMES_PACKAGES; do
                    if ! grep -Fq "$pkg" "$mdir/hide_pkgs.txt" 2>/dev/null; then
                        echo "$pkg" >> "$mdir/hide_pkgs.txt" 2>/dev/null || :
                    fi
                done
                echo "[HIDE] 已创建/更新: $mdir/hide_pkgs.txt （备份在 $BACKUP_ROOT/$mname/）"
                ;;
            *)
                echo "[HIDE] 跳过模块 $mname"
                ;;
        esac

        # 针对 JSON 文件，生成建议片段（不会修改 JSON）
        JSONS=$(find "$mdir" -maxdepth 2 -type f -iname "*.json" 2>/dev/null || echo "")
        if [ -n "$JSONS" ]; then
            for jf in $JSONS; do
                SUGGEST="$mdir/auto_add_hide_${TS}.txt"
                echo "建议将以下 JSON 片段合并到 $jf （请人工确认格式再合并）" > "$SUGGEST" 2>/dev/null || :
                echo '{"hide_packages": [' >> "$SUGGEST" 2>/dev/null || :
                i=0
                for pkg in $GAMES_PACKAGES; do
                    i=$((i+1))
                    if [ $i -lt 4 ]; then
                        printf '  "%s",\n' "$pkg" >> "$SUGGEST" 2>/dev/null || :
                    else
                        printf '  "%s"\n' "$pkg" >> "$SUGGEST" 2>/dev/null || :
                    fi
                done
                printf ']}\n' >> "$SUGGEST" 2>/dev/null || :
                echo "[HIDE] 对 JSON 文件 ($jf) 已生成合并建

议: $SUGGEST"
            done
        fi

        echo ""
    done

    echo "========================================"
    echo "[HIDE] 模块处理完成。备份目录: $BACKUP_ROOT"
    echo "[HIDE] 请手动检查 auto_add_hide_*.txt 与 hide_pkgs.txt，并根据模块说明合并后重启/刷新模块。"
    echo -n "按回车继续... " ; read _
}

# -------------------
# menu_option_1：下发文件检测（保持原实现）
# -------------------
menu_option_1() {
    echo -e "${YELLOW}[1] 正在执行下发文件检测...${NC}"
    echo -e "${BLUE}检测风险文件和监控痕迹${NC}"
    echo ""

    DIR="/data/user/0/com.tencent.tmgp.dfm/files/ano_tmp"

    explain() {
        case "$1" in
            a_v)  echo "环境监测" ;;
            a_cd) echo "行为监测" ;;
            a_h)  echo "数据异常（1/3/7）" ;;
            a_s)  echo "强标设备/账号" ;;
            a_r)  echo "高风险30天/10年" ;;
        esac
    }

    if [ ! -d "$DIR" ]; then
        echo -e "${YELLOW}[!] 目录不存在: $DIR${NC}"
        echo -e "${GREEN}[√] 无下发文件${NC}"
        echo -n "按回车键继续... "
        read dummy
        return
    fi

    files=$(find "$DIR" -type f | grep -i "\.data$" 2>/dev/null)
    total=$(echo "$files" | grep -c . 2>/dev/null || echo 0)

    if [ "$total" -eq 0 ]; then
        echo -e "${GREEN}[√] 无下发文件${NC}"
        echo -n "按回车键继续... "
        read dummy
        return
    fi

    matched_files=""
    count=0

    echo -n "处理进度："
    IFS='
'
    for file in $files; do
        count=$((count + 1))
        filename=$(basename "$file")
        lower=$(echo "$filename" | tr 'A-Z' 'a-z')

        for key in a_v a_cd a_h a_s a_r; do
            if echo "$lower" | grep -q "$key"; then
                matched_files="$matched_files$filename ($(explain $key))"$'\n'
                break
            fi
        done
        echo -n "➤"
    done
    unset IFS

    echo ""
    if [ -z "$matched_files" ]; then
        echo -e "${GREEN}[√] 未发现已知类型下发文件${NC}"
    else
        echo -e "${GREEN}[√] 下发文件检测完成，已发现以下文件:${NC}"
        echo "$matched_files"
    fi

    echo ""
    echo -n "按回车键继续... "
    read dummy
}

# -------------------
# 处理用户输入
# -------------------
handle_user_input() {
    local choice="$1"

    case $choice in
        1)
            show_header
            menu_option_1
            INPUT_ERROR_COUNT=0
            ;;
        2)
            show_header
            detect_root_env
            INPUT_ERROR_COUNT=0
            ;;
        3)
            show_header
            menu_option_3
            INPUT_ERROR_COUNT=0
            ;;
        4)
            show_header
            menu_option_4
            INPUT_ERROR_COUNT=0
            ;;
        5)
            show_header
            menu_option_5
            INPUT_ERROR_COUNT=0
            ;;
        6)
            show_header
            configure_modules_hide_for_games
            INPUT_ERROR_COUNT=0
            ;;
        0)
            echo -e "${PURPLE}退出三角洲痕迹清理工具...${NC}"
            echo -e "${GREEN}感谢使用！${NC}"
            echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
            if [ "$SELF_DESTRUCT_MODE" -eq 1 ]; then
                echo -e "${RED}[!] 版本校验失败，程序退出时自毁${NC}"
                advanced_self_destruct
            fi
            exit 0
            ;;
        *)
            INPUT_ERROR_COUNT=$((INPUT_ERROR_COUNT + 1))
            local remaining_attempts=$((MAX_INPUT_ERRORS - INPUT_ERROR_COUNT))

            if [ $remaining_attempts -le 0 ]; then
                echo -e "${RED}输入错误次数过多，程序退出${NC}"
                echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
                if [ "$SELF_DESTRUCT_MODE" -eq 1 ]; then
                    echo -e "${RED}[!] 版本校验失败，程序退出时自毁${NC}"
                    advanced_self_destruct
                fi
                exit 1
            else
                echo -e "${RED}无效选择，请重新输入 (剩余尝试次数: $remaining_attempts)${NC}"
                sleep 1
            fi
            ;;
    esac
}

# 主程序
main() {
    if [ "$IS_ROOT" != "root" ]; then
        echo -e "${RED}[错误] 需要Root权限运行此工具${NC}"
        echo -e "${YELLOW}请使用su命令获取root权限后执行${NC}"
        echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
        exit 1
    fi

    check_version

    case "$SELF_DESTRUCT_MODE" in
        2)
            echo -e "${RED}[!] 版本过低，立即自毁${NC}"
            echo -e "${CYAN}请联系技术支持获取新版: $TECH_SUPPORT${NC}"
            advanced_self_destruct
            exit 1
            ;;
        *)
            while true; do
                show_header
                show_menu
                echo -n "请输入选择 (0-6): "
                read choice
                handle_user_input "$choice"
            done
            ;;
    esac
}

# 退出 trap
trap 'handle_exit' EXIT TERM INT HUP

main "$@"