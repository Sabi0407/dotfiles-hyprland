#!/bin/bash
# ========================================
# ALIASES DE BASE
# ========================================

# Navigation
alias ..='cd ..'    # Retour d'un niveau
alias ...='cd ../..'
alias ....='cd ../../..'

# Dossiers rapides
alias dl='cd ~/Téléchargements' # Téléchargements
alias videos='cd ~/Vidéos'
alias docs='cd ~/Documents'
alias img='cd ~/Images'
alias dotfiles='cd ~/dotfiles'
alias config='cd ~/.config'
alias scripts='cd ~/.config/Scripts'


# ls amélioré
alias ll='ls -alF' # Liste détaillée avec tous les fichiers
alias la='ls -A'
alias l='ls -CF'

# cat amélioré avec bat (sans supprimer le cat classique)
alias batcat='bat --paging=never'

# Sécurité
alias rm='rm -i' # Suppression avec confirmation
alias cp='cp -i' # Copie avec confirmation
alias mv='mv -i' # Déplacement avec confirmation
alias mkdir='mkdir -p' # Création récursive même si le dossier existe déjà

# Recherche
alias grep='grep --color=auto' # Recherche avec coloration

# Système
alias df='df -h' # Disque
alias du='du -h' # Disque utilisé
alias free='free -h' # Mémoire libre

# Git basique
alias gs='git status' # État du dépôt
alias ga='git add' # Ajouter des fichiers
alias gcm='git commit -m' # Valider les modifications
alias gp='git push' # Pousser les modifications

# Éditeurs
alias m='micro' # Micro
alias firefox='env -u QT_QPA_PLATFORMTHEME -u QT_STYLE_OVERRIDE -u QT_QPA_PLATFORM -u QT5_STYLE_OVERRIDE -u GTK_THEME -u GTK_APPLICATION_PREFER_DARK_THEME -u GTK_CSD -u GTK_TITLEBAR /usr/lib/firefox/firefox'
alias obsidian='env -u QT_QPA_PLATFORMTHEME -u QT_STYLE_OVERRIDE -u QT_QPA_PLATFORM -u QT5_STYLE_OVERRIDE -u GTK_THEME -u GTK_APPLICATION_PREFER_DARK_THEME -u GTK_CSD -u GTK_TITLEBAR /usr/sbin/obsidian'

# Redémarrage rapide
alias reloadb='source ~/.bashrc' # Recharger le fichier de configuration
alias reloadz='source ~/.zshrc'
alias thumbreset='~/.config/Scripts/thunar-thumbs-reset.sh'
# Pacman avec options
alias s='sudo pacman -S' # Installer un paquet
alias r='sudo pacman -R' # Supprimer un paquet
alias rns='sudo pacman -Rs' # Supprimer un paquet et ses dépendances
alias sy='sudo pacman -Syu' # Mettre à jour le système (évite les partial upgrades)
alias syu='sudo pacman -Syu' # Mettre à jour le système (équivalent à sy)
alias ss='pacman -Ss' # Rechercher un paquet
alias si='pacman -Si' # Afficher les détails d'un paquet
pacmanclean() {
    local orphans
    if orphans=$(pacman -Qdtq 2>/dev/null) && [ -n "$orphans" ]; then
        sudo pacman -Rns -- $orphans
    else
        echo "pacmanclean: aucun paquet orphelin détecté"
    fi
    sudo pacman -Sc
}

# Yay avec options
alias ys='yay -S' # Installer un paquet
alias yr='yay -R' # Supprimer un paquet
alias yrs='yay -Rns' # Supprimer un paquet et ses dépendances
alias ysy='yay -Syu' # Mettre à jour le système (évite les partial upgrades)
alias ysyu='yay -Syu' # Mettre à jour le système (équivalent à ysy)
alias yss='yay -Ss' # Rechercher un paquet
alias ysi='yay -Si' # Afficher les détails d'un paquet
alias yayclean='yay -Yc && yay -Sc'
# Utilitaires rapides
alias x='exit' # Quitter le shell
alias c='clear' # Effacer l'écran
alias root='sudo -i' # Se connecter en tant que root

# Scripts
alias saveconfig='/home/sabi/saveconfig.sh'
alias clean='/home/sabi/.config/Scripts/cleanup-system.sh'
alias wallanim='MPVWALL_SKIP_STOP=1 ~/.config/Scripts/mpvpaper-wallpaper.sh random'
alias saveusb='~/.config/Scripts/backup-usb.sh'
alias screenlock='sleep 5 && grim -o "$(hyprctl monitors -j | jq -r '"'"'.[0].name'"'"')" hyprlock5.png'

walldyn() {
    local base_dir="${MPV_WALL_PICKER_VIDEOS:-$HOME/Images/anime-walls}"
    if [ ! -d "$base_dir" ]; then
        echo "walldyn: dossier introuvable -> $base_dir"
        return 1
    fi
    local selection
    if command -v yazi >/dev/null 2>&1; then
        local chooser_file
        chooser_file=$(mktemp)
        (
            trap 'rm -f "$chooser_file"; exit 130' INT TERM
            yazi --chooser-file "$chooser_file" "$base_dir"
        )
        local chooser_status=$?
        if [ $chooser_status -ne 0 ]; then
            rm -f "$chooser_file"
            return $chooser_status
        fi
        selection=$(sed -n '1p' "$chooser_file")
        rm -f "$chooser_file"
    else
        command -v fzf >/dev/null 2>&1 || { echo "walldyn: installe yazi ou fzf."; return 1; }
        selection=$(MPV_WALL_PICKER_VIDEOS="$base_dir" "$HOME/.config/Scripts/mpvpaper-wallpaper.sh" list | \
            fzf --prompt "Fond animé > " --height 80% --border)
    fi
    [ -z "$selection" ] && return 0
    MPVWALL_SKIP_STOP=1 MPV_WALL_VIDEO="$selection" ~/.config/Scripts/mpvpaper-wallpaper.sh start
}

# Papirus Folders - Changer couleur des icones de dossiers
alias folder-black='sudo papirus-folders -C black --theme Papirus-Dark'
alias folder-blue='sudo papirus-folders -C blue --theme Papirus-Dark'
alias folder-cyan='sudo papirus-folders -C cyan --theme Papirus-Dark'
alias folder-green='sudo papirus-folders -C green --theme Papirus-Dark'
alias folder-grey='sudo papirus-folders -C grey --theme Papirus-Dark'
alias folder-orange='sudo papirus-folders -C orange --theme Papirus-Dark'
alias folder-pink='sudo papirus-folders -C pink --theme Papirus-Dark'
alias folder-red='sudo papirus-folders -C red --theme Papirus-Dark'
alias folder-violet='sudo papirus-folders -C violet --theme Papirus-Dark'
alias folder-yellow='sudo papirus-folders -C yellow --theme Papirus-Dark'
alias folder-teal='sudo papirus-folders -C teal --theme Papirus-Dark'
alias folder-indigo='sudo papirus-folders -C indigo --theme Papirus-Dark'
alias folder-brown='sudo papirus-folders -C brown --theme Papirus-Dark'
