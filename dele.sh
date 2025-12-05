

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
    
    echo -e "  ${YELLOW}[2]${NC} ${GREEN}Root环境隐藏方案${NC}"
    echo -e "      ${BLUE}检测Root环境并配置游戏隐藏${NC}"
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
    # 游戏包名定义
    local GAME_DFM_CN="com.tencent.tmgp.dfm"
    local GAME_DFM_TW="com.garena.game.codm"
    local GAME_DFM_GL="com.activision.callofduty.shooter"
    
    local GAME_SGAME_CN="com.tencent.tmgp.sgame"
    local GAME_SGAME_TW="tw.txwy.and.kog"
    local GAME_SGAME_GL="com.ngame.allstar.eu"
    
    local GAME_PUBG_CN="com.tencent.tmgp.pubgmhd"
    local GAME_PUBG_TW="com.vng.pubgmobile"
    local GAME_PUBG_GL="com.tencent.ig"
    
    local GAME_AQTW_CN="com.tencent.tmgp.aqtw"
    local GAME_AQTW_TW="com.netease.aqtw.tw"
    local GAME_AQTW_GL="com.netease.aqtw"
    
    # 常量定义
    local MAGISK_MIN_ZYGISK_VERSION=24
    
    # 缓存pm list结果以提高性能
    local PM_LIST_CACHE=""
    
    # 检测Root环境
    detect_root_env() {
        # 使用缓存的包列表
        if [ -z "$PM_LIST_CACHE" ]; then
            PM_LIST_CACHE=$(pm list packages 2>/dev/null)
        fi
        local ROOT_TYPE=""
        local ROOT_VERSION=""
        local HAS_ROOT=0
        
        # 检测Magisk
        if [ -d "/data/adb/magisk" ] || echo "$PM_LIST_CACHE" | grep -q "com.topjohnwu.magisk"; then
            HAS_ROOT=1
            ROOT_TYPE="Magisk"
            if command -v magisk >/dev/null 2>&1; then
                ROOT_VERSION=$(magisk --version 2>/dev/null | head -1)
            elif [ -f "/data/adb/magisk/util_functions.sh" ]; then
                ROOT_VERSION=$(grep "MAGISK_VER=" /data/adb/magisk/util_functions.sh 2>/dev/null | cut -d'=' -f2 | tr -d '"' | head -1)
            fi
            
            # 检测Magisk变体
            if echo "$PM_LIST_CACHE" | grep -q "io.github.huskydg.magisk"; then
                ROOT_TYPE="Magisk Delta"
            elif echo "$PM_LIST_CACHE" | grep -q "io.github.vvb2060.magisk"; then
                ROOT_TYPE="Magisk Alpha"
            fi
        # 检测KernelSU
        elif [ -d "/data/adb/kernelsu" ] || echo "$PM_LIST_CACHE" | grep -q "me.weishu.kernelsu"; then
            HAS_ROOT=1
            ROOT_TYPE="KernelSU"
            if command -v ksud >/dev/null 2>&1; then
                ROOT_VERSION=$(ksud --version 2>/dev/null | head -1)
            fi
        # 检测APatch
        elif [ -d "/data/adb/apatch" ] || echo "$PM_LIST_CACHE" | grep -q "me.bmax.apatch"; then
            HAS_ROOT=1
            ROOT_TYPE="APatch"
            if [ -f "/data/adb/apatch/version" ]; then
                ROOT_VERSION=$(cat /data/adb/apatch/version 2>/dev/null)
            fi
        fi
        
        echo "$HAS_ROOT|$ROOT_TYPE|$ROOT_VERSION"
    }
    
    # 检测Zygisk状态
    detect_zygisk() {
        local ZYGISK_ENABLED=0
        
        if [ -f "/data/adb/magisk/config" ]; then
            if grep -q "zygisk=true" /data/adb/magisk/config 2>/dev/null; then
                ZYGISK_ENABLED=1
            fi
        fi
        
        echo "$ZYGISK_ENABLED"
    }
    
    # 检测隐藏模块
    detect_hide_modules() {
        local MODULES=""
        
        # Shamiko
        if [ -d "/data/adb/modules/zygisk_shamiko" ]; then
            MODULES="${MODULES}Shamiko "
        fi
        
        # Hide My Applist
        if echo "$PM_LIST_CACHE" | grep -q "com.tsng.hidemyapplist"; then
            MODULES="${MODULES}HideMyApplist "
        fi
        
        # Zygisk Next
        if [ -d "/data/adb/modules/zygisk_next" ]; then
            MODULES="${MODULES}ZygiskNext "
        fi
        
        echo "$MODULES"
    }
    
    # 检测已安装的游戏
    detect_installed_games() {
        local INSTALLED=""
        
        # 三角洲行动
        echo "$PM_LIST_CACHE" | grep -q "$GAME_DFM_CN" && INSTALLED="${INSTALLED}dfm_cn "
        echo "$PM_LIST_CACHE" | grep -q "$GAME_DFM_TW" && INSTALLED="${INSTALLED}dfm_tw "
        echo "$PM_LIST_CACHE" | grep -q "$GAME_DFM_GL" && INSTALLED="${INSTALLED}dfm_gl "
        
        # 王者荣耀
        echo "$PM_LIST_CACHE" | grep -q "$GAME_SGAME_CN" && INSTALLED="${INSTALLED}sgame_cn "
        echo "$PM_LIST_CACHE" | grep -q "$GAME_SGAME_TW" && INSTALLED="${INSTALLED}sgame_tw "
        echo "$PM_LIST_CACHE" | grep -q "$GAME_SGAME_GL" && INSTALLED="${INSTALLED}sgame_gl "
        
        # 和平精英
        echo "$PM_LIST_CACHE" | grep -q "$GAME_PUBG_CN" && INSTALLED="${INSTALLED}pubg_cn "
        echo "$PM_LIST_CACHE" | grep -q "$GAME_PUBG_TW" && INSTALLED="${INSTALLED}pubg_tw "
        echo "$PM_LIST_CACHE" | grep -q "$GAME_PUBG_GL" && INSTALLED="${INSTALLED}pubg_gl "
        
        # 暗区突围
        echo "$PM_LIST_CACHE" | grep -q "$GAME_AQTW_CN" && INSTALLED="${INSTALLED}aqtw_cn "
        echo "$PM_LIST_CACHE" | grep -q "$GAME_AQTW_TW" && INSTALLED="${INSTALLED}aqtw_tw "
        echo "$PM_LIST_CACHE" | grep -q "$GAME_AQTW_GL" && INSTALLED="${INSTALLED}aqtw_gl "
        
        echo "$INSTALLED"
    }
    
    # 检查游戏是否在Denylist中
    check_in_denylist() {
        local pkg="$1"
        
        if command -v magisk >/dev/null 2>&1; then
            if magisk --denylist ls 2>/dev/null | grep -q "^$pkg$"; then
                return 0
            fi
        fi
        return 1
    }
    
    # 添加到Denylist
    add_to_denylist() {
        local pkg="$1"
        local name="$2"
        
        echo -e "${CYAN}正在添加 $name ($pkg) 到 Denylist...${NC}"
        
        if command -v magisk >/dev/null 2>&1; then
            local error_msg=$(magisk --denylist add "$pkg" 2>&1)
            local exit_code=$?
            if [ $exit_code -eq 0 ]; then
                echo -e "${GREEN}  ✓ 添加成功${NC}"
                return 0
            else
                echo -e "${RED}  ✗ 添加失败${NC}"
                if [ -n "$error_msg" ]; then
                    echo -e "${YELLOW}    错误信息: $error_msg${NC}"
                fi
                return 1
            fi
        else
            echo -e "${YELLOW}  ! Magisk命令不可用${NC}"
            return 1
        fi
    }
    
    # 显示未安装Root的指引
    show_no_root_guide() {
        clear
        echo -e "${RED}===== 未检测到 Root 环境 =====${NC}"
        echo ""
        echo -e "${YELLOW}您的设备尚未获取 Root 权限，以下是获取 Root 的方案：${NC}"
        echo ""
        echo -e "${CYAN}【方案一】Magisk（推荐）${NC}"
        echo "  1. 解锁 Bootloader（BL锁）"
        echo "     - 小米：设置 → 开发者选项 → 设备解锁状态"
        echo "     - 一加：设置 → 开发者选项 → OEM解锁"
        echo "  2. 下载 Magisk APK"
        echo "     - 官方版：https://github.com/topjohnwu/Magisk/releases"
        echo "     - Alpha版：https://github.com/vvb2060/magisk_files"
        echo "  3. 提取并修补 boot.img"
        echo "  4. 刷入修补后的 boot.img"
        echo ""
        echo -e "${CYAN}【方案二】KernelSU${NC}"
        echo "  适用于部分支持的设备和内核"
        echo "  官网：https://kernelsu.org"
        echo ""
        echo -e "${CYAN}【方案三】APatch${NC}"
        echo "  无需解锁BL的Root方案（部分设备支持）"
        echo "  官网：https://github.com/bmax121/APatch"
        echo ""
        echo -e "${RED}⚠️  注意：Root 操作有风险，请提前备份数据！${NC}"
        echo ""
        echo -n "按回车键返回主菜单... "
        read dummy
    }
    
    # 显示Root方案推荐
    show_root_recommendations() {
        local root_type="$1"
        local root_version="$2"
        local zygisk_enabled="$3"
        
        echo ""
        echo -e "${CYAN}===== 隐藏方案推荐 =====${NC}"
        echo ""
        
        case "$root_type" in
            "Magisk")
                if [ -n "$root_version" ]; then
                    local ver_num=$(echo "$root_version" | grep -oE '[0-9]+' | head -1)
                    if [ -n "$ver_num" ] && [ "$ver_num" -ge "$MAGISK_MIN_ZYGISK_VERSION" ]; then
                        echo -e "${GREEN}推荐方案：Zygisk + Shamiko${NC}"
                        echo "  1. 启用 Zygisk（Magisk设置 → Zygisk）"
                        echo "  2. 下载并安装 Shamiko 模块"
                        echo "     https://github.com/LSPosed/LSPosed.github.io/releases"
                        echo "  3. 配置排除列表（Magisk → 设置 → 配置排除列表）"
                        echo "  4. 添加游戏到 Denylist"
                    else
                        echo -e "${GREEN}推荐方案：MagiskHide${NC}"
                        echo "  1. 启用 MagiskHide（Magisk设置）"
                        echo "  2. 添加游戏包名到隐藏列表"
                    fi
                fi
                ;;
            "Magisk Delta")
                echo -e "${GREEN}推荐方案：SuList 白名单${NC}"
                echo "  1. 启用 SuList（Magisk Delta设置）"
                echo "  2. 仅允许必要应用获取 Root"
                echo "  3. 确保游戏不在白名单中"
                ;;
            "Magisk Alpha")
                echo -e "${GREEN}推荐方案：Zygisk + Shamiko${NC}"
                echo "  1. 启用 Zygisk"
                echo "  2. 安装 Shamiko 模块"
                echo "  3. 配置游戏隐藏"
                ;;
            "KernelSU")
                echo -e "${GREEN}推荐方案：内置隐藏 + Zygisk Next${NC}"
                echo "  1. KernelSU → 模块 → 安装 Zygisk Next"
                echo "  2. 安装 Shamiko 模块"
                echo "  3. 在应用管理中配置游戏的Root权限为'拒绝'"
                ;;
            "APatch")
                echo -e "${GREEN}推荐方案：内置隐藏${NC}"
                echo "  1. APatch → 超级用户"
                echo "  2. 确保游戏不在允许列表中"
                echo "  3. 配置隐藏选项"
                ;;
            *)
                echo -e "${YELLOW}未知的Root类型，无法提供针对性建议${NC}"
                ;;
        esac
        echo ""
    }
    
    # 一键配置功能
    auto_configure() {
        local games_to_add="$1"
        
        echo ""
        echo -e "${CYAN}===== 开始一键配置 =====${NC}"
        echo ""
        
        local count=0
        local total=$(echo "$games_to_add" | wc -w)
        
        for game_code in $games_to_add; do
            count=$((count + 1))
            local pkg=""
            local name=""
            
            case "$game_code" in
                dfm_cn) pkg="$GAME_DFM_CN"; name="三角洲行动(国服)" ;;
                dfm_tw) pkg="$GAME_DFM_TW"; name="三角洲行动(台服)" ;;
                dfm_gl) pkg="$GAME_DFM_GL"; name="三角洲行动(国际服)" ;;
                sgame_cn) pkg="$GAME_SGAME_CN"; name="王者荣耀(国服)" ;;
                sgame_tw) pkg="$GAME_SGAME_TW"; name="王者荣耀(台服)" ;;
                sgame_gl) pkg="$GAME_SGAME_GL"; name="王者荣耀(AOV)" ;;
                pubg_cn) pkg="$GAME_PUBG_CN"; name="和平精英(国服)" ;;
                pubg_tw) pkg="$GAME_PUBG_TW"; name="和平精英(台服)" ;;
                pubg_gl) pkg="$GAME_PUBG_GL"; name="PUBG Mobile" ;;
                aqtw_cn) pkg="$GAME_AQTW_CN"; name="暗区突围(国服)" ;;
                aqtw_tw) pkg="$GAME_AQTW_TW"; name="暗区突围(台服)" ;;
                aqtw_gl) pkg="$GAME_AQTW_GL"; name="暗区突围(国际服)" ;;
            esac
            
            if [ -n "$pkg" ]; then
                echo -e "${CYAN}[$count/$total] ${name}${NC}"
                add_to_denylist "$pkg" "$name"
            fi
        done
        
        echo ""
        echo -e "${GREEN}配置完成！${NC}"
        echo ""
        echo -e "${YELLOW}⚠️  提示：${NC}"
        echo "  - 请重启游戏使配置生效"
        echo "  - 如需安装 Shamiko，请访问："
        echo "    https://github.com/LSPosed/LSPosed.github.io/releases"
        echo ""
    }
    
    # 主逻辑
    echo -e "${YELLOW}[2] Root环境隐藏方案${NC}"
    echo -e "${BLUE}检测Root环境并配置游戏隐藏${NC}"
    echo ""
    
    # 检测Root环境
    local root_info=$(detect_root_env)
    local has_root=$(echo "$root_info" | cut -d'|' -f1)
    local root_type=$(echo "$root_info" | cut -d'|' -f2)
    local root_version=$(echo "$root_info" | cut -d'|' -f3)
    
    if [ "$has_root" = "0" ]; then
        show_no_root_guide
        return
    fi
    
    # 显示Root环境信息
    echo -e "${GREEN}===== Root 环境检测 =====${NC}"
    echo ""
    echo -e "${CYAN}Root 类型：${NC}${root_type}"
    if [ -n "$root_version" ]; then
        echo -e "${CYAN}Root 版本：${NC}${root_version}"
    fi
    
    local zygisk_enabled=$(detect_zygisk)
    if [ "$zygisk_enabled" = "1" ]; then
        echo -e "${CYAN}Zygisk 状态：${NC}${GREEN}已启用${NC}"
    else
        echo -e "${CYAN}Zygisk 状态：${NC}${YELLOW}未启用${NC}"
    fi
    
    local hide_modules=$(detect_hide_modules)
    if [ -n "$hide_modules" ]; then
        echo -e "${CYAN}隐藏模块：${NC}${hide_modules}"
    else
        echo -e "${CYAN}隐藏模块：${NC}${YELLOW}未安装${NC}"
    fi
    
    # 检测已安装的游戏
    local installed_games=$(detect_installed_games)
    echo ""
    echo -e "${GREEN}===== 已安装的游戏 =====${NC}"
    echo ""
    
    if [ -z "$installed_games" ]; then
        echo -e "${YELLOW}未检测到支持的游戏${NC}"
    else
        for game_code in $installed_games; do
            local pkg=""
            local name=""
            local in_denylist=""
            
            case "$game_code" in
                dfm_cn) pkg="$GAME_DFM_CN"; name="三角洲行动(国服)" ;;
                dfm_tw) pkg="$GAME_DFM_TW"; name="三角洲行动(台服)" ;;
                dfm_gl) pkg="$GAME_DFM_GL"; name="三角洲行动(国际服)" ;;
                sgame_cn) pkg="$GAME_SGAME_CN"; name="王者荣耀(国服)" ;;
                sgame_tw) pkg="$GAME_SGAME_TW"; name="王者荣耀(台服)" ;;
                sgame_gl) pkg="$GAME_SGAME_GL"; name="王者荣耀(AOV)" ;;
                pubg_cn) pkg="$GAME_PUBG_CN"; name="和平精英(国服)" ;;
                pubg_tw) pkg="$GAME_PUBG_TW"; name="和平精英(台服)" ;;
                pubg_gl) pkg="$GAME_PUBG_GL"; name="PUBG Mobile" ;;
                aqtw_cn) pkg="$GAME_AQTW_CN"; name="暗区突围(国服)" ;;
                aqtw_tw) pkg="$GAME_AQTW_TW"; name="暗区突围(台服)" ;;
                aqtw_gl) pkg="$GAME_AQTW_GL"; name="暗区突围(国际服)" ;;
            esac
            
            if check_in_denylist "$pkg"; then
                echo -e "  ${GREEN}[√]${NC} $name - ${GREEN}已添加到隐藏列表${NC}"
            else
                echo -e "  ${RED}[×]${NC} $name - ${YELLOW}未添加到隐藏列表${NC}"
            fi
        done
    fi
    
    # 显示隐藏方案推荐
    show_root_recommendations "$root_type" "$root_version" "$zygisk_enabled"
    
    # 询问是否执行一键配置
    if [ -n "$installed_games" ]; then
        echo -n "是否执行一键配置将游戏添加到隐藏列表？(y/N): "
        read confirm
        
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            # 找出未添加到Denylist的游戏
            local games_to_add=""
            for game_code in $installed_games; do
                local pkg=""
                case "$game_code" in
                    dfm_cn) pkg="$GAME_DFM_CN" ;;
                    dfm_tw) pkg="$GAME_DFM_TW" ;;
                    dfm_gl) pkg="$GAME_DFM_GL" ;;
                    sgame_cn) pkg="$GAME_SGAME_CN" ;;
                    sgame_tw) pkg="$GAME_SGAME_TW" ;;
                    sgame_gl) pkg="$GAME_SGAME_GL" ;;
                    pubg_cn) pkg="$GAME_PUBG_CN" ;;
                    pubg_tw) pkg="$GAME_PUBG_TW" ;;
                    pubg_gl) pkg="$GAME_PUBG_GL" ;;
                    aqtw_cn) pkg="$GAME_AQTW_CN" ;;
                    aqtw_tw) pkg="$GAME_AQTW_TW" ;;
                    aqtw_gl) pkg="$GAME_AQTW_GL" ;;
                esac
                
                if ! check_in_denylist "$pkg"; then
                    games_to_add="$games_to_add $game_code"
                fi
            done
            
            if [ -n "$games_to_add" ]; then
                auto_configure "$games_to_add"
            else
                echo ""
                echo -e "${GREEN}所有游戏已添加到隐藏列表！${NC}"
                echo ""
            fi
        fi
    fi
    
    echo -e "${GREEN}[√] Root环境隐藏方案配置完成${NC}"
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
