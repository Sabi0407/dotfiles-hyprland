#!/bin/bash
set -euo pipefail

DEVICE_NAME="asup1204:00-093a:2005-touchpad"
STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/touchpad-state"
SWAYOSD_BIN="${SWAYOSD_CLIENT:-swayosd-client}"
USER_ICON_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/status"
CUSTOM_ICON_ON="trackpad_on"
CUSTOM_ICON_OFF="trackpad_off"

ICON_ON_DEFAULT="input-touchpad-symbolic"
ICON_OFF_DEFAULT="touchpad-disabled-symbolic"

if [ -f "$USER_ICON_DIR/${CUSTOM_ICON_ON}.svg" ]; then
    ICON_ON_DEFAULT="$CUSTOM_ICON_ON"
fi

if [ -f "$USER_ICON_DIR/${CUSTOM_ICON_OFF}.svg" ]; then
    ICON_OFF_DEFAULT="$CUSTOM_ICON_OFF"
fi

ICON_ON="${TOUCHPAD_ICON_ON:-$ICON_ON_DEFAULT}"
ICON_OFF="${TOUCHPAD_ICON_OFF:-$ICON_OFF_DEFAULT}"
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
