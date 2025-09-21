#!/bin/bash

# Couleurs de bordure qui changent selon l'heure du jour

# Charger les couleurs pywal
source "$HOME/.cache/wal/colors.sh" 2>/dev/null || exit 1

# Obtenir l'heure actuelle
HOUR=$(date +%H)

# Fonction pour mélanger deux couleurs selon un ratio
blend_colors() {
    local color1="$1"  # Format: #RRGGBB
    local color2="$2"  # Format: #RRGGBB
    local ratio="$3"   # 0.0 à 1.0
    
    # Extraire RGB de color1
    local r1=$((16#${color1:1:2}))
    local g1=$((16#${color1:3:2}))
    local b1=$((16#${color1:5:2}))
    
    # Extraire RGB de color2
    local r2=$((16#${color2:1:2}))
    local g2=$((16#${color2:3:2}))
    local b2=$((16#${color2:5:2}))
    
    # Calculer le mélange
    local r=$(echo "$r1 + ($r2 - $r1) * $ratio" | bc -l | cut -d. -f1)
    local g=$(echo "$g1 + ($g2 - $g1) * $ratio" | bc -l | cut -d. -f1)
    local b=$(echo "$b1 + ($b2 - $b1) * $ratio" | bc -l | cut -d. -f1)
    
    echo "rgba($r,$g,$b,1.0)"
}

# Définir les couleurs selon l'heure
if [[ $HOUR -ge 6 && $HOUR -lt 12 ]]; then
    # Matin (6h-12h) : couleurs douces et claires
    echo "🌅 Couleurs du matin"
    COLOR1=$(blend_colors "$color1" "#FFD700" 0.3)  # Doré
    COLOR2=$(blend_colors "$color2" "#FFA500" 0.3)  # Orange
    
elif [[ $HOUR -ge 12 && $HOUR -lt 18 ]]; then
    # Après-midi (12h-18h) : couleurs vives
    echo "☀️ Couleurs de l'après-midi"
    COLOR1=$(blend_colors "$color1" "#FF6B6B" 0.2)  # Rouge vif
    COLOR2=$(blend_colors "$color4" "#4ECDC4" 0.2)  # Turquoise
    
elif [[ $HOUR -ge 18 && $HOUR -lt 22 ]]; then
    # Soirée (18h-22h) : couleurs chaudes
    echo "🌆 Couleurs du soir"
    COLOR1=$(blend_colors "$color3" "#FF8C42" 0.4)  # Orange chaud
    COLOR2=$(blend_colors "$color5" "#C73E1D" 0.4)  # Rouge chaud
    
else
    # Nuit (22h-6h) : couleurs sombres et apaisantes
    echo "🌙 Couleurs de la nuit"
    COLOR1=$(blend_colors "$color1" "#2C3E50" 0.5)  # Bleu foncé
    COLOR2=$(blend_colors "$color2" "#34495E" 0.5)  # Gris bleu
fi

# Appliquer les couleurs
hyprctl keyword general:col.active_border "$COLOR1 $COLOR2 45deg"

echo "✅ Couleurs appliquées pour l'heure actuelle (${HOUR}h)"
