#!/bin/bash
set -euo pipefail

VIDEO_PATH="${MPV_WALL_VIDEO:-/home/sabi/Images/anime-walls}"
MPV_OPTIONS="${MPV_WALL_OPTIONS:---loop --no-audio --profile=fast --vo=gpu-next --hwdec=auto-safe}"
AUTOMATION_FLAGS="${MPV_WALL_AUTOMATION_FLAGS:---auto-pause}"
PAPER_FLAGS="${MPV_WALL_EXTRA_FLAGS:-}"
OUTPUTS_OVERRIDE="${MPV_WALL_OUTPUTS:-}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/mpvpaper-wallpaper"
PID_FILE="$CACHE_DIR/pids"
LOG_FILE="$CACHE_DIR/mpvpaper.log"
SOCKETS_FILE="$CACHE_DIR/sockets"
AUTO_PID_FILE="$CACHE_DIR/auto-pause.pid"
LAST_VIDEO_FILE="$CACHE_DIR/last-video.txt"
STATE_FILE="$CACHE_DIR/state"
IPC_BASE="${MPV_WALL_IPC_BASE:-/tmp/mpvpaper-wall}"
AUTO_PAUSE_ENABLED="${MPV_WALL_AUTO_PAUSE:-true}"
AUTO_PAUSE_INTERVAL="${MPV_WALL_AUTO_PAUSE_INTERVAL:-1}"
MPV_SOCKET_WAIT_SECONDS="${MPV_WALL_IPC_WAIT_SECONDS:-5}"
VIDEO_SELECTION_MODE="${MPV_WALL_VIDEO_SELECTION:-random}"
VIDEO_EXTENSIONS="${MPV_WALL_VIDEO_EXTENSIONS:-mp4,mkv,webm,avi,mov}"
VIDEO_RECURSIVE="${MPV_WALL_VIDEO_RECURSIVE:-true}"
PYWAL_ENABLED="${MPV_WALL_PYWAL_ENABLED:-true}"
PYWAL_WAIT_SECONDS="${MPV_WALL_PYWAL_WAIT_SECONDS:-5}"
PYWAL_SCREENSHOT_DIR="$CACHE_DIR/pywal"
SCRIPTS_DIR="${MPV_WALL_SCRIPTS_DIR:-$HOME/.config/Scripts}"
VIDEO_SELECTION_OVERRIDE=""
PYWAL_CACHE_DIR="${PYWAL_CACHE_DIR:-$HOME/.config/wal/cache}"
export PYWAL_CACHE_DIR
MPV_WALL_PICKER_VIDEOS="${MPV_WALL_PICKER_VIDEOS:-$HOME/Images/anime-walls}"

declare -a VIDEO_EXTENSION_LIST=()

normalize_video_extensions() {
    local raw_exts=()
    IFS=',' read -ra raw_exts <<< "$VIDEO_EXTENSIONS"
    VIDEO_EXTENSION_LIST=()
    local ext
    for ext in "${raw_exts[@]}"; do
        ext="${ext//[[:space:]]/}"
        ext="${ext,,}"
        [[ -n "$ext" ]] && VIDEO_EXTENSION_LIST+=("$ext")
    done
    if [ ${#VIDEO_EXTENSION_LIST[@]} -eq 0 ]; then
        VIDEO_EXTENSION_LIST=(mp4 mkv webm avi mov)
    fi
}

normalize_video_extensions

ensure_cache_dir() {
    mkdir -p "$CACHE_DIR"
    mkdir -p "$PYWAL_CACHE_DIR"
}

log() {
    printf '[mpvpaper-wallpaper] %s\n' "$*"
}

bool_enabled() {
    local value="${1:-}"
    case "${value,,}" in
        1|true|yes|on|enable|enabled) return 0 ;;
        0|false|no|off|disable|disabled|"") return 1 ;;
        *) return 1 ;;
    esac
}

is_supported_video() {
    local path="${1,,}"
    if [ ${#VIDEO_EXTENSION_LIST[@]} -eq 0 ]; then
        return 0
    fi
    local ext
    for ext in "${VIDEO_EXTENSION_LIST[@]}"; do
        [[ $path == *.$ext ]] && return 0
    done
    return 1
}

list_videos_in_directory() {
    local dir="$1"
    [ -d "$dir" ] || return 1

    local find_cmd=(find "$dir")
    if ! bool_enabled "$VIDEO_RECURSIVE"; then
        find_cmd+=(-maxdepth 1)
    fi
    find_cmd+=(-type f)

    local found_files=()
    mapfile -t found_files < <("${find_cmd[@]}" 2>/dev/null | LC_ALL=C sort)

    local filtered=()
    local file
    for file in "${found_files[@]}"; do
        if is_supported_video "$file"; then
            filtered+=("$file")
        fi
    done

    if [ ${#filtered[@]} -gt 0 ]; then
        printf '%s\n' "${filtered[@]}"
    fi
}

select_video_from_directory() {
    local dir="$1"
    mapfile -t videos < <(list_videos_in_directory "$dir")
    if [ ${#videos[@]} -eq 0 ]; then
        log "Erreur: aucun fichier vidéo dans $dir"
        return 1
    fi

    local mode="${VIDEO_SELECTION_OVERRIDE:-$VIDEO_SELECTION_MODE}"
    mode="${mode,,}"
    local choice=""
    case "$mode" in
        first|alpha|alphabetical)
            choice="${videos[0]}"
            ;;
        last|omega|reverse)
            choice="${videos[$((${#videos[@]} - 1))]}"
            ;;
        last-used|last|previous|sticky)
            if [ -f "$LAST_VIDEO_FILE" ]; then
                local saved
                saved=$(<"$LAST_VIDEO_FILE")
                if [ -n "$saved" ] && [ -f "$saved" ]; then
                    for candidate in "${videos[@]}"; do
                        if [ "$candidate" = "$saved" ]; then
                            choice="$candidate"
                            break
                        fi
                    done
                fi
            fi
            if [ -z "$choice" ]; then
                choice="${videos[0]}"
            fi
            ;;
        random|rand|shuffle|*)
            local idx=$((RANDOM % ${#videos[@]}))
            choice="${videos[$idx]}"
            ;;
    esac

    printf '%s\n' "$choice"
}

resolve_video_source() {
    local source="$1"
    if [ -z "$source" ]; then
        log "Erreur: aucune source vidéo n'est définie (MPV_WALL_VIDEO)."
        return 1
    fi

    if [ -f "$source" ]; then
        printf '%s\n' "$source"
        return 0
    fi

    if [ -d "$source" ]; then
        select_video_from_directory "$source"
        return $?
    fi

    log "Erreur: source vidéo introuvable ($source)"
    return 1
}

remember_selected_video() {
    local selection="$1"
    ensure_cache_dir
    printf '%s\n' "$selection" > "$LAST_VIDEO_FILE"
}

set_wall_mode() {
    ensure_cache_dir
    printf '%s\n' "${1:-video}" > "$STATE_FILE"
}

get_wall_mode() {
    if [ -f "$STATE_FILE" ]; then
        local mode
        mode=$(<"$STATE_FILE")
        if [ -n "$mode" ]; then
            printf '%s\n' "$mode"
            return 0
        fi
    fi
    printf 'video\n'
}

run_pywal_sync_helpers() {
    if [ -x "$SCRIPTS_DIR/pywal-sync.sh" ]; then
        "$SCRIPTS_DIR/pywal-sync.sh" >/dev/null 2>&1 || log "Pywal-sync a retourné une erreur (ignorée)"
        return
    fi
    local helpers=(
        update-pywalfox
        wal2swaync
        generate-pywal-waybar-style
        generate-tofi-colors
        generate-kitty-colors
        generate-hyprland-colors
        generate-hyprlock-colors
        generate-swaync-colors
    )
    local helper
    for helper in "${helpers[@]}"; do
        if [ -x "$SCRIPTS_DIR/$helper.sh" ]; then
            "$SCRIPTS_DIR/$helper.sh" >/dev/null 2>&1 || true
        fi
    done
}

reload_ui_theme() {
    systemctl --user restart waybar.service >/dev/null 2>&1 || true
    systemctl --user restart swaync.service >/dev/null 2>&1 || true
    pkill -x tofi >/dev/null 2>&1 || true
    sleep 0.2
}

python_module_available() {
    local module="$1"
    python - <<PY >/dev/null 2>&1
import importlib
import sys
try:
    importlib.import_module("$module")
except Exception:
    sys.exit(1)
PY
}

apply_pywal_from_image() {
    local image="$1"
    local backend="$2"
    local log_file="$CACHE_DIR/wal.log"
    local cmd=(wal --cols16 -i "$image" -n)
    if [ -n "$backend" ] && [ "$backend" != "default" ]; then
        cmd+=(--backend "$backend")
    fi
    if "${cmd[@]}" >"$log_file" 2>&1; then
        log "Palette Pywal générée (backend ${backend:-default})"
        run_pywal_sync_helpers
        reload_ui_theme
        return 0
    fi
    log "Erreur wal backend ${backend:-default} (voir $log_file)"
    return 1
}

require_pywal_binary() {
    if ! command -v wal >/dev/null 2>&1; then
        log "Pywal non trouvé dans PATH, génération de couleurs ignorée."
        return 1
    fi
    return 0
}

first_registered_socket() {
    if [ ! -s "$SOCKETS_FILE" ]; then
        return 1
    fi
    awk -F: 'NR==1 {print $2}' "$SOCKETS_FILE"
}

request_mpv_screenshot() {
    local socket="$1"
    local target="$2"
    mpv_ipc_send "$socket" '{"command": ["screenshot-to-file", "'"$target"'", "video"]}'$'\n'
}

take_pywal_screenshot() {
    local socket="$1"
    local outfile="$2"
    request_mpv_screenshot "$socket" "$outfile" || return 1
    wait_for_file_with_size "$outfile" "$PYWAL_WAIT_SECONDS"
}

generate_pywal_theme() {
    if ! bool_enabled "$PYWAL_ENABLED"; then
        return
    fi
    require_pywal_binary || return
    wait_for_registered_sockets
    local socket
    socket=$(first_registered_socket) || {
        log "Aucun socket mpvpaper pour générer Pywal"
        return
    }
    mkdir -p "$PYWAL_SCREENSHOT_DIR"
    local shot="$PYWAL_SCREENSHOT_DIR/wallpaper.png"
    rm -f "$shot"
    local success=1
    local attempt
    for attempt in 1 2 3; do
        if take_pywal_screenshot "$socket" "$shot"; then
            success=0
            break
        fi
        sleep 0.5
    done
    if [ $success -ne 0 ]; then
        log "Impossible d'obtenir une capture mpv pour Pywal"
        rm -f "$shot"
        return
    fi

    if apply_pywal_from_image "$shot" "default"; then
        return
    fi

    local backend
    for backend in colorthief haishoku colorz; do
        if python_module_available "$backend" && apply_pywal_from_image "$shot" "$backend"; then
            return
        fi
    done

    log "Impossible de générer une palette Pywal pour ce wallpaper vidéo"
}

terminate_pid() {
    local pid=$1
    kill "$pid" 2>/dev/null || return
    for _ in {1..30}; do
        if ! kill -0 "$pid" 2>/dev/null; then
            return
        fi
        sleep 0.1
    done
    kill -9 "$pid" 2>/dev/null || true
}

require_binary() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log "Erreur: l'exécutable '$1' est introuvable." >&2
        exit 1
    fi
}

resolve_outputs() {
    if [ -n "$OUTPUTS_OVERRIDE" ]; then
        read -r -a manual <<< "$OUTPUTS_OVERRIDE"
        printf '%s\n' "${manual[@]}"
        return
    fi

    if command -v hyprctl >/dev/null 2>&1; then
        local detected
        detected=$(hyprctl monitors 2>/dev/null | awk '/Monitor / {gsub(":","",$2); print $2}') || true
        if [ -n "$detected" ]; then
            printf '%s\n' $detected
            return
        fi
    fi

    printf '%s\n' "eDP-1"
}

split_words() {
    local value="$1"
    if [ -z "$value" ]; then
        return
    fi
    # shellcheck disable=SC2206
    local arr=($value)
    printf '%s\n' "${arr[@]}"
}

kill_tracked_instances() {
    local cleaned=0
    if [ -f "$PID_FILE" ]; then
        while IFS= read -r pid; do
            [ -n "$pid" ] || continue
            if ps -p "$pid" -o comm= 2>/dev/null | grep -q mpvpaper; then
                log "Arrêt de mpvpaper (PID $pid)"
                terminate_pid "$pid"
                cleaned=1
            fi
        done < "$PID_FILE"
        rm -f "$PID_FILE"
    fi
    rm -f "$SOCKETS_FILE"

    if [ $cleaned -eq 0 ] && pgrep -x mpvpaper >/dev/null 2>&1; then
        log "Arrêt global de toutes les instances mpvpaper restantes"
        pkill -TERM -x mpvpaper >/dev/null 2>&1 || true
        sleep 0.5
        if pgrep -x mpvpaper >/dev/null 2>&1; then
            pkill -KILL -x mpvpaper >/dev/null 2>&1 || true
        fi
    fi
}

restore_static_wallpaper() {
    if [ -x "$HOME/.config/Scripts/wallpaper-manager.sh" ]; then
        log "Restauration du dernier wallpaper statique"
        "$HOME/.config/Scripts/wallpaper-manager.sh" restore >/dev/null 2>&1 || true
    fi
}

stop_swww_daemon() {
    if pgrep -x swww-daemon >/dev/null 2>&1; then
        log "Arrêt de swww-daemon pour libérer la couche arrière-plan"
        pkill -x swww-daemon >/dev/null 2>&1 || true
        sleep 0.3
    fi
}

wait_for_socket_path() {
    local path="$1"
    local max_checks=$((MPV_SOCKET_WAIT_SECONDS * 10))
    local i
    for ((i = 0; i < max_checks; i++)); do
        if [ -S "$path" ]; then
            return 0
        fi
        sleep 0.1
    done
    return 1
}

wait_for_file_with_size() {
    local path="$1"
    local timeout="${2:-5}"
    local max_checks=$((timeout * 10))
    local i
    for ((i = 0; i < max_checks; i++)); do
        if [ -s "$path" ]; then
            return 0
        fi
        sleep 0.1
    done
    return 1
}

wait_for_registered_sockets() {
    [ -f "$SOCKETS_FILE" ] || return 0
    while IFS=: read -r _ socket; do
        [ -n "$socket" ] || continue
        wait_for_socket_path "$socket" || log "Attention: socket IPC introuvable ($socket)"
    done < "$SOCKETS_FILE"
}

mpv_ipc_send() {
    local socket="$1"
    local payload="$2"
    [ -S "$socket" ] || return 1
    python3 - "$socket" "$payload" <<'PY' >/dev/null 2>&1
import socket
import sys

sock_path = sys.argv[1]
payload = sys.argv[2]

try:
    client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    client.settimeout(0.5)
    client.connect(sock_path)
    client.sendall(payload.encode('utf-8'))
finally:
    try:
        client.close()
    except Exception:
        pass
PY
}

broadcast_mpv_command() {
    local payload="$1"
    local any_sent=1
    if [ ! -f "$SOCKETS_FILE" ]; then
        return 1
    fi
    while IFS=: read -r _ socket; do
        [ -n "$socket" ] || continue
        mpv_ipc_send "$socket" "$payload" && any_sent=0
    done < "$SOCKETS_FILE"
    return $any_sent
}

pause_all_mpv() {
    if broadcast_mpv_command '{"command": ["set_property", "pause", true]}'$'\n'; then
        log "Pause mpvpaper (workspace occupé)"
    else
        log "Avertissement: impossible d'envoyer la commande de pause"
    fi
    return 0
}

resume_all_mpv() {
    if broadcast_mpv_command '{"command": ["set_property", "pause", false]}'$'\n'; then
        log "Lecture mpvpaper (workspace vide)"
    else
        log "Avertissement: impossible d'envoyer la commande de reprise"
    fi
    return 0
}

visible_window_count() {
    local monitors clients
    monitors=$(hyprctl -j monitors 2>/dev/null) || return 1
    clients=$(hyprctl -j clients 2>/dev/null) || return 1
    jq --null-input --argjson monitors "$monitors" --argjson clients "$clients" '
        def active_ids: ($monitors | map(.activeWorkspace.id // empty) | unique);
        def visible($c):
            ($c.mapped == true)
            and ($c.hidden == false)
            and ($c.workspace.name != "special")
            and ($c.workspace.id as $wid | (active_ids | index($wid)) != null);
        $clients | map(select(visible(.))) | length
    '
}

auto_pause_loop() {
    log "Auto-pause boucle démarrée"
    local last_state=""
    local last_windows=""
    while true; do
        if [ ! -s "$SOCKETS_FILE" ]; then
            sleep "$AUTO_PAUSE_INTERVAL"
            continue
        fi

        local windows
        if ! windows=$(visible_window_count); then
            sleep "$AUTO_PAUSE_INTERVAL"
            continue
        fi

        if [ "$windows" != "$last_windows" ]; then
            log "Fenêtres visibles: $windows"
            last_windows="$windows"
        fi

        if [ "$windows" -gt 0 ] && [ "$last_state" != "paused" ]; then
            pause_all_mpv
            last_state="paused"
        elif [ "$windows" -eq 0 ] && [ "$last_state" != "resumed" ]; then
            resume_all_mpv
            last_state="resumed"
        fi

        sleep "$AUTO_PAUSE_INTERVAL"
    done
}

ensure_auto_pause_dependencies() {
    require_binary hyprctl
    require_binary jq
    require_binary python3
}

start_auto_pause_daemon() {
    if ! bool_enabled "$AUTO_PAUSE_ENABLED"; then
        return
    fi
    ensure_auto_pause_dependencies
    stop_auto_pause_daemon
    wait_for_registered_sockets
    (
        trap '' HUP
        trap 'log "Auto-pause arrêté"; exit 0' TERM INT
        auto_pause_loop
    ) >> "$LOG_FILE" 2>&1 &
    echo $! > "$AUTO_PID_FILE"
    log "Auto-pause démarré (PID $(cat "$AUTO_PID_FILE"))"
}

stop_auto_pause_daemon() {
    if [ -f "$AUTO_PID_FILE" ]; then
        local pid
        pid=$(cat "$AUTO_PID_FILE" 2>/dev/null || true)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
            wait "$pid" 2>/dev/null || true
        fi
        rm -f "$AUTO_PID_FILE"
    fi
}

start_instances() {
    local video_file="${1:-}"
    if [ -z "$video_file" ]; then
        log "Erreur: aucune vidéo fournie à start_instances"
        return 1
    fi

    ensure_cache_dir
    : > "$PID_FILE"
    : > "$SOCKETS_FILE"

    local outputs=()
    while IFS= read -r output; do
        [ -n "$output" ] && outputs+=("$output")
    done < <(resolve_outputs)

    if [ ${#outputs[@]} -eq 0 ]; then
        outputs=("eDP-1")
    fi

    mapfile -t auto_flags < <(split_words "$AUTOMATION_FLAGS")
    mapfile -t extra_flags < <(split_words "$PAPER_FLAGS")

    for output in "${outputs[@]}"; do
        local socket_path="${IPC_BASE}-${output}"
        local socket_dir
        socket_dir=$(dirname "$socket_path")
        mkdir -p "$socket_dir"

        local cmd=(mpvpaper)
        if [ ${#auto_flags[@]} -gt 0 ]; then
            cmd+=("${auto_flags[@]}")
        fi
        if [ ${#extra_flags[@]} -gt 0 ]; then
            cmd+=("${extra_flags[@]}")
        fi
        local mpv_opts="$MPV_OPTIONS"
        if [[ "$mpv_opts" != *input-ipc-server* ]]; then
            mpv_opts+=" --input-ipc-server=$socket_path"
        fi
        cmd+=("--mpv-options" "$mpv_opts" "$output" "$video_file")

        "${cmd[@]}" >>"$LOG_FILE" 2>&1 &
        local pid=$!
        disown "$pid" || true
        echo "$pid" >> "$PID_FILE"
        log "mpvpaper lancé sur $output (PID $pid)"
        echo "$output:$socket_path" >> "$SOCKETS_FILE"
    done
}

start_command() {
    require_binary mpvpaper
    ensure_cache_dir

    local selected_video
    if ! selected_video=$(resolve_video_source "$VIDEO_PATH"); then
        exit 1
    fi
    log "Vidéo mpvpaper sélectionnée: $selected_video"
    remember_selected_video "$selected_video"
    VIDEO_SELECTION_OVERRIDE=""

    stop_auto_pause_daemon
    kill_tracked_instances
    stop_swww_daemon
    start_instances "$selected_video"
    generate_pywal_theme
    set_wall_mode video
    start_auto_pause_daemon
}

stop_command() {
    stop_auto_pause_daemon
    kill_tracked_instances
    set_wall_mode static
    restore_static_wallpaper
}

resume_command() {
    local mode
    mode=$(get_wall_mode)
    if [ "$mode" = "static" ]; then
        log "Dernier démarrage en mode statique : mpvpaper reste arrêté"
        stop_auto_pause_daemon
        kill_tracked_instances
        return 0
    fi
    start_command
}

status_command() {
    if pgrep -x mpvpaper >/dev/null 2>&1; then
        log "Instances mpvpaper actives:"
        pgrep -xa mpvpaper
        if [ -f "$PID_FILE" ]; then
            log "PIDs suivis: $(tr '\n' ' ' < "$PID_FILE")"
        fi
    else
        log "Aucune instance mpvpaper en cours."
    fi
}

usage() {
    cat <<'USAGE'
Usage: mpvpaper-wallpaper.sh [start|stop|restart|status]
  start    Lance mpvpaper sur chaque écran détecté (valeur par défaut)
  stop     Termine mpvpaper et restaure le wallpaper statique
  restart  Stop puis start
  status   Affiche l'état actuel
  resume   Redémarre selon le dernier mode mémorisé
  random   Force un nouveau clip aléatoire puis l'enregistre comme dernier choix
USAGE
}

main() {
    local action="${1:-start}"
    case "$action" in
        start)
            start_command
            ;;
        stop)
            stop_command
            ;;
        restart)
            stop_command
            start_command
            ;;
        resume)
            resume_command
            ;;
        random)
            VIDEO_SELECTION_OVERRIDE="random"
            start_command
            ;;
        status)
            status_command
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
