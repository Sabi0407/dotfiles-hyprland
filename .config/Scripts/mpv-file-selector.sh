#!/bin/bash
# Script pour ouvrir un dossier ou sélectionner un fichier vidéo avec MPV

# Répertoire par défaut pour les vidéos (français)
VIDEO_DIR="$HOME/Vidéos"
# Si le dossier français n'existe pas, essayer l'anglais
[ ! -d "$VIDEO_DIR" ] && VIDEO_DIR="$HOME/Videos"
# Si aucun dossier vidéo, utiliser le home
[ ! -d "$VIDEO_DIR" ] && VIDEO_DIR="$HOME"

# Vérifier que zenity est installé
if ! command -v zenity &> /dev/null; then
    notify-send "Erreur" "Zenity n'est pas installé" --icon=dialog-error
    exit 1
fi

# Demander à l'utilisateur ce qu'il veut faire
CHOICE=$(zenity --list \
    --title="MPV - Que voulez-vous faire ?" \
    --text="Choisissez une option :" \
    --radiolist \
    --column="Sélection" \
    --column="Action" \
    --width=350 \
    --height=200 \
    TRUE "Sélectionner un fichier vidéo/audio" \
    FALSE "Ouvrir un dossier avec Nautilus" \
    2>/dev/null)

# Si l'utilisateur annule
if [ -z "$CHOICE" ]; then
    exit 0
fi

# Traiter le choix
case "$CHOICE" in
    "Sélectionner un fichier vidéo/audio")
        # Ouvrir le sélecteur de fichiers zenity ultra-compact
        VIDEO_FILE=$(zenity --file-selection \
            --title="Sélectionner une vidéo/audio" \
            --filename="$VIDEO_DIR/" \
            --width=500 \
            --height=350 \
            --file-filter="Vidéos | *.mp4 *.mkv *.avi *.mov *.wmv *.flv *.webm *.m4v *.mpg *.mpeg *.ts *.m2ts" \
            --file-filter="Audio | *.mp3 *.flac *.wav *.ogg *.m4a *.aac *.opus *.wma" \
            --file-filter="Tous les fichiers | *" \
            2>/dev/null)

        # Si l'utilisateur annule ou ne sélectionne rien
        if [ -z "$VIDEO_FILE" ]; then
            exit 0
        fi

        # Vérifier que le fichier existe
        if [ ! -f "$VIDEO_FILE" ]; then
            notify-send "Erreur MPV" "Le fichier sélectionné n'existe pas !" --icon=dialog-error
            exit 1
        fi

        # Lancer MPV avec le fichier sélectionné
        mpv "$VIDEO_FILE" &
        notify-send "MPV" "Lecture de : $(basename "$VIDEO_FILE")" --icon=video-x-generic
        ;;
        
    "Ouvrir un dossier avec Nautilus")
        # Demander quel dossier ouvrir
        FOLDER=$(zenity --file-selection \
            --title="Sélectionner un dossier" \
            --filename="$VIDEO_DIR/" \
            --width=450 \
            --height=300 \
            --directory \
            2>/dev/null)

        # Si l'utilisateur annule
        if [ -z "$FOLDER" ]; then
            exit 0
        fi

        # Ouvrir le dossier avec Nautilus
        nautilus "$FOLDER" &
        folder_name=$(basename "$FOLDER")
        notify-send "Nautilus" "Ouverture du dossier : $folder_name" --icon=folder
        ;;
esac
