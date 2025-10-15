#!/bin/sh
# Génère ~/.config/kitty/colors.conf à partir de pywal
LOCAL_CACHE_DIR="$HOME/.config/Scripts/wal-cache"
PYWAL_CACHE_DIR="${PYWAL_CACHE_DIR:-$LOCAL_CACHE_DIR}"
DEFAULT_PYWAL_CACHE="$HOME/.cache/wal"
mkdir -p "$PYWAL_CACHE_DIR"

SOURCE_FILE="$PYWAL_CACHE_DIR/colors-kitty.conf"

if [ ! -f "$SOURCE_FILE" ] && [ -f "$DEFAULT_PYWAL_CACHE/colors-kitty.conf" ]; then
  SOURCE_FILE="$DEFAULT_PYWAL_CACHE/colors-kitty.conf"
fi

if [ ! -f "$SOURCE_FILE" ]; then
  echo "[generate-kitty-colors] Fichier colors-kitty.conf introuvable" >&2
  exit 1
fi

cp "$SOURCE_FILE" "$HOME/.config/kitty/colors.conf"
