#!/bin/bash
################################################################################
# Daemon pour mettre à jour la cover art en continu pendant hyprlock
################################################################################

COVER_SCRIPT="/home/sabi/.config/Scripts/hyprlock-coverart.sh"

# Boucle infinie qui s'arrête quand hyprlock n'est plus actif
while pgrep -x hyprlock > /dev/null; do
    # Mettre à jour la cover
    "${COVER_SCRIPT}" > /dev/null 2>&1
    
    # Attendre 2 secondes avant la prochaine mise à jour
    sleep 2
done

exit 0


