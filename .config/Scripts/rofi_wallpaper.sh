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
    find "$WALLPAPER_DIR" -type f | 
    sort | while read -r wallpaper; do
        # Vérifier si c'est une image par extension ou par type de fichier
        if [[ "$wallpaper" =~ \.(jpg|jpeg|png|webp)$ ]] || file "$wallpaper" | grep -qi "image"; then
            filename=$(basename "$wallpaper")
            # Enlever l'extension si elle existe
            if [[ "$filename" =~ \.(jpg|jpeg|png|webp)$ ]]; then
                filename=$(basename "$wallpaper" | cut -d'.' -f1)
            fi
            echo -e "$filename\x00icon\x1f$wallpaper"
        fi
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
    # Debug: afficher le nombre d'images trouvées
    local image_count
    image_count=$(find "$WALLPAPER_DIR" -type f | while read -r file; do
        if [[ "$file" =~ \.(jpg|jpeg|png|webp)$ ]] || file "$file" | grep -qi "image"; then
            echo "$file"
        fi
    done | wc -l)
    echo "Debug: $image_count images trouvées dans $WALLPAPER_DIR"
    
    local selection
    selection=$(generate_list | rofi_selector)
    
    if [ -n "$selection" ]; then
        # Trouver le chemin complet du wallpaper sélectionné
        local wallpaper_path
        # Essayer d'abord avec extension, puis sans extension
        wallpaper_path=$(find "$WALLPAPER_DIR" -name "$selection.*" | head -1)
        if [ -z "$wallpaper_path" ]; then
            wallpaper_path=$(find "$WALLPAPER_DIR" -name "$selection" | head -1)
        fi
        
               if [ -f "$wallpaper_path" ]; then
                   echo "Application du wallpaper: $wallpaper_path"
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
