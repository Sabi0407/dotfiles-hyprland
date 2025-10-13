#!/bin/bash

set -euo pipefail

COLORS_SH="$HOME/.cache/wal/colors.sh"
OUT_DIR="$HOME/.config/hypr/generated"
OUT_FILE="$OUT_DIR/hyprlock-colors.conf"

mkdir -p "$OUT_DIR"

hex_to_rgba() {
    local hex="${1:-#ffffff}"
    local alpha="${2:-1.0}"

    hex="${hex#\#}"

    if [[ ${#hex} -ne 6 ]]; then
        echo "rgba(255,255,255,${alpha})"
        return
    fi

    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    echo "rgba(${r},${g},${b},${alpha})"
}

if [[ -f "$COLORS_SH" ]]; then
    set +u
    # shellcheck disable=SC1090
    source "$COLORS_SH"
    set -u

hour_hex="${color11:-${color5:-#ffffff}}"
minute_hex="${color13:-${color6:-#d0d0d0}}"
second_hex="${color7:-${foreground:-#e0e0e0}}"
else
    echo "[hyprlock-colors] Avertissement: $COLORS_SH introuvable, utilisation des couleurs par défaut." >&2
    hour_hex="#ffb86c"
    minute_hex="#8be9fd"
    second_hex="#f8f8f2"
fi

{
    echo "# Couleurs Hyprlock générées automatiquement ($(date))"
    printf '$hyprlock_hour = %s\n' "$(hex_to_rgba "$hour_hex" "1.0")"
    printf '$hyprlock_minute = %s\n' "$(hex_to_rgba "$minute_hex" "1.0")"
    printf '$hyprlock_second = %s\n' "$(hex_to_rgba "$second_hex" "1.0")"
} > "$OUT_FILE"

echo "[hyprlock-colors] Fichier mis à jour : $OUT_FILE"
