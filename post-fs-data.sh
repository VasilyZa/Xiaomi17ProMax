#!/system/bin/sh
# ============================================
# Xiaomi 17 Pro Max Device Spoofer
# post-fs-data.sh - 早期启动阶段属性修改
# 在文件系统挂载后、Zygote 启动前执行
# 支持 Magisk / KernelSU / APatch
# ============================================
# 注意: 此阶段必须使用 resetprop -n，禁止使用 setprop

MODDIR=${0%/*}

# 目标设备参数
TARGET_MODEL="2509FPN0BC"
TARGET_DEVICE="popsicle"
TARGET_NAME="popsicle"
TARGET_BRAND="Xiaomi"
TARGET_MANUFACTURER="Xiaomi"
TARGET_MARKETNAME="Xiaomi 17 Pro Max"

# ============================================
# resetprop 自动寻址（兼容三大 Root 方案）
# ============================================

find_resetprop() {
    # 1. PATH 中直接可用
    if command -v resetprop >/dev/null 2>&1; then
        echo "resetprop"
        return
    fi
    # 2. Magisk 内置
    if command -v magisk >/dev/null 2>&1; then
        echo "magisk resetprop"
        return
    fi
    # 3. Magisk 二进制路径
    if [ -f /data/adb/magisk/magisk64 ]; then
        echo "/data/adb/magisk/magisk64 resetprop"
        return
    fi
    if [ -f /data/adb/magisk/magisk32 ]; then
        echo "/data/adb/magisk/magisk32 resetprop"
        return
    fi
    # 4. KernelSU 路径
    if [ -f /data/adb/ksu/bin/resetprop ]; then
        echo "/data/adb/ksu/bin/resetprop"
        return
    fi
    # 5. APatch 路径
    if [ -f /data/adb/ap/bin/resetprop ]; then
        echo "/data/adb/ap/bin/resetprop"
        return
    fi
    # 未找到
    echo ""
}

RESETPROP_BIN=$(find_resetprop)

# 如果找不到 resetprop 则退出
if [ -z "$RESETPROP_BIN" ]; then
    exit 1
fi

# 获取 Android API 等级
API_LEVEL=$(getprop ro.build.version.sdk)

# 安全设置属性：仅修改设备上已存在的属性
set_prop_safe() {
    local current
    current=$(getprop "$1")
    if [ -n "$current" ]; then
        $RESETPROP_BIN -n "$1" "$2"
    fi
}

# ============================================
# 核心属性修改（所有版本通用）
# ============================================

# 设备型号
$RESETPROP_BIN -n ro.product.model "$TARGET_MODEL"
$RESETPROP_BIN -n ro.product.brand "$TARGET_BRAND"
$RESETPROP_BIN -n ro.product.manufacturer "$TARGET_MANUFACTURER"
$RESETPROP_BIN -n ro.product.device "$TARGET_DEVICE"
$RESETPROP_BIN -n ro.product.name "$TARGET_NAME"
$RESETPROP_BIN -n ro.build.product "$TARGET_DEVICE"

# ============================================
# 分区属性修改（Android 10+ / MIUI 12+）
# ============================================

if [ "$API_LEVEL" -ge 29 ]; then
    # 型号 - 所有分区
    set_prop_safe ro.product.system.model "$TARGET_MODEL"
    set_prop_safe ro.product.vendor.model "$TARGET_MODEL"
    set_prop_safe ro.product.odm.model "$TARGET_MODEL"
    set_prop_safe ro.product.product.model "$TARGET_MODEL"
    set_prop_safe ro.product.system_ext.model "$TARGET_MODEL"

    # 设备代号 - 所有分区
    set_prop_safe ro.product.system.device "$TARGET_DEVICE"
    set_prop_safe ro.product.vendor.device "$TARGET_DEVICE"
    set_prop_safe ro.product.odm.device "$TARGET_DEVICE"
    set_prop_safe ro.product.product.device "$TARGET_DEVICE"
    set_prop_safe ro.product.system_ext.device "$TARGET_DEVICE"

    # 产品名称 - 所有分区
    set_prop_safe ro.product.system.name "$TARGET_NAME"
    set_prop_safe ro.product.vendor.name "$TARGET_NAME"
    set_prop_safe ro.product.odm.name "$TARGET_NAME"
    set_prop_safe ro.product.product.name "$TARGET_NAME"
    set_prop_safe ro.product.system_ext.name "$TARGET_NAME"

    # 品牌 - 所有分区
    set_prop_safe ro.product.system.brand "$TARGET_BRAND"
    set_prop_safe ro.product.vendor.brand "$TARGET_BRAND"
    set_prop_safe ro.product.odm.brand "$TARGET_BRAND"
    set_prop_safe ro.product.product.brand "$TARGET_BRAND"
    set_prop_safe ro.product.system_ext.brand "$TARGET_BRAND"
fi

# ============================================
# 小米/MIUI/HyperOS 专用属性
# ============================================

# 营销名称 - 设置页面"型号"字段的关键属性
$RESETPROP_BIN -n ro.product.marketname "$TARGET_MARKETNAME"
set_prop_safe ro.product.odm.marketname "$TARGET_MARKETNAME"
set_prop_safe ro.product.vendor.marketname "$TARGET_MARKETNAME"
set_prop_safe ro.product.system.marketname "$TARGET_MARKETNAME"

# 设备描述
set_prop_safe ro.build.description "${TARGET_NAME}-user 16 BP1A.250305.001 release-keys"

# ============================================
# HyperOS 3 版本号自动修改
# 检测 ro.miui.ui.version.name 为 V170 或
# ro.build.display.id 以 OS3 开头即判定为 HyperOS 3
# ============================================

MIUI_VER=$(getprop ro.miui.ui.version.name)
DISPLAY_ID=$(getprop ro.build.display.id)
TARGET_DISPLAY_ID="OS3.0.45.0.WPBCNXM"

is_hyperos3="false"
case "$MIUI_VER" in
    V170*) is_hyperos3="true" ;;
esac
case "$DISPLAY_ID" in
    OS3*) is_hyperos3="true" ;;
esac

if [ "$is_hyperos3" = "true" ]; then
    # ro.build.display.id（标准 Android）
    $RESETPROP_BIN -n ro.build.display.id "$TARGET_DISPLAY_ID"
    set_prop_safe ro.system.build.display.id "$TARGET_DISPLAY_ID"
    set_prop_safe ro.vendor.build.display.id "$TARGET_DISPLAY_ID"
    set_prop_safe ro.product.build.display.id "$TARGET_DISPLAY_ID"
    set_prop_safe ro.odm.build.display.id "$TARGET_DISPLAY_ID"

    # HyperOS 专有版本属性（设置页面实际读取）
    $RESETPROP_BIN -n ro.mi.os.version.incremental "$TARGET_DISPLAY_ID"
    set_prop_safe ro.mi.os.version.name "OS3.0"
    set_prop_safe ro.mi.os.version.code "17"

    # 增量版本号
    $RESETPROP_BIN -n ro.build.version.incremental "$TARGET_DISPLAY_ID"
    set_prop_safe ro.system.build.version.incremental "$TARGET_DISPLAY_ID"
    set_prop_safe ro.vendor.build.version.incremental "$TARGET_DISPLAY_ID"
    set_prop_safe ro.odm.build.version.incremental "$TARGET_DISPLAY_ID"
    set_prop_safe ro.product.build.version.incremental "$TARGET_DISPLAY_ID"
    set_prop_safe ro.system_ext.build.version.incremental "$TARGET_DISPLAY_ID"
fi
