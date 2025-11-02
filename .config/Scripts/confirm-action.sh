#!/bin/bash
set -euo pipefail

# Script de confirmation générique pour logout / reboot / shutdown.
# Usage : confirm-action.sh <logout|reboot|shutdown>

run_zenity_dark() {
    GTK_THEME="catppuccin-mocha-red-standard+default" zenity "$@" 2> >(grep -v "Adwaita-WARNING")
}

usage() {
    cat <<'EOF'
Usage: confirm-action.sh <logout|reboot|shutdown>
EOF
}

if [[ $# -ne 1 ]]; then
    usage >&2
    exit 1
fi

action="$1"
case "$action" in
    logout)
        title="Déconnexion"
        message="Voulez-vous vraiment vous déconnecter ?"
        ok_label="Déconnexion"
        icon="system-log-out"
        command=(hyprctl dispatch exit)
        use_dark_theme=false
        ;;
    reboot)
        title="Redémarrage"
        message="Tu veux redémarrer le système ?"
        ok_label="Oui"
        icon="system-reboot"
        command=(systemctl reboot)
        use_dark_theme=true
        ;;
    shutdown|poweroff)
        title="Extinction"
        message="Tu veux éteindre ton système ?"
        ok_label="Oui"
        icon="system-shutdown"
        command=(systemctl poweroff)
        use_dark_theme=true
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac

cancel_label="Non flemme"

if [[ "$use_dark_theme" == true ]]; then
    if run_zenity_dark --question --title "$title" --text "$message" --ok-label "$ok_label" --cancel-label "$cancel_label" --window-icon="$icon"; then
        "${command[@]}"
    fi
else
    if zenity --question --title "$title" --text "$message" --ok-label "$ok_label" --cancel-label "$cancel_label" --window-icon="$icon"; then
        "${command[@]}"
    fi
fi
