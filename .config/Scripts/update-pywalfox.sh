#!/bin/bash

# Synchronise le cache pywal vers l'emplacement attendu par Pywalfox
# puis déclenche la mise à jour du thème Firefox.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pywal-common.sh
. "$SCRIPT_DIR/pywal-common.sh"

DEFAULT_WAL_CACHE="$HOME/.cache/wal"

if ! COLORS_JSON="$(pywal_locate_file "colors.json")"; then
    echo "[pywalfox] Avertissement : aucun cache wal valide trouvé." >&2
    exit 0
fi

WAL_CACHE_DIR="$(dirname "$COLORS_JSON")"

if [[ "$WAL_CACHE_DIR" != "$DEFAULT_WAL_CACHE" ]]; then
    mkdir -p "$DEFAULT_WAL_CACHE"
    for file in colors.json colors.css colors-rgb colors.sh; do
        if [[ -f "$WAL_CACHE_DIR/$file" ]]; then
            cp "$WAL_CACHE_DIR/$file" "$DEFAULT_WAL_CACHE/$file"
        fi
    done
fi

if ! command -v pywalfox >/dev/null 2>&1; then
    echo "[pywalfox] Avertissement : pywalfox n'est pas installé." >&2
    exit 0
fi

if ! pywalfox update >/dev/null 2>&1; then
    echo "[pywalfox] ⚠️  Échec de la mise à jour Pywalfox." >&2
    exit 1
fi

echo "[pywalfox] Thème Firefox mis à jour."
