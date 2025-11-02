#!/bin/bash
################################################################################
# Script pour récupérer la cover art de la musique en cours pour hyprlock
# Utilise playerctl pour récupérer l'URL et la télécharge localement
# Retourne une image transparente si aucune musique ne joue
################################################################################

set -euo pipefail

# Répertoire pour stocker la cover art
COVER_DIR="/tmp/hyprlock-covers"
COVER_FILE="${COVER_DIR}/current-cover.jpg"
TRANSPARENT_COVER="${COVER_DIR}/transparent.png"

# Créer le répertoire s'il n'existe pas
mkdir -p "${COVER_DIR}"

# Créer une image transparente 1x1 si elle n'existe pas
if [[ ! -f "${TRANSPARENT_COVER}" ]]; then
    if command -v convert >/dev/null 2>&1; then
        convert -size 1x1 xc:none "${TRANSPARENT_COVER}" 2>/dev/null
    else
        # Créer un PNG transparent minimal (1x1 pixel) en base64
        echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > "${TRANSPARENT_COVER}"
    fi
fi

# Vérifier que playerctl est installé
if ! command -v playerctl >/dev/null 2>&1; then
    echo "${TRANSPARENT_COVER}"
    exit 0
fi

# Liste des lecteurs à essayer (par ordre de priorité)
PLAYERS=("spotify" "spotifyd" "mpd" "vlc" "firefox" "chromium")

# Fonction pour récupérer la cover art d'un lecteur
get_cover_from_player() {
    local player="$1"
    
    # Vérifier si le lecteur est actif
    if ! playerctl --player="${player}" status &>/dev/null; then
        return 1
    fi
    
    # Récupérer l'URL de la cover art
    local art_url
    art_url="$(playerctl --player="${player}" metadata mpris:artUrl 2>/dev/null || echo "")"
    
    if [[ -z "${art_url}" ]]; then
        return 1
    fi
    
    # Télécharger ou copier l'image selon le type d'URL
    if [[ "${art_url}" == http* ]]; then
        # URL web - télécharger avec curl
        if curl -s -L "${art_url}" -o "${COVER_FILE}" --max-time 5; then
            echo "${COVER_FILE}"
            return 0
        fi
    elif [[ "${art_url}" == file://* ]]; then
        # Fichier local - copier
        local file_path="${art_url#file://}"
        if [[ -f "${file_path}" ]]; then
            cp "${file_path}" "${COVER_FILE}"
            echo "${COVER_FILE}"
            return 0
        fi
    fi
    
    return 1
}

# Vérifier si au moins un lecteur est actif et en lecture/pause
music_playing=false
for player in "${PLAYERS[@]}"; do
    status="$(playerctl --player="${player}" status 2>/dev/null || echo "")"
    if [[ "${status}" == "Playing" || "${status}" == "Paused" ]]; then
        music_playing=true
        break
    fi
done

# Si aucune musique n'est en cours, copier l'image transparente et sortir
if [[ "${music_playing}" == "false" ]]; then
    cp "${TRANSPARENT_COVER}" "${COVER_FILE}" 2>/dev/null || true
    echo "${COVER_FILE}"
    exit 0
fi

# Essayer de récupérer la cover art de chaque lecteur actif
for player in "${PLAYERS[@]}"; do
    if get_cover_from_player "${player}"; then
        exit 0
    fi
done

# Si aucune cover trouvée mais musique en cours, utiliser l'image transparente
cp "${TRANSPARENT_COVER}" "${COVER_FILE}" 2>/dev/null || true
echo "${COVER_FILE}"
exit 0


