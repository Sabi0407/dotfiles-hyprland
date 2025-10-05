#!/bin/bash
# Script de démarrage rapide pour Waybar

# Démarrer Waybar immédiatement avec la config par défaut
waybar &
WAYBAR_PID=$!

# Attendre un peu puis générer le style pywal en arrière-plan
(
    sleep 3
    
    # Générer le style pywal
    if ~/.config/Scripts/generate-pywal-waybar-style.sh; then
        # Redémarrer Waybar avec le nouveau style
        sleep 1
        kill $WAYBAR_PID 2>/dev/null
        waybar &
    fi
) &

# Le script se termine immédiatement, Waybar démarre rapidement
