#!/bin/bash
set -euo pipefail

ENV_FILE="$HOME/.config/hypr/configs/env.conf"
CACHE_FILE="$HOME/.cache/current-cursor"
DEFAULT_CURSOR="catppuccin-mocha-blue-cursors"
DEFAULT_SIZE="24"

cursor="${DEFAULT_CURSOR}"
size="${DEFAULT_SIZE}"

if [ -s "$CACHE_FILE" ]; then
    read -r cached_cursor cached_size < "$CACHE_FILE"
    cursor="${cached_cursor:-$cursor}"
    size="${cached_size:-$size}"
fi

if [ -f "$ENV_FILE" ]; then
    theme_line=$(grep -E '^env = HYPRCURSOR_THEME,' "$ENV_FILE" | tail -n1 || true)
    size_line=$(grep -E '^env = HYPRCURSOR_SIZE,' "$ENV_FILE" | tail -n1 || true)
    if [ -n "$theme_line" ]; then
        cursor=$(printf '%s' "$theme_line" | cut -d',' -f2-)
    fi
    if [ -n "$size_line" ]; then
        size=$(printf '%s' "$size_line" | cut -d',' -f2-)
    fi
fi

cursor=${cursor:-$DEFAULT_CURSOR}
size=${size:-$DEFAULT_SIZE}

echo "$cursor $size" > "$CACHE_FILE"
hyprctl setcursor "$cursor" "$size" >/dev/null 2>&1 || true
hyprctl setoption cursor inactive_timeout 0 >/dev/null 2>&1 || true

if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface cursor-theme "$cursor" >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.interface cursor-size "$size" >/dev/null 2>&1 || true
fi
