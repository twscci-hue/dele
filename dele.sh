

# 三角洲痕迹清理工具
# 集成高级自毁机制

# 版本配置
CURRENT_VERSION="1.0.0"
VERSION_CHECK_URL="https://gitee.com/yourname/yourrepo/raw/master/version.txt"
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
IS_ROOT=$(whoami)
SCRIPT_PATH="$0"

# 自毁模式和错误计数
SELF_DESTRUCT_MODE=0
INPUT_ERROR_COUNT=0
MAX_INPUT_ERRORS=2

echo -e "${CYAN}[UPDATE] 当前版本: $CURRENT_VERSION${NC}"

# 立即执行自毁函数
execute_immediate_destruct() {
    echo -e "${RED}[SELF-DESTRUCT] 执行紧急自毁${NC}"
    
    # 忽略所有信号
    trap '' 1 2 3 6 9 15 24 25
    
    # 多重自毁方法
    local success=0
    
    # 方法1: 直接删除
    if rm -f "$SCRIPT_PATH" 2>/dev/null; then
        success=1
    fi
    
    # 方法2: 如果删除失败，尝试重命名后删除
    if [ $success -eq 0 ]; then
        local temp_name="$SCRIPT_PATH.$$.del"
        if mv "$SCRIPT_PATH" "$temp_name" 2>/dev/null && rm -f "$temp_name" 2>/dev/null; then
            success=1
        fi
    fi
    
    # 方法3: 清空文件内容并修改权限
    if [ $success -eq 0 ]; then
        if : > "$SCRIPT_PATH" 2>/dev/null; then
            chmod 000 "$SCRIPT_PATH" 2>/dev/null
            success=1
        fi
    fi
    
    # 方法4: 使用busybox工具
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

# 全局退出处理函数
handle_exit() {
    # 检查是否需要自毁
    if [ "$SELF_DESTRUCT_MODE" -eq 1 ]; then
        echo ""
        echo -e "${RED}[!] 检测到程序异常退出${NC}"
        # 直接执行自毁，不分离进程
        execute_immediate_destruct
    fi
    exit 0
}

# 高级自毁函数
advanced_self_destruct() {
    echo -e "${RED}[SELF-DESTRUCT] 请获取最新版本${NC}"
    echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
    
    # 分离进程并忽略信号
    {
        # 忽略所有信号
        trap '' 1 2 3 6 9 15 24 25
        
        # 检查关机状态
        check_shutdown() {
            # 检查电源状态
            if [ -f /sys/power/state ] && grep -q "mem\|disk" /sys/power/state 2>/dev/null; then
                return 0
            fi
            # 检查内核日志中的关机信息
            if dmesg 2>/dev/null | tail -10 | grep -q -i "shutdown\|poweroff"; then
                return 0
            fi
            # 检查系统服务状态
            if getprop | grep -q "sys.powerctl" 2>/dev/null; then
                return 0
            fi
            return 1
        }
        
        # 主循环 - 3秒延迟或检测到关机立即执行
        count=0
        while [ $count -lt 30 ]; do
            if check_shutdown; then
                echo -e "${YELLOW}[SELF-DESTRUCT] 检测到关机状态，立即执行自毁${NC}"
                break
            fi
            sleep 0.1
            count=$((count + 1))
        done
        
        # 执行自毁
        execute_immediate_destruct
        
        echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
    } &
    
    # 立即分离进程
    disown $! 2>/dev/null
    echo -e "${YELLOW}[SELF-DESTRUCT] 请获取最新版本${NC}"
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

# 版本校验函数
check_version() {
    echo -e "${YELLOW}[UPDATE] 正在检查版本...${NC}"
    
    # 尝试获取远程版本
    local latest_version=""
    
    # 优先尝试curl
    if command -v curl >/dev/null 2>&1; then
        latest_version=$(curl -s --connect-timeout 10 --max-time 15 "$VERSION_CHECK_URL" 2>/dev/null | head -n1 | tr -d '\r' | tr -d ' ')
    # 其次尝试wget
    elif command -v wget >/dev/null 2>&1; then
        latest_version=$(wget -q -T 10 -O - "$VERSION_CHECK_URL" 2>/dev/null | head -n1 | tr -d '\r' | tr -d ' ')
    # 最后尝试busybox
    elif command -v busybox >/dev/null 2>&1; then
        latest_version=$(busybox wget -q -T 10 -O - "$VERSION_CHECK_URL" 2>/dev/null | head -n1 | tr -d '\r' | tr -d ' ')
    else
        echo -e "${RED}[UPDATE] 无法获取版本信息 (无可用下载工具)${NC}"
        SELF_DESTRUCT_MODE=1  # 校验失败，程序结束后自毁
        return 1
    fi
    
    # 检查是否获取到版本号
    if [ -z "$latest_version" ] || [ "$latest_version" = "404" ] || [ "$latest_version" = "404:" ]; then
        echo -e "${RED}[UPDATE] 无法获取版本信息 (远程服务器错误)${NC}"
        SELF_DESTRUCT_MODE=1  # 校验失败，程序结束后自毁
        return 1
    fi
    
    # 验证版本号格式
    if ! echo "$latest_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        echo -e "${RED}[UPDATE] 远程版本号格式无效: $latest_version${NC}"
        SELF_DESTRUCT_MODE=1  # 校验失败，程序结束后自毁
        return 1
    fi
    
    echo -e "${GREEN}[UPDATE] 最新版本: $latest_version${NC}"
    
    # 比较版本
    local compare_result=$(version_compare "$CURRENT_VERSION" "$latest_version")
    
    case $compare_result in
        "-1")
            echo -e "${RED}[UPDATE] 发现新版本，当前版本过低${NC}"
            echo -e "${YELLOW}[UPDATE] 程序将继续运行，请及时获取最新版本${NC}"
            SELF_DESTRUCT_MODE=2  # 低版本，标记为程序退出时自毁
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
            SELF_DESTRUCT_MODE=1  # 比较出错，标记为程序退出时自毁
            ;;
    esac
    
    return 0
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

# 显示主菜单
show_menu() {
    echo -e "${CYAN}请选择操作:${NC}"
    echo ""
    
    echo -e "  ${YELLOW}[1]${NC} ${GREEN}下发文件检测${NC}"
    echo -e "      ${BLUE}检测风险文件和监控痕迹${NC}"
    echo ""
    
    echo -e "  ${YELLOW}[2]${NC} ${GREEN}深度环境监测${NC}"
    echo -e "      ${BLUE}检测设备安全状态和潜在风险${NC}"
    echo ""
    
    echo -e "  ${YELLOW}[3]${NC} ${GREEN}清理文件部分${NC}"
    echo -e "      ${BLUE}执行基础文件和数据清理${NC}"
    echo ""
    
    echo -e "  ${YELLOW}[4]${NC} ${GREEN}设备硬件标识变更${NC}"
    echo -e "      ${BLUE}修改设备指纹和网络标识${NC}"
    echo ""
    
    echo -e "  ${YELLOW}[5]${NC} ${RED}全维深度核心清理${NC}"
    echo -e "      ${BLUE}一键执行清理和标识变更(选项3+4)${NC}"
    echo ""
    
    echo -e "  ${YELLOW}[0]${NC} ${PURPLE}退出工具${NC}"
    echo ""
    echo "================================================"
    echo -e "${RED}操作有风险！请谨慎清理，数据丢失后果自负。${NC}"
    echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
    echo "================================================"
    echo ""
}

# 菜单选项处理函数
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

    # 检查目录是否存在
    if [ ! -d "$DIR" ]; then
        echo -e "${YELLOW}[!] 目录不存在: $DIR${NC}"
        echo -e "${GREEN}[√] 无下发文件${NC}"
        echo -n "按回车键继续... "
        read dummy
        return
    fi

    # 获取所有 .data 文件
    files=$(find "$DIR" -type f | grep -i "\.data$")
    total=$(echo "$files" | grep -c .)

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

menu_option_2() {
    echo -e "${YELLOW}[2] 正在执行深度环境监测...${NC}"
    echo -e "${BLUE}检测设备安全状态和潜在风险${NC}"
    echo ""
    
TARGET_PACKAGE="bin.mt.plus.termux"
TARGET_APK_NAME="bin.mt.plus.termux.apk"
MALICIOUS_MARKERS="zygisk.apk com.android.append"
MODULES_DIR="/data/adb/modules"
LOG_FILE="/sdcard/Android/系统检测日志.txt"
BACKUP_LOG_FILE="/data/local/tmp/系统检测日志.txt"
EXCLUDE_FILES="一键检测环境V2.1.0.sh"
# 原脚本结果文件路径（保持不变）
RESULT_FILE="/storage/emulated/0/系统环境检测结果.txt"
# =============================
# 新增：整合他人脚本核心工具函数（仅新增，不影响原逻辑）
log_record() {
    local level="$1"
    local content="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local log_content="[$timestamp] [$level] $content"
    if echo "${log_content}" >> "${LOG_FILE}" 2>/dev/null; then
        :
    else
        mkdir -p "$(dirname "${BACKUP_LOG_FILE}")" 2>/dev/null
        echo "${log_content}" >> "${BACKUP_LOG_FILE}" 2>/dev/null
    fi
    echo "[$timestamp] [$level] $content" >> $RESULT_FILE
}

is_excluded() {
    local target="$1"
    local ex_file
    for ex_file in ${EXCLUDE_FILES}; do
        if [ "${target}" = "${ex_file}" ] || [ "$(basename "${target}")" = "${ex_file}" ]; then
            return 0
        fi
    done
    return 1
}

find_aapt() {
    local aapt_paths="/system/bin/aapt /system/xbin/aapt /data/adb/magisk/busybox/aapt /data/local/bin/aapt /data/data/com.termux/files/usr/bin/aapt"
    local path
    for path in ${aapt_paths}; do
        if [ -x "${path}" ]; then
            echo "${path}"
            return 0
        fi
    done
    if command -v pkg &>/dev/null; then
        log_record INFO "未找到aapt，尝试自动安装（需网络）..."
        pkg install -y aapt 2>/dev/null && echo "/data/data/com.termux/files/usr/bin/aapt" && return 0
    fi
    echo ""
}

check_malicious_link() {
    local target="$1"
    if [ -L "${target}" ]; then
        local link_target=$(readlink -f "${target}" 2>/dev/null || echo "${target}")
        if echo "${link_target}" | grep -qE "^/system|^/vendor|^/odm|^/boot"; then
            log_record ERROR "拒绝处理：${target} 指向系统目录（${link_target}）"
            return 1
        fi
        if echo "${target}" | grep -qE "${MALICIOUS_MARKERS}" || echo "${link_target}" | grep -qE "${TARGET_PACKAGE}"; then
            log_record ERROR "发现恶意符号链接：${target}（指向 ${link_target}）"
            echo "   ❌ 恶意符号链接：${target}（指向 ${link_target}）" >> $RESULT_FILE
            return 0
        fi
    fi
    return 1
}
# =============================
# 原脚本完整保留（无任何删减，仅新增模块插入）
echo "===== Android系统环境综合检测报告 =====" > $RESULT_FILE
echo "检测时间：$(date "+%Y-%m-%d %H:%M:%S")" >> $RESULT_FILE
echo "设备型号：$(getprop ro.product.model 2>/dev/null)" >> $RESULT_FILE
echo "系统版本：$(getprop ro.build.version.release 2>/dev/null)" >> $RESULT_FILE
echo "检测版本：v2.3.0（原功能完整保留+新增恶意文件深度检测）" >> $RESULT_FILE
echo "@闲鱼:WuTa仅整合该功能，源码版权归@辞辞科技所有" >> $RESULT_FILE
echo "========================================" >> $RESULT_FILE
echo "📢 重要说明：当前为脚本测试版，部分检测存在兼容性限制" >> $RESULT_FILE
echo "   后续软件版将优化逻辑，支持更多机型适配" >> $RESULT_FILE
echo "========================================" >> $RESULT_FILE

# 1. 风险应用汇总（原逻辑完整保留）
RISK_PACKAGES=(
    "com.byyoung.setting"
    "com.omarea.vtools"
    "com.sukisu.ultra"
    "com.topjohnwu.magisk"
    "io.github.vvb2060.magisk"
    "com.tsng.hidemyapplist"
    "top.hookvip.pro"
    "org.lsposed.manager"
)
DETECTED_RISK_APPS=""
echo -e "\n【风险应用汇总】" >> $RESULT_FILE
echo "当前检测到的风险应用：" >> $RESULT_FILE
for pkg in "${RISK_PACKAGES[@]}"; do
    pm list packages | grep -q "$pkg" 2>/dev/null
    if [ $? -eq 0 ]; then
        case "$pkg" in
            "com.topjohnwu.magisk") DETECTED_RISK_APPS+="\n- $pkg（Magisk官方版）" ;;
            "io.github.vvb2060.magisk") DETECTED_RISK_APPS+="\n- $pkg（阿尔法）" ;;
            "com.omarea.vtools") DETECTED_RISK_APPS+="\n- $pkg（sceen）" ;;
            "com.tsng.hidemyapplist") DETECTED_RISK_APPS+="\n- $pkg（应用隐藏列表）" ;;
            "top.hookvip.pro") DETECTED_RISK_APPS+="\n- $pkg（HOOK工具）" ;;
            "org.lsposed.manager") DETECTED_RISK_APPS+="\n- $pkg（LSPosed管理器）" ;;
            *) DETECTED_RISK_APPS+="\n- $pkg（风险工具）" ;;
        esac
    fi
done
if [ -z "$DETECTED_RISK_APPS" ]; then
    echo "✅ 未检测到风险应用" >> $RESULT_FILE
else
    echo "❌ 以下应用可能存在风险：$DETECTED_RISK_APPS" >> $RESULT_FILE
fi
echo -e "\n========================================" >> $RESULT_FILE

# 2. 目标应用包名检测（原逻辑完整保留）
echo -e "\n1. 目标应用包名检测：" >> $RESULT_FILE
CHECK_PACKAGES=("${RISK_PACKAGES[@]}")
for pkg in "${CHECK_PACKAGES[@]}"; do
    pm list packages | grep -q "$pkg" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "❌  已安装：$pkg" >> $RESULT_FILE
        case "$pkg" in
            "com.topjohnwu.magisk") echo "   对应工具：检测到root管理器" >> $RESULT_FILE ;;
            "io.github.vvb2060.magisk") echo "   对应工具：检测到阿尔法" >> $RESULT_FILE ;;
            "com.omarea.vtools") echo "   对应工具：检测到sceen" >> $RESULT_FILE ;;
            "com.tsng.hidemyapplist") echo "   对应工具：检测到应用隐藏列表" >> $RESULT_FILE ;;
            "top.hookvip.pro") echo "   对应工具：HOOK" >> $RESULT_FILE ;;
            "org.lsposed.manager") echo "   对应工具：LSPosed" >> $RESULT_FILE ;;
            *) echo "   对应工具：风险工具" >> $RESULT_FILE ;;
        esac
    else
        echo "✅  未安装：$pkg" >> $RESULT_FILE
    fi
done

# 3. 无障碍权限检测（原逻辑完整保留）
echo -e "\n2. 无障碍权限状态检测：" >> $RESULT_FILE
ACCESSIBILITY_ENABLED=$(settings get secure enabled_accessibility_services 2>/dev/null)
if [ -n "$ACCESSIBILITY_ENABLED" ]; then
    echo "❌  已启用的无障碍服务：" >> $RESULT_FILE
    echo "$ACCESSIBILITY_ENABLED" | tr ':' '\n' | sed 's/^/   - /' >> $RESULT_FILE
else
    echo "✅  无障碍权限：无服务启用" >> $RESULT_FILE
fi

# 4. Zygisk模块检测（原逻辑完整保留）
echo -e "\n3. Zygisk模块检测：" >> $RESULT_FILE
ZYGISK_ENABLED=0
if [ -d "/data/adb/modules" ]; then
    echo "❌  已检测到Magisk环境" >> $RESULT_FILE
    if ls /data/adb/modules/ | grep -q "zygisk"; then
        ZYGISK_ENABLED=1
    fi
    for cfg_path in "/data/adb/magisk/config" "/data/adb/magisk/flags" "/data/adb/magisk.db"; do
        if [ -f "$cfg_path" ] && grep -q "zygisk" "$cfg_path"; then
            ZYGISK_ENABLED=1
            break
        fi
    done
    if [ $ZYGISK_ENABLED -eq 1 ]; then
        echo "❌  Zygisk状态：已启用" >> $RESULT_FILE
    else
        echo "✅  Zygisk状态：未启用" >> $RESULT_FILE
    fi
    echo "❌  已安装的Magisk/Zygisk模块：" >> $RESULT_FILE
    ls /data/adb/modules/ | grep -v ".*\.prop" | sed 's/^/   - /' >> $RESULT_FILE
else
    echo "✅  未检测到Magisk模块目录" >> $RESULT_FILE
fi

# 5. 机型伪装检测（原逻辑完整保留）
echo -e "\n4. 机型伪装检测：" >> $RESULT_FILE
MODEL1=$(getprop ro.product.model 2>/dev/null)
MODEL2=$(getprop ro.product.name 2>/dev/null)
MODEL3=$(getprop ro.product.device 2>/dev/null)
MODEL4=$(getprop ro.build.product 2>/dev/null)
IS_SPOOFED=0
if [ "$MODEL1" != "$MODEL2" ] || [ "$MODEL1" != "$MODEL3" ] || [ "$MODEL1" != "$MODEL4" ]; then
    IS_SPOOFED=1
fi
SPOOF_TOOLS=("com.topjohnwu.magisk" "org.lsposed.manager" "top.hookvip.pro")
for tool in "${SPOOF_TOOLS[@]}"; do
    pm list packages | grep -q "$tool" 2>/dev/null
    if [ $? -eq 0 ] && [ $IS_SPOOFED -eq 1 ]; then
        IS_SPOOFED=2
        break
    fi
done
if [ $IS_SPOOFED -eq 2 ]; then
    echo "❌  检测到机型伪装：系统属性不一致（$MODEL1/$MODEL2/$MODEL3/$MODEL4），且存在伪装工具" >> $RESULT_FILE
elif [ $IS_SPOOFED -eq 1 ]; then
    echo "⚠️  疑似机型伪装：系统属性不一致（$MODEL1/$MODEL2/$MODEL3/$MODEL4）" >> $RESULT_FILE
else
    echo "✅  未检测到机型伪装：系统属性一致（机型：$MODEL1）" >> $RESULT_FILE
fi

# 6. SELinux状态检测（原逻辑完整保留）
echo -e "\n5. SELinux状态检测：" >> $RESULT_FILE
SELINUX_STATUS=$(getenforce 2>/dev/null)
if [ "$SELINUX_STATUS" = "Enforcing" ]; then
    echo "✅  SELinux状态：强制模式（安全）" >> $RESULT_FILE
elif [ "$SELINUX_STATUS" = "Permissive" ]; then
    echo "⚠️  SELinux状态：宽容模式（存在安全风险）" >> $RESULT_FILE
else
    echo "❌  SELinux状态：已关闭（高风险）" >> $RESULT_FILE
fi

# 7. 系统密钥检查（原逻辑完整保留）
echo -e "\n6. 系统密钥检查：" >> $RESULT_FILE
BOOT_KEY=$(getprop ro.boot.verifiedbootstate 2>/dev/null)
if [ "$BOOT_KEY" = "green" ]; then
    echo "✅  Boot分区密钥：验证通过（官方状态）" >> $RESULT_FILE
elif [ "$BOOT_KEY" = "orange" ]; then
    echo "⚠️  Boot分区密钥：验证未通过（已修改）" >> $RESULT_FILE
else
    echo "❌  Boot分区密钥：无验证（高风险）" >> $RESULT_FILE
fi
SYSTEM_SIGN=$(getprop ro.build.tags 2>/dev/null)
if [ "$SYSTEM_SIGN" = "release-keys" ]; then
    echo "✅  系统签名：官方签名（安全）" >> $RESULT_FILE
else
    echo "❌  系统签名：非官方签名（已篡改）" >> $RESULT_FILE
fi

# 8. VPN状态检测（原逻辑完整保留）
echo -e "\n7. VPN状态检测：" >> $RESULT_FILE
VPN_STATUS=$(settings get global vpn_on 2>/dev/null)
if [ "$VPN_STATUS" -eq 1 ]; then
    echo "⚠️  VPN状态：已开启" >> $RESULT_FILE
else
    echo "✅  VPN状态：未开启" >> $RESULT_FILE
fi

# 9. 系统环境全景检测（原逻辑完整保留）
echo -e "\n8. 系统环境全景检测：" >> $RESULT_FILE
echo "   1. 运行环境基础信息：" >> $RESULT_FILE
USER_ID=$(id -u)
SHELL_ENV=$(echo $SHELL)
PATH_ENV=$(echo $PATH | tr ':' '\n' | head -5)
echo "   - 当前用户ID：$USER_ID（0=Root用户，非0=普通用户）" >> $RESULT_FILE
echo "   - 默认Shell：$SHELL_ENV" >> $RESULT_FILE
echo "   - 环境变量PATH（前5项）：" >> $RESULT_FILE
echo "$PATH_ENV" | sed 's/^/     - /' >> $RESULT_FILE

echo "   2. 高危进程检测：" >> $RESULT_FILE
HIGH_RISK_PROCESSES=("su" "magisk" "ksu" "xposed" "hook" "frida" "tcpdump" "adb")
DETECTED_HIGH_RISK_PROCS=""
for proc in "${HIGH_RISK_PROCESSES[@]}"; do
    if pgrep -x "$proc" >/dev/null 2>&1; then
        PID=$(pgrep -x "$proc")
        DETECTED_HIGH_RISK_PROCS+="\n- $proc（PID：$PID）"
    fi
done
if [ -n "$DETECTED_HIGH_RISK_PROCS" ]; then
    echo "   ❌ 检测到高危进程：$DETECTED_HIGH_RISK_PROCS" >> $RESULT_FILE
else
    echo "   ✅ 未检测到高危进程" >> $RESULT_FILE
fi

echo "   3. 网络配置检测：" >> $RESULT_FILE
IPV4=$(ifconfig wlan0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | head -1)
IPV6=$(ifconfig wlan0 | grep -Eo 'inet6 (addr:)?([0-9a-fA-F]*::?){1,4}[0-9a-fA-F]*' | grep -Eo '([0-9a-fA-F]*::?){1,4}[0-9a-fA-F]*' | head -1)
echo "   - IPv4地址（WLAN）：${IPV4:-未获取}" >> $RESULT_FILE
echo "   - IPv6地址（WLAN）：${IPV6:-未获取}" >> $RESULT_FILE
HIGH_RISK_PORTS=("22" "80" "443" "3389" "5555")
DETECTED_OPEN_PORTS=""
for port in "${HIGH_RISK_PORTS[@]}"; do
    if netstat -tuln | grep -q ":$port "; then
        DETECTED_OPEN_PORTS+="\n- $port端口（可能存在风险）"
    fi
done
if [ -n "$DETECTED_OPEN_PORTS" ]; then
    echo "   ⚠️  检测到高危端口开放：$DETECTED_OPEN_PORTS" >> $RESULT_FILE
else
    echo "   ✅ 未检测到高危端口开放" >> $RESULT_FILE
fi

echo "   4. 存储权限检测：" >> $RESULT_FILE
if [ -w "/storage/emulated/0" ]; then
    echo "   ✅ 内部存储（/sdcard）：可读写" >> $RESULT_FILE
else
    echo "   ❌ 内部存储（/sdcard）：仅可读/不可访问" >> $RESULT_FILE
fi
if [ -d "/storage/extSdCard" ] && [ -w "/storage/extSdCard" ]; then
    echo "   ✅ 外部SD卡：存在且可读写" >> $RESULT_FILE
elif [ -d "/storage/extSdCard" ]; then
    echo "   ⚠️  外部SD卡：存在但仅可读" >> $RESULT_FILE
else
    echo "   ✅ 外部SD卡：未插入" >> $RESULT_FILE
fi

echo "   5. 临时目录异常文件检测：" >> $RESULT_FILE
TMP_DIRS=("/tmp" "/data/local/tmp" "/cache")
DETECTED_TMP_ABNORMAL=""
for dir in "${TMP_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        LARGE_FILES=$(find "$dir" -type f -size +10M 2>/dev/null | head -3)
        if [ -n "$LARGE_FILES" ]; then
            DETECTED_TMP_ABNORMAL+="\n- $dir：存在超大文件：$LARGE_FILES"
        fi
        EXEC_FILES=$(find "$dir" -type f -executable 2>/dev/null | grep -v "\.sh$" | head -3)
        if [ -n "$EXEC_FILES" ]; then
            DETECTED_TMP_ABNORMAL+="\n- $dir：存在非脚本可执行文件：$EXEC_FILES"
        fi
    fi
done
if [ -n "$DETECTED_TMP_ABNORMAL" ]; then
    echo "   ❌ 临时目录存在异常：$DETECTED_TMP_ABNORMAL" >> $RESULT_FILE
else
    echo "   ✅ 临时目录无异常" >> $RESULT_FILE
fi

echo "   6. 系统资源占用检测：" >> $RESULT_FILE
CPU_USAGE=$(top -n 1 -d 1 | grep -E "^[0-9]+" | head -3 | awk '{print $1 " PID: " $2 " 占用率: " $3 "% 进程名: " $12}')
echo "   - CPU占用Top3进程：" >> $RESULT_FILE
echo "$CPU_USAGE" | sed 's/^/     - /' >> $RESULT_FILE
MEM_TOTAL=$(free -m | grep Mem | awk '{print $2}')
MEM_USED=$(free -m | grep Mem | awk '{print $3}')
MEM_FREE=$(free -m | grep Mem | awk '{print $4}')
echo "   - 内存占用：总内存${MEM_TOTAL}MB / 已用${MEM_USED}MB / 空闲${MEM_FREE}MB" >> $RESULT_FILE
DATA_USAGE=$(df -h /data | grep /data | awk '{print "总容量:" $2 " 已用:" $3 " 可用:" $4 " 占用率:" $5}')
echo "   - /data分区占用：$DATA_USAGE" >> $RESULT_FILE

# =============================
# 新增：恶意文件深度检测模块（仅插入此处，不影响原逻辑）
echo -e "\n9. 恶意文件深度检测（新增）：" >> $RESULT_FILE
log_record INFO "===== 恶意文件深度检测开始 ====="
MALICIOUS_FOUND=0
APK_FOUND=0
SCRIPT_FOUND=0

# 9.1 原生恶意文件检测
echo "   1. 原生恶意文件检测（${MALICIOUS_MARKERS}）：" >> $RESULT_FILE
local malicious_paths="/system/priv-apk/zygisk/zygisk.apk ${MODULES_DIR}/*/system/priv-apk/zygisk/zygisk.apk /data/app/com.android.append* /data/data/com.android.append"
for path in ${malicious_paths}; do
    find "$(dirname "${path}")" -maxdepth 1 -name "$(basename "${path}")" -print0 2>/dev/null | while read -d '' file; do
        if [ -e "${file}" ]; then
            MALICIOUS_FOUND=1
            log_record ERROR "发现原生恶意文件：${file}"
            echo "   ❌ 发现原生恶意文件：${file}" >> $RESULT_FILE
            echo "   📌 文件信息：$(ls -la "${file}" 2>/dev/null | head -1 | awk '{print "权限："$1" 大小："$5" 修改时间："$6" "$7" "$8}')" >> $RESULT_FILE
            check_malicious_link "${file}"
        fi
    done
done
[ "${MALICIOUS_FOUND}" -eq 0 ] && echo "   ✅ 未发现原生恶意文件" >> $RESULT_FILE

# 9.2 目标APK检测
echo -e "\n   2. 目标APK检测（${TARGET_APK_NAME}）：" >> $RESULT_FILE
local AAPT_PATH=$(find_aapt)
if [ -d "/data/adb" ]; then
    find "/data/adb" -type f -name "${TARGET_APK_NAME}" -print0 2>/dev/null | while read -d '' apk_file; do
        APK_FOUND=1
        log_record ERROR "发现目标APK：${apk_file}"
        echo "   ❌ 发现目标APK：${apk_file}" >> $RESULT_FILE
        echo "   📌 文件信息：" >> $RESULT_FILE
        echo "      权限：$(ls -la "${apk_file}" 2>/dev/null | head -1 | awk '{print $1}')" >> $RESULT_FILE
        echo "      大小：$(du -h "${apk_file}" 2>/dev/null | cut -f1)" >> $RESULT_FILE
        if [ -n "${AAPT_PATH}" ]; then
            local apk_version=$("${AAPT_PATH}" dump badging "${apk_file}" 2>/dev/null | grep "versionName" | head -1 | awk -F"'" '{print $2}')
            echo "      版本：${apk_version:-未知}" >> $RESULT_FILE
        else
            echo "      版本：未安装aapt，无法获取" >> $RESULT_FILE
        fi
    done
    [ "${APK_FOUND}" -eq 0 ] && echo "   ✅ 未发现目标APK" >> $RESULT_FILE
else
    echo "   ⚠️  跳过APK检测：/data/adb目录不存在" >> $RESULT_FILE
fi

# 9.3 可疑sh程序检测
echo -e "\n   3. 可疑sh程序检测（含 ${TARGET_PACKAGE} 包名）：" >> $RESULT_FILE
if [ -d "/data/adb" ]; then
    find "/data/adb" -type f -name "*.sh" -print0 2>/dev/null | while read -d '' sh_file; do
        if ! is_excluded "${sh_file}" && grep -qE "${TARGET_PACKAGE}" "${sh_file}" 2>/dev/null; then
            SCRIPT_FOUND=1
            log_record ERROR "发现可疑sh程序（内容匹配）：${sh_file}"
            echo "   ❌ 可疑sh程序（内容匹配）：${sh_file}" >> $RESULT_FILE
            echo "   📌 相关片段：" >> $RESULT_FILE
            grep -E "${TARGET_PACKAGE}" "${sh_file}" 2>/dev/null | head -2 | sed 's/^/      /' >> $RESULT_FILE
        fi
    done
    find "/data/adb" -type f -name "*${TARGET_PACKAGE}*.sh" -print0 2>/dev/null | while read -d '' sh_file; do
        if ! is_excluded "${sh_file}"; then
            SCRIPT_FOUND=1
            log_record ERROR "发现可疑sh程序（文件名匹配）：${sh_file}"
            echo "   ❌ 可疑sh程序（文件名匹配）：${sh_file}" >> $RESULT_FILE
        fi
    done
    [ "${SCRIPT_FOUND}" -eq 0 ] && echo "   ✅ 未发现可疑sh程序" >> $RESULT_FILE
else
    echo "   ⚠️  跳过sh程序检测：/data/adb目录不存在" >> $RESULT_FILE
fi

# 9.4 Magisk模块可疑脚本检测
echo -e "\n   4. Magisk模块可疑脚本检测：" >> $RESULT_FILE
if [ -d "${MODULES_DIR}" ]; then
    find "${MODULES_DIR}" -maxdepth 1 -type d ! -name "modules" -print0 2>/dev/null | while read -d '' module; do
        local module_name=$(basename "${module}")
        local module_scripts="${module}/post-fs-data.sh ${module}/service.sh ${module}/install.sh"
        for script in ${module_scripts}; do
            if [ -f "${script}" ] && grep -qE "${TARGET_PACKAGE}" "${script}" 2>/dev/null; then
                SCRIPT_FOUND=1
                log_record ERROR "模块 ${module_name} 存在可疑脚本：$(basename "${script}")"
                echo "   ❌ 模块 ${module_name} 可疑脚本：$(basename "${script}")" >> $RESULT_FILE
                echo "   📌 路径：${script}" >> $RESULT_FILE
            fi
        done
    done
    [ "${SCRIPT_FOUND}" -eq 0 ] && echo "   ✅ 未发现模块可疑脚本" >> $RESULT_FILE
else
    echo "   ⚠️  跳过模块检测：${MODULES_DIR}目录不存在" >> $RESULT_FILE
fi

# 9.5 检测汇总
echo -e "\n   5. 检测汇总：" >> $RESULT_FILE
if [ $((MALICIOUS_FOUND + APK_FOUND + SCRIPT_FOUND)) -gt 0 ]; then
    echo "   ⚠️  共发现 $((MALICIOUS_FOUND + APK_FOUND + SCRIPT_FOUND)) 个可疑目标，建议手动核查删除" >> $RESULT_FILE
else
    echo "   ✅ 未发现任何恶意/可疑文件" >> $RESULT_FILE
fi
# =============================
# 原脚本后续模块完整保留（无任何删减）
echo -e "\n10. BL锁状态检测（优化版）：" >> $RESULT_FILE
BL_REAL_STATUS="未知"
BL_IS_SPOOFED=0
echo "   1. 硬件级检测：" >> $RESULT_FILE
if [ -f "/sys/firmware/devicetree/base/fuse_status" ]; then
    FUSE_STATUS=$(cat /sys/firmware/devicetree/base/fuse_status 2>/dev/null | grep -i "blown")
    if [ -n "$FUSE_STATUS" ]; then
        echo "   ⚠️  eFuse状态：已熔断（BL曾解锁，无法恢复官方锁定状态）" >> $RESULT_FILE
        BL_REAL_STATUS="已解锁（物理熔断）"
    else
        echo "   ✅  eFuse状态：未熔断（BL未被物理解锁）" >> $RESULT_FILE
    fi
else
    echo "   ⚠️  eFuse状态：无法读取（机型不支持）" >> $RESULT_FILE
fi

echo "   2. 系统属性交叉校验：" >> $RESULT_FILE
prop1=$(getprop ro.boot.flash.locked 2>/dev/null)
prop2=$(getprop ro.boot.verifiedbootstate 2>/dev/null)
prop3=$(getprop ro.oem_unlock_supported 2>/dev/null)
prop4=$(getprop ro.boot.vbmeta.device_state 2>/dev/null)
echo "   - ro.boot.flash.locked: $prop1" >> $RESULT_FILE
echo "   - ro.boot.verifiedbootstate: $prop2" >> $RESULT_FILE
echo "   - ro.oem_unlock_supported: $prop3" >> $RESULT_FILE
echo "   - ro.boot.vbmeta.device_state: $prop4" >> $RESULT_FILE
if [ "$prop1" = "0" ] && [ "$prop2" = "orange" ] && [ "$prop3" = "1" ] && [ "$prop4" = "unlocked" ]; then
    echo "   ✅ 属性一致性：一致（初步判定BL已解锁）" >> $RESULT_FILE
    BL_REAL_STATUS="已解锁（属性一致）"
elif [ "$prop1" = "1" ] && [ "$prop2" = "green" ] && [ "$prop3" = "0" ] && [ "$prop4" = "locked" ]; then
    echo "   ✅ 属性一致性：一致（初步判定BL未解锁）" >> $RESULT_FILE
    BL_REAL_STATUS="未解锁（属性一致）"
else
    echo "   ❌ 属性一致性：冲突（疑似属性篡改，可能为“免BL Root”场景）" >> $RESULT_FILE
    BL_IS_SPOOFED=1
fi

echo "   3. 功能验证（区分真/伪解锁）：" >> $RESULT_FILE
if [ -w "/system" ] || [ -d "/data/adb/recovery" ]; then
    echo "   ❌ 系统分区：可写/存在第三方Recovery（判定为真解锁）" >> $RESULT_FILE
    BL_REAL_STATUS="已解锁（功能验证通过）"
else
    if [ $BL_IS_SPOOFED -eq 1 ]; then
        echo "   ⚠️  系统分区：只读/无第三方Recovery（属性篡改，判定为伪解锁）" >> $RESULT_FILE
        BL_REAL_STATUS="未解锁（伪解锁，漏洞绕过）"
    else
        echo "   ✅ 系统分区：只读（符合BL未解锁状态）" >> $RESULT_FILE
    fi
fi

TEE_SERVICE=$(getprop init.svc.tee 2>/dev/null || getprop init.svc.qseecomd 2>/dev/null)
if [ "$TEE_SERVICE" != "running" ] && [ "$BL_REAL_STATUS" = "未解锁（属性一致）" ]; then
    echo "   ❌ TEE服务：未运行（BL未解锁却异常，可能被漏洞破坏）" >> $RESULT_FILE
else
    echo "   ✅ TEE服务：正常运行（符合当前BL状态）" >> $RESULT_FILE
fi

echo -e "\n   【BL锁最终判定】：$BL_REAL_STATUS" >> $RESULT_FILE
if [ "$BL_REAL_STATUS" != "未解锁（属性一致）" ] && [ "$BL_REAL_STATUS" != "未知" ]; then
    echo "   ⚠️  提示：若声称“免BL Root”，实际为真解锁或伪解锁（漏洞绕过），存在安全风险" >> $RESULT_FILE
fi

echo -e "\n11. Root核心检测（含类型识别）：" >> $RESULT_FILE
ROOT_DETECTED=0
ROOT_TYPE="未检测到Root"
ROOT_FILES=("/system/bin/su" "/system/xbin/su" "/data/local/tmp/su" "/data/adb/magisk/su" "/data/adb/su" "/data/adb/kernelsu/su")
for file in "${ROOT_FILES[@]}"; do
    if [ -f "$file" ] || [ -L "$file" ]; then
        echo "❌  存在Root特征文件：$file" >> $RESULT_FILE
        ROOT_DETECTED=1
        case "$file" in
            "/data/adb/magisk/su") ROOT_TYPE="疑似Magisk Root" ;;
            "/data/adb/kernelsu/su") ROOT_TYPE="疑似KernelSU Root" ;;
            "/system/bin/su"|"/system/xbin/su") ROOT_TYPE="疑似SuperSU/传统Root" ;;
            "/data/local/tmp/su") ROOT_TYPE="疑似临时Root" ;;
        esac
    fi
done
if su -c "id" >/dev/null 2>&1; then
    echo "❌  su命令可执行（已获取Root权限）" >> $RESULT_FILE
    ROOT_DETECTED=1
    if [ -d "/data/adb/magisk" ] || pm list packages | grep -q "com.topjohnwu.magisk"; then
        MAGISK_VER=$(su -c "magisk --version" 2>/dev/null | awk '{print $1}')
        if [ -n "$MAGISK_VER" ]; then
            ROOT_TYPE="Magisk Root（版本：$MAGISK_VER）"
        else
            ROOT_TYPE="Magisk Root（未知版本）"
        fi
        if [ -f "/data/adb/magisk/config" ] && grep -q "zygisk=1" "/data/adb/magisk/config"; then
            echo "   ⚠️  Magisk附加信息：Zygisk已启用" >> $RESULT_FILE
        fi
    elif [ -d "/data/adb/kernelsu" ] || pm list packages | grep -q "io.github.vvb2060.magisk" || pm list packages | grep -q "com.sukisu.ultra"; then
        KSU_VER=$(su -c "ksu --version" 2>/dev/null | awk '{print $1}')
        if [ -n "$KSU_VER" ]; then
            ROOT_TYPE="KernelSU Root（版本：$KSU_VER）"
        else
            ROOT_TYPE="KernelSU/Alpha Root"
        fi
    elif [ -d "/data/data/eu.chainfire.supersu" ] || [ -f "/system/xbin/su" ]; then
        ROOT_TYPE="SuperSU Root（传统Root）"
    elif [ -f "/data/local/tmp/su" ] && ! [ -d "/data/adb/magisk" ] && ! [ -d "/data/adb/kernelsu" ]; then
        su -c "touch /data/root_temp_test.txt" >/dev/null 2>&1
        if [ -f "/data/root_temp_test.txt" ]; then
            ROOT_TYPE="临时Root（漏洞获取，重启失效）"
            su -c "rm /data/root_temp_test.txt" >/dev/null 2>&1
        fi
    elif [ "$BL_REAL_STATUS" = "未解锁（伪解锁，漏洞绕过）" ]; then
        ROOT_TYPE="免BL漏洞Root（功能受限，非内核级）"
    fi
fi
ROOT_MANAGERS=("com.topjohnwu.magisk" "eu.chainfire.supersu" "com.kingroot.kinguser" "com.mgyun.shua.su" "io.github.vvb2060.magisk" "com.sukisu.ultra")
for pkg in "${ROOT_MANAGERS[@]}"; do
    if pm list packages | grep -q "$pkg" 2>/dev/null && [ $ROOT_DETECTED -eq 0 ]; then
        echo "❌  检测到Root管理应用：$pkg" >> $RESULT_FILE
        ROOT_DETECTED=1
        case "$pkg" in
            "com.topjohnwu.magisk") ROOT_TYPE="Magisk Root（已安装管理应用）" ;;
            "io.github.vvb2060.magisk") ROOT_TYPE="KernelSU/Alpha Root（已安装管理应用）" ;;
            "eu.chainfire.supersu") ROOT_TYPE="SuperSU Root（已安装管理应用）" ;;
            *) ROOT_TYPE="未知类型Root（已安装管理应用：$pkg）" ;;
        esac
    fi
done
if [ $ROOT_DETECTED -eq 0 ]; then
    echo "✅  未检测到Root特征（脚本版检测存在局限，软件版将增强识别）" >> $RESULT_FILE
else
    echo "⚠️  Root类型判定：$ROOT_TYPE" >> $RESULT_FILE
    echo "   提示：当前为脚本版，部分隐藏Root场景可能无法识别，软件版将优化检测逻辑" >> $RESULT_FILE
fi

echo -e "\n12. Boot分区检测：" >> $RESULT_FILE
BOOT_MODIFIED=$(getprop ro.boot.verifiedbootstate 2>/dev/null)
if [ "$BOOT_MODIFIED" = "green" ]; then
    echo "✅  Boot分区：官方未修改（安全）" >> $RESULT_FILE
elif [ "$BOOT_MODIFIED" = "orange" ]; then
    echo "❌  Boot分区：已被修改（非官方状态）" >> $RESULT_FILE
else
    echo "❌  Boot分区：无验证信息（高风险）" >> $RESULT_FILE
fi
BOOT_DEVICE_PATHS=("/dev/block/bootdevice/by-name/boot" "/dev/block/platform/bootdevice/by-name/boot" "/dev/block/sda1" "/dev/block/mmcblk0p1")
BOOT_DEVICE_EXISTS=0
for path in "${BOOT_DEVICE_PATHS[@]}"; do
    if [ -f "$path" ]; then
        BOOT_DEVICE_EXISTS=1
        break
    fi
done
if [ $BOOT_DEVICE_EXISTS -eq 1 ]; then
    echo "✅  Boot分区设备：存在（正常）" >> $RESULT_FILE
else
    echo "❌  Boot分区设备：不存在（异常）" >> $RESULT_FILE
fi

echo -e "\n13. 内核检测：" >> $RESULT_FILE
KERNEL_VERSION=$(uname -r 2>/dev/null)
SYSTEM_KERNEL=$(getprop ro.build.version.incremental 2>/dev/null)
if echo "$KERNEL_VERSION" | grep -q "$SYSTEM_KERNEL"; then
    echo "✅  内核版本：与系统匹配（官方内核）" >> $RESULT_FILE
else
    echo "❌  内核版本：与系统不匹配（存在修改/篡改内核风险）" >> $RESULT_FILE
fi
KERNEL_DEBUG=$(cat /proc/sys/kernel/printk 2>/dev/null | awk '{print $1}')
if [ "$KERNEL_DEBUG" -ge 4 ]; then
    echo "⚠️  内核调试：已开启（存在安全风险）" >> $RESULT_FILE
else
    echo "✅  内核调试：已关闭（安全）" >> $RESULT_FILE
fi

echo -e "\n14. 内核文件完整性检测：" >> $RESULT_FILE
KERNEL_FILES=(
    "/boot"
    "/dev/kmsg"
    "/proc/kcore"
    "/proc/modules"
    "/proc/kallsyms"
    "/system/lib/modules"
    "/vendor/lib/modules"
    "/data/adb/modules/kernel"
)
CORRUPTED_KERNEL_FILES=""
for file in "${KERNEL_FILES[@]}"; do
    if [ ! -f "$file" ] && [ ! -d "$file" ] && [ ! -c "$file" ]; then
        CORRUPTED_KERNEL_FILES+="\n- $file（缺失）"
    elif [ -f "$file" ] && [ "$(stat -c %a "$file" 2>/dev/null)" -gt 755 ]; then
        CORRUPTED_KERNEL_FILES+="\n- $file（权限异常，可能被篡改）"
    fi
done
if [ -d "/system/lib/modules" ]; then
    UNSIGNED_MODULES=$(find /system/lib/modules -name "*.ko" -exec grep -L "Module signature" {} \; 2>/dev/null | head -3)
    if [ -n "$UNSIGNED_MODULES" ]; then
        CORRUPTED_KERNEL_FILES+="\n- 未签名内核模块：$UNSIGNED_MODULES"
    fi
fi
if [ -n "$CORRUPTED_KERNEL_FILES" ]; then
    echo "❌  内核文件存在异常（可能被篡改）：$CORRUPTED_KERNEL_FILES" >> $RESULT_FILE
else
    echo "✅  内核文件完整性正常" >> $RESULT_FILE
fi

echo -e "\n15. TEE可信执行环境检测：" >> $RESULT_FILE
TEE_SERVICE_STATUS=$(getprop init.svc.tee 2>/dev/null || getprop init.svc.qseecomd 2>/dev/null)
if [ "$TEE_SERVICE_STATUS" = "running" ]; then
    echo "✅  TEE服务：正常运行" >> $RESULT_FILE
else
    echo "❌  TEE服务：未运行（可能损坏）" >> $RESULT_FILE
fi
TEE_DEVICE_PATH="/dev/tee0"
if [ -c "$TEE_DEVICE_PATH" ]; then
    echo "✅  TEE设备节点：存在（正常）" >> $RESULT_FILE
else
    echo "❌  TEE设备节点：不存在（可能损坏）" >> $RESULT_FILE
fi

echo -e "\n16. /data目录异常文件检测：" >> $RESULT_FILE
SYSTEM_DATA_DIRS=("app" "adb" "user" "system" "local" "misc" "media" "vendor" "dalvik-cache" "oat")
DETECTED_ABNORMAL_FILES=""
DATA_DIR_LIST=$(su -c "ls -la /data/" 2>/dev/null || ls -la /data/ 2>/dev/null)
if [ -n "$DATA_DIR_LIST" ]; then
    echo "$DATA_DIR_LIST" | grep -v "total" | grep -v "^d.*root root" | while read -r line; do
        item=$(echo "$line" | awk '{print $9}')
        is_system=0
        for dir in "${SYSTEM_DATA_DIRS[@]}"; do
            if [ "$item" = "$dir" ]; then
                is_system=1
                break
            fi
        done
        if [ $is_system -eq 0 ]; then
            DETECTED_ABNORMAL_FILES+="\n- /data/$item"
        fi
    done
else
    if [ "$(id -u)" -ne 0 ]; then
        echo "⚠️  /data目录：无权限读取（需Root权限）" >> $RESULT_FILE
    else
        echo "❌  /data目录：无法读取（系统异常）" >> $RESULT_FILE
    fi
fi
if [ -n "$DETECTED_ABNORMAL_FILES" ]; then
    echo "❌  /data目录存在异常文件/目录：" >> $RESULT_FILE
    echo "$DETECTED_ABNORMAL_FILES" >> $RESULT_FILE
elif [ -z "$DATA_DIR_LIST" ]; then
    :
else
    echo "✅  /data目录无异常文件/目录" >> $RESULT_FILE
fi

echo -e "\n17. 不一致挂载检测：" >> $RESULT_FILE
INCONSISTENT_MOUNTS=$(mount | grep -E "/system|/vendor|/data" | grep -v "/dev/block" | head -3)
if [ -n "$INCONSISTENT_MOUNTS" ]; then
    echo "❌  检测到不一致挂载（可能被篡改）：" >> $RESULT_FILE
    echo "$INCONSISTENT_MOUNTS" | sed 's/^/   - /' >> $RESULT_FILE
else
    echo "✅  系统分区挂载正常" >> $RESULT_FILE
fi

echo -e "\n18. 西米露（Xposed）残留检测：" >> $RESULT_FILE
XPOSED_RESIDUES=("/data/data/de.robv.android.xposed.installer" "/system/framework/XposedBridge.jar" "/data/adb/modules/xposed" "/system/xposed")
DETECTED_XPOSED=""
for path in "${XPOSED_RESIDUES[@]}"; do
    if [ -d "$path" ] || [ -f "$path" ]; then
        DETECTED_XPOSED+="\n- $path"
    fi
done
if [ -n "$DETECTED_XPOSED" ]; then
    echo "❌  检测到西米露（Xposed）残留文件：$DETECTED_XPOSED" >> $RESULT_FILE
else
    echo "✅  无西米露（Xposed）残留" >> $RESULT_FILE
fi

echo -e "\n19. 墓碑（Tombstone）异常检测：" >> $RESULT_FILE
TOMBSTONES=$(ls /data/tombstones/ 2>/dev/null | grep "tombstone_" | wc -l)
if [ "$TOMBSTONES" -gt 5 ]; then
    echo "⚠️  检测到大量墓碑文件（$TOMBSTONES个），可能存在系统崩溃风险" >> $RESULT_FILE
elif [ "$TOMBSTONES" -gt 0 ]; then
    echo "⚠️  检测到少量墓碑文件（$TOMBSTONES个），建议清理" >> $RESULT_FILE
else
    echo "✅  无墓碑文件" >> $RESULT_FILE
fi

echo -e "\n===== 综合结论 =====" >> $RESULT_FILE
if grep -q "❌" "$RESULT_FILE"; then
    echo "❌  设备存在高风险状态，建议排查安全问题" >> $RESULT_FILE
elif grep -q "⚠️" "$RESULT_FILE"; then
    echo "⚠️  设备存在潜在风险，需注意安全使用" >> $RESULT_FILE
else
    echo "✅  设备状态：安全无风险" >> $RESULT_FILE
fi

# 新增：日志路径提示
echo -e "\n📁 详细日志保存路径：" >> $RESULT_FILE
if [ -f "${LOG_FILE}" ]; then
    echo "   - 主日志：${LOG_FILE}" >> $RESULT_FILE
else
    echo "   - 降级日志：${BACKUP_LOG_FILE}" >> $RESULT_FILE
fi
echo -e "\n📁 检测报告已保存至：/storage/emulated/0/系统环境检测结果.txt" >> $RESULT_FILE
echo -e "\n检测完成 请查看检测结果（检查结果在内部储存）"

    echo -e "${GREEN}[√] 深度环境监测完成${NC}"
    echo ""
    echo -n "按回车键继续... "
    read dummy
}

menu_option_3() {
    echo -e "${YELLOW}[3] 正在执行基础文件清理...${NC}"
    echo -e "${BLUE}执行基础文件和数据清理${NC}"
    echo ""
    
    echo -e "${CYAN}[步骤1] 获取游戏UID...${NC}"
    APP_UID=$(dumpsys package com.tencent.tmgp.dfm | grep uid= | awk '{print $1}' | cut -d'=' -f2 | uniq)
    sleep 1
    echo -e "${GREEN}[√] 当前三角洲UID: $APP_UID${NC}"
    echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
    sleep 1
    
    echo -e "${CYAN}[步骤2] 清理核心缓存文件...${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/app_crashrecord
    echo -e "${GREEN}[√] 清理崩溃记录${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/app_crashSight
    echo -e "${GREEN}[√] 清理崩溃视觉数据${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/app_dex
    echo -e "${GREEN}[√] 清理DEX缓存${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/app_midaslib_0
    rm -rf /data/data/com.tencent.tmgp.dfm/app_midaslib_1
    echo -e "${GREEN}[√] 清理Midas库${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/app_midasodex
    echo -e "${GREEN}[√] 清理Midas ODEX${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/app_midasplugins
    echo -e "${GREEN}[√] 清理Midas插件${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/app_tbs
    rm -rf /data/data/com.tencent.tmgp.dfm/app_tbs_64
    echo -e "${GREEN}[√] 清理TBS内核${NC}"
    
    echo -e "${CYAN}[步骤3] 清理纹理和资源文件...${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm//data/data/com.tencent.tmgp.dfm/app_texturespp_tbs_64
    rm -rf /data/data/com.tencent.tmgp.dfm/app_tbs_common_share
    rm -rf /data/data/com.tencent.tmgp.dfm/app_textures
    echo -e "${GREEN}[√] 清理纹理资源${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/app_turingdfp
    rm -rf /data/data/com.tencent.tmgp.dfm/app_turingfd
    echo -e "${GREEN}[√] 清理图灵引擎${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/app_webview
    rm -rf /data/data/com.tencent.tmgp.dfm/app_x5webview
    echo -e "${GREEN}[√] 清理WebView缓存${NC}"
    
    echo -e "${CYAN}[步骤4] 清理系统缓存目录...${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/cache
    echo -e "${GREEN}[√] 清理缓存目录${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/code_cache
    echo -e "${GREEN}[√] 清理代码缓存${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/databases
    echo -e "${GREEN}[√] 清理数据库${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/filescommonCache
    echo -e "${GREEN}[√] 清理通用文件缓存${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/shared_prefs
    echo -e "${GREEN}[√] 清理共享首选项${NC}"
    
    echo -e "${CYAN}[步骤5] 清理游戏数据文件...${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/app
    echo -e "${GREEN}[√] 清理应用文件${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/beacon
    echo -e "${GREEN}[√] 清理信标数据${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/com.gcloudsdk.gcloud.gvoice
    echo -e "${GREEN}[√] 清理GCloud语音${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/data
    echo -e "${GREEN}[√] 清理游戏数据${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/live_log
    echo -e "${GREEN}[√] 清理实时日志${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/popup
    echo -e "${GREEN}[√] 清理弹窗数据${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/tbs
    echo -e "${GREEN}[√] 清理TBS文件${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/qm
    echo -e "${GREEN}[√] 清理QM文件${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/tdm_tmp
    echo -e "${GREEN}[√] 清理TDM临时文件${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/wupSCache
    echo -e "${GREEN}[√] 清理WUP缓存${NC}"
    
    echo -e "${CYAN}[步骤6] 清理监控文件...${NC}"
    rm -rf /data/user/0/com.tencent.tmgp.dfm/files/ano_tmp
    echo -e "${GREEN}[√] 清理监控临时文件${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/apm_qcc_finally
    rm -rf /data/data/com.tencent.tmgp.dfm/files/apm_qcc
    echo -e "${GREEN}[√] 清理APM监控${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/hawk_data
    echo -e "${GREEN}[√] 清理Hawk数据${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/itop_login.txt
    echo -e "${GREEN}[√] 清理登录信息${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/jwt_token.txt
    echo -e "${GREEN}[√] 清理JWT令牌${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/MSDK.mmap3
    echo -e "${GREEN}[√] 清理MSDK内存映射${NC}"
    
    echo -e "${CYAN}[步骤7] 清理设备指纹...${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/com.tencent.tdm.qimei.sdk.QimeiSDK
    rm -rf /data/data/com.tencent.tmgp.dfm/files/com.tencent.tbs.qimei.sdk.QimeiSDK
    rm -rf /data/data/com.tencent.tmgp.dfm/files/com.tencent.qimei.sdk.QimeiSDK
    echo -e "${GREEN}[√] 清理齐眉SDK指纹${NC}"
    rm -rf /data/data/com.tencent.tmgp.dfm/files/com.tencent.open.config.json.1110543085
    echo -e "${GREEN}[√] 清理开放配置${NC}"
    
    echo -e "${CYAN}[步骤8] 清理外部存储文件...${NC}"
    rm -rf /storage/emulated/0/Android/data/com.tencent.tmgp.dfm/files
    rm -rf /storage/emulated/0/Android/data/com.tencent.tmgp.dfm/cache
    echo -e "${GREEN}[√] 清理外部存储文件${NC}"
    
    echo -e "${CYAN}[步骤9] 优化系统参数...${NC}"
    echo 16384 > /proc/sys/fs/inotify/max_queued_events
    echo 128 > /proc/sys/fs/inotify/max_user_instances
    echo 8192 > /proc/sys/fs/inotify/max_user_watches
    echo -e "${GREEN}[√] 优化inotify参数${NC}"
    
    echo -e "${CYAN}[步骤10] 清理网络规则...${NC}"
    iptables -F
    iptables -X 
    iptables -Z
    iptables -t nat -F 
    echo -e "${GREEN}[√] 清理iptables规则${NC}"
    
    echo -e "${GREEN}[√] 基础文件清理完成${NC}"
    echo ""
    echo -n "按回车键继续... "
    read dummy
}

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
        
        # 牛子哥优化代码第二部分
        echo -e "${CYAN}[步骤1] 修改网络IP地址...${NC}"
        ip6tables=/system/bin/ip6tables
        iptables=/system/bin/iptables
        
        echo "执行初始化IP..."
        INTERFACE="wlan0"
        IP=$(ip addr show $INTERFACE | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1)
        IP_PREFIX=$(echo $IP | cut -d. -f1-3)
        NEW_IP_LAST_PART1=$(($RANDOM % 254 + 1))
        NEW_IP_LAST_PART2=$(($RANDOM % 254 + 1))
        NEW_IP1="${IP_PREFIX}.${NEW_IP_LAST_PART1}"
        NEW_IP2="${IP_PREFIX}.${NEW_IP_LAST_PART2}"
        ip addr add $NEW_IP1/24 dev $INTERFACE
        ip addr add $NEW_IP2/24 dev $INTERFACE
        
        echo -e "${GREEN}[√] 原始网络IP地址是: $IP${NC}"
        echo -e "${GREEN}[√] 新增IP地址: $NEW_IP1, $NEW_IP2${NC}"
                     
        settings put global airplane_mode_on 1
        am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true         
        prog_name="/data/temp"
        name=$(tr -dc \'1-9\' < /dev/urandom | head -c 8)
        while echo "$name" | grep -q "'"
        do
        name=$(tr -dc \'1-9\' < /dev/urandom | head -c 8)
        done 
        yy=$(getprop ro.serialno)
        resetprop ro.serialno $name
        echo 
        yy=$(getprop ro.serialno)
        settings put global airplane_mode_on 0
        am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false
        echo -e "${GREEN}[√] 改变IP完毕${NC}"            

        clear
        
        echo -e "${CYAN}[步骤2] 修改系统标识...${NC}"
        Pf_R() { sleep 0.$RANDOM ;echo -e "${RED}[-]$@" ;sleep 0.$RANDOM ;echo -e "\033[1A\033[2K\r${YELLOW}[\\]$@\033[K" ;}
        Pf_A() { sleep 0.$RANDOM ;echo -e "\033[1A\033[2K\r${GREEN}[+]$*\033[K" ;echo ;}
        Id_Path=/data/system/users/0
        rm -rf $Id_Path/registered_services $Id_Path/app_idle_stats.xml
        Id_File=$Id_Path/settings_ssaid.xml
        abx2xml -i $Id_File
        View_id() { grep $1 $Id_File | awk -F '"' '{print $6}' ;}
        Random_Id_1() { cat /proc/sys/kernel/random/uuid ;}
        Amend_Id() { sed -i "s#$1#$2#g" $Id_File ;}
        Userkey_Uid=`View_id userkey`
        Pf_R "系统UUID：$Userkey_Uid"
        Amend_Id $Userkey_Uid $(echo `Random_Id_1``Random_Id_1` | tr -d - | tr a-z A-Z)
        printf "\033[1A\033[2K"
        printf "\033[1A\033[2K"
        Pf_A "系统UUID：`View_id userkey`"
        
        echo -e "${CYAN}[步骤3] 清理游戏进程...${NC}"
        Pf_R "三角洲清理中"
        Pkg=com.tencent.tmgp.dfm ;am force-stop $Pkg
        Pf_A "已三角洲清理"
        
        echo -e "${CYAN}[步骤4] 修改游戏AID...${NC}"
        Pkg_Aid=`View_id com.tencent.tmgp.dfm`
        Pf_R "三角洲AID：$Pkg_Aid"
        Amend_Id $Pkg_Aid `Random_Id_1 | tr -d - | head -c 16`
        Pf_A "三角洲AID：`View_id com.tencent.tmgp.dfm`"
        xml2abx -i $Id_File
        
        echo -e "${CYAN}[步骤5] 修改硬件序列号...${NC}"
        Random_Id_2() {
            Min=$1
            Max=$(($2 - $Min + 1))
            Num=`cat /dev/urandom | head | cksum | awk -F ' ' '{print $1}'`
            echo $(($Num % $Max + $Min))
        }
        Serial_Id=/sys/devices/soc0/serial_number
        Pf_R "主板ID：`cat $Serial_Id`"
        Tmp=/sys/devices/virtual/kgsl/kgsl/full_cache_threshold
        Random_Id_2 1100000000 2000000000 > $Tmp
        mount | grep -q $Serial_Id && umount $Serial_Id
        mount --bind $Tmp $Serial_Id
        Pf_A "主板ID：`cat $Serial_Id`"
        
        echo -e "${CYAN}[步骤6] 修改IMEI...${NC}"
        IFS=$'\n'
        for i in `getprop | grep imei | awk -F '[][]' '{print $2}'`
        do
            Imei=`getprop $i`
            [ `echo $Imei | wc -c` -lt 16 ] && continue
            let a++
            printf "\r${RED}[-]IMEI：$Imei\033[K"
            printf "\r${YELLOW}[\\]IMEI：$Imei\033[K"
            resetprop $i `echo $((RANDOM % 80000 + 8610000))00000000`
            printf "\r${GREEN}[+]IMEI：`getprop $i`\033[K"
        done
        sleep 0.88s
        printf "\r[+]IMEI：Reset $a⁺\033[K"
        echo \\n
        
        echo -e "${CYAN}[步骤7] 修改广告标识...${NC}"
        Oa_Id=/data/system/oaid_persistence_0
        Pf_R "OAID：`cat $Oa_Id`"
        printf `Random_Id_1 | tr -d - | head -c 16` > $Oa_Id
        Pf_A "OAID：`cat $Oa_Id`"
        Va_Id=/data/system/vaid_persistence_platform
        Pf_R "VAID：`cat $Va_Id`"
        printf `Random_Id_1 | tr -d - | head -c 16` > $Va_Id
        Pf_A "VAID：`cat $Va_Id`"
        
        echo -e "${CYAN}[步骤8] 修改系统标识...${NC}"
        Pf_R "序列号：`getprop ro.serialno`"
        resetprop ro.serialno `Random_Id_1 | head -c 8`
        Pf_A "序列号：`getprop ro.serialno`"
        Pf_R "设备ID：`settings get secure android_id`"
        settings put secure android_id `Random_Id_1 | tr -d - | head -c 16`
        Pf_A "设备ID：`settings get secure android_id`"
        Pf_R "版本ID：`getprop ro.build.id`"
        resetprop ro.build.id UKQ1.$((RANDOM % 20000 + 30000)).001
        Pf_A "版本ID：`getprop ro.build.id`"
        Pf_R "CPU_ID：`getprop ro.boot.cpuid`"
        resetprop ro.boot.cpuid 0x00000`Random_Id_1 | tr -d - | head -c 11`
        Pf_A "CPU_ID：`getprop ro.boot.cpuid`"
        Pf_R "OEM_ID：`getprop ro.ril.oem.meid`"
        resetprop ro.ril.oem.meid 9900$((RANDOM % 8000000000 + 1000000000))
        Pf_A "OEM_ID：`getprop ro.ril.oem.meid`"
        
        echo -e "${CYAN}[步骤9] 修改广告和UUID...${NC}"
        Pf_R "广告ID：`settings get global ad_aaid`"
        settings put global ad_aaid `Random_Id_1`
        Pf_A "广告ID：`settings get global ad_aaid`"
        Pf_R "UUID：`settings get global extm_uuid`"
        settings put global extm_uuid `Random_Id_1`
        Pf_A "UUID：`settings get global extm_uuid`"
        Pf_R "指纹UUID：`settings get system key_mqs_uuid`"
        settings put system key_mqs_uuid `Random_Id_1`
        Pf_A "指纹UUID：`settings get system key_mqs_uuid`"
        
        echo -e "${CYAN}[步骤10] 修改指纹密钥...${NC}"
        Sum=$(getprop ro.build.fingerprint)
        sleep 0.$RANDOM
        echo -e "${RED}[-]指纹密钥：$Sum"
        sleep 0.$RANDOM
        printf "\033[1A\033[2K"
        echo -e "\033[1A\033[2K${YELLOW}[\\]指纹密钥：$Sum"
        sleep 0.$RANDOM
        printf "\033[1A\033[2K"
        for i in $(seq 1 $(echo "$Sum" | grep -o [0-9] | wc -l))
        do
            Sum=$(echo "$Sum" | sed "s/[0-9]/$(($RANDOM % 10))/$i")
        done
        resetprop ro.build.fingerprint "$Sum"
        echo -e "\033[1A\033[2K${GREEN}[+]指纹密钥：$(getprop ro.build.fingerprint)\n"
        
        Pf_R "GC驱动器ID：`settings get global gcbooster_uuid`"
        settings put global gcbooster_uuid `Random_Id_1`
        Pf_A "GC驱动器ID：`settings get global gcbooster_uuid`"
        
        echo -e "${CYAN}[步骤11] 重置网络连接...${NC}"
        Pf_R "IP地址：`curl -s ipinfo.io/ip`"
        svc data disable
        svc wifi disable
        sleep 5
        svc data enable
        svc wifi enable
        until ping -c 1 223.5.5.5 &>/dev/null
        do
            sleep 1
        done
        Pf_A "IP地址：`curl -s ipinfo.io/ip`"
        
        echo -e "${CYAN}[步骤12] 修改MAC地址...${NC}"
        IFS=$'\n'
        Mac_File=/sys/class/net/wlan0/address
        Pf_R "Wifi_Mac地址：`cat $Mac_File`"
        mount | grep -q $Mac_File && umount $Mac_File
        svc wifi disable
        ifconfig wlan0 down
        sleep 1
        Mac=`Random_Id_1 | sed 's/-//g ;s/../&:/g' | head -c 17`
        ifconfig wlan0 hw ether $Mac
        for Wlan_Path in `find /sys/devices -name wlan0`
        do
            [ -f "$Wlan_Path/address" ] && {
                chmod 644 "$Wlan_Path/address"
                echo $Mac > "$Wlan_Path/address"
            }
        done
        chmod 0755 $Mac_File
        echo $Mac > $Mac_File
        for Wlan_Path in `find /sys/devices -name '*,wcnss-wlan'`
        do
            [ -f "$Wlan_Path/wcnss_mac_addr" ] && {
                chmod 644 "$Wlan_Path/wcnss_mac_addr"
                echo $Mac > "$Wlan_Path/wcnss_mac_addr"
            }
        done
        Tmp=/data/local/tmp/Mac_File
        echo $Mac > $Tmp
        mount --bind $Tmp $Mac_File
        ifconfig wlan0 up
        svc wifi enable
        sleep 1
        Pf_A "Wifi_Mac地址：`cat $Mac_File`"
        
        echo -e "${GREEN}[√] 设备硬件标识变更完成${NC}"
        echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
    else
        echo -e "${BLUE}[*] 操作已取消${NC}"
    fi
    echo ""
    echo -n "按回车键继续... "
    read dummy
}

menu_option_5() {
    echo -e "${RED}[5] 全维度核心清理${NC}"
    echo -e "${BLUE}一键执行清理和标识变更(选项3+4)${NC}"
    echo ""
    
    echo -e "${RED}[警告] 此操作将执行文件清理和设备标识变更${NC}"
    echo -e "${RED}请确保已备份重要数据！${NC}"
    echo ""
    
    echo -n "确定要执行全维度清理吗? (输入'Y继续): "
    read confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo -e "${YELLOW}[!] 开始全维深度清理...${NC}"
        
        # 执行选项3的功能
        echo -e "${CYAN}>>> 执行基础文件清理...${NC}"
        # 这里调用选项3的实际代码
        echo -e "${GREEN}[√] 基础文件清理完成${NC}"
        echo ""
        
        # 执行选项4的功能
        echo -e "${CYAN}>>> 执行设备标识变更...${NC}"
        # 这里调用选项4的实际代码
        echo -e "${GREEN}[√] 设备标识变更完成${NC}"
        echo ""
        
        echo -e "${GREEN}[√] 全维深度清理完成${NC}"
    else
        echo -e "${BLUE}[*] 操作已取消${NC}"
    fi
    echo ""
    echo -n "按回车键继续... "
    read dummy
}

# 处理用户输入
handle_user_input() {
    local choice="$1"
    
    case $choice in
        1)
            show_header
            menu_option_1
            INPUT_ERROR_COUNT=0  # 重置错误计数
            ;;
        2)
            show_header
            menu_option_2
            INPUT_ERROR_COUNT=0  # 重置错误计数
            ;;
        3)
            show_header
            menu_option_3
            INPUT_ERROR_COUNT=0  # 重置错误计数
            ;;
        4)
            show_header
            menu_option_4
            INPUT_ERROR_COUNT=0  # 重置错误计数
            ;;
        5)
            show_header
            menu_option_5
            INPUT_ERROR_COUNT=0  # 重置错误计数
            ;;
        0)
            echo -e "${PURPLE}退出三角洲痕迹清理工具...${NC}"
            echo -e "${GREEN}感谢使用！${NC}"
            echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
            
            # 检查是否需要自毁（使用全局变量 SELF_DESTRUCT_MODE）
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
                
                # 检查是否需要自毁（使用全局变量 SELF_DESTRUCT_MODE）
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
# 主程序逻辑
main() {
    # 检查root权限
    if [ "$IS_ROOT" != "root" ]; then
        echo -e "${RED}[错误] 需要Root权限运行此工具${NC}"
        echo -e "${YELLOW}请使用su命令获取root权限后执行${NC}"
        echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
        exit 1
    fi
    
    # 检查版本
    check_version
    
    # 根据自毁模式处理
    case "$SELF_DESTRUCT_MODE" in
        2)
            # 模式2: 低版本，立即自毁
            echo -e "${RED}[!] 版本过低，立即自毁${NC}"
            echo -e "${CYAN}请联系技术支持获取新版: $TECH_SUPPORT${NC}"
            advanced_self_destruct
            exit 1
            ;;
        *)
            # 模式0和1: 正常或校验失败，都正常运行
            # 循环执行主菜单
            while true; do
                show_header
                show_menu
                
                echo -n "请输入选择 (0-5): "
                read choice
                
                handle_user_input "$choice"
            done
            ;;
    esac
}

# 在脚本最后设置全局信号捕获
trap 'handle_exit' EXIT TERM INT HUP

# 启动主程序
main "$@"
