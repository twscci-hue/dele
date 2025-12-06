#!/system/bin/sh

# 三角洲痕迹清理工具
# 集成高级自毁机制
# 说明：
# - 已移除原“深度环境监测（原选项2）”并替换为独立 Root/Magisk 检测（菜单项2）。
# - 清理逻辑（原三角洲的所有 rm -rf 条目）保持原样，但封装为 perform_full_clean(pkg,name)；
#   并为和平精英与王者荣耀复用相同清理目录与命令（暗区已移除）。
# - 设备标识修改（选项4）完整保留原始代码。
# - 选项5 为一键执行三角洲完整清理 + 设备标识修改（不交互）。
# - 请在 root 环境下运行（脚本会检查 root），并确保对替换后的文件设置可执行权限：chmod +x dele-a.sh

# 版本配置
CURRENT_VERSION="3.0.0"
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
IS_ROOT=$(whoami 2>/dev/null || echo "unknown")
SCRIPT_PATH="$0"

# 自毁模式和错误计数
SELF_DESTRUCT_MODE=0
INPUT_ERROR_COUNT=0
MAX_INPUT_ERRORS=2

echo -e "${CYAN}[UPDATE] 当前版本: $CURRENT_VERSION${NC}"

# 立即执行自毁函数
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

# 全局退出处理函数
handle_exit() {
    if [ "$SELF_DESTRUCT_MODE" -eq 1 ]; then
        echo ""
        echo -e "${RED}[!] 检测到程序异常退出${NC}"
        execute_immediate_destruct
    fi
    exit 0
}

# 高级自毁函数
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
    local latest_version=""

    if command -v curl >/dev/null 2>&1; then
        latest_version=$(curl -s --connect-timeout 10 --max-time 15 "$VERSION_CHECK_URL" 2>/dev/null | head -n1 | tr -d '\r' | tr -d ' ')
    elif command -v wget >/dev/null 2>&1; then
        latest_version=$(wget -q -T 10 -O - "$VERSION_CHECK_URL" 2>/dev/null | head -n1 | tr -d '\r' | tr -d ' ')
    elif command -v busybox >/dev/null 2>&1; then
        latest_version=$(busybox wget -q -T 10 -O - "$VERSION_CHECK_URL" 2>/dev/null | head -n1 | tr -d '\r' | tr -d ' ')
    else
        echo -e "${RED}[UPDATE] 无法获取版本信息 (无可用下载工具)${NC}"
        SELF_DESTRUCT_MODE=1
        return 1
    fi

    if [ -z "$latest_version" ] || [ "$latest_version" = "404" ] || [ "$latest_version" = "404:" ]; then
        echo -e "${RED}[UPDATE] 无法获取版本信息 (远程服务器错误)${NC}"
        SELF_DESTRUCT_MODE=1
        return 1
    fi

    if ! echo "$latest_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        echo -e "${RED}[UPDATE] 远程版本号格式无效: $latest_version${NC}"
        SELF_DESTRUCT_MODE=1
        return 1
    fi

    echo -e "${GREEN}[UPDATE] 最新版本: $latest_version${NC}"

    local compare_result=$(version_compare "$CURRENT_VERSION" "$latest_version")

    case $compare_result in
        "-1")
            echo -e "${RED}[UPDATE] 发现新版本，当前版本过低${NC}"
            echo -e "${YELLOW}[UPDATE] 程序将继续运行，请及时获取最新版本${NC}"
            SELF_DESTRUCT_MODE=2
            ;;
        "0")
            echo -e "${GREEN}[UPDATE] 已是最新版本${NC}"
            SELF_DESTRUCT_MODE=0
            ;;
        "1")
            echo -e "${YELLOW}[UPDATE] 当前版本高于远程版本 (开发版)${NC}"
            SELF_DESTRUCT_MODE=0
            ;;
        *)
            echo -e "${RED}[UPDATE] 版本比较出错${NC}"
            SELF_DESTRUCT_MODE=1
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
    echo -e "  ${YELLOW}[0]${NC} ${PURPLE}退出工具${NC}"
    echo ""
    echo "================================================"
    echo -e "${RED}操作有风险！请谨慎清理，数据丢失后果自负。${NC}"
    echo -e "${CYAN}技术支持: $TECH_SUPPORT${NC}"
    echo "================================================"
    echo ""
}

# -------------------
# 新增：Root/Magisk/Zygisk 检测（独立选项2）
# -------------------
detect_root_env() {
    echo -e "${CYAN}[检测] Root/Magisk/Zygisk 环境检测开始${NC}"
    ROOT_DETECTED=0
    ROOT_TYPE="未检测到Root"
    MAGISK_VER=""
    ZYGISK_ENABLED=0
    KERNELSU_DETECTED=0

    if su -c "id" >/dev/null 2>&1; then
        ROOT_DETECTED=1
    fi

    if pm list packages | grep -q "com.topjohnwu.magisk" 2>/dev/null || [ -d "/data/adb/magisk" ]; then
        ROOT_DETECTED=1
        ROOT_TYPE="Magisk Root"
        if su -c "magisk --version" >/dev/null 2>&1; then
            MAGISK_VER=$(su -c "magisk --version" 2>/dev/null | awk '{print $1}')
        fi
    fi

    if [ -d "/data/adb/kernelsu" ] || pm list packages | grep -q "io.github.vvb2060.magisk\|com.sukisu.ultra" 2>/dev/null; then
        ROOT_DETECTED=1
        KERNELSU_DETECTED=1
        [ "$ROOT_TYPE" = "未检测到Root" ] && ROOT_TYPE="KernelSU/Alpha Root"
    fi

    if [ -f "/data/adb/magisk/config" ] && grep -q "zygisk=1" "/data/adb/magisk/config" 2>/dev/null; then
        ZYGISK_ENABLED=1
    fi

    if [ $ROOT_DETECTED -eq 1 ]; then
        echo -e "${RED}❌ 检测到 Root: ${ROOT_TYPE} ${MAGISK_VER:+(Magisk ver:$MAGISK_VER)}${NC}"
    else
        echo -e "${GREEN}✅ 未检测到 Root${NC}"
    fi

    if [ $ZYGISK_ENABLED -eq 1 ]; then
        echo -e "${RED}❌ Zygisk: 已启用${NC}"
    else
        echo -e "${GREEN}✅ Zygisk: 未启用${NC}"
    fi

    if [ $KERNELSU_DETECTED -eq 1 ]; then
        echo -e "${YELLOW}⚠️ 检测到 KernelSU 或类似管理工具，隐藏方案可能受限${NC}"
    fi

    echo ""
    echo -e "${CYAN}建议（参考）：${NC}"
    if [ $ROOT_DETECTED -eq 1 ] && [ $ZYGISK_ENABLED -eq 1 ]; then
        echo "  推荐：Zygisk + Shamiko（或其他 Zygisk hide 模块），可在模块中添加需隐藏的包名并重启生效。"
        echo "  Shamiko: https://github.com/Shamiko/Shamiko"
    elif [ $ROOT_DETECTED -eq 1 ] && [ $ZYGISK_ENABLED -eq 0 ]; then
        echo "  若使用 Magisk 但未启用 Zygisk，可考虑启用 Zygisk 并配合 Shamiko；未使用 Zygisk 时可使用 Riru+LSPosed（兼容性视版本而定）。"
        echo "  LSPosed: https://github.com/LSPosed/LSPosed"
        echo "  Riru: https://github.com/RikkaApps/Riru"
    else
        echo "  未检测到可用隐藏框架。若需隐藏 Root/模块，建议在了解风险后安装并配置 Magisk + Zygisk + 隐藏模块。"
    fi

    echo -e "${CYAN}安全提示：${NC} 隐藏与修改 Root/模块涉及风险，可能导致系统不稳定或服务被检测，操作前请备份。"
    echo -n "按回车键继续... "
    read dummy
}

# -------------------
# 新增：通用完整清理函数（保持原三角洲清理目录与命令不变）
# 该函数会把原有三角洲所有 rm -rf/path 替换为以 $pkg 变量形式执行，
# 因此对和平精英与王者荣耀使用相同目录并执行相同清理。
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

# 处理用户输入
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

# 主程序逻辑
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
                echo -n "请输入选择 (0-5): "
                read choice
                handle_user_input "$choice"
            done
            ;;
    esac
}

trap 'handle_exit' EXIT TERM INT HUP

main "$@"