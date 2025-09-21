#!/bin/bash

# Keyboard backlight control script for Waybar
# Utilise brightnessctl pour gérer les permissions automatiquement

# Obtenir le niveau actuel
get_brightness() {
    brightnessctl -d asus::kbd_backlight get 2>/dev/null || echo "0"
}

# Régler le niveau
set_brightness() {
    local level=$1
    brightnessctl -d asus::kbd_backlight set "$level%" >/dev/null 2>&1
}

# Cycle entre 0%, 33%, 66%, 100%
cycle_brightness() {
    local current=$(get_brightness)
    local max=$(brightnessctl -d asus::kbd_backlight max 2>/dev/null || echo "100")
    local current_percent=$((current * 100 / max))
    local levels=(0 33 66 100)
    local next_level=0
    for i in "${!levels[@]}"; do
        if [ "$current_percent" -le "${levels[$i]}" ]; then
            next_level=${levels[$((i + 1))]}
            if [ -z "$next_level" ]; then
                next_level=${levels[0]}
            fi
            break
        fi
    done
    set_brightness $next_level
}

case "${1:-}" in
    "up")
        current=$(get_brightness)
        max=$(brightnessctl -d asus::kbd_backlight max 2>/dev/null || echo "100")
        new_level=$((current + 25))
        if [ $new_level -gt $max ]; then
            new_level=$max
        fi
        set_brightness $new_level
        ;;
    "down")
        current=$(get_brightness)
        new_level=$((current - 25))
        if [ $new_level -lt 0 ]; then
            new_level=0
        fi
        set_brightness $new_level
        ;;
    "toggle"|"cycle")
        cycle_brightness
        ;;
    *)
        current=$(get_brightness)
        max=$(brightnessctl -d asus::kbd_backlight max 2>/dev/null || echo "100")
        if [ "$max" -gt 0 ]; then
            echo $((current * 100 / max))
        else
            echo "0"
        fi
        ;;
esac 