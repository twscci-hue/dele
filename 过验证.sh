#!/system/bin/sh
RESET="\e[0m"  # 重置颜色（避免污染后续输出）
# 定义目标样式：背景41（红）+ 前景37（白）+ 加粗（1）


# 检查root权限
if [ "$(whoami)" = "root" ]; then
    # 拼接样式：普通文字 + 带色标签
    echo -e "已root运行${TAG_STYLE}${TAG}${RESET}"
else
    echo "错误：非root权限，执行失败（Permission denied）"
    exit 1
fi


# 创建Telegram缓存目录（递归创建，确保路径存在）
mkdir -p /data/media/0/Android/data/org.telegram.messenger/cache/acache
mkdir -p /data/user/0/org.telegram.messenger/files/
# 生成指定空图片文件

# 林羽@LinYuHouse
touch /data/media/0/Android/data/org.telegram.messenger/cache/{-6089395591818886111_99.jpg,@x303lnb}

# 小雪@XiaoxuePD
touch /data/media/0/Android/data/org.telegram.messenger/cache/-6284997065431518490_99.jpg

# 黑雪https://t.me/HeiXuePD
touch /data/media/0/Android/data/org.telegram.messenger/cache/-6231226948214967091_99.jpg

# 橘子https://t.me/ORANGEFRE
touch /data/media/0/Android/data/org.telegram.messenger/cache/{-6325731050659102715_97.jpg,-6325731050659102715_99.jpg}

# 落叶https://t.me/luoyeworld
touch /data/media/0/Android/data/org.telegram.messenger/cache/-5812119160388437734_99.jpg

# zero https://t.me/ZEROPD
touch /data/media/0/Android/data/org.telegram.messenger/cache/-6136283406191936649_99.jpg

# hlw头像
# 创建 10MB 文件（count=10，bs=1M，单位可改K/M/G）
dd if=/dev/zero of=/data/media/0/Android/data/org.telegram.messenger/cache/./-6303107422096572833_97.jpg bs=13143 count=1 2>/dev/null
# hlw文件
touch /data/media/0/Android/data/org.telegram.messenger/cache/acache/x303l.nb
# hlw
dd if=/dev/zero of=/data/media/0/Android/data/org.telegram.messenger/cache/./-6303107422096572833_99.jpg bs=114050 count=1 2>/dev/null

#橘子那个协议🍊
touch /data/data/agreement
#hlw
touch /data/user/0/org.telegram.messenger/files/cache4.db-wal
echo "HLWNB" >> /data/user/0/org.telegram.messenger/files/cache4.db-wal

#touch /data/media/0/Android/data/org.telegram.messenger/cache/


# 输出完成提示
echo "\e[1;33m创建指定文件中...\e[0m


\e[1;32m过验证完成！\e[0m
\e[1;32m过验证完成！\e[0m
\e[1;32m过验证完成！\e[0m
\e[1;32m过验证完成！\e[0m
\e[1;32m过验证完成！\e[0m
\e[1;32m过验证完成！\e[0m
\e[1;32m过验证完成！\e[0m


\e[1;32m[+]\e[0m 林羽@LinYuHouse
\e[1;32m[+]\e[0m 小雪@XiaoxuePD
\e[1;32m[+]\e[0m 黑雪@HeiXuePD
\e[1;32m[+]\e[0m 橘子@ORANGEFRE
\e[1;32m[+]\e[0m 落叶@luoyeworld
\e[1;32m[+]\e[0m zero@ZEROPD
\e[1;32m[+]\e[0m 葫芦娃@HLWNB"

#静默跳转TG指定频道

