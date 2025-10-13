#!/bin/bash

# Script pour le démarrage - restaure le dernier wallpaper choisi
WALLPAPER_DIR="$HOME/Images/wallpapers"
LAST_WALLPAPER_FILE="$HOME/.config/dernier_wallpaper.txt"

# Démarrer swww-daemon si pas déjà actif
if ! pgrep -x swww-daemon > /dev/null; then
    swww-daemon &
    sleep 1
fi

# Vérifier s'il y a un dernier wallpaper sauvegardé et valide
if [ -f "$LAST_WALLPAPER_FILE" ]; then
    saved_wallpaper=$(cat "$LAST_WALLPAPER_FILE")
    if [ -f "$saved_wallpaper" ]; then
        # Restaurer le dernier wallpaper choisi
        wallpaper="$saved_wallpaper"
        echo "Restauration du dernier wallpaper choisi : $(basename "$wallpaper")"
        should_save=true
    else
        # Le fichier sauvegardé n'existe plus, choisir un aléatoire
        wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)
        echo "Wallpaper sauvegardé introuvable, nouveau aléatoire : $(basename "$wallpaper")"
        should_save=false
    fi
else
    # Pas de fichier sauvegardé, choisir un aléatoire
    wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)
    echo "Nouveau wallpaper aléatoire (aucun sauvegardé) : $(basename "$wallpaper")"
    should_save=false
fi

if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
    # Appliquer le wallpaper avec transition simple
    swww img "$wallpaper" --transition-type fade --transition-duration 2
    
    # Générer les couleurs avec pywal
    wal -i "$wallpaper" -n
    
    # Synchroniser tous les thèmes avec pywal
    ~/.config/Scripts/wal2swaync.sh
    ~/.config/Scripts/generate-pywal-waybar-style.sh
~/.config/Scripts/generate-tofi-colors.sh
~/.config/Scripts/generate-kitty-colors.sh
~/.config/Scripts/generate-wlogout-colors.sh
~/.config/Scripts/generate-hyprland-colors.sh
~/.config/Scripts/generate-hyprlock-colors.sh
    
    # Générer le thème Discord avec pywal-discord
    pywal-discord -t abou
    echo '* { color: #ffffff !important; }' >> "$HOME/.config/BetterDiscord/themes/pywal-discord-abou.theme.css"
    
    # Sauvegarder le wallpaper utilisé
    echo "$wallpaper" > "$LAST_WALLPAPER_FILE"
    echo "Wallpaper sauvegardé : $(basename "$wallpaper")"
    
    # Recharger waybar et swaync pour appliquer les nouvelles couleurs
    pkill waybar
    sleep 0.5
    waybar &
    pkill swaync
    sleep 0.5
    hyprctl dispatch exec swaync
    
    echo "Wallpaper de démarrage appliqué : $(basename "$wallpaper")"
else
    echo "Aucun wallpaper trouvé dans $WALLPAPER_DIR"
fi 
