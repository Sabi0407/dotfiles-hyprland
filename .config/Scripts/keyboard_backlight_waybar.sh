#!/bin/bash

# Script pour Waybar avec logique temporelle intégrée
# Affiche le rétroéclairage seulement entre 19h et 9h
KBD_DEVICE="/sys/class/leds/asus::kbd_backlight"

# Vérifier l'heure (affichage seulement le soir/nuit)
HOUR=$(date +%H)
if [ "$HOUR" -lt 19 ] && [ "$HOUR" -ge 9 ]; then
    # Journée : ne pas afficher
    exit 0
fi

# Soir/Nuit : afficher le pourcentage
if [ -f "$KBD_DEVICE/brightness" ]; then
    MAX_BRIGHTNESS=$(cat "$KBD_DEVICE/max_brightness" 2>/dev/null || echo "3")
    CURRENT_BRIGHTNESS=$(cat "$KBD_DEVICE/brightness" 2>/dev/null || echo "0")
    PERCENT=$((CURRENT_BRIGHTNESS * 100 / MAX_BRIGHTNESS))
    echo "$PERCENT"
else
    echo "0"
fi 