#!/bin/bash
#  Capture d'écran automatique vers ~/Documents/Notes/Cours/Images/
# Fonctionne sous Wayland avec grim + slurp + wl-copy

# Dossier cible
base_dir="$HOME/Documents/Notes/Cours/Images"
mkdir -p "$base_dir"

# Nom de fichier horodaté
filename="$(date +%Y-%m-%d_%H-%M-%S).png"
filepath="$base_dir/$filename"

# Capture interactive et copie dans le presse-papiers
grim -g "$(slurp)" - | tee "$filepath" | wl-copy --type image/png

# Notification et message console
notify-send "Capture enregistrée" "$filepath"
echo "Capture enregistrée dans : $filepath"
