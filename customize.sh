#!/system/bin/sh
# ============================================
# DeviceSpoofX
# customize.sh - 模块安装脚本
# 支持 Magisk / KernelSU / APatch
# ============================================

# ============================================
# 扫描并选择配置文件
# ============================================

ui_print ""
ui_print "╔══════════════════════════════════════╗"
ui_print "║        DeviceSpoofX v2.0.0           ║"
ui_print "║  适配 MIUI 12 ~ HyperOS 3           ║"
ui_print "║  支持 Magisk / KernelSU / APatch     ║"
ui_print "╚══════════════════════════════════════╝"
ui_print ""

PROFILE_DIR="$MODPATH/profiles"
PROFILE_COUNT=0
PROFILE_KEYS=""
PROFILE_NAMES=""

ui_print "- 正在扫描配置文件..."

for conf in "$PROFILE_DIR"/*.conf; do
    if [ -f "$conf" ]; then
        key=$(basename "$conf" .conf)
        PROFILE_NAME=$(grep "^PROFILE_NAME=" "$conf" | cut -d'=' -f2- | tr -d '"')
        TARGET_MODEL=$(grep "^TARGET_MODEL=" "$conf" | cut -d'=' -f2- | tr -d '"')
        PROFILE_COUNT=$((PROFILE_COUNT + 1))
        PROFILE_KEYS="$PROFILE_KEYS|$key"
        PROFILE_NAMES="$PROFILE_NAMES|$PROFILE_NAME|$TARGET_MODEL"
    fi
done

PROFILE_KEYS=$(echo "$PROFILE_KEYS" | cut -c2-)
PROFILE_NAMES=$(echo "$PROFILE_NAMES" | cut -c2-)

if [ $PROFILE_COUNT -eq 0 ]; then
    ui_print "! 错误: 未找到任何配置文件"
    abort "! 安装中止"
fi

ui_print "- 找到 $PROFILE_COUNT 个配置文件"
ui_print ""

if [ $PROFILE_COUNT -eq 1 ]; then
    PROFILE_KEY="$PROFILE_KEYS"
    . "$MODPATH/profiles/${PROFILE_KEY}.conf"
    ui_print "- 只有一个配置，自动选择: $PROFILE_NAME"
else
    ui_print "请选择要伪装的机型:"
    ui_print ""
    
    INDEX=1
    
    while true; do
        OLDIFS="$IFS"
        IFS='|'
        set -- $PROFILE_KEYS
        CURRENT_KEY=$(eval echo \${$INDEX})
        IFS='|'
        set -- $PROFILE_NAMES
        CURRENT_NAME=$(eval echo \${$((INDEX * 2 - 1))})
        CURRENT_MODEL=$(eval echo \${$((INDEX * 2))})
        IFS="$OLDIFS"
        
        CONF="$MODPATH/profiles/${CURRENT_KEY}.conf"
        TARGET_DEVICE=$(grep "^TARGET_DEVICE=" "$CONF" | cut -d'=' -f2- | tr -d '"')
        
        ui_print "=================================="
        ui_print "[$INDEX/$PROFILE_COUNT]"
        ui_print "  $CURRENT_NAME"
        ui_print "  型号: $CURRENT_MODEL"
        ui_print "  代号: $TARGET_DEVICE"
        ui_print "=================================="
        
        ui_print "音量上: 浏览下一项"
        ui_print "音量下: 确认此项"
        
        chooseport 0
        
        case $chosen in
            0)
                INDEX=$((INDEX + 1))
                if [ $INDEX -gt $PROFILE_COUNT ]; then
                    INDEX=1
                fi
                ;;
            1)
                break
                ;;
        esac
    done
    
    PROFILE_KEY=$CURRENT_KEY
    . "$MODPATH/profiles/${PROFILE_KEY}.conf"
    
    ui_print ""
    ui_print "- 已选择: $PROFILE_NAME"
fi

echo "$PROFILE_KEY" > "$MODPATH/current_profile"
ui_print ""

# ============================================
# 升级: 强制清理旧版文件
# ============================================

OLD_MODULE="/data/adb/modules/DeviceSpoofX"
OLD_MODULE_LEGACY="/data/adb/modules/Xiaomi17ProMax"

# 清理当前版本旧文件
if [ -d "$OLD_MODULE" ]; then
    ui_print "- 检测到旧版模块，清理旧文件..."
    rm -rf "$OLD_MODULE/webroot" 2>/dev/null
    rm -rf "$OLD_MODULE/system" 2>/dev/null
    rm -f "$OLD_MODULE/is_hyperos3" 2>/dev/null
    ui_print "  旧版文件已清理"
fi

# 清理旧名称模块残留
if [ -d "$OLD_MODULE_LEGACY" ]; then
    ui_print "- 检测到旧版 Xiaomi17ProMax 模块，清理..."
    rm -rf "$OLD_MODULE_LEGACY" 2>/dev/null
    ui_print "  旧版模块已清理"
fi

# ============================================
# Root 方案检测
# ============================================

ROOT_SOLUTION="Unknown"

if [ -n "$KSU" ] && [ "$KSU" = "true" ]; then
    ROOT_SOLUTION="KernelSU"
    ui_print "- Root 方案: KernelSU ${KSU_VER:-unknown}"
elif [ -n "$APATCH" ] && [ "$APATCH" = "true" ]; then
    ROOT_SOLUTION="APatch"
    ui_print "- Root 方案: APatch ${APATCH_VER:-unknown}"
elif [ -n "$MAGISK_VER" ]; then
    ROOT_SOLUTION="Magisk"
    ui_print "- Root 方案: Magisk $MAGISK_VER"
else
    ui_print "- Root 方案: 未知"
fi

ui_print "- Android API: $API"
ui_print "- 架构: $ARCH"

# ============================================
# 当前设备信息
# ============================================

CURRENT_MODEL=$(getprop ro.product.model)
CURRENT_MARKET=$(getprop ro.product.marketname)
CURRENT_DEVICE=$(getprop ro.product.device)
ui_print "- 当前型号: $CURRENT_MODEL"
ui_print "- 当前营销名: $CURRENT_MARKET"
ui_print "- 当前代号: $CURRENT_DEVICE"
ui_print ""
ui_print "- 目标型号: $TARGET_MODEL"
ui_print "- 目标营销名: $TARGET_MARKETNAME"
ui_print "- 目标代号: $TARGET_DEVICE"
ui_print ""

# ============================================
# HyperOS 3 版本号检测
# ============================================

MIUI_VER=$(getprop ro.miui.ui.version.name)
DISPLAY_ID=$(getprop ro.build.display.id)
MI_OS_INC=$(getprop ro.mi.os.version.incremental)
BUILD_INC=$(getprop ro.build.version.incremental)

is_hyperos3="false"
case "$MIUI_VER" in V170*) is_hyperos3="true" ;; esac
case "$DISPLAY_ID" in OS3*|3.*) is_hyperos3="true" ;; esac
case "$MI_OS_INC" in OS3*|3.*) is_hyperos3="true" ;; esac
case "$BUILD_INC" in OS3*|3.*) is_hyperos3="true" ;; esac

if [ "$is_hyperos3" = "true" ]; then
    ui_print "- 检测到 HyperOS 3，将在启动时修改版本号"
    echo "true" > "$MODPATH/is_hyperos3"
else
    ui_print "- 未检测到 HyperOS 3，跳过版本号修改"
fi

# ============================================
# 设置权限
# ============================================

ui_print ""
ui_print "- 设置文件权限..."
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/post-fs-data.sh 0 0 0755
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/uninstall.sh 0 0 0755

ui_print ""
ui_print "- 安装完成！重启后生效。"
ui_print "- 属性将通过 resetprop 在每次启动时注入。"
ui_print "- 如需恢复，请在 ${ROOT_SOLUTION} 中卸载本模块后重启。"
ui_print ""
