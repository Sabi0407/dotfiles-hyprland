#!/bin/bash

# Script de confirmation pour le reboot

# Afficher une boîte de dialogue de confirmation avec zenity
if zenity --question --title "Redémarrage" --text "Tu veux  redémarrer le système ?" --ok-label "Oui" --cancel-label "Non flemme" --window-icon=system-reboot; then
    # Si l'utilisateur clique sur "Oui"
    systemctl reboot
else
    # Si l'utilisateur clique sur "Non" ou ferme la fenêtre
    exit 0
fi 