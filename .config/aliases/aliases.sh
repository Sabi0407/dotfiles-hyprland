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

# cat amélioré avec bat
alias cat='bat'

# Sécurité
alias rm='rm -i' # Suppression avec confirmation            
alias cp='cp -i' # Copie avec confirmation
alias mv='mv -i' # Déplacement avec confirmation
alias mkdir='mkdir -p' # Création de dossiers avec confirmation

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
# Pacman avec options
alias s='sudo pacman -S' # Installer un paquet
alias r='sudo pacman -R' # Supprimer un paquet
alias rns='sudo pacman -Rs' # Supprimer un paquet et ses dépendances
alias sy='sudo pacman -Sy' # Mettre à jour la base de données
alias syu='sudo pacman -Syu' # Mettre à jour le système
alias ss='pacman -Ss' # Rechercher un paquet
alias si='pacman -Si' # Afficher les détails d'un paquet
alias pacmanclean='sudo pacman -Rns $(pacman -Qdtq) && sudo pacman -Sc'

# Yay avec options
alias ys='yay -S' # Installer un paquet
alias yr='yay -R' # Supprimer un paquet
alias yrs='yay -Rns' # Supprimer un paquet et ses dépendances
alias ysy='yay -Sy' # Mettre à jour la base de données
alias ysyu='yay -Syu' # Mettre à jour le système
alias yss='yay -Ss' # Rechercher un paquet
alias ysi='yay -Si' # Afficher les détails d'un paquet
alias yayclean='yay -Yc && yay -Sc'
# Utilitaires rapides
alias x='exit' # Quitter le shell
alias c='clear' # Effacer l'écran
alias root='sudo -i' # Se connecter en tant que root

# Scripts
alias saveconfig='/home/sabi/saveconfig.sh'
alias syup='cd ~/ChromiumPywal && ./generate-theme.sh'
alias clean='/home/sabi/.config/Scripts/cleanup-system.sh'

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
