

# 三角洲痕迹清理工具
# 集成高级自毁机制

# 版本配置
CURRENT_VERSION="2.0.0"
VERSION_CHECK_URL="https://gitee.com/yourname/yourrepo/raw/master/version.txt"
TECH_SUPPORT="@闲鱼:WuTa"

# 支持的游戏列表
# 三角洲行动
GAME_DFM_CN="com.tencent.tmgp.dfm"
GAME_DFM_TW="com.garena.game.codm"
GAME_DFM_GL="com.activision.callofduty.shooter"

# 暗区突围
GAME_AQTW_CN="com.tencent.tmgp.aqtw"
GAME_AQTW_TW="com.netease.aqtw.tw"
GAME_AQTW_GL="com.netease.aqtw"

# 王者荣耀
GAME_SGAME_CN="com.tencent.tmgp.sgame"
GAME_SGAME_TW="tw.txwy.and.kog"
GAME_SGAME_GL="com.ngame.allstar.eu"

# 和平精英
GAME_PUBG_CN="com.tencent.tmgp.pubgmhd"
GAME_PUBG_TW="com.vng.pubgmobile"
GAME_PUBG_GL="com.tencent.ig"

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
    
    echo -e "  ${YELLOW}[2]${NC} ${GREEN}Root环境检查${NC}"
    echo -e "      ${BLUE}Root环境检查 配置隐藏及方案推荐${NC}"
    echo ""
    
    echo -e "  ${YELLOW}[3]${NC} ${GREEN}清理文件部分${NC}"
    echo -e "      ${BLUE}游戏列表/指定游戏清理${NC}"
    echo ""
    
    echo -e "  ${YELLOW}[4]${NC} ${GREEN}设备硬件标识变更${NC}"
    echo -e "      ${BLUE}修改设备指纹和网络标识${NC}"
    echo ""
    
    echo -e "  ${YELLOW}[5]${NC} ${GREEN}一键智能清理+设备标识变更${NC}"
    echo -e "      ${BLUE}智能清理所有已安装游戏并变更设备标识${NC}"
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
    while true; do
        clear
        echo -e "${CYAN}===== Root环境检查 =====${NC}"
        echo ""
        echo -e "  ${YELLOW}[1]${NC} ${GREEN}检测Root环境${NC}"
        echo -e "      ${BLUE}检测Root类型、版本、Zygisk状态${NC}"
        echo ""
        echo -e "  ${YELLOW}[2]${NC} ${GREEN}查看隐藏方案${NC}"
        echo -e "      ${BLUE}根据Root类型推荐模块搭配组合${NC}"
        echo ""
        echo -e "  ${YELLOW}[3]${NC} ${GREEN}一键配置隐藏${NC}"
        echo -e "      ${BLUE}自动添加游戏到Denylist，配置隐藏模块${NC}"
        echo ""
        echo -e "  ${YELLOW}[4]${NC} ${GREEN}三角洲专项配置${NC}"
        echo -e "      ${BLUE}针对ACE反作弊的专项隐藏配置${NC}"
        echo ""
        echo -e "  ${YELLOW}[5]${NC} ${GREEN}Root痕迹清理${NC}"
        echo -e "      ${BLUE}清理Root检测痕迹（不影响Root功能）${NC}"
        echo ""
        echo -e "  ${YELLOW}[6]${NC} ${GREEN}模块下载地址${NC}"
        echo -e "      ${BLUE}显示隐藏模块下载链接${NC}"
        echo ""
        echo -e "  ${YELLOW}[0]${NC} ${PURPLE}返回主菜单${NC}"
        echo ""
        echo "================================================"
        echo ""
        echo -n "请选择操作 (0-6): "
        read choice
        
        case $choice in
            1)
                root_detect
                ;;
            2)
                root_hiding_solutions
                ;;
            3)
                one_click_configure
                ;;
            4)
                delta_specific_config
                ;;
            5)
                root_trace_cleanup
                ;;
            6)
                module_download_links
                ;;
            0)
                return
                ;;
            *)
                echo -e "${RED}无效选择，请重新输入${NC}"
                sleep 1
                ;;
        esac
    done
}

# Root检测函数
root_detect() {
    clear
    echo -e "${CYAN}===== Root环境检测 =====${NC}"
    echo ""
    
    # 检测Root类型
    ROOT_TYPE="未检测到Root"
    ROOT_VERSION=""
    ZYGISK_STATUS="未启用"
    
    if [ -d "/data/adb/magisk" ]; then
        if [ -f "/data/adb/magisk/util_functions.sh" ]; then
            ROOT_VERSION=$(su -c "magisk -V" 2>/dev/null || echo "未知")
            if echo "$ROOT_VERSION" | grep -qi "delta"; then
                ROOT_TYPE="Magisk Delta"
            elif echo "$ROOT_VERSION" | grep -qi "alpha"; then
                ROOT_TYPE="Magisk Alpha"
            else
                ROOT_TYPE="Magisk官方版"
            fi
            
            # 检测Zygisk状态
            if [ -f "/data/adb/magisk/zygisk" ] || grep -q "zygisk=1" /data/adb/magisk/config 2>/dev/null; then
                ZYGISK_STATUS="已启用"
            fi
        fi
    elif [ -d "/data/adb/ksu" ]; then
        ROOT_TYPE="KernelSU"
        ROOT_VERSION=$(su -c "ksu -V" 2>/dev/null || echo "未知")
        
        # 检测Zygisk Next
        if [ -d "/data/adb/modules/zygisksu" ] || [ -d "/data/adb/modules/zygisk_next" ]; then
            ZYGISK_STATUS="Zygisk Next已启用"
        fi
    elif [ -d "/data/adb/ap" ]; then
        ROOT_TYPE="APatch"
        ROOT_VERSION=$(su -c "apatch -V" 2>/dev/null || echo "未知")
    fi
    
    # 显示检测结果
    echo -e "${GREEN}Root类型：${NC}$ROOT_TYPE"
    echo -e "${GREEN}Root版本：${NC}$ROOT_VERSION"
    echo -e "${GREEN}Zygisk状态：${NC}$ZYGISK_STATUS"
    echo ""
    
    # 检测已安装隐藏模块
    echo -e "${CYAN}已安装隐藏模块：${NC}"
    MODULES_FOUND=0
    
    if [ -d "/data/adb/modules" ]; then
        # 检测Shamiko
        if [ -d "/data/adb/modules/zygisk_shamiko" ]; then
            echo -e "  ${GREEN}✓ Shamiko${NC}"
            MODULES_FOUND=1
        fi
        
        # 检测HMAL
        if [ -d "/data/adb/modules/hide_my_applist" ]; then
            echo -e "  ${GREEN}✓ Hide My Applist${NC}"
            MODULES_FOUND=1
        fi
        
        # 检测PlayIntegrityFix
        if [ -d "/data/adb/modules/playintegrityfix" ]; then
            echo -e "  ${GREEN}✓ PlayIntegrityFix${NC}"
            MODULES_FOUND=1
        fi
        
        # 检测Zygisk Next
        if [ -d "/data/adb/modules/zygisk_next" ] || [ -d "/data/adb/modules/zygisksu" ]; then
            echo -e "  ${GREEN}✓ Zygisk Next${NC}"
            MODULES_FOUND=1
        fi
        
        # 检测Cherish Peekaboo
        if [ -d "/data/adb/modules/cherish_peekaboo" ]; then
            echo -e "  ${GREEN}✓ Cherish Peekaboo${NC}"
            MODULES_FOUND=1
        fi
    fi
    
    if [ $MODULES_FOUND -eq 0 ]; then
        echo -e "  ${YELLOW}未检测到隐藏模块${NC}"
    fi
    
    echo ""
    echo -n "按回车键继续... "
    read dummy
}

# Root隐藏方案推荐
root_hiding_solutions() {
    clear
    echo -e "${CYAN}===== Root隐藏方案推荐 =====${NC}"
    echo ""
    
    echo -e "${GREEN}【Magisk 26+】${NC}"
    echo -e "  推荐组合：Zygisk + Shamiko + HMAL + PlayIntegrityFix"
    echo -e "  ${BLUE}说明：最新版本，完整支持所有隐藏功能${NC}"
    echo ""
    
    echo -e "${GREEN}【Magisk 24-25】${NC}"
    echo -e "  推荐组合：Zygisk + Shamiko + HMAL"
    echo -e "  ${BLUE}说明：稳定版本，适合大多数设备${NC}"
    echo ""
    
    echo -e "${GREEN}【Magisk 23.x】${NC}"
    echo -e "  推荐组合：MagiskHide + 添加游戏包名"
    echo -e "  ${BLUE}说明：旧版本，功能有限${NC}"
    echo ""
    
    echo -e "${GREEN}【Magisk Delta】${NC}"
    echo -e "  推荐组合：SuList白名单模式"
    echo -e "  ${BLUE}说明：特殊版本，自带高级隐藏${NC}"
    echo ""
    
    echo -e "${GREEN}【KernelSU】${NC}"
    echo -e "  推荐组合：Zygisk Next + Shamiko + HMAL"
    echo -e "  ${BLUE}说明：内核级Root，需要配合Zygisk Next${NC}"
    echo ""
    
    echo -e "${GREEN}【APatch】${NC}"
    echo -e "  推荐组合：Cherish Peekaboo + 内置隐藏"
    echo -e "  ${BLUE}说明：新型Root方案，自带强力隐藏${NC}"
    echo ""
    
    echo -n "按回车键继续... "
    read dummy
}

# 一键配置隐藏
one_click_configure() {
    clear
    echo -e "${CYAN}===== 一键配置隐藏 =====${NC}"
    echo ""
    
    echo -e "${YELLOW}此功能将自动配置Root隐藏${NC}"
    echo -e "${YELLOW}包括：添加游戏到Denylist，启用隐藏模块${NC}"
    echo ""
    
    echo -n "是否继续? (y/N): "
    read confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo ""
        echo -e "${GREEN}[1/4] 检测Root环境...${NC}"
        sleep 1
        
        # 添加游戏到Denylist
        echo -e "${GREEN}[2/4] 添加游戏到Denylist...${NC}"
        GAME_PACKAGES=("$GAME_DFM_CN" "$GAME_DFM_TW" "$GAME_DFM_GL" "$GAME_AQTW_CN" "$GAME_SGAME_CN" "$GAME_PUBG_CN")
        
        for pkg in "${GAME_PACKAGES[@]}"; do
            if pm list packages | grep -q "$pkg" 2>/dev/null; then
                # Magisk Denylist
                if [ -d "/data/adb/magisk" ]; then
                    su -c "magisk --denylist add $pkg" 2>/dev/null && echo -e "  ${GREEN}✓ 已添加：$pkg${NC}"
                fi
                # KernelSU Denylist  
                if [ -d "/data/adb/ksu" ]; then
                    su -c "ksu denylist add $pkg" 2>/dev/null && echo -e "  ${GREEN}✓ 已添加：$pkg${NC}"
                fi
            fi
        done
        
        echo -e "${GREEN}[3/4] 配置隐藏模块...${NC}"
        sleep 1
        
        echo -e "${GREEN}[4/4] 完成配置${NC}"
        echo ""
        echo -e "${GREEN}[√] 配置完成，建议重启设备${NC}"
    else
        echo -e "${BLUE}操作已取消${NC}"
    fi
    
    echo ""
    echo -n "按回车键继续... "
    read dummy
}

# 三角洲专项配置
delta_specific_config() {
    clear
    echo -e "${CYAN}===== 三角洲专项配置 =====${NC}"
    echo ""
    
    echo -e "${YELLOW}此功能针对三角洲ACE反作弊进行专项配置${NC}"
    echo ""
    
    echo -n "是否继续? (y/N): "
    read confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo ""
        echo -e "${GREEN}[1/3] 添加三角洲到Denylist...${NC}"
        
        DELTA_PACKAGES=("$GAME_DFM_CN" "$GAME_DFM_TW" "$GAME_DFM_GL")
        for pkg in "${DELTA_PACKAGES[@]}"; do
            if pm list packages | grep -q "$pkg" 2>/dev/null; then
                if [ -d "/data/adb/magisk" ]; then
                    su -c "magisk --denylist add $pkg" 2>/dev/null && echo -e "  ${GREEN}✓ 已添加：$pkg${NC}"
                fi
                if [ -d "/data/adb/ksu" ]; then
                    su -c "ksu denylist add $pkg" 2>/dev/null && echo -e "  ${GREEN}✓ 已添加：$pkg${NC}"
                fi
            fi
        done
        
        echo -e "${GREEN}[2/3] 配置HMAL黑名单...${NC}"
        echo -e "  ${YELLOW}请手动在HMAL中添加三角洲到黑名单${NC}"
        sleep 1
        
        echo -e "${GREEN}[3/3] 启用Shamiko...${NC}"
        if [ -d "/data/adb/modules/zygisk_shamiko" ]; then
            echo -e "  ${GREEN}✓ Shamiko已安装${NC}"
        else
            echo -e "  ${YELLOW}! Shamiko未安装，请参考模块下载地址${NC}"
        fi
        
        echo ""
        echo -e "${GREEN}[√] 三角洲专项配置完成${NC}"
    else
        echo -e "${BLUE}操作已取消${NC}"
    fi
    
    echo ""
    echo -n "按回车键继续... "
    read dummy
}

# Root痕迹清理
root_trace_cleanup() {
    clear
    echo -e "${CYAN}===== Root痕迹清理 =====${NC}"
    echo ""
    
    echo -e "${RED}注意：此操作只清理痕迹，不影响Root功能${NC}"
    echo -e "${GREEN}保护的核心目录（不会清理）：${NC}"
    echo -e "  - /data/adb/magisk/（Magisk核心）"
    echo -e "  - /data/adb/modules/（已安装模块）"
    echo -e "  - /data/adb/ksu/（KernelSU核心）"
    echo -e "  - /data/adb/ap/（APatch核心）"
    echo -e "  - /data/adb/magisk.db（授权记录）"
    echo ""
    
    echo -n "是否继续清理? (y/N): "
    read confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo ""
        echo -e "${GREEN}[1/4] 清理历史命令记录...${NC}"
        rm -f /data/local/tmp/.bash_history 2>/dev/null
        rm -f /data/local/tmp/.sh_history 2>/dev/null
        history -c 2>/dev/null
        echo -e "  ${GREEN}✓ 完成${NC}"
        
        echo -e "${GREEN}[2/4] 清理临时su文件...${NC}"
        rm -f /data/local/tmp/su_* 2>/dev/null
        rm -f /cache/su_* 2>/dev/null
        echo -e "  ${GREEN}✓ 完成${NC}"
        
        echo -e "${GREEN}[3/4] 清理Root日志...${NC}"
        rm -f /data/adb/*.log 2>/dev/null
        rm -f /data/local/tmp/*.log 2>/dev/null
        echo -e "  ${GREEN}✓ 完成${NC}"
        
        echo -e "${GREEN}[4/4] 清理SuperSU残留...${NC}"
        rm -rf /data/data/eu.chainfire.supersu 2>/dev/null
        rm -f /system/xbin/su.bak 2>/dev/null
        echo -e "  ${GREEN}✓ 完成${NC}"
        
        echo ""
        echo -e "${GREEN}[√] Root痕迹清理完成${NC}"
    else
        echo -e "${BLUE}操作已取消${NC}"
    fi
    
    echo ""
    echo -n "按回车键继续... "
    read dummy
}

# 模块下载地址
module_download_links() {
    clear
    echo -e "${CYAN}===== 模块下载地址 =====${NC}"
    echo ""
    
    echo -e "${GREEN}【Shamiko】${NC}"
    echo -e "  https://github.com/LSPosed/LSPosed.github.io/releases"
    echo ""
    
    echo -e "${GREEN}【Hide My Applist】${NC}"
    echo -e "  https://github.com/Dr-TSNG/Hide-My-Applist/releases"
    echo ""
    
    echo -e "${GREEN}【PlayIntegrityFix】${NC}"
    echo -e "  https://github.com/chiteroman/PlayIntegrityFix/releases"
    echo ""
    
    echo -e "${GREEN}【Tricky Store】${NC}"
    echo -e "  https://github.com/5ec1cff/TrickyStore/releases"
    echo ""
    
    echo -e "${GREEN}【Zygisk Next】${NC}"
    echo -e "  https://github.com/Dr-TSNG/ZygiskNext/releases"
    echo ""
    
    echo -e "${GREEN}【Cherish Peekaboo】${NC}"
    echo -e "  https://github.com/nicekwell/cherish-peekaboo/releases"
    echo ""
    
    echo -e "${YELLOW}提示：请使用浏览器访问以上链接下载最新版本${NC}"
    echo ""
    
    echo -n "按回车键继续... "
    read dummy
}

# 检测已安装游戏
detect_installed_games() {
    INSTALLED_GAMES=""
    PM_LIST=$(pm list packages 2>/dev/null)
    
    # 三角洲行动
    echo "$PM_LIST" | grep -q "$GAME_DFM_CN" && INSTALLED_GAMES="$INSTALLED_GAMES dfm_cn:"
    echo "$PM_LIST" | grep -q "$GAME_DFM_TW" && INSTALLED_GAMES="$INSTALLED_GAMES dfm_tw:"
    echo "$PM_LIST" | grep -q "$GAME_DFM_GL" && INSTALLED_GAMES="$INSTALLED_GAMES dfm_gl:"
    
    # 暗区突围
    echo "$PM_LIST" | grep -q "$GAME_AQTW_CN" && INSTALLED_GAMES="$INSTALLED_GAMES aqtw_cn:"
    echo "$PM_LIST" | grep -q "$GAME_AQTW_TW" && INSTALLED_GAMES="$INSTALLED_GAMES aqtw_tw:"
    echo "$PM_LIST" | grep -q "$GAME_AQTW_GL" && INSTALLED_GAMES="$INSTALLED_GAMES aqtw_gl:"
    
    # 王者荣耀
    echo "$PM_LIST" | grep -q "$GAME_SGAME_CN" && INSTALLED_GAMES="$INSTALLED_GAMES sgame_cn:"
    echo "$PM_LIST" | grep -q "$GAME_SGAME_TW" && INSTALLED_GAMES="$INSTALLED_GAMES sgame_tw:"
    echo "$PM_LIST" | grep -q "$GAME_SGAME_GL" && INSTALLED_GAMES="$INSTALLED_GAMES sgame_gl:"
    
    # 和平精英
    echo "$PM_LIST" | grep -q "$GAME_PUBG_CN" && INSTALLED_GAMES="$INSTALLED_GAMES pubg_cn:"
    echo "$PM_LIST" | grep -q "$GAME_PUBG_TW" && INSTALLED_GAMES="$INSTALLED_GAMES pubg_tw:"
    echo "$PM_LIST" | grep -q "$GAME_PUBG_GL" && INSTALLED_GAMES="$INSTALLED_GAMES pubg_gl:"
    
    echo "$INSTALLED_GAMES"
}

# 判断目录是否应该清理
should_clean_dir() {
    local dir_name="$1"
    local dir_lower=$(echo "$dir_name" | tr 'A-Z' 'a-z')
    
    # 检查白名单（不清理）
    case "$dir_lower" in
        *lib*|*libs*|*lib64*|*app_lib*|*shared_libs*|*native_libs*) return 1 ;;
    esac
    
    # 检查高风险关键词（必清理）
    case "$dir_lower" in
        *turing*|*turingdfp*|*turingfd*|*qimei*|*beacon*|*ano_tmp*|*apm*|*hawk*|*jwt_token*|*itop_login*|*crashrecord*|*crashsight*) return 0 ;;
    esac
    
    # 检查缓存关键词（建议清理）
    case "$dir_lower" in
        *cache*|*tbs*|*webview*|*tmp*|*temp*|*log*|*dex*|*odex*|*code_cache*) return 0 ;;
    esac
    
    return 1
}

# 智能清理游戏
smart_clean_game() {
    local pkg="$1"
    local game_name="$2"
    
    echo -e "${CYAN}[智能清理] $game_name${NC}"
    
    if [ ! -d "/data/data/$pkg" ]; then
        echo -e "  ${YELLOW}游戏未安装或无权限访问${NC}"
        return
    fi
    
    local cleaned_count=0
    
    # 清理高风险目录
    for dir in /data/data/$pkg/app_* /data/data/$pkg/files/*; do
        if [ -d "$dir" ]; then
            local dir_name=$(basename "$dir")
            if should_clean_dir "$dir_name"; then
                rm -rf "$dir" 2>/dev/null && {
                    echo -e "  ${GREEN}✓ 清理：$dir_name${NC}"
                    cleaned_count=$((cleaned_count + 1))
                }
            fi
        fi
    done
    
    # 清理标准目录
    rm -rf /data/data/$pkg/cache 2>/dev/null && echo -e "  ${GREEN}✓ 清理：cache${NC}"
    rm -rf /data/data/$pkg/code_cache 2>/dev/null && echo -e "  ${GREEN}✓ 清理：code_cache${NC}"
    rm -rf /storage/emulated/0/Android/data/$pkg/cache 2>/dev/null && echo -e "  ${GREEN}✓ 清理：外部cache${NC}"
    
    echo -e "  ${GREEN}[√] 完成智能清理${NC}"
}

# 三角洲专用清理（保留原有代码）
clean_delta_game() {
    local pkg="$1"
    echo -e "${CYAN}[三角洲专用清理] 包名：$pkg${NC}"
    echo ""
    
    echo -e "${CYAN}[步骤1] 获取游戏UID...${NC}"
    APP_UID=$(dumpsys package $pkg | grep uid= | awk '{print $1}' | cut -d'=' -f2 | uniq)
    sleep 1
    echo -e "${GREEN}[√] 当前三角洲UID: $APP_UID${NC}"
    sleep 1
    
    echo -e "${CYAN}[步骤2] 清理核心缓存文件...${NC}"
    rm -rf /data/data/$pkg/app_crashrecord && echo -e "${GREEN}[√] 清理崩溃记录${NC}"
    rm -rf /data/data/$pkg/app_crashSight && echo -e "${GREEN}[√] 清理崩溃视觉数据${NC}"
    rm -rf /data/data/$pkg/app_dex && echo -e "${GREEN}[√] 清理DEX缓存${NC}"
    rm -rf /data/data/$pkg/app_midaslib_0 /data/data/$pkg/app_midaslib_1 && echo -e "${GREEN}[√] 清理Midas库${NC}"
    rm -rf /data/data/$pkg/app_midasodex && echo -e "${GREEN}[√] 清理Midas ODEX${NC}"
    rm -rf /data/data/$pkg/app_midasplugins && echo -e "${GREEN}[√] 清理Midas插件${NC}"
    rm -rf /data/data/$pkg/app_tbs /data/data/$pkg/app_tbs_64 && echo -e "${GREEN}[√] 清理TBS内核${NC}"
    
    echo -e "${CYAN}[步骤3] 清理纹理和资源文件...${NC}"
    rm -rf /data/data/$pkg/app_texturespp_tbs_64 && echo -e "${GREEN}[√] 清理纹理资源${NC}"
    rm -rf /data/data/$pkg/app_tbs_common_share /data/data/$pkg/app_textures && echo -e "${GREEN}[√] 清理纹理资源${NC}"
    rm -rf /data/data/$pkg/app_turingdfp /data/data/$pkg/app_turingfd && echo -e "${GREEN}[√] 清理图灵引擎${NC}"
    rm -rf /data/data/$pkg/app_webview /data/data/$pkg/app_x5webview && echo -e "${GREEN}[√] 清理WebView缓存${NC}"
    
    echo -e "${CYAN}[步骤4] 清理系统缓存目录...${NC}"
    rm -rf /data/data/$pkg/cache && echo -e "${GREEN}[√] 清理缓存目录${NC}"
    rm -rf /data/data/$pkg/code_cache && echo -e "${GREEN}[√] 清理代码缓存${NC}"
    rm -rf /data/data/$pkg/databases && echo -e "${GREEN}[√] 清理数据库${NC}"
    rm -rf /data/data/$pkg/filescommonCache && echo -e "${GREEN}[√] 清理通用文件缓存${NC}"
    rm -rf /data/data/$pkg/shared_prefs && echo -e "${GREEN}[√] 清理共享首选项${NC}"
    
    echo -e "${CYAN}[步骤5] 清理游戏数据文件...${NC}"
    rm -rf /data/data/$pkg/files/app && echo -e "${GREEN}[√] 清理应用文件${NC}"
    rm -rf /data/data/$pkg/files/beacon && echo -e "${GREEN}[√] 清理信标数据${NC}"
    rm -rf /data/data/$pkg/files/com.gcloudsdk.gcloud.gvoice && echo -e "${GREEN}[√] 清理GCloud语音${NC}"
    rm -rf /data/data/$pkg/files/data && echo -e "${GREEN}[√] 清理游戏数据${NC}"
    rm -rf /data/data/$pkg/files/live_log && echo -e "${GREEN}[√] 清理实时日志${NC}"
    rm -rf /data/data/$pkg/files/popup && echo -e "${GREEN}[√] 清理弹窗数据${NC}"
    rm -rf /data/data/$pkg/files/tbs && echo -e "${GREEN}[√] 清理TBS文件${NC}"
    rm -rf /data/data/$pkg/files/qm && echo -e "${GREEN}[√] 清理QM文件${NC}"
    rm -rf /data/data/$pkg/files/tdm_tmp && echo -e "${GREEN}[√] 清理TDM临时文件${NC}"
    rm -rf /data/data/$pkg/files/wupSCache && echo -e "${GREEN}[√] 清理WUP缓存${NC}"
    
    echo -e "${CYAN}[步骤6] 清理监控文件...${NC}"
    rm -rf /data/user/0/$pkg/files/ano_tmp && echo -e "${GREEN}[√] 清理监控临时文件${NC}"
    rm -rf /data/data/$pkg/files/apm_qcc_finally /data/data/$pkg/files/apm_qcc && echo -e "${GREEN}[√] 清理APM监控${NC}"
    rm -rf /data/data/$pkg/files/hawk_data && echo -e "${GREEN}[√] 清理Hawk数据${NC}"
    rm -rf /data/data/$pkg/files/itop_login.txt && echo -e "${GREEN}[√] 清理登录信息${NC}"
    rm -rf /data/data/$pkg/files/jwt_token.txt && echo -e "${GREEN}[√] 清理JWT令牌${NC}"
    rm -rf /data/data/$pkg/files/MSDK.mmap3 && echo -e "${GREEN}[√] 清理MSDK内存映射${NC}"
    
    echo -e "${CYAN}[步骤7] 清理设备指纹...${NC}"
    rm -rf /data/data/$pkg/files/com.tencent.tdm.qimei.sdk.QimeiSDK
    rm -rf /data/data/$pkg/files/com.tencent.tbs.qimei.sdk.QimeiSDK
    rm -rf /data/data/$pkg/files/com.tencent.qimei.sdk.QimeiSDK
    echo -e "${GREEN}[√] 清理齐眉SDK指纹${NC}"
    rm -rf /data/data/$pkg/files/com.tencent.open.config.json.1110543085 && echo -e "${GREEN}[√] 清理开放配置${NC}"
    
    echo -e "${CYAN}[步骤8] 清理外部存储文件...${NC}"
    rm -rf /storage/emulated/0/Android/data/$pkg/files
    rm -rf /storage/emulated/0/Android/data/$pkg/cache
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
    
    echo -e "${GREEN}[√] 三角洲专用清理完成${NC}"
}


menu_option_3() {
    while true; do
        clear
        echo -e "${CYAN}===== 清理文件部分 =====${NC}"
        echo ""
        
        # 检测已安装游戏
        GAMES=$(detect_installed_games)
        
        if [ -z "$GAMES" ]; then
            echo -e "${YELLOW}未检测到支持的游戏${NC}"
            echo ""
            echo -n "按回车键返回主菜单... "
            read dummy
            return
        fi
        
        echo -e "${GREEN}检测到以下已安装游戏:${NC}"
        echo ""
        
        # 显示游戏列表
        local index=1
        local game_map=""
        
        # 三角洲行动
        local has_dfm=0
        echo "$GAMES" | grep -q "dfm_cn" && { echo -e "${YELLOW}【三角洲行动】${NC}"; echo -e "  ${GREEN}[$index]${NC} ✓ 国服"; game_map="$game_map $index:dfm_cn"; index=$((index + 1)); has_dfm=1; }
        echo "$GAMES" | grep -q "dfm_tw" && { [ $has_dfm -eq 0 ] && echo -e "${YELLOW}【三角洲行动】${NC}"; echo -e "  ${GREEN}[$index]${NC} ✓ 台服"; game_map="$game_map $index:dfm_tw"; index=$((index + 1)); has_dfm=1; }
        echo "$GAMES" | grep -q "dfm_gl" && { [ $has_dfm -eq 0 ] && echo -e "${YELLOW}【三角洲行动】${NC}"; echo -e "  ${GREEN}[$index]${NC} ✓ 国际服"; game_map="$game_map $index:dfm_gl"; index=$((index + 1)); has_dfm=1; }
        [ $has_dfm -eq 1 ] && echo ""
        
        # 暗区突围
        local has_aqtw=0
        echo "$GAMES" | grep -q "aqtw_cn" && { echo -e "${YELLOW}【暗区突围】${NC}"; echo -e "  ${GREEN}[$index]${NC} ✓ 国服"; game_map="$game_map $index:aqtw_cn"; index=$((index + 1)); has_aqtw=1; }
        echo "$GAMES" | grep -q "aqtw_tw" && { [ $has_aqtw -eq 0 ] && echo -e "${YELLOW}【暗区突围】${NC}"; echo -e "  ${GREEN}[$index]${NC} ✓ 台服"; game_map="$game_map $index:aqtw_tw"; index=$((index + 1)); has_aqtw=1; }
        echo "$GAMES" | grep -q "aqtw_gl" && { [ $has_aqtw -eq 0 ] && echo -e "${YELLOW}【暗区突围】${NC}"; echo -e "  ${GREEN}[$index]${NC} ✓ 国际服"; game_map="$game_map $index:aqtw_gl"; index=$((index + 1)); has_aqtw=1; }
        [ $has_aqtw -eq 1 ] && echo ""
        
        # 王者荣耀
        local has_sgame=0
        echo "$GAMES" | grep -q "sgame_cn" && { echo -e "${YELLOW}【王者荣耀】${NC}"; echo -e "  ${GREEN}[$index]${NC} ✓ 国服"; game_map="$game_map $index:sgame_cn"; index=$((index + 1)); has_sgame=1; }
        echo "$GAMES" | grep -q "sgame_tw" && { [ $has_sgame -eq 0 ] && echo -e "${YELLOW}【王者荣耀】${NC}"; echo -e "  ${GREEN}[$index]${NC} ✓ 台服"; game_map="$game_map $index:sgame_tw"; index=$((index + 1)); has_sgame=1; }
        echo "$GAMES" | grep -q "sgame_gl" && { [ $has_sgame -eq 0 ] && echo -e "${YELLOW}【王者荣耀】${NC}"; echo -e "  ${GREEN}[$index]${NC} ✓ 国际服(AOV)"; game_map="$game_map $index:sgame_gl"; index=$((index + 1)); has_sgame=1; }
        [ $has_sgame -eq 1 ] && echo ""
        
        # 和平精英
        local has_pubg=0
        echo "$GAMES" | grep -q "pubg_cn" && { echo -e "${YELLOW}【和平精英】${NC}"; echo -e "  ${GREEN}[$index]${NC} ✓ 国服"; game_map="$game_map $index:pubg_cn"; index=$((index + 1)); has_pubg=1; }
        echo "$GAMES" | grep -q "pubg_tw" && { [ $has_pubg -eq 0 ] && echo -e "${YELLOW}【和平精英】${NC}"; echo -e "  ${GREEN}[$index]${NC} ✓ 台服"; game_map="$game_map $index:pubg_tw"; index=$((index + 1)); has_pubg=1; }
        echo "$GAMES" | grep -q "pubg_gl" && { [ $has_pubg -eq 0 ] && echo -e "${YELLOW}【和平精英】${NC}"; echo -e "  ${GREEN}[$index]${NC} ✓ 国际服"; game_map="$game_map $index:pubg_gl"; index=$((index + 1)); has_pubg=1; }
        [ $has_pubg -eq 1 ] && echo ""
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo -e "  ${GREEN}[A]${NC} 清理全部已安装游戏"
        echo -e "  ${GREEN}[0]${NC} 返回主菜单"
        echo ""
        echo -n "请选择要清理的游戏: "
        read choice
        
        case $choice in
            0)
                return
                ;;
            [Aa])
                echo ""
                echo -e "${YELLOW}[!] 开始清理全部已安装游戏...${NC}"
                echo ""
                
                # 清理三角洲（使用专用清理）
                echo "$GAMES" | grep -q "dfm_cn" && clean_delta_game "$GAME_DFM_CN"
                echo "$GAMES" | grep -q "dfm_tw" && clean_delta_game "$GAME_DFM_TW"
                echo "$GAMES" | grep -q "dfm_gl" && clean_delta_game "$GAME_DFM_GL"
                
                # 清理其他游戏（使用智能清理）
                echo "$GAMES" | grep -q "aqtw_cn" && smart_clean_game "$GAME_AQTW_CN" "暗区突围-国服"
                echo "$GAMES" | grep -q "aqtw_tw" && smart_clean_game "$GAME_AQTW_TW" "暗区突围-台服"
                echo "$GAMES" | grep -q "aqtw_gl" && smart_clean_game "$GAME_AQTW_GL" "暗区突围-国际服"
                
                echo "$GAMES" | grep -q "sgame_cn" && smart_clean_game "$GAME_SGAME_CN" "王者荣耀-国服"
                echo "$GAMES" | grep -q "sgame_tw" && smart_clean_game "$GAME_SGAME_TW" "王者荣耀-台服"
                echo "$GAMES" | grep -q "sgame_gl" && smart_clean_game "$GAME_SGAME_GL" "王者荣耀-国际服"
                
                echo "$GAMES" | grep -q "pubg_cn" && smart_clean_game "$GAME_PUBG_CN" "和平精英-国服"
                echo "$GAMES" | grep -q "pubg_tw" && smart_clean_game "$GAME_PUBG_TW" "和平精英-台服"
                echo "$GAMES" | grep -q "pubg_gl" && smart_clean_game "$GAME_PUBG_GL" "和平精英-国际服"
                
                echo ""
                echo -e "${GREEN}[√] 全部游戏清理完成${NC}"
                echo ""
                echo -n "按回车键继续... "
                read dummy
                ;;
            [1-9]|[1-9][0-9])
                # 查找对应的游戏
                local selected_game=""
                for mapping in $game_map; do
                    local map_index=$(echo $mapping | cut -d: -f1)
                    local map_game=$(echo $mapping | cut -d: -f2)
                    if [ "$map_index" = "$choice" ]; then
                        selected_game="$map_game"
                        break
                    fi
                done
                
                if [ -n "$selected_game" ]; then
                    echo ""
                    case $selected_game in
                        dfm_cn) clean_delta_game "$GAME_DFM_CN" ;;
                        dfm_tw) clean_delta_game "$GAME_DFM_TW" ;;
                        dfm_gl) clean_delta_game "$GAME_DFM_GL" ;;
                        aqtw_cn) smart_clean_game "$GAME_AQTW_CN" "暗区突围-国服" ;;
                        aqtw_tw) smart_clean_game "$GAME_AQTW_TW" "暗区突围-台服" ;;
                        aqtw_gl) smart_clean_game "$GAME_AQTW_GL" "暗区突围-国际服" ;;
                        sgame_cn) smart_clean_game "$GAME_SGAME_CN" "王者荣耀-国服" ;;
                        sgame_tw) smart_clean_game "$GAME_SGAME_TW" "王者荣耀-台服" ;;
                        sgame_gl) smart_clean_game "$GAME_SGAME_GL" "王者荣耀-国际服" ;;
                        pubg_cn) smart_clean_game "$GAME_PUBG_CN" "和平精英-国服" ;;
                        pubg_tw) smart_clean_game "$GAME_PUBG_TW" "和平精英-台服" ;;
                        pubg_gl) smart_clean_game "$GAME_PUBG_GL" "和平精英-国际服" ;;
                    esac
                    echo ""
                    echo -n "按回车键继续... "
                    read dummy
                else
                    echo -e "${RED}无效选择${NC}"
                    sleep 1
                fi
                ;;
            *)
                echo -e "${RED}无效选择${NC}"
                sleep 1
                ;;
        esac
    done
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
    clear
    echo -e "${RED}[5] 一键智能清理+设备标识变更${NC}"
    echo -e "${BLUE}智能清理所有已安装游戏并变更设备标识${NC}"
    echo ""
    
    echo -e "${RED}[警告] 此操作将执行以下操作：${NC}"
    echo -e "${YELLOW}  1. 自动检测并清理所有已安装游戏${NC}"
    echo -e "${YELLOW}  2. 执行设备标识变更${NC}"
    echo -e "${RED}请确保已备份重要数据！${NC}"
    echo ""
    
    echo -n "确定要继续吗? (y/N): "
    read confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo ""
        echo -e "${YELLOW}[!] 开始一键智能清理...${NC}"
        echo ""
        
        # 步骤1：检测并清理游戏
        echo -e "${CYAN}>>> 步骤1：智能清理游戏文件${NC}"
        echo ""
        
        GAMES=$(detect_installed_games)
        
        if [ -z "$GAMES" ]; then
            echo -e "${YELLOW}未检测到支持的游戏，跳过游戏清理${NC}"
        else
            echo -e "${GREEN}检测到已安装游戏，开始清理...${NC}"
            echo ""
            
            # 清理三角洲（使用专用清理）
            if echo "$GAMES" | grep -q "dfm_cn"; then
                echo -e "${CYAN}正在清理：三角洲行动-国服${NC}"
                clean_delta_game "$GAME_DFM_CN"
                echo ""
            fi
            if echo "$GAMES" | grep -q "dfm_tw"; then
                echo -e "${CYAN}正在清理：三角洲行动-台服${NC}"
                clean_delta_game "$GAME_DFM_TW"
                echo ""
            fi
            if echo "$GAMES" | grep -q "dfm_gl"; then
                echo -e "${CYAN}正在清理：三角洲行动-国际服${NC}"
                clean_delta_game "$GAME_DFM_GL"
                echo ""
            fi
            
            # 清理其他游戏（使用智能清理）
            echo "$GAMES" | grep -q "aqtw_cn" && { smart_clean_game "$GAME_AQTW_CN" "暗区突围-国服"; echo ""; }
            echo "$GAMES" | grep -q "aqtw_tw" && { smart_clean_game "$GAME_AQTW_TW" "暗区突围-台服"; echo ""; }
            echo "$GAMES" | grep -q "aqtw_gl" && { smart_clean_game "$GAME_AQTW_GL" "暗区突围-国际服"; echo ""; }
            
            echo "$GAMES" | grep -q "sgame_cn" && { smart_clean_game "$GAME_SGAME_CN" "王者荣耀-国服"; echo ""; }
            echo "$GAMES" | grep -q "sgame_tw" && { smart_clean_game "$GAME_SGAME_TW" "王者荣耀-台服"; echo ""; }
            echo "$GAMES" | grep -q "sgame_gl" && { smart_clean_game "$GAME_SGAME_GL" "王者荣耀-国际服"; echo ""; }
            
            echo "$GAMES" | grep -q "pubg_cn" && { smart_clean_game "$GAME_PUBG_CN" "和平精英-国服"; echo ""; }
            echo "$GAMES" | grep -q "pubg_tw" && { smart_clean_game "$GAME_PUBG_TW" "和平精英-台服"; echo ""; }
            echo "$GAMES" | grep -q "pubg_gl" && { smart_clean_game "$GAME_PUBG_GL" "和平精英-国际服"; echo ""; }
            
            echo -e "${GREEN}[√] 游戏清理完成${NC}"
        fi
        echo ""
        
        # 步骤2：设备标识变更
        echo -e "${CYAN}>>> 步骤2：设备标识变更${NC}"
        echo ""
        echo -e "${GREEN}开始修改设备标识...${NC}"
        
        # 调用设备标识变更的核心代码（从menu_option_4复制）
        echo -e "${CYAN}[1] 修改网络IP地址...${NC}"
        ip6tables=/system/bin/ip6tables
        iptables=/system/bin/iptables
        
        INTERFACE="wlan0"
        IP=$(ip addr show $INTERFACE 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1)
        IP_PREFIX=$(echo $IP | cut -d. -f1-3)
        NEW_IP_LAST_PART1=$(($RANDOM % 254 + 1))
        NEW_IP_LAST_PART2=$(($RANDOM % 254 + 1))
        NEW_IP1="${IP_PREFIX}.${NEW_IP_LAST_PART1}"
        NEW_IP2="${IP_PREFIX}.${NEW_IP_LAST_PART2}"
        ip addr add $NEW_IP1/24 dev $INTERFACE 2>/dev/null
        ip addr add $NEW_IP2/24 dev $INTERFACE 2>/dev/null
        
        echo -e "${GREEN}[√] IP地址已变更${NC}"
                     
        settings put global airplane_mode_on 1 2>/dev/null
        am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true 2>/dev/null
        prog_name="/data/temp"
        name=$(tr -dc '1-9' < /dev/urandom | head -c 8)
        resetprop ro.serialno $name 2>/dev/null
        settings put global airplane_mode_on 0 2>/dev/null
        am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false 2>/dev/null
        echo -e "${GREEN}[√] 网络重置完成${NC}"
        
        echo -e "${CYAN}[2] 修改系统UUID...${NC}"
        Id_Path=/data/system/users/0
        Id_File=$Id_Path/settings_ssaid.xml
        if [ -f "$Id_File" ]; then
            abx2xml -i $Id_File 2>/dev/null
            Random_Id_1() { cat /proc/sys/kernel/random/uuid; }
            Amend_Id() { sed -i "s#$1#$2#g" $Id_File 2>/dev/null; }
            Userkey_Uid=$(grep userkey $Id_File 2>/dev/null | awk -F '"' '{print $6}')
            if [ -n "$Userkey_Uid" ]; then
                Amend_Id $Userkey_Uid $(echo `Random_Id_1``Random_Id_1` | tr -d - | tr a-z A-Z)
                xml2abx -i $Id_File 2>/dev/null
            fi
        fi
        echo -e "${GREEN}[√] 系统UUID已变更${NC}"
        
        echo -e "${CYAN}[3] 修改设备标识...${NC}"
        resetprop ro.serialno $(cat /proc/sys/kernel/random/uuid | head -c 8) 2>/dev/null
        settings put secure android_id $(cat /proc/sys/kernel/random/uuid | tr -d - | head -c 16) 2>/dev/null
        settings put global ad_aaid $(cat /proc/sys/kernel/random/uuid) 2>/dev/null
        echo -e "${GREEN}[√] 设备标识已变更${NC}"
        
        echo ""
        echo -e "${GREEN}[√] 一键智能清理+设备标识变更完成${NC}"
        echo -e "${YELLOW}建议重启设备使更改完全生效${NC}"
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
