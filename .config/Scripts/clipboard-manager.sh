#!/bin/bash
# Gestionnaire de presse-papiers avec historique

# Créer le répertoire si nécessaire
mkdir -p ~/.cache/cliphist

# Activer cliphist si pas déjà actif
if ! pgrep -x cliphist > /dev/null; then
    cliphist daemon &
    sleep 0.5
fi

# Sélectionner un élément de l'historique avec Tofi
CHOICE=$(cliphist list | tofi --prompt-text="📋 Presse-papiers: " --drun-launch=false)

if [ -n "$CHOICE" ]; then
    # Copier l'élément sélectionné
    echo "$CHOICE" | wl-copy
    
    # Notification
    notify-send "Presse-papiers" "Élément copié :\n${CHOICE:0:50}..." -i edit-copy -t 3000
fi
