#!/bin/bash

# Script simple pour piloter le rétroéclairage clavier Asus/brightnessctl
NIGHT_BEGIN=18   # début d'activation automatique (18h)
NIGHT_END=4      # fin d'activation automatique (04h)

KBD_DEVICE="asus::kbd_backlight"

is_night_hours() {
    local hour=$(date +%H)
    if (( NIGHT_END > NIGHT_BEGIN )); then
        (( hour >= NIGHT_BEGIN && hour < NIGHT_END ))
    else
        (( hour >= NIGHT_BEGIN || hour < NIGHT_END ))
    fi
}

get_current() {
    brightnessctl -d "$KBD_DEVICE" get 2>/dev/null || echo "0"
}

# Commandes utilisateur -------------------------------------------------------
manual_up() {
    local current=$(get_current)
    local max=$(brightnessctl -d "$KBD_DEVICE" max 2>/dev/null || echo "3")
    local new_level=$((current + 1))
    (( new_level > max )) && new_level=$max
    brightnessctl -d "$KBD_DEVICE" set "$new_level" >/dev/null 2>&1
    echo "Niveau: $new_level"
}

manual_down() {
    local current=$(get_current)
    local new_level=$((current - 1))
    (( new_level < 0 )) && new_level=0
    brightnessctl -d "$KBD_DEVICE" set "$new_level" >/dev/null 2>&1
    echo "Niveau: $new_level"
}

manual_toggle() {
    local current=$(get_current)
    if (( current == 0 )); then
        brightnessctl -d "$KBD_DEVICE" set 1 >/dev/null 2>&1
        echo "Allumé (1)"
    else
        brightnessctl -d "$KBD_DEVICE" set 0 >/dev/null 2>&1
        echo "Éteint"
    fi
}

status() {
    local current=$(get_current)
    if (( current > 0 )); then
        echo "ON ($current)"
    else
        echo "OFF"
    fi
}

case "${1:-status}" in
    up) manual_up ;;
    down) manual_down ;;
    toggle) manual_toggle ;;
    off|lock)
        brightnessctl -d "$KBD_DEVICE" set 0 >/dev/null 2>&1
        echo "Rétroéclairage éteint (off)"
        ;;
    on|wake|unlock)
        if is_night_hours; then
            brightnessctl -d "$KBD_DEVICE" set 1 >/dev/null 2>&1
            echo "Rétroéclairage activé (1)"
        else
            echo "Hors plage nocturne (19h-04h) : rétroéclairage laissé éteint"
        fi
        ;;
    schedule|check)
        if is_night_hours; then
            brightnessctl -d "$KBD_DEVICE" set 1 >/dev/null 2>&1
            echo "(schedule) activation automatique"
        else
            brightnessctl -d "$KBD_DEVICE" set 0 >/dev/null 2>&1
            echo "(schedule) extinction automatique"
        fi
        ;;
    status|*) status ;;
esac
