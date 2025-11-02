#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pywal-common.sh
. "$SCRIPT_DIR/pywal-common.sh"

TEMPLATE="$HOME/.config/waybar/style.template.css"
OUT="$HOME/.config/waybar/style.css"

if ! pywal_source_colors; then
    pywal_warn "Aucune palette pywal trouvée, utilisation de couleurs de secours."
fi

fallback() {
    local key="$1" value=""
    if [[ "${PYWAL_COLORS_STATUS:-1}" -eq 0 ]]; then
        value="$(eval "printf '%s' \"\${$key:-}\"")"
    fi
    if [[ -z "$value" ]]; then
        case "$key" in
            background) value="#22223b" ;;
            foreground) value="#e0e0e0" ;;
            color0) value="#22223b" ;;
            color1) value="#ef4444" ;;
            color2) value="#4ade80" ;;
            color3) value="#f97316" ;;
            color4) value="#2563eb" ;;
            color5) value="#a21caf" ;;
            color6) value="#0891b2" ;;
            color7) value="#a1a1aa" ;;
            color8) value="#27272a" ;;
            color9) value="#f43f5e" ;;
            color10) value="#22d3ee" ;;
            color11) value="#fde68a" ;;
            color12) value="#818cf8" ;;
            color13) value="#f472b6" ;;
            color14) value="#34d399" ;;
            color15) value="#f1f5f9" ;;
            *) value="#ffffff" ;;
        esac
    fi
    printf '%s\n' "$value"
}

sed \
  -e "s|{background}|$(fallback background)|g" \
  -e "s|{foreground}|$(fallback foreground)|g" \
  -e "s|{color0}|$(fallback color0)|g" \
  -e "s|{color1}|$(fallback color1)|g" \
  -e "s|{color2}|$(fallback color2)|g" \
  -e "s|{color3}|$(fallback color3)|g" \
  -e "s|{color4}|$(fallback color4)|g" \
  -e "s|{color5}|$(fallback color5)|g" \
  -e "s|{color6}|$(fallback color6)|g" \
  -e "s|{color7}|$(fallback color7)|g" \
  -e "s|{color8}|$(fallback color8)|g" \
  -e "s|{color9}|$(fallback color9)|g" \
  -e "s|{color10}|$(fallback color10)|g" \
  -e "s|{color11}|$(fallback color11)|g" \
  -e "s|{color12}|$(fallback color12)|g" \
  -e "s|{color13}|$(fallback color13)|g" \
  -e "s|{color14}|$(fallback color14)|g" \
  -e "s|{color15}|$(fallback color15)|g" \
  -e "s|{background-rgb}|$(pywal_hex_to_rgb "$(fallback background)")|g" \
  -e "s|{foreground-rgb}|$(pywal_hex_to_rgb "$(fallback foreground)")|g" \
  -e "s|{color0-rgb}|$(pywal_hex_to_rgb "$(fallback color0)")|g" \
  -e "s|{color1-rgb}|$(pywal_hex_to_rgb "$(fallback color1)")|g" \
  -e "s|{color2-rgb}|$(pywal_hex_to_rgb "$(fallback color2)")|g" \
  -e "s|{color3-rgb}|$(pywal_hex_to_rgb "$(fallback color3)")|g" \
  -e "s|{color4-rgb}|$(pywal_hex_to_rgb "$(fallback color4)")|g" \
  -e "s|{color5-rgb}|$(pywal_hex_to_rgb "$(fallback color5)")|g" \
  -e "s|{color6-rgb}|$(pywal_hex_to_rgb "$(fallback color6)")|g" \
  -e "s|{color7-rgb}|$(pywal_hex_to_rgb "$(fallback color7)")|g" \
  -e "s|{color8-rgb}|$(pywal_hex_to_rgb "$(fallback color8)")|g" \
  -e "s|{color9-rgb}|$(pywal_hex_to_rgb "$(fallback color9)")|g" \
  -e "s|{color10-rgb}|$(pywal_hex_to_rgb "$(fallback color10)")|g" \
  -e "s|{color11-rgb}|$(pywal_hex_to_rgb "$(fallback color11)")|g" \
  -e "s|{color12-rgb}|$(pywal_hex_to_rgb "$(fallback color12)")|g" \
  -e "s|{color13-rgb}|$(pywal_hex_to_rgb "$(fallback color13)")|g" \
  -e "s|{color14-rgb}|$(pywal_hex_to_rgb "$(fallback color14)")|g" \
  -e "s|{color15-rgb}|$(pywal_hex_to_rgb "$(fallback color15)")|g" \
  "$TEMPLATE" > "$OUT"
