#!/bin/bash

# Script exécuté automatiquement après changement de wallpaper via Waypaper

# Obtenir le wallpaper actuel
CURRENT_WALLPAPER=$(swww query 2>/dev/null | grep -o '/.*' | head -1)

if [[ -n "$CURRENT_WALLPAPER" && -f "$CURRENT_WALLPAPER" ]]; then
    echo "🎨 Application pywal pour: $(basename "$CURRENT_WALLPAPER")"
    
    # Notification de début
    notify-send "Wallpaper" "Génération des thèmes pywal..." -i image-x-generic -t 2000
    
    # Générer les couleurs avec pywal
    wal -i "$CURRENT_WALLPAPER" -n
    
    # Synchroniser tous les thèmes en arrière-plan
    {
        ~/.config/Scripts/wal2swaync.sh
        ~/.config/Scripts/generate-pywal-waybar-style.sh
        ~/.config/Scripts/generate-wofi-colors.sh
        ~/.config/Scripts/generate-kitty-colors.sh
        ~/.config/Scripts/generate-wlogout-colors.sh
        ~/.config/Scripts/generate-hyprland-colors.sh
        pywal-discord -t abou
        echo '* { color: #ffffff !important; }' >> "$HOME/.config/BetterDiscord/themes/pywal-discord-abou.theme.css"
    } 2>/dev/null &
    
    # Sauvegarder le wallpaper
    echo "$CURRENT_WALLPAPER" > "$HOME/.config/dernier_wallpaper.txt"
    
    # Recharger l'interface après un court délai
    sleep 2
    pkill waybar && sleep 0.5 && hyprctl dispatch exec waybar
    pkill swaync && sleep 0.5 && hyprctl dispatch exec swaync
    pkill wofi && sleep 0.5 && hyprctl dispatch exec wofi
    
    # Notification de succès
    notify-send "Wallpaper" "✅ Thèmes pywal appliqués !" -i image-x-generic -t 3000
    
    echo "✅ Pywal appliqué avec succès pour $(basename "$CURRENT_WALLPAPER")"
else
    echo "❌ Impossible de récupérer le wallpaper actuel"
fi
