#!/bin/bash

# Script simple pour piloter le rétroéclairage clavier Asus/brightnessctl

KBD_DEVICE="asus::kbd_backlight"
STATE_FILE="/tmp/auto-backlight-state"

load_state() {
    LAST_LEVEL=0
    MANUAL_OFF=0
    if [[ -f "$STATE_FILE" ]]; then
        read -r LAST_LEVEL MANUAL_OFF <"$STATE_FILE" 2>/dev/null || true
        [[ "$LAST_LEVEL" =~ ^[0-9]+$ ]] || LAST_LEVEL=0
        [[ "$MANUAL_OFF" =~ ^[0-9]+$ ]] || MANUAL_OFF=0
    fi
}

save_state() {
    printf '%s %s\n' "$LAST_LEVEL" "$MANUAL_OFF" >"$STATE_FILE"
}

get_current() {
    brightnessctl -d "$KBD_DEVICE" get 2>/dev/null || echo "0"
}

cycle_brightness() {
    local current=$(get_current)
    local next_level
    case "$current" in
        0) next_level=1 ;;
        1) next_level=2 ;;
        2|3|*) next_level=0 ;;
    esac
    brightnessctl -d "$KBD_DEVICE" set "$next_level" >/dev/null 2>&1
    echo "Rétroéclairage réglé sur $next_level"
    load_state
    if (( next_level > 0 )); then
        LAST_LEVEL=$next_level
        MANUAL_OFF=0
        save_state
    else
        MANUAL_OFF=1
        save_state
    fi
}

# Commandes utilisateur -------------------------------------------------------
case "${1:-status}" in
    off|lock)
        brightnessctl -d "$KBD_DEVICE" set 0 >/dev/null 2>&1
        echo "Rétroéclairage éteint (off)"
        load_state
        MANUAL_OFF=1
        save_state
        ;;
    on|wake|unlock)
        load_state
        local current=$(get_current)
        if [[ "${AUTO_BACKLIGHT_FORCE:-0}" == "1" ]]; then
            LAST_LEVEL=${LAST_LEVEL:-1}
            (( LAST_LEVEL == 0 )) && LAST_LEVEL=1
            MANUAL_OFF=0
            save_state
            brightnessctl -d "$KBD_DEVICE" set "$LAST_LEVEL" >/dev/null 2>&1
            echo "Rétroéclairage activé ($LAST_LEVEL)"
        elif (( MANUAL_OFF == 1 )); then
            echo "Rétroéclairage laissé éteint"
        elif (( current == 0 )) && (( LAST_LEVEL > 0 )); then
            brightnessctl -d "$KBD_DEVICE" set "$LAST_LEVEL" >/dev/null 2>&1
            echo "Rétroéclairage restauré ($LAST_LEVEL)"
        fi
        ;;
    maybe_off)
        brightnessctl -d "$KBD_DEVICE" set 0 >/dev/null 2>&1
        echo "Extinction automatique (maybe_off)"
        load_state
        MANUAL_OFF=0
        save_state
        ;;
    cycle)
        cycle_brightness
        ;;
    restore)
        load_state
        if (( MANUAL_OFF == 0 )) && (( LAST_LEVEL > 0 )); then
            brightnessctl -d "$KBD_DEVICE" set "$LAST_LEVEL" >/dev/null 2>&1
            echo "Rétroéclairage restauré ($LAST_LEVEL)"
        fi
        ;;
    status)
        local current=$(get_current)
        if (( current > 0 )); then
            echo "ON ($current)"
        else
            echo "OFF"
        fi
        ;;
    *)
        cycle_brightness
        ;;
esac
