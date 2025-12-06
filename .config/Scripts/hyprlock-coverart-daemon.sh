#!/bin/bash
################################################################################
# Daemon persistant : met à jour la cover art si hyprlock est actif
################################################################################

COVER_SCRIPT="/home/sabi/.config/Scripts/hyprlock-coverart.sh"
SLEEP_ACTIVE=2
SLEEP_IDLE=3

while true; do
    if pgrep -x hyprlock >/dev/null; then
        "${COVER_SCRIPT}" >/dev/null 2>&1
        sleep "$SLEEP_ACTIVE"
    else
        sleep "$SLEEP_IDLE"
    fi
done

