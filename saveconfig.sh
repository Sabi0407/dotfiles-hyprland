#!/bin/bash

# Répertoire de destination dans ton dépôt dotfiles
DEST="$HOME/dotfiles"

# Fichier de log
LOG_FILE="$HOME/.config/saveconfig.log"

# Dossiers sous ~/.config à synchroniser
CONFIG_DEST="$DEST/.config"
DIRS=(aliases flameshot fastfetch gtk-3.0 gtk-4.0 hypr kitty Kvantum Mousepad mpv nerdfetch nwg-look qt5ct Scripts spicetify swaync swayosd Thunar waybar tofi micro yazi zathura waypaper)

# Dossier ~/.icons (hors thème symbolique \"default\")
ICONS_SRC="$HOME/.icons/"
ICONS_DEST="$DEST/icons"

# Dossier ~/.local/share/applications
APPS_SRC="$HOME/.local/share/applications/"
APPS_DEST="$DEST/applications"

# Configuration ly (gestionnaire de connexion)
LY_SRC="/etc/ly/"
LY_DEST="$DEST/ly-config"

# Dossier Wallpapers uniquement
WALLPAPERS_SRC="$HOME/Images/wallpapers/"
WALLPAPERS_DEST="$DEST/wallpapers"

# Documentation Hyprland
HYPR_DOC_SRC="$HOME/Documents/Perso/Hyprland-Docs/"
HYPR_DOC_DEST="$DEST/Hyprland-Docs"

# Emplacements VSCodium
VSCODIUM_SETTINGS_SRC="$HOME/.config/VSCodium/User/settings.json"
VSCODIUM_LANG_SRC="$HOME/.config/VSCodium/languagepacks.json"
VSCODIUM_DEST_BASE="$DEST/.config/VSCodium"
VSCODIUM_USER_DEST="$VSCODIUM_DEST_BASE/User"

# Créer le répertoire de destination principal s'il n'existe pas
mkdir -p "$DEST"
mkdir -p "$CONFIG_DEST"

# 1) Sync de ~/.config
echo "$(date): Début de la sauvegarde de ~/.config" >> "$LOG_FILE"
for dir in "${DIRS[@]}"; do
    echo "$(date): Sauvegarde de $dir" >> "$LOG_FILE"
    rsync -av --delete "$HOME/.config/$dir/" "$CONFIG_DEST/$dir/" >> "$LOG_FILE" 2>&1
done

# 2) Sync des icônes
echo "$(date): Sauvegarde des icônes" >> "$LOG_FILE"
mkdir -p "$ICONS_DEST"
rm -rf "$ICONS_DEST/default"
if [ -d "$ICONS_SRC" ]; then
    rsync -av --delete --exclude 'default/' "$ICONS_SRC" "$ICONS_DEST/" >> "$LOG_FILE" 2>&1
else
    echo "$(date): ATTENTION - Dossier ~/.icons/ non trouvé" >> "$LOG_FILE"
fi

# 3) Sync des .desktop
echo "$(date): Sauvegarde des applications" >> "$LOG_FILE"
mkdir -p "$APPS_DEST"
rsync -av --delete "$APPS_SRC" "$APPS_DEST/" >> "$LOG_FILE" 2>&1

# 4) Sync de la configuration ly (sauf save.ini)
echo "$(date): Sauvegarde de la configuration ly" >> "$LOG_FILE"
mkdir -p "$LY_DEST"
sudo rsync -av --delete --exclude 'save.ini' "$LY_SRC" "$LY_DEST/" >> "$LOG_FILE" 2>&1

# 5) Sync du dossier Wallpapers uniquement
echo "$(date): Sauvegarde des wallpapers" >> "$LOG_FILE"
if [ -d "$WALLPAPERS_SRC" ]; then
    mkdir -p "$WALLPAPERS_DEST"
    rsync -av --delete "$WALLPAPERS_SRC" "$WALLPAPERS_DEST/" >> "$LOG_FILE" 2>&1
    echo "$(date): Wallpapers sauvegardés depuis ~/wallpapers/" >> "$LOG_FILE"
else
    echo "$(date): ATTENTION - Dossier ~/wallpapers/ non trouvé" >> "$LOG_FILE"
fi

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

# 10) Sync de la configuration VSCodium (settings.json + languagepacks)
echo "$(date): Sauvegarde de la configuration VSCodium" >> "$LOG_FILE"
mkdir -p "$VSCODIUM_USER_DEST"
if [ -f "$VSCODIUM_SETTINGS_SRC" ]; then
    rsync -av "$VSCODIUM_SETTINGS_SRC" "$VSCODIUM_USER_DEST/" >> "$LOG_FILE" 2>&1
    echo "$(date): Fichier settings.json sauvegardé" >> "$LOG_FILE"
else
    echo "$(date): ATTENTION - settings.json introuvable" >> "$LOG_FILE"
fi

if [ -f "$VSCODIUM_LANG_SRC" ]; then
    mkdir -p "$VSCODIUM_DEST_BASE"
    rsync -av "$VSCODIUM_LANG_SRC" "$VSCODIUM_DEST_BASE/" >> "$LOG_FILE" 2>&1
    echo "$(date): languagepacks.json sauvegardé" >> "$LOG_FILE"
else
    echo "$(date): ATTENTION - languagepacks.json introuvable" >> "$LOG_FILE"
fi

# 11) Sync de la documentation Hyprland
echo "$(date): Sauvegarde de la documentation Hyprland" >> "$LOG_FILE"
if [ -d "$HYPR_DOC_SRC" ]; then
    mkdir -p "$HYPR_DOC_DEST"
    rsync -av --delete "$HYPR_DOC_SRC" "$HYPR_DOC_DEST/" >> "$LOG_FILE" 2>&1
else
    echo "$(date): ATTENTION - Dossier $HYPR_DOC_SRC non trouvé" >> "$LOG_FILE"
fi

# Message de statut
if [ $? -eq 0 ]; then
    echo "Sauvegarde réussie à $(date)"
    echo "$(date): SUCCES - Sauvegarde terminée avec succès" >> "$LOG_FILE"
else
    echo "La sauvegarde a échoué à $(date)"
    echo "$(date): ERREUR - La sauvegarde a échoué" >> "$LOG_FILE"
fi

echo "Log détaillés disponible dans: $LOG_FILE"

# Basculer automatiquement dans le dépôt dotfiles
if ! cd "$DEST"; then
    echo "$(date): ERREUR - Impossible de se placer dans $DEST" >> "$LOG_FILE"
fi
