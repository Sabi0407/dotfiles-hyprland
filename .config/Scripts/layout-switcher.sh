#!/bin/bash
# Script pour basculer entre dwindle et scrolling dans le fichier de config
# Usage: layout-switcher.sh

CONFIG_FILE="$HOME/.config/hypr/configs/look.conf"

# Vérifier le layout actuel dans le fichier
current_layout=$(grep "layout = " "$CONFIG_FILE" | grep -o "dwindle\|scrolling")

if [[ "$current_layout" == "dwindle" ]]; then
    # Changer vers scrolling
    sed -i 's/layout = dwindle/layout = scrolling/' "$CONFIG_FILE"
    hyprctl reload
    notify-send "Layout Switcher" " Basculé vers Scrolling" -t 2000
    echo "Layout changé vers: scrolling"
else
    # Changer vers dwindle
    sed -i 's/layout = scrolling/layout = dwindle/' "$CONFIG_FILE"
    hyprctl reload
    notify-send "Layout Switcher" " Basculé vers Dwindle" -t 2000
    echo "Layout changé vers: dwindle"
fi
