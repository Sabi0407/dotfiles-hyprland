#!/bin/bash

# Script de démarrage : ne restaure le wallpaper statique
# que si le dernier mode n'était pas un fond animé mpvpaper.

STATE_FILE="$HOME/.cache/mpvpaper-wallpaper/state"
if [ -f "$STATE_FILE" ]; then
    mode=$(<"$STATE_FILE")
    if [ "$mode" = "video" ]; then
        # mpvpaper se chargera via mpvpaper-wallpaper.sh resume
        exit 0
    fi
fi

exec "$HOME/.config/Scripts/wallpaper-manager.sh" restore "$@"
