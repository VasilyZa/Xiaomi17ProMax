#!/system/bin/sh
# ============================================
# DeviceSpoofX
# post-fs-data.sh - 启动早期属性注入
# 使用 resetprop 直接设置所有伪装属性
# ============================================

MODDIR=${0%/*}

TARGET_MODEL="2509FPN0BC"
TARGET_DEVICE="popsicle"
TARGET_NAME="popsicle"
TARGET_BRAND="Xiaomi"
TARGET_MANUFACTURER="Xiaomi"
TARGET_MARKETNAME="Xiaomi 17 Pro Max"
TARGET_DISPLAY_ID="OS3.0.45.0.WPBCNXM"

# ============================================
# resetprop 自动寻址
# ============================================

find_resetprop() {
    if command -v resetprop >/dev/null 2>&1; then
        echo "resetprop"; return
    fi
    if command -v magisk >/dev/null 2>&1; then
        echo "magisk resetprop"; return
    fi
    for bin in \
        /data/adb/magisk/magisk64 \
        /data/adb/magisk/magisk32 \
        /data/adb/ksu/bin/resetprop \
        /data/adb/ap/bin/resetprop; do
        if [ -f "$bin" ]; then
            echo "$bin"; return
        fi
    done
    echo ""
}

RESETPROP_BIN=$(find_resetprop)
[ -z "$RESETPROP_BIN" ] && exit 0

# ============================================
# 设备型号
# ============================================

$RESETPROP_BIN -n ro.product.model "$TARGET_MODEL"
$RESETPROP_BIN -n ro.product.system.model "$TARGET_MODEL"
$RESETPROP_BIN -n ro.product.vendor.model "$TARGET_MODEL"
$RESETPROP_BIN -n ro.product.odm.model "$TARGET_MODEL"
$RESETPROP_BIN -n ro.product.product.model "$TARGET_MODEL"
$RESETPROP_BIN -n ro.product.system_ext.model "$TARGET_MODEL"

# ============================================
# 设备代号
# ============================================

$RESETPROP_BIN -n ro.product.device "$TARGET_DEVICE"
$RESETPROP_BIN -n ro.product.system.device "$TARGET_DEVICE"
$RESETPROP_BIN -n ro.product.vendor.device "$TARGET_DEVICE"
$RESETPROP_BIN -n ro.product.odm.device "$TARGET_DEVICE"
$RESETPROP_BIN -n ro.build.product "$TARGET_DEVICE"

# ============================================
# 产品名称
# ============================================

$RESETPROP_BIN -n ro.product.name "$TARGET_NAME"
$RESETPROP_BIN -n ro.product.system.name "$TARGET_NAME"
$RESETPROP_BIN -n ro.product.vendor.name "$TARGET_NAME"
$RESETPROP_BIN -n ro.product.odm.name "$TARGET_NAME"

# ============================================
# 品牌
# ============================================

$RESETPROP_BIN -n ro.product.brand "$TARGET_BRAND"
$RESETPROP_BIN -n ro.product.system.brand "$TARGET_BRAND"
$RESETPROP_BIN -n ro.product.vendor.brand "$TARGET_BRAND"

# ============================================
# 制造商
# ============================================

$RESETPROP_BIN -n ro.product.manufacturer "$TARGET_MANUFACTURER"

# ============================================
# 营销名称
# ============================================

$RESETPROP_BIN -n ro.product.marketname "$TARGET_MARKETNAME"
$RESETPROP_BIN -n ro.product.odm.marketname "$TARGET_MARKETNAME"
$RESETPROP_BIN -n ro.product.vendor.marketname "$TARGET_MARKETNAME"
$RESETPROP_BIN -n ro.product.system.marketname "$TARGET_MARKETNAME"

# ============================================
# HyperOS 3 版本号（仅在安装时检测到时执行）
# ============================================

if [ -f "$MODDIR/is_hyperos3" ]; then
    $RESETPROP_BIN -n ro.build.display.id "$TARGET_DISPLAY_ID"
    $RESETPROP_BIN -n ro.build.version.incremental "$TARGET_DISPLAY_ID"
    $RESETPROP_BIN -n ro.mi.os.version.incremental "$TARGET_DISPLAY_ID"
    $RESETPROP_BIN -n ro.mi.os.version.name "OS3.0"
    $RESETPROP_BIN -n ro.mi.os.version.code "17"
fi
