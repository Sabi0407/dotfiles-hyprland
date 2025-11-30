#!/bin/bash
set -euo pipefail

DEVICE_NAME="asup1204:00-093a:2005-touchpad"
STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/touchpad-state"
SWAYOSD_BIN="${SWAYOSD_CLIENT:-swayosd-client}"
USER_ICON_DIRS=(
    "${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/symbolic/status"
    "${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/status"
)
CUSTOM_ICON_ON="trackpad-on-symbolic"
CUSTOM_ICON_OFF="trackpad-off-symbolic"

ICON_ON_DEFAULT="input-touchpad-symbolic"
ICON_OFF_DEFAULT="touchpad-disabled-symbolic"

icon_exists() {
    local name=$1
    for dir in "${USER_ICON_DIRS[@]}"; do
        if [ -f "$dir/${name}.svg" ]; then
            return 0
        fi
    done
    return 1
}

if icon_exists "$CUSTOM_ICON_ON"; then
    ICON_ON_DEFAULT="$CUSTOM_ICON_ON"
fi

if icon_exists "$CUSTOM_ICON_OFF"; then
    ICON_OFF_DEFAULT="$CUSTOM_ICON_OFF"
fi

ICON_ON="${TOUCHPAD_ICON_ON:-$ICON_ON_DEFAULT}"
ICON_OFF="${TOUCHPAD_ICON_OFF:-$ICON_OFF_DEFAULT}"
ICON_ERR="${TOUCHPAD_ICON_ERROR:-dialog-error}"

osd() {
    local state_text=$1
    local icon=$2
    if command -v "$SWAYOSD_BIN" >/dev/null 2>&1; then
        "$SWAYOSD_BIN" \
            --custom-icon "$icon" \
            --custom-message "Touchpad $state_text" >/dev/null 2>&1 || true
    else
        printf 'Touchpad %s\n' "$state_text"
    fi
}

mkdir -p "$(dirname "$STATE_FILE")"
state=$(cat "$STATE_FILE" 2>/dev/null || echo 1)

if [ "$state" -eq 1 ]; then
    if hyprctl keyword "device[${DEVICE_NAME}]:enabled" 0 >/dev/null; then
        echo 0 > "$STATE_FILE"
        osd "désactivé" "$ICON_OFF"
    else
        osd "erreur (désactivation)" 0 "$ICON_ERR"
    fi
else
    if hyprctl keyword "device[${DEVICE_NAME}]:enabled" 1 >/dev/null; then
        echo 1 > "$STATE_FILE"
        osd "activé" "$ICON_ON"
    else
        osd "erreur (activation)" 0 "$ICON_ERR"
    fi
fi
