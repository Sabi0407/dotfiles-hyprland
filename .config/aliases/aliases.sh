
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

# ls amélioré
alias ll='ls -alF' # Liste détaillée avec tous les fichiers
alias la='ls -A'
alias l='ls -CF'




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

# Yay avec options
alias ys='yay -S' # Installer un paquet
alias yr='yay -R' # Supprimer un paquet
alias yrs='yay -Rs' # Supprimer un paquet et ses dépendances
alias ysy='yay -Sy' # Mettre à jour la base de données
alias ysyu='yay -Syu' # Mettre à jour le système
alias yss='yay -Ss' # Rechercher un paquet
alias ysi='yay -Si' # Afficher les détails d'un paquet
alias yayclean='yay -Yc && yay -Sc'
alias pacmanclean='sudo pacman -Rns $(pacman -Qdtq) && sudo pacman -Sc'
# Utilitaires rapides
alias x='exit' # Quitter le shell
alias c='clear' # Effacer l'écran
alias root='sudo -i' # Se connecter en tant que root

# Scripts
alias saveconfig='/home/sabi/saveconfig.sh'
alias wallmenu='~/.config/Scripts/wallpaper-manager.sh random'

alias syup='cd ~/ChromiumPywal && ./generate-theme.sh'

alias clean='/home/sabi/.config/Scripts/cleanup-system.sh'
