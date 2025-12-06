#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pywal-common.sh
. "$SCRIPT_DIR/pywal-common.sh"

TARGET="$HOME/.config/kitty/colors.conf"
SPECIAL_WALLPAPER="$HOME/Images/wallpapers/guts-berserk-dark.jpg"
SPECIAL_COLORS="$HOME/.config/kitty/colors-special.conf"

if ! SOURCE_FILE="$(pywal_locate_file "colors-kitty.conf")"; then
    echo "[generate-kitty-colors] Fichier colors-kitty.conf introuvable." >&2
    exit 1
fi

pywal_source_colors || true

use_special=false
if [[ -f "$SPECIAL_COLORS" && -n "${wallpaper:-}" ]]; then
    special_base="${SPECIAL_WALLPAPER%.*}"
    if [[ "$wallpaper" == "$SPECIAL_WALLPAPER" || "$wallpaper" == "${special_base}-"* ]]; then
        use_special=true
    fi
fi

if $use_special; then
    cp "$SPECIAL_COLORS" "$TARGET"
else
    cp "$SOURCE_FILE" "$TARGET"
fi
