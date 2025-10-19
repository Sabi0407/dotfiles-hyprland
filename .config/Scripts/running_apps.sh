#!/bin/bash

# Script pour afficher les processus en arrière-plan dans Waybar
# Affiche les applications qui tournent en arrière-plan

# Fonction pour obtenir les processus en arrière-plan
get_background_processes() {
    # Obtenir les processus avec des noms d'applications connus
    ps aux | grep -E "(discord|spotify|steam|telegram|signal|whatsapp|slack|obsidian|anki|qBittorrent|virtualbox|gimp|blender|onlyoffice|firefox|chrome|brave)" | \
    grep -v grep | \
    awk '{print $11}' | \
    sort | uniq | \
    sed 's/.*\///' | \
    tr '\n' ' ' | \
    sed 's/ $//'
}

# Obtenir les processus
processes=$(get_background_processes)

# Si aucun processus trouvé
if [ -z "$processes" ]; then
    echo "Aucun processus en arrière-plan"
else
    echo "$processes"
fi
