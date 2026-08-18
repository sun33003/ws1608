#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
# echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
# echo 'src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages' >>feeds.conf.default



#!/bin/bash
set -e

echo "=========================================="
echo " JCG Q30 / MT7981 CONFIG FIX"
echo " ImmortalWrt 24.10"
echo "=========================================="

# ==========================================================
# 1. 清理旧 Target 配置
# ==========================================================

echo "[1] Cleaning old target configuration..."

sed -i \
  -e '/^CONFIG_TARGET_/d' \
  -e '/^CONFIG_TARGET_DEVICE_/d' \
  .config


# ==========================================================
# 2. 强制 JCG Q30 / MT7981 / Filogic
# ==========================================================

echo "[2] Force JCG Q30 / MT7981..."

cat >> .config <<'EOF'

#
# JCG Q30 / MT7981
#

CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_mediatek_filogic_DEVICE_jcg_q30=y

EOF


# ==========================================================
# 3. 极简科学上网
# ==========================================================

cat >> .config <<'EOF'

#
# LuCI
#

CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-ssl=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y

#
# SSH
#

CONFIG_PACKAGE_dropbear=y

#
# IPv6
#

CONFIG_PACKAGE_odhcp6c=y
CONFIG_PACKAGE_odhcpd-ipv6only=y
CONFIG_PACKAGE_luci-proto-ipv6=y

#
# TPROXY
#

CONFIG_PACKAGE_kmod-ipt-tproxy=y
CONFIG_PACKAGE_iptables-mod-tproxy=y
CONFIG_PACKAGE_kmod-nft-tproxy=y

#
# TUN
#

CONFIG_PACKAGE_kmod-tun=y

#
# SSR Plus
#

CONFIG_PACKAGE_luci-app-ssr-plus=y

#
# Xray
#

CONFIG_PACKAGE_xray-core=y

#
# V2Ray
#

CONFIG_PACKAGE_v2ray-core=y

#
# Trojan
#

CONFIG_PACKAGE_trojan=y

#
# Hysteria2
#

CONFIG_PACKAGE_hysteria=y

#
# MT7981 WiFi
#

CONFIG_PACKAGE_kmod-mac80211=y
CONFIG_PACKAGE_kmod-mt76=y
CONFIG_PACKAGE_kmod-mt7915e=y
CONFIG_PACKAGE_kmod-mt7981-firmware=y
CONFIG_PACKAGE_mt7981-wo-firmware=y
CONFIG_PACKAGE_wireless-regdb=y

EOF


# ==========================================================
# 4. 删除明显不需要的东西
# ==========================================================

echo "[3] Removing unnecessary packages..."

sed -i '/^CONFIG_PACKAGE_openssh-/d' .config
sed -i '/^CONFIG_PACKAGE_luci-app-radicale3=/d' .config
sed -i '/^CONFIG_PACKAGE_radicale3=/d' .config

cat >> .config <<'EOF'

# No OpenSSH
# CONFIG_PACKAGE_openssh-client is not set
# CONFIG_PACKAGE_openssh-server is not set
# CONFIG_PACKAGE_openssh-sftp-server is not set

# No NAS
# CONFIG_PACKAGE_samba4-server is not set
# CONFIG_PACKAGE_aria2 is not set

# No DNS extras
# CONFIG_PACKAGE_mosdns is not set
# CONFIG_PACKAGE_luci-app-mosdns is not set
# CONFIG_PACKAGE_smartdns is not set
# CONFIG_PACKAGE_luci-app-smartdns is not set

# No other proxy platforms
# CONFIG_PACKAGE_luci-app-passwall is not set
# CONFIG_PACKAGE_luci-app-passwall2 is not set
# CONFIG_PACKAGE_luci-app-homeproxy is not set
# CONFIG_PACKAGE_luci-app-openclash is not set
# CONFIG_PACKAGE_sing-box is not set
# CONFIG_PACKAGE_mihomo is not set

EOF


# ==========================================================
# 5. 显示最终 Target
# ==========================================================

echo
echo "=========================================="
echo " TARGET CONFIG"
echo "=========================================="

grep '^CONFIG_TARGET_' .config || true

echo
echo "=========================================="
echo " PROXY CONFIG"
echo "=========================================="

grep -E \
  '^CONFIG_PACKAGE_(luci-app-ssr-plus|xray-core|v2ray-core|trojan|hysteria)=' \
  .config || true
