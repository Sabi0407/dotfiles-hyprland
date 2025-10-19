#!/bin/bash

# Script pour notifier l'utilisateur lorsque la batterie atteint un niveau critique

BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT0/capacity)
BATTERY_STATUS=$(cat /sys/class/power_supply/BAT0/status)

WARNING_LEVEL=15

if [ "$BATTERY_STATUS" = "Discharging" ] && [ "$BATTERY_LEVEL" -le "$WARNING_LEVEL" ]; then
    dunstify -u critical "Batterie faible !" "Votre batterie est à ${BATTERY_LEVEL}%." -i "battery-low"
fi