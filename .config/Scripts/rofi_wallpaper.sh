#!/bin/bash

# Sélecteur de wallpapers avec Rofi

WALLPAPER_DIR="$HOME/Images/wallpapers"

# Vérifier le dossier
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Erreur: Dossier wallpapers introuvable"
    exit 1
fi

# Générer la liste des wallpapers
generate_list() {
    find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | 
    sort | while read -r wallpaper; do
        filename=$(basename "$wallpaper" | cut -d'.' -f1)
        printf "%s\0icon\x1f%s\n" "$filename" "$wallpaper"
    done
}

# Configuration Rofi mode sombre
rofi_selector() {
    rofi -dmenu \
        -p "Wallpapers" \
        -show-icons \
        -i \
        -no-custom \
        -theme-str 'window { width: 800px; height: 600px; background-color: #1a1a1a; }' \
        -theme-str 'listview { columns: 3; background-color: #1a1a1a; }' \
        -theme-str 'element { background-color: #2a2a2a; text-color: #ffffff; }' \
        -theme-str 'element selected { background-color: #404040; }' \
        -theme-str 'element-icon { size: 100px; }' \
        -theme-str 'inputbar { background-color: #2a2a2a; text-color: #ffffff; }' \
        -theme-str 'prompt { text-color: #ffffff; }' \
        -theme-str 'entry { text-color: #ffffff; }'
}


# Fonction d'application du wallpaper
apply_wallpaper() {
    local wallpaper_path="$1"
    
    if [ ! -f "$wallpaper_path" ]; then
        echo "Erreur: Fichier introuvable"
        return 1
    fi
    
    echo "Application: $(basename "$wallpaper_path")"
    
    # Appliquer avec transition
    swww img "$wallpaper_path" --transition-type wipe --transition-duration 1.5
    
    # Générer couleurs pywal
    wal -i "$wallpaper_path" -n
    
    # Synchroniser thèmes
    for script in wal2swaync generate-pywal-waybar-style generate-tofi-colors generate-kitty-colors generate-hyprland-colors generate-hyprlock-colors; do
        [ -f "$HOME/.config/Scripts/$script.sh" ] && "$HOME/.config/Scripts/$script.sh" 2>/dev/null
    done
    
    # Discord
    command -v pywal-discord >/dev/null && pywal-discord -t abou 2>/dev/null
    
    # Sauvegarder
    echo "$wallpaper_path" > "$HOME/.config/dernier_wallpaper.txt"
    
    # Recharger interface
    pkill waybar && sleep 0.2 && hyprctl dispatch exec waybar
    pkill swaync && sleep 0.2 && hyprctl dispatch exec swaync
    
    echo "Wallpaper appliqué"
}

# Fonction principale
main() {
    local selection
    selection=$(generate_list | rofi_selector)
    
    if [ -n "$selection" ]; then
        # Trouver le chemin complet du wallpaper sélectionné
        local wallpaper_path
        wallpaper_path=$(find "$WALLPAPER_DIR" -name "$selection.*" | head -1)
        
        if [ -f "$wallpaper_path" ]; then
            apply_wallpaper "$wallpaper_path"
            echo "Wallpaper '$selection' appliqué avec succès !"
        else
            echo "Wallpaper introuvable: $selection"
        fi
    else
        echo "Sélection annulée"
    fi
}

# Exécuter
main
