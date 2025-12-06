#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pywal-common.sh
. "$SCRIPT_DIR/pywal-common.sh"

HYPR_CONFIG="$HOME/.config/hypr/configs/look.conf"
SPECIAL_WALLPAPERS=(
    "$HOME/Images/wallpapers/guts-berserk-dark.jpg"
    "$HOME/Images/wallpapers/berserk-guts-colored-5k-1920x1080-13633.jpg"
    "$HOME/Images/wallpapers/guts-berserk-dark-1920x1080-13650.jpg"
)
SPECIAL_ACCENT_PRIMARY="#d60f2c"
SPECIAL_ACCENT_SECONDARY="#8f3532"
SPECIAL_INACTIVE="#090404"

is_special_wallpaper() {
    local target="$1"
    [[ -z "$target" ]] && return 1
    local candidate base
    for candidate in "${SPECIAL_WALLPAPERS[@]}"; do
        base="${candidate%.*}"
        if [[ "$target" == "$candidate" || "$target" == "$base"-* ]]; then
            return 0
        fi
    done
    return 1
}

if ! pywal_source_colors; then
    echo "Pywal n'a pas encore généré de palette. Lancez 'wal' puis réessayez." >&2
    exit 1
fi

use_special=false
if [[ -n "${wallpaper:-}" ]] && is_special_wallpaper "$wallpaper"; then
    use_special=true
fi

if $use_special; then
    ACTIVE_PRIMARY="$(pywal_hex_to_rgba "$SPECIAL_ACCENT_PRIMARY" "1.0")"
    ACTIVE_SECONDARY="$(pywal_hex_to_rgba "$SPECIAL_ACCENT_SECONDARY" "1.0")"
    INACTIVE_COLOR="$(pywal_hex_to_rgba "$SPECIAL_INACTIVE" "0.9")"
else
    ACTIVE_PRIMARY="$(pywal_hex_to_rgba "${color1:-#ff0000}" "1.0")"
    ACTIVE_SECONDARY="$(pywal_hex_to_rgba "${color4:-#00ffcc}" "1.0")"
    INACTIVE_COLOR="$(pywal_hex_to_rgba "${background:-#1e1e2e}" "0.8")"
fi

echo " Génération des couleurs Hyprland avec pywal..."
echo "   Côté primaire: ${color1:-inconnu}"
echo "   Côté secondaire: ${color4:-inconnu}"
echo "   Inactive border: ${background:-inconnu}"

cat > /tmp/hyprland_colors_temp <<EOF
# Couleurs générées automatiquement par pywal
# Généré le $(date)
# Wallpaper source: $(cat ~/.config/dernier_wallpaper.txt 2>/dev/null || echo "Inconnu")

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 3
    
    # Dégradé simple : côté primaire vers côté secondaire
    col.active_border = $ACTIVE_PRIMARY $ACTIVE_SECONDARY 45deg
    col.inactive_border = $INACTIVE_COLOR
    
    resize_on_border = false
    allow_tearing = false
    layout = dwindle
}
EOF

# Lire le fichier de configuration actuel et remplacer la section general
if [[ -f "$HYPR_CONFIG" ]]; then
    # Créer un fichier temporaire avec tout sauf les sections general et animations en double
    awk '
    /^# Couleurs générées automatiquement par pywal/ { skip_block=1; next }
    /^general \{/ { skip=1; next }
    /^# Animation des bordures/ { skip_anim=1; next }
    /^animations \{/ && skip_anim { skip_anim_block=1; next }
    skip && /^\}/ { skip=0; next }
    skip_anim_block && /^\}/ { skip_anim_block=0; skip_anim=0; next }
    skip_block && /^$/ { skip_block=0; next }
    !skip && !skip_anim_block && !skip_block { print }
    ' "$HYPR_CONFIG" > /tmp/hyprland_config_temp
    
    # Ajouter la nouvelle section general
    cat /tmp/hyprland_config_temp /tmp/hyprland_colors_temp > "$HYPR_CONFIG"
    
    # Nettoyer
    rm -f /tmp/hyprland_config_temp /tmp/hyprland_colors_temp
    
    echo "Couleurs Hyprland mises à jour dans $HYPR_CONFIG"
    
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload
        echo "Configuration Hyprland rechargée"
    fi
    
    echo ""
    echo " Couleurs appliquées :"
    echo "   Dégradé: $ACTIVE_PRIMARY → $ACTIVE_SECONDARY"
    echo "   Inactive border: $INACTIVE_COLOR"
    
else
    echo " Fichier de configuration Hyprland introuvable : $HYPR_CONFIG"
    exit 1
fi
