#!/bin/bash

# Script de test pour les couleurs Hyprland avec pywal

echo "🎨 Test des couleurs Hyprland avec pywal"
echo

# Vérifier que pywal a des couleurs
if [[ -f "$HOME/.cache/wal/colors.sh" ]]; then
    source "$HOME/.cache/wal/colors.sh"
    
    echo "Couleurs pywal actuelles :"
    echo "  Background: $background"
    echo "  Foreground: $foreground"
    echo "  Color1: $color1"
    echo "  Color5: $color5"
    echo
    
    # Exécuter le script de génération
    ~/.config/Scripts/generate-hyprland-colors.sh
    
    echo
    echo "✅ Test terminé !"
    echo "Les bordures de vos fenêtres Hyprland devraient maintenant"
    echo "utiliser les couleurs du wallpaper actuel."
    
else
    echo "❌ Aucune couleur pywal trouvée"
    echo "Veuillez d'abord changer un wallpaper avec pywal"
fi
