#!/bin/sh
TEMPLATE="$HOME/.config/waybar/style.template.css"
OUT="$HOME/.config/waybar/style.css"

# Charger les couleurs pywal si possible
if [ -f "$HOME/.cache/wal/colors.sh" ]; then
    . "$HOME/.cache/wal/colors.sh"
else
    echo "[pywal-waybar] Avertissement : ~/.cache/wal/colors.sh introuvable, utilisation des couleurs par défaut."
fi

# Définir des couleurs de secours si une variable n'est pas définie
fallback() {
    eval "val=\${$1}"
    if [ -z "$val" ]; then
        case "$1" in
            background) echo "#22223b" ;;
            foreground) echo "#e0e0e0" ;;
            color0) echo "#22223b" ;;
            color1) echo "#ef4444" ;;
            color2) echo "#4ade80" ;;
            color3) echo "#f97316" ;;
            color4) echo "#2563eb" ;;
            color5) echo "#a21caf" ;;
            color6) echo "#0891b2" ;;
            color7) echo "#a1a1aa" ;;
            color8) echo "#27272a" ;;
            color9) echo "#f43f5e" ;;
            color10) echo "#22d3ee" ;;
            color11) echo "#fde68a" ;;
            color12) echo "#818cf8" ;;
            color13) echo "#f472b6" ;;
            color14) echo "#34d399" ;;
            color15) echo "#f1f5f9" ;;
            *) echo "#ffffff" ;;
        esac
        echo "[pywal-waybar] Avertissement : $1 non défini, couleur de secours utilisée." >&2
    else
        echo "$val"
    fi
}

# Convertit une couleur hexadécimale en r,g,b
hex_to_rgb() {
    hex="${1#'#'}" # retire le # éventuel
    if [ ${#hex} -eq 6 ]; then
        r=$((16#${hex:0:2}))
        g=$((16#${hex:2:2}))
        b=$((16#${hex:4:2}))
        echo "$r,$g,$b"
    else
        echo "0,0,0"
    fi
}

# Génère le CSS Waybar à partir du template
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
  -e "s|{background-rgb}|$(hex_to_rgb $(fallback background))|g" \
  -e "s|{foreground-rgb}|$(hex_to_rgb $(fallback foreground))|g" \
  -e "s|{color0-rgb}|$(hex_to_rgb $(fallback color0))|g" \
  -e "s|{color1-rgb}|$(hex_to_rgb $(fallback color1))|g" \
  -e "s|{color2-rgb}|$(hex_to_rgb $(fallback color2))|g" \
  -e "s|{color3-rgb}|$(hex_to_rgb $(fallback color3))|g" \
  -e "s|{color4-rgb}|$(hex_to_rgb $(fallback color4))|g" \
  -e "s|{color5-rgb}|$(hex_to_rgb $(fallback color5))|g" \
  -e "s|{color6-rgb}|$(hex_to_rgb $(fallback color6))|g" \
  -e "s|{color7-rgb}|$(hex_to_rgb $(fallback color7))|g" \
  -e "s|{color8-rgb}|$(hex_to_rgb $(fallback color8))|g" \
  -e "s|{color9-rgb}|$(hex_to_rgb $(fallback color9))|g" \
  -e "s|{color10-rgb}|$(hex_to_rgb $(fallback color10))|g" \
  -e "s|{color11-rgb}|$(hex_to_rgb $(fallback color11))|g" \
  -e "s|{color12-rgb}|$(hex_to_rgb $(fallback color12))|g" \
  -e "s|{color13-rgb}|$(hex_to_rgb $(fallback color13))|g" \
  -e "s|{color14-rgb}|$(hex_to_rgb $(fallback color14))|g" \
  -e "s|{color15-rgb}|$(hex_to_rgb $(fallback color15))|g" \
  "$TEMPLATE" > "$OUT" 