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

echo "======================================"
echo " Fix Amlogic OneCloud S805 Build"
echo " Remove S905D DTS Patch Conflict"
echo "======================================"


# 当前源码目录
cd $GITHUB_WORKSPACE/openwrt 2>/dev/null || cd /workdir/openwrt


echo "Current path:"
pwd


# =====================================
# 删除 S905D 错误补丁
# =====================================

PATCH_FILE="target/linux/amlogic/patches-6.6/001-dts-s905d-fix-high-load.patch"


if [ -f "$PATCH_FILE" ]; then

    echo "Remove incompatible S905D patch..."

    rm -f "$PATCH_FILE"

else

    echo "S905D patch not found, skip."

fi



# =====================================
# 删除失败残留
# =====================================

echo "Cleaning reject files..."

find target/linux/amlogic -name "*.rej" -delete


# =====================================
# 确认 OneCloud DTS
# =====================================

echo "Checking OneCloud DTS..."

find target/linux/amlogic -name "*onecloud*"



# =====================================
# 禁止无关 S905D设备
# =====================================

echo "Disable S905D related patches..."

find target/linux/amlogic/patches-6.6 \
-name "*s905*" \
-not -name "*onecloud*" \
-exec rm -f {} \;


# =====================================
# 修复设备名称
# =====================================

echo "Amlogic S805 patch cleanup finished."


exit 0


