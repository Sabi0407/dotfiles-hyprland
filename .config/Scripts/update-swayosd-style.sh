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

if [ -f "$SRC" ]; then
    install -Dm644 "$SRC" "$DST"
    systemctl --user reload-or-restart swayosd.service >/dev/null 2>&1 || true
fi
