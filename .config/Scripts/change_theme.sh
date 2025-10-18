#!/bin/bash

# Script pour changer facilement de thème
# Usage: ./change_theme.sh [nom_du_theme]

LOCAL_CACHE_DIR="$HOME/.config/Scripts/wal-cache"
PYWAL_CACHE_DIR="${PYWAL_CACHE_DIR:-$LOCAL_CACHE_DIR}"
export PYWAL_CACHE_DIR
mkdir -p "$PYWAL_CACHE_DIR"

if [ -z "$1" ]; then
    echo "Thèmes disponibles :"
    echo "  gruvbox"
    echo "  catppuccin-mocha"
    echo "  dracula"
    echo "  tokyonight-night"
    echo "  rose-pine"
    echo "  base16-gruvbox-medium"
    echo "  base16-gruvbox-soft"
    echo ""
    echo "Usage: $0 [nom_du_theme]"
    exit 1
fi

THEME="$1"

echo "Application du thème : $THEME"

# Appliquer le thème
wal --theme "$THEME"
~/.config/Scripts/update-pywalfox.sh > /dev/null 2>&1 || true

# Synchroniser tous les composants
~/.config/Scripts/wal2swaync.sh
~/.config/Scripts/generate-pywal-waybar-style.sh
~/.config/Scripts/generate-tofi-colors.sh
~/.config/Scripts/generate-kitty-colors.sh
~/.config/Scripts/generate-hyprlock-colors.sh
~/.config/Scripts/generate-hyprland-colors.sh

# Recharger waybar
pkill waybar
sleep 0.5
hyprctl dispatch exec waybar

echo "Thème $THEME appliqué avec succès !" 
