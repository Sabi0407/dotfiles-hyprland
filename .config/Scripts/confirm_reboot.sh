#!/bin/bash

run_zenity_dark() {
  # Appliquer le thème Catppuccin Mocha Red à Zenity
  GTK_THEME="catppuccin-mocha-red-standard+default" zenity "$@" 2> >(grep -v "Adwaita-WARNING")
}

# Script de confirmation pour le reboot

# Afficher une boîte de dialogue de confirmation avec zenity
if run_zenity_dark --question --title "Redémarrage" --text "Tu veux  redémarrer le système ?" --ok-label "Oui" --cancel-label "Non flemme" --window-icon=system-reboot; then
    # Si l'utilisateur clique sur "Oui"
    systemctl reboot
else
    # Si l'utilisateur clique sur "Non" ou ferme la fenêtre
    exit 0
fi