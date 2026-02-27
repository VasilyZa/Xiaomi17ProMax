#!/system/bin/sh
# ============================================
# Xiaomi 17 Pro Max Device Spoofer
# customize.sh - 模块安装脚本（仅安装时执行一次）
# 支持 Magisk / KernelSU / APatch
# ============================================

# 可用环境变量:
# Magisk:    MAGISK_VER, MAGISK_VER_CODE
# KernelSU:  KSU, KSU_VER, KSU_VER_CODE, KSU_KERNEL_VER_CODE
# APatch:    APATCH, APATCH_VER, APATCH_VER_CODE
# 通用:      BOOTMODE, MODPATH, TMPDIR, ZIPFILE, ARCH, IS64BIT, API

ui_print ""
ui_print "╔══════════════════════════════════════╗"
ui_print "║  Xiaomi 17 Pro Max Device Spoofer    ║"
ui_print "║  适配 MIUI 12 ~ HyperOS 3           ║"
ui_print "║  支持 Magisk / KernelSU / APatch     ║"
ui_print "║  版本: v1.1.0                        ║"
ui_print "╚══════════════════════════════════════╝"
ui_print ""

# ============================================
# Root 方案检测
# ============================================

ROOT_SOLUTION="Unknown"

if [ -n "$KSU" ] && [ "$KSU" = "true" ]; then
    ROOT_SOLUTION="KernelSU"
    ROOT_VER="${KSU_VER:-unknown} (${KSU_VER_CODE:-unknown})"
    ROOT_KERNEL_VER="${KSU_KERNEL_VER_CODE:-unknown}"
    ui_print "- Root 方案: KernelSU"
    ui_print "- KSU 版本: $ROOT_VER"
    ui_print "- KSU 内核版本: $ROOT_KERNEL_VER"
elif [ -n "$APATCH" ] && [ "$APATCH" = "true" ]; then
    ROOT_SOLUTION="APatch"
    ROOT_VER="${APATCH_VER:-unknown} (${APATCH_VER_CODE:-unknown})"
    ui_print "- Root 方案: APatch"
    ui_print "- APatch 版本: $ROOT_VER"
elif [ -n "$MAGISK_VER" ]; then
    ROOT_SOLUTION="Magisk"
    ROOT_VER="$MAGISK_VER ($MAGISK_VER_CODE)"
    ui_print "- Root 方案: Magisk"
    ui_print "- Magisk 版本: $ROOT_VER"
else
    ui_print "- Root 方案: 未知 (将尝试继续安装)"
fi

ui_print "- 当前 Android API: $API"
ui_print "- 设备架构: $ARCH"

# ============================================
# resetprop 可用性检查
# ============================================

RESETPROP_BIN=""

if command -v resetprop >/dev/null 2>&1; then
    RESETPROP_BIN="resetprop"
elif command -v magisk >/dev/null 2>&1; then
    RESETPROP_BIN="magisk resetprop"
elif [ -f /data/adb/magisk/magisk64 ]; then
    RESETPROP_BIN="/data/adb/magisk/magisk64 resetprop"
elif [ -f /data/adb/magisk/magisk32 ]; then
    RESETPROP_BIN="/data/adb/magisk/magisk32 resetprop"
elif [ -f /data/adb/ksu/bin/resetprop ]; then
    RESETPROP_BIN="/data/adb/ksu/bin/resetprop"
elif [ -f /data/adb/ap/bin/resetprop ]; then
    RESETPROP_BIN="/data/adb/ap/bin/resetprop"
fi

if [ -n "$RESETPROP_BIN" ]; then
    ui_print "- resetprop: 可用 ($RESETPROP_BIN)"
else
    ui_print "! 警告: 未找到 resetprop，脚本将在启动时重新检测"
fi

# ============================================
# MIUI/HyperOS 检测
# ============================================

MIUI_VERSION=$(getprop ro.miui.ui.version.name)
if [ -n "$MIUI_VERSION" ]; then
    ui_print "- 检测到 MIUI/HyperOS 版本: $MIUI_VERSION"
else
    ui_print "- 未检测到 MIUI/HyperOS，模块仍可工作但部分功能可能受限"
fi

# ============================================
# 当前设备信息
# ============================================

CURRENT_MODEL=$(getprop ro.product.model)
CURRENT_MARKET=$(getprop ro.product.marketname)
CURRENT_DEVICE=$(getprop ro.product.device)
ui_print "- 当前设备型号: $CURRENT_MODEL"
ui_print "- 当前营销名称: $CURRENT_MARKET"
ui_print "- 当前设备代号: $CURRENT_DEVICE"

ui_print ""
ui_print "- 目标伪装型号: 2509FPN0BC"
ui_print "- 目标营销名称: Xiaomi 17 Pro Max"
ui_print "- 目标设备代号: popsicle"

# ============================================
# 最低 API 检查
# ============================================

if [ "$API" -lt 29 ]; then
    ui_print ""
    ui_print "! 警告: 当前 Android 版本低于 10"
    ui_print "! 部分分区属性修改可能不生效"
    ui_print "! 建议在 Android 10+ 设备上使用"
    ui_print ""
fi

# ============================================
# 设置文件权限
# ============================================

ui_print "- 设置文件权限..."
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/post-fs-data.sh 0 0 0755
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/uninstall.sh 0 0 0755

ui_print ""
ui_print "- 安装完成！重启后生效。"
ui_print "- 如需恢复，请在 ${ROOT_SOLUTION} 中禁用或卸载本模块后重启。"
ui_print ""
