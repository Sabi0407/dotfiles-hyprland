#!/bin/bash

# Script wallpaper Zenity ultra-simple

FOLDER="$HOME/Images/wallpapers"

[[ ! -d "$FOLDER" ]] && { zenity --error --title="Erreur" --text="Dossier wallpapers introuvable" --width=300; exit 1; }

# Créer la liste simple
WALLPAPERS=($(find "$FOLDER" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -exec basename {} \; | sort))

[[ ${#WALLPAPERS[@]} -eq 0 ]] && { zenity --error --title="Erreur" --text="Aucun wallpaper trouvé" --width=300; exit 1; }

# Menu simple
SELECTED=$(printf '%s\n' "${WALLPAPERS[@]}" | zenity --list \
    --title="🎨 Wallpapers" \
    --text="Choisissez un fond d'écran :" \
    --column="Fichiers disponibles" \
    --width=500 \
    --height=400 \
    --ok-label="Appliquer" \
    --cancel-label="Annuler" 2>/dev/null)

if [[ -n "$SELECTED" ]]; then
    WALLPAPER_PATH="$FOLDER/$SELECTED"
    
    if zenity --question --title="Confirmation" --text="Appliquer $SELECTED ?" --ok-label="Oui" --cancel-label="Non" --width=300; then
        notify-send "Wallpaper" "Application en cours..." -i image-x-generic -t 2000
        
        # Appliquer
        swww img "$WALLPAPER_PATH" --transition-type fade --transition-duration 2
        wal -i "$WALLPAPER_PATH" -n
        
        # Recharger les thèmes en arrière-plan
        {
            ~/.config/Scripts/wal2swaync.sh
            ~/.config/Scripts/generate-pywal-waybar-style.sh
            ~/.config/Scripts/generate-wofi-colors.sh
            ~/.config/Scripts/generate-kitty-colors.sh
            ~/.config/Scripts/generate-wlogout-colors.sh
            ~/.config/Scripts/generate-hyprland-colors.sh
            pywal-discord -t abou
        } 2>/dev/null &
        
        # Recharger waybar
        pkill waybar && sleep 0.5 && hyprctl dispatch exec waybar
        pkill swaync && sleep 0.5 && hyprctl dispatch exec swaync
        
        echo "$WALLPAPER_PATH" > "$HOME/.config/dernier_wallpaper.txt"
        notify-send "Wallpaper" "✅ $SELECTED appliqué !" -i image-x-generic -t 3000
    fi
fi
