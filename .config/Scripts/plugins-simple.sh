#!/bin/bash
# Script simple pour activer les plugins Hyprland

echo "🔌 Activation des plugins..."

# Vérifier si Hyprland fonctionne
if ! hyprctl version &>/dev/null; then
    echo "❌ Hyprland non accessible"
    exit 1
fi

echo "📊 Tentative d'activation hyprexpo..."
hyprpm enable hyprexpo &
sleep 2

echo "📜 Tentative d'activation hyprscrolling..."  
hyprpm enable hyprscrolling &
sleep 2

echo "🔍 Plugins chargés :"
hyprctl plugin list || echo "Aucun plugin chargé"

echo "✅ Terminé"
