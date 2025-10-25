#!/bin/bash

# Répertoire de destination dans ton dépôt dotfiles
DEST="$HOME/dotfiles"

# Fichier de log
LOG_FILE="$HOME/.config/saveconfig.log"

# Dossiers sous ~/.config à synchroniser
CONFIG_DEST="$DEST/.config"
DIRS=(aliases flameshot fastfetch gtk-3.0 gtk-4.0 hypr kitty Kvantum Mousepad mpv nerdfetch nwg-look qt5ct Scripts swaync Thunar waybar tofi micro yazi zathura waypaper)

# Dossier ~/.icons (hors thème symbolique \"default\")
ICONS_SRC="$HOME/.icons/"
ICONS_DEST="$DEST/icons"

# Dossier ~/.local/share/applications
APPS_SRC="$HOME/.local/share/applications/"
APPS_DEST="$DEST/applications"

# Configuration ly (gestionnaire de connexion)
LY_SRC="$HOME/etc/ly/"
LY_DEST="$DEST/ly-config"

# Dossier Wallpapers uniquement
WALLPAPERS_SRC="$HOME/wallpapers/"
WALLPAPERS_DEST="$DEST/wallpapers"

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

# 4) Sync de la configuration ly
echo "$(date): Sauvegarde de la configuration ly" >> "$LOG_FILE"
mkdir -p "$LY_DEST"
sudo rsync -av --delete "$LY_SRC" "$LY_DEST/" >> "$LOG_FILE" 2>&1

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

# 10) Sync de la configuration Firefox (userChrome.css et user.js)
echo "$(date): Sauvegarde de la configuration Firefox" >> "$LOG_FILE"
mapfile -t FIREFOX_PROFILE_DIRS < <(find "$HOME/.mozilla/firefox" -maxdepth 1 -type d -name "*.default*" -printf "%f\n" | sort)

if [ ${#FIREFOX_PROFILE_DIRS[@]} -gt 0 ]; then
    BASE_FIREFOX_DEST="$DEST/firefox"
    mkdir -p "$BASE_FIREFOX_DEST"

    for FIREFOX_PROFILE_DIR in "${FIREFOX_PROFILE_DIRS[@]}"; do
        PROFILE_SRC="$HOME/.mozilla/firefox/$FIREFOX_PROFILE_DIR"
        PROFILE_DEST="$BASE_FIREFOX_DEST/$FIREFOX_PROFILE_DIR"
        CHROME_SRC="$PROFILE_SRC/chrome"
        CHROME_DEST="$PROFILE_DEST/chrome"

        mkdir -p "$PROFILE_DEST"

        if [ -d "$CHROME_SRC" ]; then
            mkdir -p "$CHROME_DEST"
            rsync -av --delete "$CHROME_SRC/" "$CHROME_DEST/" >> "$LOG_FILE" 2>&1
        else
            echo "$(date): INFO - Aucun dossier chrome pour le profil $FIREFOX_PROFILE_DIR" >> "$LOG_FILE"
        fi

        FIREFOX_USER_JS="$PROFILE_SRC/user.js"
        if [ -f "$FIREFOX_USER_JS" ]; then
            rsync -av "$FIREFOX_USER_JS" "$PROFILE_DEST/" >> "$LOG_FILE" 2>&1
        else
            echo "$(date): INFO - Aucun user.js trouvé pour le profil $FIREFOX_PROFILE_DIR" >> "$LOG_FILE"
        fi

        echo "$(date): Configuration Firefox sauvegardée depuis le profil $FIREFOX_PROFILE_DIR" >> "$LOG_FILE"
    done
else
    echo "$(date): ATTENTION - Aucun profil Firefox par défaut trouvé" >> "$LOG_FILE"
fi

# 11) Sync de la configuration VSCodium (settings.json)
echo "$(date): Sauvegarde de la configuration VSCodium" >> "$LOG_FILE"
VSCODIUM_SRC="$HOME/.config/VSCodium/User/settings.json"
VSCODIUM_DEST="$DEST/VSCodium/User"
if [ -f "$VSCODIUM_SRC" ]; then
    mkdir -p "$VSCODIUM_DEST"
    rsync -av "$VSCODIUM_SRC" "$VSCODIUM_DEST/" >> "$LOG_FILE" 2>&1
    echo "$(date): Configuration VSCodium sauvegardée" >> "$LOG_FILE"
else
    echo "$(date): ATTENTION - Fichier VSCodium settings.json non trouvé" >> "$LOG_FILE"
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
