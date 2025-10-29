#!/bin/bash
#  Capture d'écran automatique vers ~/Documents/Notes/Cours/Images/
# Fonctionne sous Wayland avec grim + slurp + wl-copy

set -euo pipefail

base_dir="$HOME/Documents/Notes/Cours.BTS2/Images"
mkdir -p "$base_dir"

filename="$(date +%d-%m-%Y_%H-%M-%S).png"
filepath="$base_dir/$filename"

if ! region="$(slurp)"; then
    echo "Capture annulée."
    exit 1
fi

grim -g "$region" - | tee "$filepath" | wl-copy --type image/png

notify-send "Capture enregistrée" "$filepath"
echo "Capture enregistrée dans : $filepath"
