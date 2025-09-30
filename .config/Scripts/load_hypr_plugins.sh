#!/bin/bash

# Script pour charger automatiquement les plugins Hyprland au démarrage
# Attendre que Hyprland soit complètement démarré

sleep 5

# Vérifier si Hyprland est en cours d'exécution
if pgrep -x "Hyprland" > /dev/null; then
    echo "Hyprland détecté, chargement des plugins..."
    
    # Recharger les plugins
    hyprpm reload
    
    # Vérifier si les plugins sont chargés
    if hyprctl plugin list | grep -q "hyprexpo"; then
        echo "Plugin hyprexpo chargé avec succès"
        notify-send "Hyprland" "Plugins chargés avec succès" -i applications-system
    else
        echo "Échec du chargement des plugins, nouvelle tentative..."
        sleep 2
        hyprpm reload
    fi
else
    echo "Hyprland non détecté"
fi
