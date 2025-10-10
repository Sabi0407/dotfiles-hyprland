#!/bin/bash

# Configuration
WALLPAPER_DIR="$HOME/Images/wallpapers"
LAST_WALLPAPER_FILE="$HOME/.config/dernier_wallpaper.txt"
SCRIPTS_DIR="$HOME/.config/Scripts"

# Fonction pour appliquer un wallpaper avec pywal
apply_wallpaper() {
    local wallpaper_path="$1"
    
    # Vérifier si le fichier existe
    if [ ! -f "$wallpaper_path" ]; then
        echo "Erreur: Wallpaper non trouvé - $wallpaper_path"
        return 1
    fi
    
    echo "Application du wallpaper: $(basename "$wallpaper_path")"
    
    # Démarrer swww-daemon si nécessaire
    if ! pgrep -x swww-daemon > /dev/null; then
        swww-daemon &
        sleep 1
    fi
    
    # Appliquer le wallpaper avec transition
    transitions=("fade" "wipe" "grow" "center" "outer")
    transition=${transitions[$RANDOM % ${#transitions[@]}]}
    swww img "$wallpaper_path" --transition-type "$transition" --transition-duration 2
    
    # Générer les couleurs pywal
    wal -i "$wallpaper_path" -n
    
    # Synchroniser tous les thèmes
    for script in wal2swaync generate-pywal-waybar-style generate-tofi-colors generate-kitty-colors generate-hyprland-colors; do
        if [ -f "$SCRIPTS_DIR/$script.sh" ]; then
            "$SCRIPTS_DIR/$script.sh" 2>/dev/null
        fi
    done
    
    # Générer le thème Discord si disponible
    if command -v pywal-discord >/dev/null 2>&1; then
        pywal-discord -t abou 2>/dev/null
    fi
    
    # Sauvegarder le wallpaper utilisé
    echo "$wallpaper_path" > "$LAST_WALLPAPER_FILE"
    
    # Recharger l'interface
    pkill waybar
    sleep 0.3
    hyprctl dispatch exec waybar
    
    pkill swaync
    sleep 0.3
    hyprctl dispatch exec swaync
    
    # Forcer la fermeture de Tofi pour qu'il recharge les couleurs
    pkill tofi 2>/dev/null
    sleep 0.2
    
    echo "Wallpaper appliqué avec succès: $(basename "$wallpaper_path")"
}

# Fonction pour choisir un wallpaper aléatoire
choose_random_wallpaper() {
    find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1
}

# Fonction principale
main() {
    case "${1:-random}" in
        "random"|"r"|"")
            wallpaper=$(choose_random_wallpaper)
            if [ -n "$wallpaper" ]; then
                apply_wallpaper "$wallpaper"
            else
                echo "Erreur: Aucun wallpaper trouvé dans $WALLPAPER_DIR"
            fi
            ;;
        "specific"|"s")
            if [ -z "$2" ]; then
                echo "Usage: $0 specific fichier.jpg"
                exit 1
            fi
            apply_wallpaper "$WALLPAPER_DIR/$2"
            ;;
        "restore")
            if [ -f "$LAST_WALLPAPER_FILE" ]; then
                saved_wallpaper=$(cat "$LAST_WALLPAPER_FILE")
                if [ -f "$saved_wallpaper" ]; then
                    apply_wallpaper "$saved_wallpaper"
                else
                    echo "Wallpaper sauvegardé introuvable, application d'un wallpaper aléatoire"
                    main random
                fi
            else
                echo "Aucun wallpaper sauvegardé trouvé, application d'un wallpaper aléatoire"
                main random
            fi
            ;;
        "list"|"l")
            echo "Wallpapers disponibles dans $WALLPAPER_DIR:"
            find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort
            ;;
        "help"|"h"|*)
            echo "Script de gestion des wallpapers avec pywal"
            echo ""
            echo "Usage:"
            echo "  $0 [random|r]              - Wallpaper aléatoire"
            echo "  $0 [specific|s] <fichier>  - Wallpaper spécifique"
            echo "  $0 [restore]               - Restaurer le dernier wallpaper"
            echo "  $0 [list|l]                - Lister les wallpapers disponibles"
            echo "  $0 [help|h]                - Afficher cette aide"
            echo ""
            echo "Exemples:"
            echo "  $0                         - Wallpaper aléatoire"
            echo "  $0 specific mountain.jpg   - Wallpaper spécifique"
            echo "  $0 restore                 - Restaurer le dernier"
            echo "  $0 list                    - Voir tous les wallpapers"
            ;;
    esac
}

# Exécuter le script
main "$@"
