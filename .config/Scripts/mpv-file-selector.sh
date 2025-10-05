#!/bin/bash
# Script pour sélectionner et lire une vidéo avec MPV via zenity

# Ouvrir le sélecteur de fichiers en mode compact
VIDEO_FILE=$(zenity --file-selection \
    --title="Sélectionner une vidéo" \
    --width=600 \
    --height=400 \
    --file-filter="Vidéos | *.mp4 *.mkv *.avi *.mov *.wmv *.flv *.webm *.m4v *.mpg *.mpeg" \
    --file-filter="Audio | *.mp3 *.flac *.wav *.ogg *.m4a *.aac *.opus" \
    --file-filter="Tous les fichiers | *" \
    2>/dev/null)

# Si l'utilisateur annule ou ne sélectionne rien
if [ -z "$VIDEO_FILE" ]; then
    exit 0
fi

# Vérifier que le fichier existe
if [ ! -f "$VIDEO_FILE" ]; then
    zenity --error \
        --title="Erreur" \
        --text="Le fichier sélectionné n'existe pas !" \
        2>/dev/null
    exit 1
fi

# Lancer MPV avec le fichier sélectionné
mpv "$VIDEO_FILE" &
