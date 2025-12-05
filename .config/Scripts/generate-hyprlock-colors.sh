#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pywal-common.sh
. "$SCRIPT_DIR/pywal-common.sh"

OUT_DIR="$HOME/.config/hypr/colors"
OUT_FILE="$OUT_DIR/hyprlock-colors.conf"
mkdir -p "$OUT_DIR"

fallback_hour="#ffb86c"
fallback_minute="#8be9fd"
fallback_second="#f8f8f2"
fallback_label="#ff79c6"

if pywal_source_colors; then
    hour_hex="${color11:-${color5:-$fallback_hour}}"
    minute_hex="${color13:-${color6:-$fallback_minute}}"
    second_hex="${color7:-${foreground:-$fallback_second}}"
    label_hex="${color4:-${color11:-$fallback_label}}"
else
    pywal_warn "palette introuvable, utilisation des couleurs de secours."
    hour_hex="$fallback_hour"
    minute_hex="$fallback_minute"
    second_hex="$fallback_second"
    label_hex="$fallback_label"
fi

hour_rgba="$(pywal_hex_to_rgba "$hour_hex" "1.0")"
minute_rgba="$(pywal_hex_to_rgba "$minute_hex" "1.0")"
second_rgba="$(pywal_hex_to_rgba "$second_hex" "1.0")"
label_rgba="$(pywal_hex_to_rgba "$label_hex" "1.0")"

{
    echo "# Couleurs Hyprlock générées automatiquement ($(date))"
    printf '$hyprlock_hour = %s\n' "$hour_rgba"
    printf '$hyprlock_minute = %s\n' "$minute_rgba"
    printf '$hyprlock_second = %s\n' "$second_rgba"
    printf '$hyprlock_label = %s\n' "$label_rgba"
} > "$OUT_FILE"

CSS_EXPORT="$HOME/.config/swaync/hyprlock-colors.css"
mkdir -p "$(dirname "$CSS_EXPORT")"
{
    echo "/* Hyprlock colors exported for GTK / swaync ($(date)) */"
    printf '@define-color hyprlock_hour %s;\n' "$hour_rgba"
    printf '@define-color hyprlock_minute %s;\n' "$minute_rgba"
    printf '@define-color hyprlock_second %s;\n' "$second_rgba"
    printf '@define-color hyprlock_label %s;\n' "$label_rgba"
} > "$CSS_EXPORT"

echo "[hyprlock-colors] Fichiers mis à jour : $OUT_FILE et $CSS_EXPORT"
