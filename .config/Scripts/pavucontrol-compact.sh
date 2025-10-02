#!/bin/bash
# Script pour lancer pavucontrol en mode compact et centré
# Usage: pavucontrol-compact.sh

# Vérifier si pavucontrol est déjà ouvert
if pgrep -x "pavucontrol" > /dev/null; then
    # Si ouvert, le fermer
    pkill pavucontrol
    echo "🔇 Pavucontrol fermé"
else
    # Si fermé, l'ouvrir
    pavucontrol &
    echo "🔊 Pavucontrol ouvert en mode compact"
    
    # Attendre que la fenêtre soit créée puis appliquer les règles
    sleep 0.5
    
    # Forcer la taille et position avec hyprctl si nécessaire
    hyprctl dispatch resizewindowpixel exact 500 400,pavucontrol 2>/dev/null
    hyprctl dispatch centerwindow pavucontrol 2>/dev/null
fi
