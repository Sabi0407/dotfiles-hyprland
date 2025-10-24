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

escape_json() {
    local input=${1//\\/\\\\}
    input=${input//\"/\\\"}
    input=${input//$'\n'/\\n}
    echo "$input"
}

# Obtenir les processus
processes=$(get_background_processes)

if [ -z "$processes" ]; then
    tooltip="Aucun processus en arrière-plan"
else
    tooltip="Processus en arrière-plan :\n$processes"
fi

printf '{"text":"","tooltip":"%s"}\n' "$(escape_json "$tooltip")"
