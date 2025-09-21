#!/bin/bash

# Script simplifié pour gérer le rétroéclairage du clavier
KBD_DEVICE="asus::kbd_backlight"
STATE_FILE="/tmp/kbd_backlight_state"

case "${1:-}" in
    "off")
        # Sauvegarder l'état actuel et éteindre
        current=$(brightnessctl -d "$KBD_DEVICE" get 2>/dev/null || echo "0")
        if [ "$current" -gt 0 ]; then
            echo "$current" > "$STATE_FILE"
            brightnessctl -d "$KBD_DEVICE" set 0 >/dev/null 2>&1
        fi
        ;;
    "on")
        # Restaurer l'état précédent
        if [ -f "$STATE_FILE" ]; then
            saved_level=$(cat "$STATE_FILE")
            brightnessctl -d "$KBD_DEVICE" set "$saved_level" >/dev/null 2>&1
            rm -f "$STATE_FILE"
        fi
        ;;
    "status")
        current=$(brightnessctl -d "$KBD_DEVICE" get 2>/dev/null || echo "0")
        [ "$current" -gt 0 ] && echo "on" || echo "off"
        ;;
    *)
        echo "Usage: $0 {off|on|status}"
        exit 1
        ;;
esac 