#!/bin/bash

# Sélectionner des wallpapers avec wofi (compatible Wayland)

FOLDER="$HOME/Images/wallpapers"

# Vérifier que le dossier existe
if [ ! -d "$FOLDER" ]; then
    notify-send "Erreur" "Dossier wallpapers introuvable: $FOLDER" -u critical
    exit 1
fi

# Trouver tous les wallpapers
WALLPAPERS=($(find "$FOLDER" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' -o -iname '*.gif' -o -iname '*.webp' \) | sort))

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    notify-send "Erreur" "Aucun wallpaper trouvé dans $FOLDER" -u critical
    exit 1
fi

# Créer la liste simple pour wofi
PREVIEW_LIST=""
for wallpaper in "${WALLPAPERS[@]}"; do
    filename=$(basename "$wallpaper")
    PREVIEW_LIST+="$filename\n"
done

# Sélectionner avec wofi (version simplifiée)
SELECTED_WALLPAPER=$(printf '%b' "$PREVIEW_LIST" | wofi --dmenu --prompt "🎨 Choisir un wallpaper:")

if [ -n "$SELECTED_WALLPAPER" ]; then
    WALLPAPER_PATH="$FOLDER/$SELECTED_WALLPAPER"
    
    # Vérifier que le fichier existe
    if [ ! -f "$WALLPAPER_PATH" ]; then
        notify-send "Erreur" "Wallpaper introuvable: $WALLPAPER_PATH" -u critical
        exit 1
    fi
    
    # Notification de début
    notify-send "Wallpaper" "Application de $(basename "$WALLPAPER_PATH")..." -u low
    
    # Appliquer le wallpaper avec transition élégante
    swww img "$WALLPAPER_PATH" --transition-type fade --transition-duration 3
    
    # Générer les couleurs avec pywal
    wal -i "$WALLPAPER_PATH" -n
    
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
    
    # Sauvegarder le wallpaper sélectionné
    echo "$WALLPAPER_PATH" > "$HOME/.config/dernier_wallpaper.txt"
    
    # Recharger waybar et swaync avec animation
    pkill waybar
    sleep 0.3
    hyprctl dispatch exec waybar
    
    pkill swaync
    sleep 0.3
    hyprctl dispatch exec swaync
    
    # Notification de succès
    notify-send "Wallpaper" "✅ $(basename "$WALLPAPER_PATH") appliqué avec succès !" -u normal
    
    echo "Wallpaper sélectionné appliqué : $(basename "$WALLPAPER_PATH")"
else
    echo "Sélection annulée"
fi 