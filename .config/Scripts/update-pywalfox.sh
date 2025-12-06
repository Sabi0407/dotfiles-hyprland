#!/bin/bash

# Synchronise le cache pywal vers l'emplacement attendu par Pywalfox
# puis déclenche la mise à jour du thème Firefox.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pywal-common.sh
. "$SCRIPT_DIR/pywal-common.sh"

DEFAULT_WAL_CACHE="$HOME/.cache/wal"
SPECIAL_WALLPAPERS=(
    "$HOME/Images/wallpapers/guts-berserk-dark.jpg"
    "$HOME/Images/wallpapers/berserk-guts-colored-5k-1920x1080-13633.jpg"
    "$HOME/Images/wallpapers/guts-berserk-dark-1920x1080-13650.jpg"
)
SPECIAL_ACCENT="#d60f2c"
SPECIAL_ACCENT_DIM="#8f3532"

is_special_wallpaper() {
    local target="$1"
    [[ -z "$target" ]] && return 1
    local candidate base
    for candidate in "${SPECIAL_WALLPAPERS[@]}"; do
        base="${candidate%.*}"
        if [[ "$target" == "$candidate" || "$target" == "$base"-* ]]; then
            return 0
        fi
    done
    return 1
}

PYWALFOX_PATCHED=0
PYWALFOX_JSON_BACKUP=""

restore_colors_json() {
    if [[ $PYWALFOX_PATCHED -eq 1 && -n "$PYWALFOX_JSON_BACKUP" && -f "$PYWALFOX_JSON_BACKUP" ]]; then
        mv "$PYWALFOX_JSON_BACKUP" "$DEFAULT_WAL_CACHE/colors.json"
    fi
}
trap restore_colors_json EXIT

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

CURRENT_WALLPAPER=""
if command -v python3 >/dev/null 2>&1; then
    CURRENT_WALLPAPER="$(python3 - "$COLORS_JSON" <<'PY'
import json, sys
try:
    data = json.load(open(sys.argv[1], encoding="utf-8"))
except Exception:
    sys.exit(1)
print(data.get("wallpaper",""))
PY
)" || CURRENT_WALLPAPER=""
    CURRENT_WALLPAPER="${CURRENT_WALLPAPER//$'\n'/}"
fi

DEFAULT_JSON="$DEFAULT_WAL_CACHE/colors.json"
if [[ -f "$DEFAULT_JSON" && -n "$CURRENT_WALLPAPER" ]] && is_special_wallpaper "$CURRENT_WALLPAPER"; then
    PYWALFOX_JSON_BACKUP="${DEFAULT_JSON}.pywalfox-backup"
    cp "$DEFAULT_JSON" "$PYWALFOX_JSON_BACKUP"
    python3 - "$DEFAULT_JSON" "$SPECIAL_ACCENT" "$SPECIAL_ACCENT_DIM" <<'PY'
import json, sys
path, accent, accent_dim = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, encoding="utf-8") as fh:
    data = json.load(fh)
colors = data.setdefault("colors", {})
for key in ("color9", "color10", "color14"):
    colors[key] = accent
for key in ("color1", "color11"):
    colors[key] = accent_dim
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=4)
PY
    PYWALFOX_PATCHED=1
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
