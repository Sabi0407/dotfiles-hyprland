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

{
    echo "# Couleurs Hyprlock générées automatiquement ($(date))"
    printf '$hyprlock_hour = %s\n' "$(pywal_hex_to_rgba "$hour_hex" "1.0")"
    printf '$hyprlock_minute = %s\n' "$(pywal_hex_to_rgba "$minute_hex" "1.0")"
    printf '$hyprlock_second = %s\n' "$(pywal_hex_to_rgba "$second_hex" "1.0")"
    printf '$hyprlock_label = %s\n' "$(pywal_hex_to_rgba "$label_hex" "1.0")"
} > "$OUT_FILE"

echo "[hyprlock-colors] Fichier mis à jour : $OUT_FILE"
