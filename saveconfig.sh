#!/bin/bash

# Répertoire de destination dans ton dépôt dotfiles
DEST="$HOME/dotfiles"

# Fichier de log
LOG_FILE="$HOME/.config/saveconfig.log"

# Dossiers sous ~/.config à synchroniser
CONFIG_DEST="$DEST/.config"
DIRS=(aliases assets flameshot gtk-3.0 gtk-4.0 hypr hyprpanel kitty Kvantum nerdfetch nwg-look qt5ct Scripts swaync waybar wlogout wofi micro yazi)

# Dossier ~/.icons
ICONS_SRC="$HOME/.icons/"
ICONS_DEST="$DEST/icons"

# Dossier ~/.local/share/applications
APPS_SRC="$HOME/.local/share/applications/"
APPS_DEST="$DEST/applications"

# Configuration SDDM
SDDM_SRC="/etc/sddm.conf.d/"
SDDM_DEST="$DEST/sddm"

# Dossier Images et Wallpapers
#IMAGES_SRC="$HOME/Images/"
#IMAGES_DEST="$DEST/Images"

# 1) Sync de ~/.config
echo "$(date): Début de la sauvegarde de ~/.config" >> "$LOG_FILE"
for dir in "${DIRS[@]}"; do
    echo "$(date): Sauvegarde de $dir" >> "$LOG_FILE"
    rsync -av --delete "$HOME/.config/$dir/" "$CONFIG_DEST/$dir/" >> "$LOG_FILE" 2>&1
done

# 2) Sync des icônes
echo "$(date): Sauvegarde des icônes" >> "$LOG_FILE"
mkdir -p "$ICONS_DEST"
rsync -av --delete "$ICONS_SRC" "$ICONS_DEST/" >> "$LOG_FILE" 2>&1

# 3) Sync des .desktop
echo "$(date): Sauvegarde des applications" >> "$LOG_FILE"
mkdir -p "$APPS_DEST"
rsync -av --delete "$APPS_SRC" "$APPS_DEST/" >> "$LOG_FILE" 2>&1

# 4) Sync de la configuration SDDM
echo "$(date): Sauvegarde de la configuration SDDM" >> "$LOG_FILE"
mkdir -p "$SDDM_DEST"
sudo rsync -av --delete "$SDDM_SRC" "$SDDM_DEST/" >> "$LOG_FILE" 2>&1

# 5) Sync des Images et Wallpapers (exclut Screenshot)
#echo "$(date): Sauvegarde des images et wallpapers" >> "$LOG_FILE"
#mkdir -p "$IMAGES_DEST"
#rsync -av --delete --exclude='Screenshot/' "$IMAGES_SRC" "$IMAGES_DEST/" >> "$LOG_FILE" 2>&1

# 6) Sync de .bashrc
echo "$(date): Sauvegarde de .bashrc" >> "$LOG_FILE"
rsync -av --delete "$HOME/.bashrc" "$DEST/" >> "$LOG_FILE" 2>&1

# 7) Sync de .zshrc
echo "$(date): Sauvegarde de .zshrc" >> "$LOG_FILE"
rsync -av --delete "$HOME/.zshrc" "$DEST/" >> "$LOG_FILE" 2>&1

# 8) Sync de mimeapps.list
echo "$(date): Sauvegarde de mimeapps.list" >> "$LOG_FILE"
rsync -av --delete "$HOME/.config/mimeapps.list" "$DEST/.config/" >> "$LOG_FILE" 2>&1

# 9) Sync de saveconfig.sh
echo "$(date): Sauvegarde de saveconfig.sh" >> "$LOG_FILE"
rsync -av --delete "$HOME/saveconfig.sh" "$DEST/" >> "$LOG_FILE" 2>&1

# Message de statut
if [ $? -eq 0 ]; then
    echo "Sauvegarde réussie à $(date)"
    echo "$(date): SUCCES - Sauvegarde terminée avec succès" >> "$LOG_FILE"
else
    echo "La sauvegarde a échoué à $(date)"
    echo "$(date): ERREUR - La sauvegarde a échoué" >> "$LOG_FILE"
fi

echo "Log détaillé disponible dans: $LOG_FILE"
