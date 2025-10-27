#!/bin/bash
# Script de confirmation pour la déconnexion
# Utilise zenity pour demander confirmation avant de se déconnecter

# Demander confirmation avec zenity
zenity --question \
    --title="Déconnexion" \
    --text="Voulez-vous vraiment vous déconnecter ?" \
    --width=300 \
    --ok-label="Déconnexion" \
    --cancel-label="Annuler"

# Si l'utilisateur confirme (code de sortie 0)
if [ $? -eq 0 ]; then
    # Déconnexion d'Hyprland
    hyprctl dispatch exit
fi

