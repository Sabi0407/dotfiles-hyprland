#!/bin/bash

# Script simplifié de gestion du rétroéclairage clavier
# Activation automatique 19h-8h, extinction 8h-19h

KBD_DEVICE="asus::kbd_backlight"

# Vérifier si on est dans les heures nocturnes (19h-8h)
is_night_hours() {
    local hour=$(date +%H)
    [ "$hour" -ge 19 ] || [ "$hour" -lt 8 ]
}

# Obtenir le niveau actuel
get_current() {
    brightnessctl -d "$KBD_DEVICE" get 2>/dev/null || echo "0"
}

# Obtenir le niveau maximum
get_max() {
    brightnessctl -d "$KBD_DEVICE" max 2>/dev/null || echo "3"
}

# Contrôles manuels
manual_up() {
    local current=$(get_current)
    local max=$(get_max)
    local new_level=$((current + 1))
    [ $new_level -gt $max ] && new_level=$max
    brightnessctl -d "$KBD_DEVICE" set "$new_level" >/dev/null 2>&1
    echo "Niveau: $new_level"
}

manual_down() {
    local current=$(get_current)
    local new_level=$((current - 1))
    [ $new_level -lt 0 ] && new_level=0
    brightnessctl -d "$KBD_DEVICE" set "$new_level" >/dev/null 2>&1
    echo "Niveau: $new_level"
}

manual_toggle() {
    local current=$(get_current)
    if [ "$current" -eq 0 ]; then
        brightnessctl -d "$KBD_DEVICE" set 1 >/dev/null 2>&1
        echo "Allumé (1)"
    else
        brightnessctl -d "$KBD_DEVICE" set 0 >/dev/null 2>&1
        echo "Éteint"
    fi
}

# Gestion horaire automatique
schedule_check() {
    local current=$(get_current)
    local hour=$(date +%H)

    if is_night_hours; then
        # Heures nocturnes : activer si éteint
        if [ "$current" -eq 0 ]; then
            brightnessctl -d "$KBD_DEVICE" set 1 >/dev/null 2>&1
            echo "Activation nocturne (${hour}h)"
        fi
    else
        # Heures diurnes : éteindre si allumé
        if [ "$current" -gt 0 ]; then
            brightnessctl -d "$KBD_DEVICE" set 0 >/dev/null 2>&1
            echo "Extinction diurne (${hour}h)"
        fi
    fi
}

# Vérifier le statut
status() {
    local current=$(get_current)
    local hour=$(date +%H)
    local period="jour"

    is_night_hours && period="nuit"

    if [ "$current" -gt 0 ]; then
        echo "ON ($current) - ${hour}h ($period)"
    else
        echo "OFF - ${hour}h ($period)"
    fi
}

# Actions selon le paramètre
case "${1:-status}" in
    "up")
        manual_up
        ;;
    "down")
        manual_down
        ;;
    "toggle")
        manual_toggle
        ;;
    "schedule"|"check")
        schedule_check
        ;;
    "status"|*)
        status
        ;;
esac
