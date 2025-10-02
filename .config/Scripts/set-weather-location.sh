#!/bin/bash
# Script pour définir la ville de la météo dans hyprlock
# Usage: ./set-weather-location.sh [ville]

HYPRLOCK_CONFIG="$HOME/.config/hypr/hyprlock.conf"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <ville>"
    echo "Exemple: $0 Paris"
    echo "         $0 Lyon"
    echo "         $0 auto  (pour géolocalisation automatique)"
    exit 1
fi

CITY="$1"

if [ "$CITY" = "auto" ]; then
    # Géolocalisation automatique
    NEW_WEATHER_CMD='location_data=$(curl -s "http://ip-api.com/json/?fields=city,regionName,country" 2>/dev/null); city=$(echo "$location_data" | grep -o "\"city\":\"[^\"]*\"" | cut -d"\"" -f4); if [[ -n "$city" ]]; then location="$city"; weather=$(curl -s "wttr.in/$city?format=%t+%C" 2>/dev/null); if [[ -z "$weather" || "$weather" == *"not found"* ]]; then weather=$(curl -s "wttr.in/?format=%t+%C" 2>/dev/null); fi; else location="Votre ville"; weather=$(curl -s "wttr.in/?format=%t+%C" 2>/dev/null); fi;'
else
    # Ville fixe
    NEW_WEATHER_CMD="location=\"$CITY\"; weather=\$(curl -s \"wttr.in/$CITY?format=%t+%C\" 2>/dev/null);"
fi

# Remplacer la ligne de météo dans hyprlock.conf
sed -i "s|location=.*weather=\$(curl[^;]*;|$NEW_WEATHER_CMD|" "$HYPRLOCK_CONFIG"

echo "✅ Ville météo définie sur: $CITY"
notify-send "Météo" "Ville définie sur: $CITY" -t 2000
