#!/usr/bin/env bash
set -euo pipefail

# Affiche tous les binds connus par Hyprland dans un menu de type dmenu (wofi ici).
# Sélectionner une ligne ferme simplement le menu (c'est un "rappel" / cheat-sheet).
hyprctl binds | sed '/^\s*$/d' | wofi --dmenu -i -p "Raccourcis Hyprland" >/dev/null
