#!/bin/bash

DIR="$HOME/Vidéos/Capture_Videos"
mkdir -p "$DIR"
FILENAME="$DIR/recording-$(date +%F_%H-%M-%S).mp4"

command -v wf-recorder >/dev/null 2>&1 || { notify-send "Erreur" "wf-recorder non trouvé"; exit 1; }
command -v slurp >/dev/null 2>&1 || { notify-send "Erreur" "slurp non trouvé"; exit 1; }

notify-send "Enregistrement" "Début de l'enregistrement"
wf-recorder --audio -g "$(slurp)" -f "$FILENAME"
