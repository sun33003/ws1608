#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.222.3/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
sed -i 's/LEDE/OneCloud/g' package/base-files/files/bin/config_generate

# 替换终端为bash
sed -i 's/\/bin\/ash/\/bin\/bash/' package/base-files/files/etc/passwd

# ❗ 修复 default-settings 冲突（通用）
# rm -rf package/lean/default-settings
# rm -rf package/emortal/default-settings 2>/dev/null

#!/bin/bash

echo "================================="
echo " OneCloud S805 Auto NAS Setup"
echo " Auto Detect Disk Version"
echo "================================="


# ================================
# 修改默认IP
# ================================

echo "Set LAN IP 192.168.222.3"

sed -i 's/192.168.1.1/192.168.222.3/g' \
package/base-files/files/bin/config_generate



# ================================
# 创建目录
# ================================

mkdir -p package/base-files/files/etc/uci-defaults


# ================================
# 自动NAS初始化脚本
# ================================


cat > package/base-files/files/etc/uci-defaults/99-auto-nas <<'EOF'


#!/bin/sh


echo "=== OneCloud NAS Auto Detect ==="



NAS_DIR="/mnt/nas"


mkdir -p $NAS_DIR



# 安装依赖后扫描

if [ -x /usr/sbin/blkid ]; then


    DISK_UUID=$(blkid -o value -s UUID \
    | head -n 1)


    FS_TYPE=$(blkid -o value -s TYPE \
    | head -n 1)



else

    exit 0

fi




if [ -n "$DISK_UUID" ]; then


echo "Found filesystem:"
echo $FS_TYPE

echo "UUID:"
echo $DISK_UUID



cat > /etc/config/fstab <<EOT


config global automount
	option from_fstab '1'
	option anon_mount '1'


config global autoswap
	option from_fstab '1'
	option anon_swap '0'


config mount
	option target '/mnt/nas'
	option uuid '$DISK_UUID'
	option fstype '$FS_TYPE'
	option options 'rw,noatime'
	option enabled '1'


EOT



fi





# ==========================
# Samba自动配置
# ==========================


cat > /etc/config/samba4 <<EOT


config samba
	option workgroup 'WORKGROUP'
	option charset 'UTF-8'
	option description 'OneCloud NAS'


config sambashare
	option name 'NAS'
	option path '/mnt/nas'
	option read_only 'no'
	option guest_ok 'yes'
	option create_mask '0777'
	option dir_mask '0777'


EOT




mkdir -p /mnt/nas


chmod 777 /mnt/nas



/etc/init.d/fstab enable 2>/dev/null

/etc/init.d/samba4 enable 2>/dev/null



exit 0

EOF



chmod +x package/base-files/files/etc/uci-defaults/99-auto-nas



echo "Auto NAS setup finished"
