#!/bin/bash

# Script pour des couleurs de bordure dynamiques qui changent en temps réel

# Charger les couleurs pywal
if [[ ! -f "$HOME/.cache/wal/colors.sh" ]]; then
    echo "❌ Pywal requis. Lancez d'abord un wallpaper avec pywal."
    exit 1
fi

source "$HOME/.cache/wal/colors.sh"

# Fonction pour créer des variations de couleur
create_color_variations() {
    local base_color="$1"
    local variations=()
    
    # Supprimer le #
    base_color="${base_color#\#}"
    
    # Extraire RGB
    local r=$((16#${base_color:0:2}))
    local g=$((16#${base_color:2:2}))
    local b=$((16#${base_color:4:2}))
    
    # Créer des variations (plus clair, plus foncé, saturé)
    variations[0]="rgba($r,$g,$b,1.0)"
    variations[1]="rgba($((r + 30 > 255 ? 255 : r + 30)),$((g + 30 > 255 ? 255 : g + 30)),$((b + 30 > 255 ? 255 : b + 30)),1.0)"
    variations[2]="rgba($((r - 30 < 0 ? 0 : r - 30)),$((g - 30 < 0 ? 0 : g - 30)),$((b - 30 < 0 ? 0 : b - 30)),1.0)"
    variations[3]="rgba($((r + 50 > 255 ? 255 : r + 50)),$g,$b,1.0)"
    
    printf '%s\n' "${variations[@]}"
}

# Mode de couleurs dynamiques
case "${1:-cycle}" in
    "cycle")
        echo "🌈 Mode cycle de couleurs activé"
        
        # Créer des variations basées sur les couleurs pywal
        mapfile -t colors1 < <(create_color_variations "$color1")
        mapfile -t colors2 < <(create_color_variations "$color4")
        
        for i in {0..3}; do
            echo "Couleur $((i+1))/4..."
            
            # Appliquer la couleur
            hyprctl keyword general:col.active_border "${colors1[i]} ${colors2[i]} 45deg"
            
            sleep 2
        done
        
        echo "✅ Cycle terminé"
        ;;
        
    "rainbow")
        echo "🌈 Mode arc-en-ciel activé"
        
        # Couleurs arc-en-ciel basées sur les couleurs pywal
        local rainbow_colors=(
            "rgba(255,0,0,1.0) rgba(255,127,0,1.0) 45deg"      # Rouge-Orange
            "rgba(255,127,0,1.0) rgba(255,255,0,1.0) 45deg"    # Orange-Jaune
            "rgba(255,255,0,1.0) rgba(0,255,0,1.0) 45deg"      # Jaune-Vert
            "rgba(0,255,0,1.0) rgba(0,255,255,1.0) 45deg"      # Vert-Cyan
            "rgba(0,255,255,1.0) rgba(0,0,255,1.0) 45deg"      # Cyan-Bleu
            "rgba(0,0,255,1.0) rgba(127,0,255,1.0) 45deg"      # Bleu-Violet
            "rgba(127,0,255,1.0) rgba(255,0,255,1.0) 45deg"    # Violet-Magenta
            "rgba(255,0,255,1.0) rgba(255,0,0,1.0) 45deg"      # Magenta-Rouge
        )
        
        for color in "${rainbow_colors[@]}"; do
            hyprctl keyword general:col.active_border "$color"
            sleep 1
        done
        
        echo "✅ Arc-en-ciel terminé"
        ;;
        
    "pulse")
        echo "💓 Mode pulsation activé"
        
        # Couleur de base
        local base_r=$((16#${color1:1:2}))
        local base_g=$((16#${color1:3:2}))
        local base_b=$((16#${color1:5:2}))
        
        for intensity in {50..100..10} {100..50..-10}; do
            local r=$((base_r * intensity / 100))
            local g=$((base_g * intensity / 100))
            local b=$((base_b * intensity / 100))
            
            hyprctl keyword general:col.active_border "rgba($r,$g,$b,1.0) rgba($((r+30)),$((g+30)),$((b+30)),1.0) 45deg"
            sleep 0.5
        done
        
        echo "✅ Pulsation terminée"
        ;;
        
    "restore")
        echo "🔄 Restauration des couleurs pywal..."
        ~/.config/Scripts/generate-hyprland-colors.sh
        ;;
        
    *)
        echo "Usage: $0 {cycle|rainbow|pulse|restore}"
        echo "  cycle    - Cycle à travers les variations de couleurs pywal"
        echo "  rainbow  - Animation arc-en-ciel"
        echo "  pulse    - Effet de pulsation"
        echo "  restore  - Restaurer les couleurs pywal normales"
        ;;
esac
