#!/bin/bash

# Script pour appliquer les couleurs pywal à zenity

# Récupérer les couleurs pywal depuis le cache
WAL_CACHE="$HOME/.cache/wal/colors"
if [ ! -f "$WAL_CACHE" ]; then
    echo "Cache pywal non trouvé. Génération des couleurs..."
    wal --theme random
fi

# Lire les couleurs pywal
source "$WAL_CACHE"

# Créer le thème GTK pour zenity
export GTK_THEME="Adwaita:dark"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

# Variables d'environnement pour les couleurs pywal
export GTK_COLOR_SCHEME="bg_color:$color0;fg_color:$color7;base_color:$color0;text_color:$color7;selected_bg_color:$color4;selected_fg_color:$color0;tooltip_bg_color:$color0;tooltip_fg_color:$color7"

# Appliquer le thème sombre
export GTK_THEME="Adwaita:dark" 