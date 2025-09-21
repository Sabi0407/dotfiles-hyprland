#!/bin/bash

# Script Waypaper avec intégration pywal automatique

WALLPAPER_DIR="$HOME/Images/wallpapers"

echo "🎨 Lancement de Waypaper..."
echo "📁 Dossier: $WALLPAPER_DIR"
echo "⚡ Pywal s'appliquera automatiquement après sélection"

# Lancer Waypaper (la configuration post_command gère pywal automatiquement)
waypaper --folder "$WALLPAPER_DIR" --backend swww

echo "✅ Waypaper fermé"
