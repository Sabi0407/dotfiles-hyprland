#!/bin/bash
set -euo pipefail
COLORS_SH="$HOME/.cache/wal/colors.sh"
OUT_DIR="$HOME/.config/hypr/colors"
OUT_FILE="$OUT_DIR/hyprlock-colors.conf"
mkdir -p "$OUT_DIR"
hex_to_rgba(){
  local hex="${1:-#ffffff}" alpha="${2:-1.0}"
  hex="${hex#\#}";[[ ${#hex} -eq 6 ]] || { echo "rgba(255,255,255,$alpha)";return; }
  printf 'rgba(%d,%d,%d,%s)\n' 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2} "$alpha"
}
if [[ -f "$COLORS_SH" ]]; then
  set +u
  source "$COLORS_SH"
  set -u
  hour_hex="${color11:-${color5:-#ffffff}}"
  minute_hex="${color13:-${color6:-#d0d0d0}}"
  second_hex="${color7:-${foreground:-#e0e0e0}}"
  label_hex="${color4:-${color11:-#ffffff}}"
else
  hour_hex="#ffb86c";minute_hex="#8be9fd";second_hex="#f8f8f2";label_hex="#ff79c6"
fi
{
  echo "# Couleurs Hyprlock générées automatiquement ($(date))"
  printf '$hyprlock_hour = %s\n' "$(hex_to_rgba "$hour_hex" "1.0")"
  printf '$hyprlock_minute = %s\n' "$(hex_to_rgba "$minute_hex" "1.0")"
  printf '$hyprlock_second = %s\n' "$(hex_to_rgba "$second_hex" "1.0")"
  printf '$hyprlock_label = %s\n' "$(hex_to_rgba "$label_hex" "1.0")"
} > "$OUT_FILE"
echo "[hyprlock-colors] Fichier mis à jour : $OUT_FILE"
