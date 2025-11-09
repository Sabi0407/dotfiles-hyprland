#!/bin/bash
set -euo pipefail

DEVICE_NAME="asup1204:00-093a:2005-touchpad"
STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/touchpad-state"
SWAYOSD_BIN="${SWAYOSD_CLIENT:-swayosd-client}"
ICON_THEME_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/status"
ICON_ON_PRESET="$ICON_THEME_DIR/touchpad-enabled-symbolic.svg"
ICON_OFF_PRESET="$ICON_THEME_DIR/touchpad-disabled-symbolic.svg"
ICON_ON="${TOUCHPAD_ICON_ON:-$ICON_ON_PRESET}"
ICON_OFF="${TOUCHPAD_ICON_OFF:-$ICON_OFF_PRESET}"
if [ ! -f "$ICON_ON" ]; then
    ICON_ON="input-touchpad"
fi
if [ ! -f "$ICON_OFF" ]; then
    ICON_OFF="touchpad-disabled-symbolic"
fi
ICON_ERR="${TOUCHPAD_ICON_ERROR:-dialog-error}"

osd() {
    local state_text=$1
    local progress=$2
    local icon=$3
    if command -v "$SWAYOSD_BIN" >/dev/null 2>&1; then
        "$SWAYOSD_BIN" \
            --custom-message "Touchpad $state_text" \
            --custom-icon "$icon" \
            --custom-progress "$progress" \
            --custom-progress-text "$state_text" >/dev/null 2>&1 || true
    else
        printf 'Touchpad %s\n' "$state_text"
    fi
}

mkdir -p "$(dirname "$STATE_FILE")"
state=$(cat "$STATE_FILE" 2>/dev/null || echo 1)

if [ "$state" -eq 1 ]; then
    if hyprctl keyword "device[${DEVICE_NAME}]:enabled" 0 >/dev/null; then
        echo 0 > "$STATE_FILE"
        osd "désactivé" 0 "$ICON_OFF"
    else
        osd "erreur (désactivation)" 0 "$ICON_ERR"
    fi
else
    if hyprctl keyword "device[${DEVICE_NAME}]:enabled" 1 >/dev/null; then
        echo 1 > "$STATE_FILE"
        osd "activé" 1 "$ICON_ON"
    else
        osd "erreur (activation)" 0 "$ICON_ERR"
    fi
fi
