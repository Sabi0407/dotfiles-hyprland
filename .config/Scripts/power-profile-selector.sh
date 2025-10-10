#!/bin/bash

# Script zenity compact pour sélectionner le profil d'alimentation
# Interface floating moderne pour Hyprland

# Vérifier si powerprofilesctl est disponible
if ! command -v powerprofilesctl &> /dev/null; then
    zenity --error --text="powerprofilesctl n'est pas installé" --width=300
    exit 1
fi

# Obtenir le profil actuel
current_profile=$(powerprofilesctl get)

# Créer la liste des profils avec le profil actuel marqué
profiles=(
    "performance" "🚀 Performance (Max CPU)"
    "balanced" "⚖️ Équilibré (Recommandé)"
    "power-saver" "🔋 Économie d'énergie"
)

# Marquer le profil actuel
for i in "${!profiles[@]}"; do
    if [[ "${profiles[$i]}" == "$current_profile" ]]; then
        profiles[$((i+1))]="✅ ${profiles[$((i+1))]}"
    fi
done

# Afficher le sélecteur zenity
selected=$(zenity --list \
    --title="Profil d'alimentation" \
    --text="Profil actuel: $current_profile" \
    --column="Profil" --column="Description" \
    "${profiles[@]}" \
    --width=400 \
    --height=250 \
    --hide-header \
    --ok-label="Appliquer" \
    --cancel-label="Annuler")

# Appliquer le profil sélectionné
if [ -n "$selected" ]; then
    case "$selected" in
        "performance")
            powerprofilesctl set performance
            notify-send "Profil d'alimentation" "Performance activé 🚀" --icon=battery
            ;;
        "balanced")
            powerprofilesctl set balanced
            notify-send "Profil d'alimentation" "Équilibré activé ⚖️" --icon=battery
            ;;
        "power-saver")
            powerprofilesctl set power-saver
            notify-send "Profil d'alimentation" "Économie d'énergie activée 🔋" --icon=battery
            ;;
    esac
fi
