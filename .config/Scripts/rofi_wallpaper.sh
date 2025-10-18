#!/bin/bash

# Sélecteur de wallpapers avec Rofi

PYWAL_CACHE_DIR="${PYWAL_CACHE_DIR:-$HOME/.config/wal/cache}"
export PYWAL_CACHE_DIR
mkdir -p "$PYWAL_CACHE_DIR"

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


# Fonction principale
main() {
    local selection
    selection=$(generate_list | rofi_selector)
    
    if [ -n "$selection" ]; then
        # Trouver le chemin complet du wallpaper sélectionné
        local wallpaper_path
        wallpaper_path=$(find "$WALLPAPER_DIR" -name "$selection.*" | head -1)
        
        if [ -f "$wallpaper_path" ]; then
            "$HOME/.config/Scripts/wallpaper-manager.sh" apply-path "$wallpaper_path"
        else
            echo "Wallpaper introuvable: $selection"
        fi
    else
        echo "Sélection annulée"
    fi
}

# Exécuter
main
