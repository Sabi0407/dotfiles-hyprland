# Powerlevel10k instant prompt (accélère l'affichage du prompt)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Chemin d'installation de Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Thème utilisé pour le prompt
ZSH_THEME="powerlevel10k/powerlevel10k"

# Completion sensible à la casse
CASE_SENSITIVE="true"

# Plugins activés (sans zsh-completions)
plugins=(
  z
  colored-man-pages
  command-not-found
)

# Ajout du chemin correct pour zsh-completions (installé via pacman)
fpath=(/usr/share/zsh/plugins/zsh-completions $fpath)

# Charge le système de complétion une seule fois après avoir mis à jour fpath
autoload -Uz compinit
compinit

# Charge Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Alias personnalisés
source ~/.config/aliases/aliases.sh

# Thème Powerlevel10k (nécessaire si pas chargé automatiquement)
source ~/powerlevel10k/powerlevel10k.zsh-theme

# Charge la configuration du prompt Powerlevel10k si elle existe
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Coloration syntaxique des commandes
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Améliore la complétion (insensible à la casse)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Instant prompt Powerlevel9k (désactive si tu as des soucis)
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Lance nerdfetch seulement si installé
if command -v nerdfetch &>/dev/null; then
  nerdfetch
fi

# Fonction de mise à jour
update() {
    echo "== Mise à jour pacman =="
    sudo pacman -Sy && sudo pacman -Syu

    echo "== Mise à jour yay (AUR) =="
    yay -Sy && yay -Syu

    echo "== Mise à jour flatpak =="
    flatpak update -y
}

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/sabi/.dart-cli-completion/zsh-config.zsh ]] && . /home/sabi/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

