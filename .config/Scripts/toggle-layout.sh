#!/bin/bash
# Script pour basculer entre les layouts Dwindle et Master

CURRENT_LAYOUT=$(hyprctl getoption general:layout | grep "^layout:" | awk '{print $2}')

if [ "$CURRENT_LAYOUT" = "dwindle" ]; then
    # Passer à Master
    hyprctl keyword general:layout master
    notify-send "Layout" "Master (Fenêtre principale)" -i view-restore -t 2000
else
    # Passer à Dwindle
    hyprctl keyword general:layout dwindle
    notify-send "Layout" "Dwindle (Tiling flexible)" -i view-grid -t 2000
fi
