#!/bin/sh
STATE=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
if [ "$STATE" = "yes" ]; then
    pactl set-source-mute @DEFAULT_SOURCE@ 0
    notify-send "Microphone activé" "Le micro est maintenant actif." -i microphone-sensitivity-high
else
    pactl set-source-mute @DEFAULT_SOURCE@ 1
    notify-send "Microphone coupé" "Le micro est maintenant coupé." -i microphone-sensitivity-muted
fi 