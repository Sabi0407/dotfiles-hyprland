#!/bin/bash

# Script pour générer les couleurs Hyprland à partir de pywal

# Vérifier que pywal a été exécuté
if [[ ! -f "$HOME/.cache/wal/colors.sh" ]]; then
    echo "❌ Pywal n'a pas été exécuté. Lancez d'abord 'wal -i /path/to/image'"
    exit 1
fi

# Charger les couleurs pywal
source "$HOME/.cache/wal/colors.sh"

# Fichier de configuration Hyprland
HYPR_CONFIG="$HOME/.config/hypr/configs/look.conf"

# Sauvegarder le fichier original si ce n'est pas déjà fait
if [[ ! -f "${HYPR_CONFIG}.backup" ]]; then
    cp "$HYPR_CONFIG" "${HYPR_CONFIG}.backup"
    echo "✅ Sauvegarde créée : ${HYPR_CONFIG}.backup"
fi

# Fonction pour convertir hex en rgba
hex_to_rgba() {
    local hex="$1"
    local alpha="${2:-1.0}"
    
    # Supprimer le # si présent
    hex="${hex#\#}"
    
    # Convertir en RGB
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    
    echo "rgba($r,$g,$b,$alpha)"
}

# Générer les couleurs de bordure simples
# Active border : côté primaire + côté secondaire sur la même fenêtre
ACTIVE_PRIMARY=$(hex_to_rgba "$color1" "1.0")    # Couleur primaire (côté principal)
ACTIVE_SECONDARY=$(hex_to_rgba "$color4" "1.0")  # Couleur secondaire (côté opposé)

# Inactive border : utilise background avec un peu de transparence
INACTIVE_COLOR=$(hex_to_rgba "$background" "0.8")

echo "🎨 Génération des couleurs Hyprland avec pywal..."
echo "   Côté primaire: $color1"
echo "   Côté secondaire: $color4"
echo "   Inactive border: $background"

# Créer le fichier temporaire avec les nouvelles couleurs
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
    
    echo "✅ Couleurs Hyprland mises à jour dans $HYPR_CONFIG"
    
    # Recharger la configuration Hyprland
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload
        echo "✅ Configuration Hyprland rechargée"
    fi
    
    # Afficher les couleurs appliquées
    echo ""
    echo "🎨 Couleurs appliquées :"
    echo "   Dégradé: $ACTIVE_PRIMARY → $ACTIVE_SECONDARY"
    echo "   Inactive border: $INACTIVE_COLOR"
    
else
    echo "❌ Fichier de configuration Hyprland introuvable : $HYPR_CONFIG"
    exit 1
fi
