#!/bin/bash

# Forcer l'environnement Wayland pour swww
export WAYLAND_DISPLAY=$WAYLAND_DISPLAY

# --- CONFIG ---
WALLPAPER_DIR="$HOME/Images/wallpapers"

# --- 1. Sélection du nouveau fond d'écran ---
if [ -n "$1" ] && [ -f "$1" ]; then
    NEW_WALLPAPER="$1"
else
    # Utiliser wofi pour la sélection (version simplifiée sans thème)
    NEW_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' -o -iname '*.gif' -o -iname '*.webp' \) | wofi --dmenu --prompt "🎨 Choisir un wallpaper:" --width 600 --height 400)
    [ -z "$NEW_WALLPAPER" ] && echo "Annulé." && exit 1
fi

# Vérifier que le wallpaper existe
if [ ! -f "$NEW_WALLPAPER" ]; then
    echo "Erreur : Le wallpaper sélectionné n'existe pas : $NEW_WALLPAPER"
    exit 1
fi

echo "Wallpaper sélectionné : $NEW_WALLPAPER"

# --- 2. Lancer swww-daemon si besoin ---
if pgrep -x swww-daemon > /dev/null; then
    pkill swww-daemon
    sleep 0.5
fi
swww-daemon &
sleep 1

# --- 3. Appliquer le fond d'écran avec swww ---
TRANSITION_DIRECTIONS=(left right top bottom)
TRANSITION_DIR=${TRANSITION_DIRECTIONS[$RANDOM % ${#TRANSITION_DIRECTIONS[@]}]}
swww img "$NEW_WALLPAPER" --transition-type "$TRANSITION_DIR" --transition-duration 5

# --- 4. Générer la palette pywal et les thèmes ---
wal -i "$NEW_WALLPAPER" -n

# Synchroniser SwayNC avec pywal
~/.config/Scripts/wal2swaync.sh

# Générer le style Waybar avec pywal
~/.config/Scripts/generate-pywal-waybar-style.sh

# Générer les couleurs Wofi avec pywal
~/.config/Scripts/generate-wofi-colors.sh

# Générer les couleurs Kitty avec pywal
~/.config/Scripts/generate-kitty-colors.sh

# Générer les couleurs wlogout avec pywal
~/.config/Scripts/generate-wlogout-colors.sh

# Générer les couleurs Hyprland avec pywal
~/.config/Scripts/generate-hyprland-colors.sh

# --- Générer le thème Discord avec pywal-discord ---
pywal-discord -t abou
echo '* { color: #ffffff !important; }' >> "$HOME/.config/BetterDiscord/themes/pywal-discord-abou.theme.css"

# --- 5. Enregistrer le fond d'écran utilisé ---
echo "$NEW_WALLPAPER" > "$HOME/.config/dernier_wallpaper.txt"
echo "Wallpaper sauvegardé : $NEW_WALLPAPER"

# --- 6. Recharger les applis pour appliquer les couleurs ---
pkill waybar
sleep 0.5
waybar &
pkill swaync
sleep 0.5
hyprctl dispatch exec swaync
pkill wlogout
sleep 0.5

# --- 7. Message de statut ---
echo "Fond d'écran et couleurs adaptés à $NEW_WALLPAPER !" 