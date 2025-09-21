#!/bin/bash

# Script pour redémarrer Waybar
echo "Arrêt de Waybar..."
pkill -f waybar

# Attendre un moment pour s'assurer que le processus est terminé
sleep 2

echo "Redémarrage de Waybar..."
nohup waybar > /dev/null 2>&1 &

sleep 1

if pgrep -f waybar > /dev/null; then
    echo "✅ Waybar redémarré avec succès !"
else
    echo "❌ Erreur lors du redémarrage de Waybar"
    echo "Tentative de diagnostic..."
    waybar 2>&1 | head -3
fi
