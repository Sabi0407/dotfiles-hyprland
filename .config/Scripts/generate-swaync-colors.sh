#!/bin/sh
LOCAL_CACHE_DIR="$HOME/.config/Scripts/wal-cache"
PYWAL_CACHE_DIR="${PYWAL_CACHE_DIR:-$LOCAL_CACHE_DIR}"
DEFAULT_PYWAL_CACHE="$HOME/.cache/wal"
mkdir -p "$PYWAL_CACHE_DIR"

SOURCE_FILE="$PYWAL_CACHE_DIR/colors.css"
if [ ! -f "$SOURCE_FILE" ] && [ -f "$DEFAULT_PYWAL_CACHE/colors.css" ]; then
  SOURCE_FILE="$DEFAULT_PYWAL_CACHE/colors.css"
fi

if [ ! -f "$SOURCE_FILE" ]; then
  echo "[generate-swaync-colors] Fichier colors.css introuvable" >&2
  exit 1
fi

cp "$SOURCE_FILE" "$HOME/.config/swaync/colors.css"
