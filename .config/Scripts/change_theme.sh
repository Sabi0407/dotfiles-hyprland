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

# Synchroniser tous les composants
~/.config/Scripts/wal2swaync.sh
~/.config/Scripts/generate-pywal-waybar-style.sh
~/.config/Scripts/generate-tofi-colors.sh
~/.config/Scripts/generate-kitty-colors.sh
~/.config/Scripts/generate-hyprlock-colors.sh
~/.config/Scripts/generate-hyprland-colors.sh

# Générer le thème Discord
pywal-discord -t abou
echo '* { color: #ffffff !important; }' >> "$HOME/.config/BetterDiscord/themes/pywal-discord-abou.theme.css"

# Recharger waybar
pkill waybar
sleep 0.5
hyprctl dispatch exec waybar

echo "Thème $THEME appliqué avec succès !" 
