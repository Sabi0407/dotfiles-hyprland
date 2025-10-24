#!/bin/sh

STATE_FILE="$HOME/.cache/mic_status_waybar_state"

STATE=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
NOW=$(date +%s)

if [ -f "$STATE_FILE" ]; then
    read LAST_STATE LAST_TIME < "$STATE_FILE"
else
    LAST_STATE=""
    LAST_TIME=0
fi

if [ "$STATE" != "$LAST_STATE" ]; then
    echo "$STATE $NOW" > "$STATE_FILE"
    SHOW=1
else
    DELTA=$((NOW - LAST_TIME))
    if [ $DELTA -le 5 ]; then
        SHOW=1
    else
        SHOW=0
    fi
fi

if [ $SHOW -eq 1 ]; then
    if [ "$STATE" = "no" ]; then
        echo '{"text": "󰍬", "tooltip": "Microphone actif", "class": "active"}'
    else
        echo '{"text": "󰍭<span foreground=\"red\"><sup></sup></span>", "tooltip": "Microphone coupé", "class": "muted"}'
    fi
else
    echo ''
fi 
