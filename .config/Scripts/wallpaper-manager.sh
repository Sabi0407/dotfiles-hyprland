#!/bin/bash

# Configuration
PYWAL_CACHE_DIR="${PYWAL_CACHE_DIR:-$HOME/.config/wal/cache}"
export PYWAL_CACHE_DIR
mkdir -p "$PYWAL_CACHE_DIR"

WALLPAPER_DIR="$HOME/Images/wallpapers"
LAST_WALLPAPER_FILE="$HOME/.config/dernier_wallpaper.txt"
SCRIPTS_DIR="$HOME/.config/Scripts"
WLOGOUT_UPDATE_SCRIPT="$HOME/.config/Scripts/update-wlogout-wallpaper.sh"
declare -A WAL_BACKEND_MODULES=(
    [colorz]=colorz
    [colorthief]=colorthief
    [average]=""
)
WAL_BACKEND_PRIORITY=(colorz colorthief average)

backend_available() {
    local backend="$1"
    [[ "$backend" == "default" ]] && return 0
    local module="${WAL_BACKEND_MODULES[$backend]}"
    if [[ -z "$module" ]]; then
        return 0
    fi
    python - "$module" >/dev/null 2>&1 <<'PY'
import importlib, sys
module = sys.argv[1]
try:
    importlib.import_module(module)
except Exception:
    sys.exit(1)
PY
}

generate_palette_with_backend() {
    local backend="$1"
    local wallpaper="$2"
    local cmd=(wal --cols16 -i "$wallpaper" -n)
    if [[ "$backend" != "default" ]]; then
        cmd+=(--backend "$backend")
    fi
    "${cmd[@]}"
}

generate_dynamic_palette() {
    local wallpaper="$1"
    local backend
    for backend in "${WAL_BACKEND_PRIORITY[@]}"; do
        if ! backend_available "$backend"; then
            continue
        fi
        if generate_palette_with_backend "$backend" "$wallpaper"; then
            echo "[wallpaper-manager] Palette générée avec backend ${backend}" >&2
            return 0
        fi
    done
    echo "[wallpaper-manager] Aucun backend Pywal n'a fonctionné." >&2
    return 1
}

restart_waybar() {
    if systemctl --user restart waybar.service >/dev/null 2>&1; then
        return
    fi
    pkill -x waybar >/dev/null 2>&1 || true
    sleep 0.3
    if command -v waybar >/dev/null 2>&1; then
        nohup waybar >/dev/null 2>&1 &
    fi
}

restart_swaync() {
    if systemctl --user restart swaync.service >/dev/null 2>&1; then
        return
    fi
    pkill -x swaync >/dev/null 2>&1 || true
    sleep 0.3
    if command -v swaync >/dev/null 2>&1; then
        nohup swaync >/dev/null 2>&1 &
    fi
}

refresh_wlogout_background() {
    if [ -x "$WLOGOUT_UPDATE_SCRIPT" ]; then
        if ! WLOGOUT_FORCE_STATIC=1 "$WLOGOUT_UPDATE_SCRIPT" >/dev/null 2>&1; then
            echo "[wallpaper-manager] Impossible de mettre à jour wlogout." >&2
        fi
    fi
}

# Fonction pour appliquer un wallpaper avec pywal
apply_wallpaper() {
    local wallpaper_path="$1"
    
    # Vérifier si le fichier existe
    if [ ! -f "$wallpaper_path" ]; then
        echo "Erreur: Wallpaper non trouvé - $wallpaper_path"
        return 1
    fi

    # Si mpvpaper est actif, l'arrêter proprement (une seule fois)
    if [ "${MPVWALL_SKIP_STOP:-0}" != "1" ]; then
        if [ -x "$HOME/.config/Scripts/mpvpaper-wallpaper.sh" ]; then
            MPVWALL_SKIP_STOP=1 "$HOME/.config/Scripts/mpvpaper-wallpaper.sh" stop >/dev/null 2>&1 || true
        fi
    fi

    echo "Application du wallpaper: $(basename "$wallpaper_path")"
    
    # Démarrer swww-daemon si nécessaire
    if ! pgrep -x swww-daemon > /dev/null; then
        swww-daemon &
        sleep 1
    fi
    
    # Appliquer le wallpaper avec transition
    transitions=("none" "simple" "fade" "left" "right" "top" "bottom" "wipe" "wave" "grow" "center" "outer" "random")
    transition=${transitions[$RANDOM % ${#transitions[@]}]}
    swww img "$wallpaper_path" --transition-type "$transition" --transition-duration 2
    
    if ! generate_dynamic_palette "$wallpaper_path"; then
        echo "[wallpaper-manager] Impossible de générer une palette Pywal pour ce wallpaper." >&2
        return 1
    fi

    if [ -x "$SCRIPTS_DIR/update-swayosd-style.sh" ]; then
        "$SCRIPTS_DIR/update-swayosd-style.sh" >/dev/null 2>&1 || true
    fi

    if [ -x "$SCRIPTS_DIR/pywal-sync.sh" ]; then
        if ! "$SCRIPTS_DIR/pywal-sync.sh" >/dev/null 2>&1; then
            echo "[wallpaper-manager] Avertissement : certains modules pywal ont échoué." >&2
        fi
        sleep 0.3
    else
        for script in wal2swaync generate-tofi-colors generate-kitty-colors generate-hyprland-colors generate-hyprlock-colors; do
            if [ -f "$SCRIPTS_DIR/$script.sh" ]; then
                "$SCRIPTS_DIR/$script.sh" > /dev/null 2>&1 || true
            fi
        done
    fi
    
    # Sauvegarder le wallpaper utilisé
    echo "$wallpaper_path" > "$LAST_WALLPAPER_FILE"
    
    # Recharger l'interface
    restart_waybar
    restart_swaync
    
    # Forcer la fermeture de Tofi pour qu'il recharge les couleurs
    pkill -x tofi 2>/dev/null
    sleep 0.2

    refresh_wlogout_background
    
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
        "apply-path")
            if [ -z "$2" ]; then
                echo "Usage: $0 apply-path /chemin/vers/fichier.jpg"
                exit 1
            fi
            apply_wallpaper "$2"
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
        "fast-waybar")
            waybar &
            WAYBAR_PID=$!
            (
                sleep 3
                if "$SCRIPTS_DIR/generate-pywal-waybar-style.sh"; then
                    sleep 1
                    kill "$WAYBAR_PID" 2>/dev/null
                    waybar &
                fi
            ) &
            ;;
        "help"|"h"|*)
            echo "Script de gestion des wallpapers avec pywal"
            echo ""
            echo "Usage:"
            echo "  $0 [random|r]              - Wallpaper aléatoire"
            echo "  $0 [specific|s] <fichier>  - Wallpaper spécifique"
            echo "  $0 [restore]               - Restaurer le dernier wallpaper"
            echo "  $0 apply-path /chemin.jpg  - Appliquer un fichier précis (absolu)"
            echo "  $0 fast-waybar             - Démarrer Waybar rapidement puis resynchroniser le thème"
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
