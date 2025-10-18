#!/bin/bash

# Synchronise le cache pywal vers l'emplacement attendu par Pywalfox
# puis déclenche la mise à jour du thème Firefox.

set -euo pipefail

# Déterminer le dossier où wal écrit actuellement ses fichiers.
DEFAULT_WAL_CACHE="$HOME/.cache/wal"
CANDIDATE_DIRS=()

if [[ -n "${PYWAL_CACHE_DIR:-}" ]]; then
    CANDIDATE_DIRS+=("$PYWAL_CACHE_DIR")
fi

CANDIDATE_DIRS+=(
    "$HOME/.config/wal/cache"
    "$DEFAULT_WAL_CACHE"
)

WAL_CACHE_DIR=""
for dir in "${CANDIDATE_DIRS[@]}"; do
    if [[ -d "$dir" && -f "$dir/colors.json" ]]; then
        WAL_CACHE_DIR="$dir"
        break
    fi
done

if [[ -z "$WAL_CACHE_DIR" ]]; then
    echo "[pywalfox] Avertissement : aucun cache wal valide trouvé." >&2
    exit 0
fi

# S'assurer que Pywalfox lit bien les dernières couleurs.
if [[ "$WAL_CACHE_DIR" != "$DEFAULT_WAL_CACHE" ]]; then
    mkdir -p "$DEFAULT_WAL_CACHE"
    for file in colors.json colors.css colors-rgb colors.sh; do
        if [[ -f "$WAL_CACHE_DIR/$file" ]]; then
            cp "$WAL_CACHE_DIR/$file" "$DEFAULT_WAL_CACHE/$file"
        fi
    done
fi

# Vérifier la présence de Pywalfox.
if ! command -v pywalfox >/dev/null 2>&1; then
    echo "[pywalfox] Avertissement : pywalfox n'est pas installé." >&2
    exit 0
fi

# Déclencher la mise à jour du thème Firefox.
if ! pywalfox update >/dev/null 2>&1; then
    echo "[pywalfox] ⚠️  Échec de la mise à jour Pywalfox." >&2
    exit 1
fi

echo "[pywalfox] Thème Firefox mis à jour."
