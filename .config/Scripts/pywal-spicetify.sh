#!/bin/bash
set -euo pipefail

THEMES_DIR="$HOME/.config/spicetify/Themes"
CURRENT_THEME="$(spicetify config current_theme | awk 'NR==1 {print $1}')"
THEME="${SPICETIFY_THEME:-${CURRENT_THEME:-Pywal}}"
WAL_CACHE_DIR="${PYWAL_CACHE_DIR:-$HOME/.config/wal/cache}"
TEMPLATE_FILE="$HOME/.config/wal/templates/colors-spicetify.ini"
CURRENT_SCHEME="$(spicetify config color_scheme | awk 'NR==1 {print $1}')"
COLOR_SCHEME="${SPICETIFY_COLOR_SCHEME:-${CURRENT_SCHEME:-Pywal}}"
DEFAULT_THEME_DIR=""

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[pywal-spicetify] Commande introuvable: $1" >&2
        exit 1
    fi
}

require_cmd spicetify
require_cmd pywal-spicetify
require_cmd wal

if [[ -d "$THEMES_DIR/SpicetifyDefault" ]]; then
    DEFAULT_THEME_DIR="$THEMES_DIR/SpicetifyDefault"
elif [[ -d "/usr/share/spicetify-cli/Themes/SpicetifyDefault" ]]; then
    DEFAULT_THEME_DIR="/usr/share/spicetify-cli/Themes/SpicetifyDefault"
elif [[ -d "/opt/spicetify-cli/Themes/SpicetifyDefault" ]]; then
    DEFAULT_THEME_DIR="/opt/spicetify-cli/Themes/SpicetifyDefault"
elif [[ -d "/opt/spotify/share/spicetify-cli/Themes/SpicetifyDefault" ]]; then
    DEFAULT_THEME_DIR="/opt/spotify/share/spicetify-cli/Themes/SpicetifyDefault"
fi

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "[pywal-spicetify] Aucun template colors-spicetify.ini trouvé." >&2
    exit 1
fi

if [[ ! -f "$WAL_CACHE_DIR/colors-spicetify.ini" ]]; then
    wal -R -n >/dev/null 2>&1 || {
        if [[ -f "$WAL_CACHE_DIR/wal" ]]; then
            wal -n -i "$(cat "$WAL_CACHE_DIR/wal")" >/dev/null 2>&1 || true
        fi
    }
fi

if [[ ! -f "$WAL_CACHE_DIR/colors-spicetify.ini" ]]; then
    echo "[pywal-spicetify] Impossible de générer colors-spicetify.ini." >&2
    exit 1
fi

DEFAULT_CACHE="$HOME/.cache/wal"
mkdir -p "$DEFAULT_CACHE"
cp "$WAL_CACHE_DIR/colors-spicetify.ini" "$DEFAULT_CACHE/colors-spicetify.ini"

TARGET_DIR="$THEMES_DIR/$THEME"
if [[ ! -d "$TARGET_DIR" ]]; then
    if [[ -z "$DEFAULT_THEME_DIR" ]]; then
        echo "[pywal-spicetify] Thème de base introuvable." >&2
        exit 1
    fi
    mkdir -p "$THEMES_DIR"
    cp -r "$DEFAULT_THEME_DIR" "$TARGET_DIR"
fi
COLOR_FILE="$TARGET_DIR/color.ini"

WAL_CACHE_DIR="$WAL_CACHE_DIR" COLOR_FILE="$COLOR_FILE" COLOR_SCHEME="$COLOR_SCHEME" \
python3 <<'PY'
import os
from pathlib import Path

input_file = Path(os.environ["WAL_CACHE_DIR"]) / "colors-spicetify.ini"
output_file = Path(os.environ["COLOR_FILE"])
scheme = os.environ["COLOR_SCHEME"]

with input_file.open("r", encoding="utf-8") as src:
    lines = src.readlines()

if lines and lines[0].startswith("["):
    lines[0] = f"[{scheme}]\n"

output_file.parent.mkdir(parents=True, exist_ok=True)
with output_file.open("w", encoding="utf-8") as dst:
    dst.writelines(lines)
PY

spicetify config color_scheme "$COLOR_SCHEME" >/dev/null
echo "[pywal-spicetify] Palette mise à jour pour le thème '$THEME' (schéma '$COLOR_SCHEME')." >&2
echo "[pywal-spicetify] Lancez 'spicetify apply --no-restart' quand vous souhaitez appliquer la mise à jour." >&2
