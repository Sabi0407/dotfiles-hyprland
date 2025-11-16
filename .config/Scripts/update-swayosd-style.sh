#!/bin/bash
set -euo pipefail

DEFAULT_SRC="$HOME/.config/wal/cache/swayosd-style.css"
ALT_SRC="${XDG_CACHE_HOME:-$HOME/.cache}/wal/swayosd-style.css"
if [ -f "$DEFAULT_SRC" ]; then
    SRC="$DEFAULT_SRC"
else
    SRC="$ALT_SRC"
fi
DST="${XDG_CONFIG_HOME:-$HOME/.config}/swayosd/style.css"

resolve_swayosd_binary() {
    if command -v swayosd >/dev/null 2>&1; then
        printf 'swayosd\n'
        return 0
    fi
    if command -v swayosd-server >/dev/null 2>&1; then
        printf 'swayosd-server\n'
        return 0
    fi
    return 1
}

restart_swayosd() {
    if systemctl --user reload-or-restart swayosd.service >/dev/null 2>&1; then
        return
    fi
    local bin
    if ! bin="$(resolve_swayosd_binary)"; then
        echo "[update-swayosd-style] Binaire swayosd introuvable." >&2
        return
    fi
    pkill -x swayosd >/dev/null 2>&1 || true
    pkill -x swayosd-server >/dev/null 2>&1 || true
    sleep 0.2
    nohup "$bin" >/dev/null 2>&1 &
}

if [ -f "$SRC" ]; then
    install -Dm644 "$SRC" "$DST"
    restart_swayosd
fi
