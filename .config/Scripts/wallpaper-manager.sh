#!/bin/bash

# Configuration
PYWAL_CACHE_DIR="${PYWAL_CACHE_DIR:-$HOME/.config/wal/cache}"
export PYWAL_CACHE_DIR
mkdir -p "$PYWAL_CACHE_DIR"

WALLPAPER_DIR="$HOME/Images/wallpapers"
LAST_WALLPAPER_FILE="$HOME/.config/dernier_wallpaper.txt"
SCRIPTS_DIR="$HOME/.config/Scripts"
WLOGOUT_UPDATE_SCRIPT="$HOME/.config/Scripts/update-wlogout-wallpaper.sh"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-manager"
WALLPAPER_CACHE_FILE="$CACHE_DIR/wallpapers.list"
WALLPAPER_CACHE_TTL="${WALLPAPER_CACHE_TTL:-600}"
declare -A WAL_BACKEND_MODULES=(
    [colorz]=colorz
    [colorthief]=colorthief
    [average]=""
)
WAL_BACKEND_PRIORITY=(colorz colorthief average)

ensure_cache_dir() {
    mkdir -p "$CACHE_DIR"
}

wallpaper_cache_is_outdated() {
    if [ ! -s "$WALLPAPER_CACHE_FILE" ]; then
        return 0
    fi
    local ttl="$WALLPAPER_CACHE_TTL"
    case "$ttl" in
        ''|*[!0-9]*) ttl=0 ;;
    esac
    if [ "$ttl" -le 0 ]; then
        return 0
    fi
    local last_update
    last_update=$(stat -c %Y "$WALLPAPER_CACHE_FILE" 2>/dev/null || echo 0)
    local now
    now=$(date +%s)
    if [ "$last_update" -eq 0 ]; then
        return 0
    fi
    (( now - last_update >= ttl ))
}

build_wallpaper_cache() {
    ensure_cache_dir
    if [ ! -d "$WALLPAPER_DIR" ]; then
        echo "[wallpaper-manager] Dossier wallpapers introuvable: $WALLPAPER_DIR" >&2
        return 1
    fi
    local tmp
    tmp=$(mktemp "$CACHE_DIR/wallpapers.XXXXXX") || return 1
    if ! find "$WALLPAPER_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        -print >"$tmp" 2>/dev/null; then
        rm -f "$tmp"
        return 1
    fi
    mv "$tmp" "$WALLPAPER_CACHE_FILE"
}

ensure_wallpaper_cache_ready() {
    ensure_cache_dir
    if [ ! -s "$WALLPAPER_CACHE_FILE" ]; then
        build_wallpaper_cache
        return
    fi
    if wallpaper_cache_is_outdated; then
        (build_wallpaper_cache >/dev/null 2>&1) &
    fi
    return 0
}

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

ensure_swww_daemon() {
    if pgrep -x swww-daemon >/dev/null 2>&1; then
        return
    fi
    swww-daemon >/dev/null 2>&1 &
    for _ in {1..20}; do
        if swww query >/dev/null 2>&1; then
            return
        fi
        sleep 0.1
    done
    sleep 0.2
}

update_theme_components() {
    local wallpaper_path="$1"
    if ! generate_dynamic_palette "$wallpaper_path"; then
        return 1
    fi

    if [ -x "$SCRIPTS_DIR/update-swayosd-style.sh" ]; then
        "$SCRIPTS_DIR/update-swayosd-style.sh" >/dev/null 2>&1 || true
    fi

    local sync_success=0
    if [ -x "$SCRIPTS_DIR/pywal-sync.sh" ]; then
        if "$SCRIPTS_DIR/pywal-sync.sh" >/dev/null 2>&1; then
            sync_success=1
        else
            echo "[wallpaper-manager] Avertissement : certains modules pywal ont échoué." >&2
        fi
    fi

    if [ "$sync_success" -eq 0 ]; then
        for script in wal2swaync generate-tofi-colors generate-kitty-colors generate-hyprland-colors generate-hyprlock-colors generate-pywal-waybar-style update-pywalfox; do
            if [ -x "$SCRIPTS_DIR/$script.sh" ]; then
                "$SCRIPTS_DIR/$script.sh" >/dev/null 2>&1 || true
            fi
        done
        restart_waybar
        restart_swaync
    fi

    pkill -x tofi 2>/dev/null || true
    sleep 0.15
    return 0
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
    
    ensure_swww_daemon
    
    # Appliquer le wallpaper avec transition
    transitions=("none" "simple" "fade" "left" "right" "top" "bottom" "wipe" "wave" "grow" "center" "outer" "random")
    transition=${transitions[$RANDOM % ${#transitions[@]}]}
    swww img "$wallpaper_path" --transition-type "$transition" --transition-duration 2

    if ! update_theme_components "$wallpaper_path"; then
        echo "[wallpaper-manager] Impossible de générer une palette Pywal pour ce wallpaper." >&2
    fi

    # Sauvegarder le wallpaper utilisé
    echo "$wallpaper_path" > "$LAST_WALLPAPER_FILE"

    refresh_wlogout_background
    
    echo "Wallpaper appliqué avec succès: $(basename "$wallpaper_path")"
}

# Fonction pour choisir un wallpaper aléatoire
choose_random_wallpaper() {
    if ! ensure_wallpaper_cache_ready; then
        return 1
    fi
    if [ ! -s "$WALLPAPER_CACHE_FILE" ]; then
        return 1
    fi
    local -a wallpapers=()
    mapfile -t wallpapers < "$WALLPAPER_CACHE_FILE"
    local count=${#wallpapers[@]}
    if [ "$count" -eq 0 ]; then
        return 1
    fi
    local index=$((RANDOM % count))
    local selection="${wallpapers[$index]}"
    if [ -n "$selection" ]; then
        printf '%s\n' "$selection"
    fi
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
            if ensure_wallpaper_cache_ready && [ -s "$WALLPAPER_CACHE_FILE" ]; then
                sed 's#.*/##' "$WALLPAPER_CACHE_FILE" | sort
            else
                find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort
            fi
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
