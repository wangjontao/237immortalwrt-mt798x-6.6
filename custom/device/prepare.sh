#!/bin/bash
set -euo pipefail
cat >> feeds.conf.default <<'FEEDS'
src-git passwall https://github.com/Openwrt-Passwall/openwrt-passwall.git^6c45f659251fd91ac0e414db94710288ab9cda61
src-git passwall2 https://github.com/Openwrt-Passwall/openwrt-passwall2.git^c613dc317bec3e3bf6ac920177fbe1e69495d1c8
src-git istore https://github.com/linkease/istore.git^3fca15b30aeed9ecacb3efc8b4a8b9c2584ad5c7
src-git nas_packages https://github.com/linkease/nas-packages.git^b51237b6929f5c7fda6ba2a8b9cd3b7ac0ec3f82
src-git nas_luci https://github.com/linkease/nas-packages-luci.git^c3af221503298abb6b92a2fc2a31f78f1fec13e4
src-git openclash https://github.com/vernesong/OpenClash.git^c3a33c1d3407956fdf8f0e0b7c1a4c52e6ad9593
FEEDS
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/feeds install -f -p passwall luci-app-passwall
./scripts/feeds install -f -p passwall2 luci-app-passwall2
./scripts/feeds install -f -p istore luci-app-store
./scripts/feeds install -f -p nas_packages quickstart
./scripts/feeds install -f -p nas_luci luci-app-quickstart
./scripts/feeds install -f -p openclash luci-app-openclash
grep -q 'PKG_VERSION:=26.3.6' feeds/passwall/luci-app-passwall/Makefile
grep -q 'PKG_VERSION:=26.3.5' feeds/passwall2/luci-app-passwall2/Makefile
cp custom/device/config.seed .config
make defconfig
grep -q '^CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_cmcc_a10=y$' .config
 grep -q '^CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_cmcc_a10_stock=y$' .config
 grep -q '^CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_cmcc_a10_ubootmod=y$' .config
for p in kmod-mt7915e kmod-mt7981-firmware luci-app-passwall luci-app-passwall2 luci-app-homeproxy luci-app-openclash luci-app-store quickstart luci-app-quickstart luci-theme-argon luci-app-ttyd luci-app-nps npc; do grep -q "^CONFIG_PACKAGE_${p}=y$" .config || { echo "Required package missing: $p"; exit 1; }; done
HASH="$(openssl passwd -1 'password')"
cp package/base-files/files/etc/shadow files/etc/shadow
sed -i "s#^root:[^:]*:#root:${HASH}:#" files/etc/shadow
printf '%s
' "$HASH" > files/etc/dulwifi-root.hash
chmod 600 files/etc/shadow files/etc/dulwifi-root.hash
chmod 755 files/etc/uci-defaults/99-zz-dulwifi files/etc/init.d/dulwifi-firstboot files/usr/libexec/dulwifi-firstboot
./scripts/diffconfig.sh > build.config



