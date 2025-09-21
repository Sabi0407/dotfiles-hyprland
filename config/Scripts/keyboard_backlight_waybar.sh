#!/bin/bash

# Script simplifié pour Waybar - retourne juste le pourcentage
KBD_DEVICE="/sys/class/leds/asus::kbd_backlight"

if [ -f "$KBD_DEVICE/brightness" ]; then
    MAX_BRIGHTNESS=$(cat "$KBD_DEVICE/max_brightness" 2>/dev/null || echo "3")
    CURRENT_BRIGHTNESS=$(cat "$KBD_DEVICE/brightness" 2>/dev/null || echo "0")
    PERCENT=$((CURRENT_BRIGHTNESS * 100 / MAX_BRIGHTNESS))
    echo "$PERCENT"
else
    echo "0"
fi 