#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pywal-common.sh
. "$SCRIPT_DIR/pywal-common.sh"

TARGET="$HOME/.config/swaync/colors.css"

if ! SOURCE_FILE="$(pywal_locate_file "colors.css")"; then
    echo "[generate-swaync-colors] Fichier colors.css introuvable." >&2
    exit 1
fi

cp "$SOURCE_FILE" "$TARGET"
