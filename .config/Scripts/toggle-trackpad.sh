#!/bin/bash
# Script pour activer/désactiver le trackpad
# Usage: toggle-trackpad.sh

# Fichier de statut pour se souvenir de l'état
STATUS_FILE="/tmp/trackpad_disabled"

# Trouver le nom du trackpad
TRACKPAD=$(hyprctl devices | grep -i "touchpad" | head -1 | awk '{print $1}')

if [ -z "$TRACKPAD" ]; then
    echo "❌ Aucun trackpad trouvé"
    notify-send "Trackpad" "Aucun trackpad détecté" -i input-touchpad
    exit 1
fi

echo "🔍 Trackpad détecté: $TRACKPAD"

# Vérifier si le trackpad est désactivé (via fichier de statut)
if [ -f "$STATUS_FILE" ]; then
    # Trackpad désactivé, l'activer
    rm "$STATUS_FILE"
    # Utiliser hyprctl pour réactiver
    hyprctl keyword "device[$TRACKPAD]:enabled" true
    echo "✅ Trackpad activé"
    notify-send "Trackpad" "Trackpad activé" -i input-touchpad
else
    # Trackpad activé, le désactiver
    touch "$STATUS_FILE"
    # Utiliser hyprctl pour désactiver
    hyprctl keyword "device[$TRACKPAD]:enabled" false
    echo "🚫 Trackpad désactivé"
    notify-send "Trackpad" "Trackpad désactivé" -i input-touchpad-off
fi
