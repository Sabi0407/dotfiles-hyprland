#!/bin/bash

# Script pour appliquer pywal au wallpaper sélectionné par waypaper
# Ce script est appelé par waypaper après chaque changement de wallpaper

# Récupérer le wallpaper actuel depuis waypaper
CURRENT_WALLPAPER=$(waypaper --get 2>/dev/null)

if [ -n "$CURRENT_WALLPAPER" ] && [ -f "$CURRENT_WALLPAPER" ]; then
    echo "🎨 Application de pywal pour : $(basename "$CURRENT_WALLPAPER")"
    
    # Générer les couleurs avec pywal
    wal -i "$CURRENT_WALLPAPER" -n
    
    # Synchroniser tous les thèmes avec pywal
    ~/.config/Scripts/wal2swaync.sh
    ~/.config/Scripts/generate-pywal-waybar-style.sh
    ~/.config/Scripts/generate-wofi-colors.sh
    ~/.config/Scripts/generate-kitty-colors.sh
    ~/.config/Scripts/generate-wlogout-colors.sh
    ~/.config/Scripts/generate-hyprland-colors.sh
    
    # Générer le thème Discord avec pywal-discord
    pywal-discord -t abou
    echo '* { color: #ffffff !important; }' >> "$HOME/.config/BetterDiscord/themes/pywal-discord-abou.theme.css"
    
    # Sauvegarder le wallpaper utilisé
    echo "$CURRENT_WALLPAPER" > "$HOME/.config/dernier_wallpaper.txt"
    
    # Recharger waybar et swaync
    pkill waybar
    sleep 0.3
    hyprctl dispatch exec waybar
    
    pkill swaync
    sleep 0.3
    hyprctl dispatch exec swaync
    
    echo "✅ Pywal appliqué avec succès !"
else
    echo "⚠️  Impossible de récupérer le wallpaper actuel"
fi
