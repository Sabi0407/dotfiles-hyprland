#!/bin/bash

# Script de confirmation pour l'extinction

# Afficher une boîte de dialogue de confirmation avec zenity
if zenity --question --title "Extinction" --text "Tu veux éteindre ton système?" --ok-label "Oui" --cancel-label "Non flemme" --window-icon=system-shutdown; then
    # Si l'utilisateur clique sur "Oui"
    systemctl poweroff
else
    # Si l'utilisateur clique sur "Non" ou ferme la fenêtre
    exit 0
fi 