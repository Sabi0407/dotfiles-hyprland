#!/bin/bash
HOUR=$(date +%H)
if [ "$HOUR" -ge 19 ] || [ "$HOUR" -lt 9 ]; then
    ~/.config/Scripts/keyboard_backlight_waybar.sh
else
    exit 0
fi 