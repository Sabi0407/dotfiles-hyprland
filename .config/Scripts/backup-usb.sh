#!/bin/bash

# Sauvegardes rapides des coffres Obsidian + dotfiles vers la clé USB.
# Les données sont copiées dans /run/media/sabi/Sabi/Backup.

set -euo pipefail

COFFRE_COURS="$HOME/Documents/Cours"
COFFRE_PERSO="$HOME/Documents/Perso"
POINT_MONTAGE="/run/media/sabi/Sabi"
DOSSIER_USB="$POINT_MONTAGE/Backup"

OBSIDIAN_DIR="$DOSSIER_USB/Obsidian"
DOTFILES_DIR="$DOSSIER_USB/dotfiles"
CONFIG_BASE="$HOME/.config"

CONFIG_DIRS=(
    aliases fastfetch flameshot gtk-3.0 gtk-4.0 hypr kitty Kvantum
    micro Mousepad mpv nwg-look qt5ct Scripts spicetify swaync swayosd
    Thunar tofi waybar waypaper yazi zathura
)

DEST_CONFIG_BASE="$DOTFILES_DIR/.config"
DEST_APPS="$DOTFILES_DIR/applications"
DEST_ICONS="$DOTFILES_DIR/icons"
DEST_WALLPAPERS="$DOTFILES_DIR/wallpapers"
DEST_ANIME="$DOTFILES_DIR/anime-walls"
DEST_LY="$DOTFILES_DIR/ly-config"
DEST_SAVE_SCRIPT="$DEST_CONFIG_BASE"
DEST_VSCODIUM_USER="$DEST_CONFIG_BASE/VSCodium/User"

CHANGES=0

require_ready_disk() {
    if ! command -v zenity >/dev/null 2>&1; then
        echo "Zenity est requis pour lancer cette sauvegarde." >&2
        exit 1
    fi

    if [ ! -d "$POINT_MONTAGE" ] || [ ! -d "$DOSSIER_USB" ]; then
        zenity --error --title="Sauvegarde USB" \
            --text="Impossible de trouver $DOSSIER_USB.\nMonte la clé USB puis relance." && exit 1
    fi
}

track_rsync() {
    local log
    log=$(mktemp)
    if rsync "$@" >"$log"; then
        if grep -Eq '^[<>ch\*]' "$log"; then
            CHANGES=1
        fi
        rm -f "$log"
    else
        rm -f "$log"
        zenity --error --title="Sauvegarde USB" --text="Rsync a échoué pour $2"
        exit 1
    fi
}

sync_dir() {
    local src="$1" dest="$2"
    [ -d "$src" ] || return
    mkdir -p "$dest"
    track_rsync -a --delete "$src/" "$dest/"
}

sync_file() {
    local src="$1" dest_dir="$2"
    [ -f "$src" ] || return
    mkdir -p "$dest_dir"
    track_rsync -a "$src" "$dest_dir/"
}

backup_obsidian() {
    sync_dir "$COFFRE_COURS" "$OBSIDIAN_DIR/Cours"
    sync_dir "$COFFRE_PERSO" "$OBSIDIAN_DIR/Perso"
}

backup_configs() {
    mkdir -p "$DEST_CONFIG_BASE"
    for dir in "${CONFIG_DIRS[@]}"; do
        sync_dir "$CONFIG_BASE/$dir" "$DEST_CONFIG_BASE/$dir"
    done

    sync_file "$CONFIG_BASE/mimeapps.list" "$DEST_CONFIG_BASE"
    sync_dir "$CONFIG_BASE/VSCodium/User" "$DEST_VSCODIUM_USER"
}

backup_assets() {
    sync_dir "$HOME/.local/share/applications" "$DEST_APPS"
    sync_dir "$HOME/.icons" "$DEST_ICONS"
    sync_dir "$HOME/Images/wallpapers" "$DEST_WALLPAPERS"
    sync_dir "$HOME/Images/anime-walls" "$DEST_ANIME"
    sync_dir "/etc/ly" "$DEST_LY"
    sync_file "$HOME/saveconfig.sh" "$DEST_SAVE_SCRIPT"
}

main() {
    require_ready_disk

    zenity --question --title="Sauvegarde USB" \
        --text="Sauvegarder Obsidian et les dotfiles vers la clé USB ?" || exit 0

    backup_obsidian
    backup_configs
    backup_assets

    if (( CHANGES )); then
        zenity --info --title="Sauvegarde USB" \
            --text="Sauvegarde terminée. Les nouveaux fichiers sont copiés."
    else
        zenity --info --title="Sauvegarde USB" \
            --text="Tout est déjà à jour, aucune copie nécessaire."
    fi
}

main "$@"
