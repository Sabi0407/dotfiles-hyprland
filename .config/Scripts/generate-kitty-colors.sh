#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pywal-common.sh
. "$SCRIPT_DIR/pywal-common.sh"

TARGET="$HOME/.config/kitty/colors.conf"

if ! SOURCE_FILE="$(pywal_locate_file "colors-kitty.conf")"; then
    echo "[generate-kitty-colors] Fichier colors-kitty.conf introuvable." >&2
    exit 1
fi

cp "$SOURCE_FILE" "$TARGET"
