#!/bin/sh
OVERRIDE_FILE="$HOME/.cache/auto-backlight.force"
HOUR=$(date +%H)

if [ -f "$OVERRIDE_FILE" ]; then
  exit 0
fi

if [ "$HOUR" -ge 18 ] || [ "$HOUR" -lt 6 ]; then
  /home/sabi/.config/Scripts/auto-backlight.sh maybe_off
fi
