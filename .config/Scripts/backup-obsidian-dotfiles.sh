#!/bin/bash

COFFRE_COURS="/home/sabi/Documents/Cours"      # Coffre Obsidian pour les cours
COFFRE_PERSO="/home/sabi/Documents/Perso"      # Coffre Obsidian personnel
POINT_MONTAGE="/run/media/sabi/Sabi"           # Point de montage de la clé USB
DOSSIER_USB="$POINT_MONTAGE/dotfiles-hypr"    # Répertoire racine utilisé sur la clé

CONFIG_DIRS=(aliases flameshot fastfetch gtk-3.0 gtk-4.0 hypr kitty Kvantum Mousepad mpv nerdfetch nwg-look qt5ct Scripts spicetify swaync swayosd Thunar waybar tofi micro yazi zathura waypaper)
CONFIG_BASE="$HOME/.config"
DEST_CONFIG_BASE="$DOSSIER_USB/dotfiles/.config"
DEST_ICONS="$DOSSIER_USB/dotfiles/icons"
DEST_APPS="$DOSSIER_USB/dotfiles/applications"
DEST_ROOT="$DOSSIER_USB/dotfiles"

# S'assure que Zenity est disponible pour afficher les boîtes de dialogue.
if ! command -v zenity >/dev/null 2>&1; then
    echo "Zenity est requis pour lancer cette sauvegarde."
    exit 1
fi

# Vérifie que la clé est montée et contient le dossier de destination.
if [ ! -d "$POINT_MONTAGE" ] || [ ! -d "$DOSSIER_USB" ]; then
    zenity --error --text="Le dossier $DOSSIER_USB est introuvable.\nMonte la clé USB et crée ce dossier si nécessaire." --title="Sauvegarde USB"
    exit 1
fi

zenity --question \
    --title="Sauvegarde USB" \
    --text="Sauvegarder les coffres Obsidian et les dossiers de configuration vers la clé USB ?" \
    || exit 0

mkdir -p "$DOSSIER_USB/Cours" "$DOSSIER_USB/Perso"

sync_and_check() {
    local src="$1" dest="$2" log
    log=$(mktemp)
    if rsync -av --delete --itemize-changes "$src/" "$dest/" >"$log"; then
        if grep -E '^[<>ch\*]' "$log" >/dev/null 2>&1; then
            rm -f "$log"
            echo "changed"
        else
            rm -f "$log"
            echo "unchanged"
        fi
    else
        rm -f "$log"
        echo "error"
    fi
}

obsidian_status=(
    "$(sync_and_check "$COFFRE_COURS" "$DOSSIER_USB/Cours")"
    "$(sync_and_check "$COFFRE_PERSO" "$DOSSIER_USB/Perso")"
)

if [[ " ${obsidian_status[*]} " == *" error "* ]]; then
    zenity --error --text="Une erreur est survenue pendant la sauvegarde des coffres Obsidian." --title="Sauvegarde USB"
    exit 1
fi

copy_config_dirs() {
    mkdir -p "$DEST_CONFIG_BASE"
    local dir src dest
    for dir in "${CONFIG_DIRS[@]}"; do
        src="$CONFIG_BASE/$dir"
        dest="$DEST_CONFIG_BASE/$dir"
        [ -d "$src" ] || continue
        mkdir -p "$dest"
        rsync -av --delete "$src/" "$dest/"
    done
}

copy_other_assets() {
    [ -d "$HOME/.icons" ] && rsync -av --delete "$HOME/.icons/" "$DEST_ICONS/"
    [ -d "$HOME/.local/share/applications" ] && rsync -av --delete "$HOME/.local/share/applications/" "$DEST_APPS/"
    [ -d "$HOME/Images/anime-walls" ] && rsync -av --delete "$HOME/Images/anime-walls/" "$DOSSIER_USB/anime-walls/"

    mkdir -p "$DEST_ROOT"
    for file in "$HOME/.bashrc" "$HOME/.zshrc"; do
        [ -f "$file" ] && rsync -av "$file" "$DEST_ROOT/" >/dev/null 2>&1
    done
    [ -f "$HOME/.config/mimeapps.list" ] && rsync -av "$HOME/.config/mimeapps.list" "$DEST_CONFIG_BASE/" >/dev/null 2>&1

    local vs_src="$HOME/.config/VSCodium/User/settings.json"
    if [ -f "$vs_src" ]; then
        rsync -av "$vs_src" "$DEST_ROOT/VSCodium/User/"
    fi
}

copy_config_dirs
copy_other_assets

if [[ " ${obsidian_status[*]} " == *" changed "* ]]; then
    zenity --info --text="Sauvegarde terminée avec succès." --title="Sauvegarde USB"
else
    zenity --info --text="Aucun nouveau fichier à copier (tout est déjà à jour)." --title="Sauvegarde USB"
fi
