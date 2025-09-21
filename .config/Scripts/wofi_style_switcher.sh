#!/bin/bash

# Script pour changer le style de Wofi

WOFI_DIR="$HOME/.config/wofi"

case "${1:-normal}" in
    "compact"|"c")
        echo "🎨 Passage en mode compact"
        cp "$WOFI_DIR/config.compact" "$WOFI_DIR/config"
        cp "$WOFI_DIR/style.compact.css" "$WOFI_DIR/style.css"
        
        # Régénérer les couleurs
        ~/.config/Scripts/generate-wofi-colors.sh
        
        echo "✅ Wofi configuré en mode compact"
        echo "   • Taille: 500x300"
        echo "   • 3 colonnes"
        echo "   • Icônes 20px"
        ;;
        
    "normal"|"n")
        echo "🎨 Passage en mode normal"
        # Restaurer depuis les sauvegardes ou recréer
        if [[ -f "$WOFI_DIR/config.backup" ]]; then
            cp "$WOFI_DIR/config.backup" "$WOFI_DIR/config"
        fi
        if [[ -f "$WOFI_DIR/style.backup.css" ]]; then
            cp "$WOFI_DIR/style.backup.css" "$WOFI_DIR/style.css"
        fi
        
        # Régénérer les couleurs
        ~/.config/Scripts/generate-wofi-colors.sh
        
        echo "✅ Wofi configuré en mode normal"
        echo "   • Taille: 580x360"
        echo "   • 2 colonnes"
        echo "   • Icônes 24px"
        ;;
        
    "test"|"t")
        echo "🧪 Test du Wofi actuel"
        wofi --show drun &
        ;;
        
    "backup"|"b")
        echo "💾 Sauvegarde des configurations actuelles"
        cp "$WOFI_DIR/config" "$WOFI_DIR/config.backup"
        cp "$WOFI_DIR/style.css" "$WOFI_DIR/style.backup.css"
        echo "✅ Sauvegarde créée"
        ;;
        
    *)
        echo "Usage: $0 {normal|compact|test|backup}"
        echo ""
        echo "Modes disponibles:"
        echo "  normal (n)  - Style moderne standard (580x360, 2 colonnes)"
        echo "  compact (c) - Style ultra-compact (500x300, 3 colonnes)"
        echo "  test (t)    - Tester Wofi avec la config actuelle"
        echo "  backup (b)  - Sauvegarder les configurations actuelles"
        echo ""
        echo "Configuration actuelle:"
        if [[ -f "$WOFI_DIR/config" ]]; then
            echo "  Taille: $(grep -E '^width|^height' "$WOFI_DIR/config" | tr '\n' ' ')"
            echo "  Colonnes: $(grep '^columns' "$WOFI_DIR/config" || echo 'columns=1 (défaut)')"
        fi
        ;;
esac
