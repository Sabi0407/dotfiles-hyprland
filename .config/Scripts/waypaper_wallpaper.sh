#!/bin/bash
# Lance l'interface Waypaper en utilisant wallpaper-manager pour appliquer le fond d'écran

set -euo pipefail

if ! command -v waypaper >/dev/null 2>&1; then
    echo "Erreur : waypaper n'est pas installé ou introuvable dans le PATH." >&2
    exit 1
fi

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Images/wallpapers}"
EXTRA_DIRS="$WALLPAPER_DIR:$HOME/dotfiles/wallpapers:$HOME/Images/wallpapers"
CONFIG_DIR="$HOME/.config/waypaper"
CONFIG_FILE="$CONFIG_DIR/config.ini"
STATE_FILE="$CONFIG_DIR/state.ini"
SCRIPTS_DIR="$HOME/.config/Scripts"
POST_COMMAND="$SCRIPTS_DIR/wallpaper-manager.sh apply-path \$wallpaper"
BACKEND="${WAYPAPER_BACKEND:-swww}"

if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Erreur : dossier des wallpapers introuvable ($WALLPAPER_DIR)." >&2
    exit 1
fi

mkdir -p "$CONFIG_DIR"

CONFIG_FILE="$CONFIG_FILE" EXTRA_DIRS="$EXTRA_DIRS" POST_COMMAND="$POST_COMMAND" BACKEND="$BACKEND" python - <<'PY'
import configparser
import os
from pathlib import Path

config_path = Path(os.environ["CONFIG_FILE"]).expanduser()
folders = []
for entry in os.environ["EXTRA_DIRS"].split(":"):
    path = Path(entry).expanduser().resolve()
    if path.exists() and str(path) not in folders:
        folders.append(str(path))

config = configparser.ConfigParser(strict=False)
config_path.parent.mkdir(parents=True, exist_ok=True)
config.read(config_path, encoding="utf-8")
settings = config.setdefault("Settings", {})

existing = [line.strip() for line in settings.get("folder", "").splitlines() if line.strip()]
merged = []
for folder in folders + existing:
    if folder and folder not in merged:
        merged.append(folder)
settings["folder"] = "\n".join(merged)

defaults = {
    "backend": os.environ["BACKEND"],
    "fill": "fill",
    "sort": "name",
    "number_of_columns": "9",
    "post_command": os.environ["POST_COMMAND"],
    "color": "#000000",
    "swww_transition_type": "random",
    "swww_transition_step": "63",
    "swww_transition_angle": "0",
    "swww_transition_duration": "2",
    "swww_transition_fps": "60",
    "zen_mode": "True",
    "show_path_in_tooltip": "True",
    "subfolders": "True",
    "all_subfolders": "True",
    "show_hidden": "False",
    "stylesheet": str((Path.home() / ".config/waypaper/style.css").resolve()),
}

for key, value in defaults.items():
    settings.setdefault(key, value)

with config_path.open("w", encoding="utf-8") as f:
    config.write(f)
PY

waypaper --backend "$BACKEND" --state-file "$STATE_FILE"
