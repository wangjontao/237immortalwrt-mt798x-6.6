#!/bin/bash
set -euo pipefail
sed -i -E '/^src-git (passwall|passwall2|istore|nas_packages|nas_luci|openclash|homeproxy) /d' feeds.conf.default
cat >> feeds.conf.default <<'FEEDS'
src-git passwall https://github.com/Openwrt-Passwall/openwrt-passwall.git;26.3.6-1
src-git passwall2 https://github.com/Openwrt-Passwall/openwrt-passwall2.git;26.3.5-1
src-git istore https://github.com/linkease/istore.git;main
src-git nas_packages https://github.com/linkease/nas-packages.git;master
src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main
src-git openclash https://github.com/vernesong/OpenClash.git;master
src-git homeproxy https://github.com/immortalwrt/homeproxy.git;main
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




