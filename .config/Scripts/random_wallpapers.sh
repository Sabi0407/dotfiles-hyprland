#!/bin/bash

# Script simple pour changer de wallpaper aléatoirement
# Pour le keybinding $mainMod + W

WALLPAPER_DIR="$HOME/Images/wallpapers"

# Trouver un wallpaper aléatoire
wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)

if [ -n "$wallpaper" ]; then
    # Toutes les transitions disponibles
    transitions=("none" "simple" "fade" "left" "right" "top" "bottom" "wipe" "wave" "grow" "center" "outer" "random")
    
    # Choisir une transition aléatoire
    transition=${transitions[$RANDOM % ${#transitions[@]}]}
    
    # Appliquer le wallpaper avec transition aléatoire
    swww img "$wallpaper" --transition-type "$transition" --transition-duration 2
    
    # Générer les couleurs avec pywal
    wal -i "$wallpaper" -n
    
    # Synchroniser tous les thèmes avec pywal
    ~/.config/Scripts/wal2swaync.sh
    ~/.config/Scripts/generate-pywal-waybar-style.sh
    ~/.config/Scripts/generate-tofi-colors.sh
    ~/.config/Scripts/generate-kitty-colors.sh
    ~/.config/Scripts/generate-wlogout-colors.sh
    ~/.config/Scripts/generate-hyprland-colors.sh
    
    # Générer le thème Discord avec pywal-discord
    pywal-discord -t abou
    echo '* { color: #ffffff !important; }' >> "$HOME/.config/BetterDiscord/themes/pywal-discord-abou.theme.css"
    
    # Sauvegarder le wallpaper aléatoire
    echo "$wallpaper" > "$HOME/.config/dernier_wallpaper.txt"
    echo "Wallpaper aléatoire sauvegardé : $(basename "$wallpaper")"
    
    # Recharger waybar (tuer l'ancien puis lancer le nouveau)
    pkill waybar
    sleep 0.5
    hyprctl dispatch exec waybar
    
    # Redémarrer swaync pour appliquer le nouveau thème
    pkill swaync
    sleep 0.5
    hyprctl dispatch exec swaync
    
    # Tuer Tofi s'il est ouvert (pour appliquer les nouvelles couleurs au prochain lancement)
    pkill tofi 2>/dev/null
    
    echo "Wallpaper changé : $(basename "$wallpaper") avec transition: $transition"
else
    echo "Aucun wallpaper trouvé dans $WALLPAPER_DIR"
fi 