#!/bin/bash
# Lance l'interface Waypaper en utilisant wallpaper-manager pour appliquer le fond d'écran

set -euo pipefail

if ! command -v waypaper >/dev/null 2>&1; then
    echo "Erreur : waypaper n'est pas installé ou introuvable dans le PATH." >&2
    exit 1
fi

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Images/wallpapers}"
CONFIG_DIR="$HOME/.config/waypaper"
CONFIG_FILE="$CONFIG_DIR/config.ini"
STATE_FILE="$CONFIG_DIR/state.ini"
SCRIPTS_DIR="$HOME/.config/Scripts"
POST_COMMAND="$SCRIPTS_DIR/wallpaper-manager.sh apply-path \$wallpaper"

if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Erreur : dossier des wallpapers introuvable ($WALLPAPER_DIR)." >&2
    exit 1
fi

mkdir -p "$CONFIG_DIR"

CONFIG_FILE="$CONFIG_FILE" WALLPAPER_DIR="$WALLPAPER_DIR" POST_COMMAND="$POST_COMMAND" python - <<'PY'
import configparser
import os
import pathlib

config_path = pathlib.Path(os.environ["CONFIG_FILE"]).expanduser()
wallpaper_dir = pathlib.Path(os.environ["WALLPAPER_DIR"]).expanduser()
post_command = os.environ["POST_COMMAND"]

extra_dirs = [
    wallpaper_dir,
    pathlib.Path.home() / "dotfiles/wallpapers",
    pathlib.Path.home() / "Images/wallpapers",
]

folders = []
for path in extra_dirs:
    if not path.exists():
        continue
    resolved = str(path.resolve())
    if resolved not in folders:
        folders.append(resolved)

config_path.parent.mkdir(parents=True, exist_ok=True)
config = configparser.ConfigParser()
config.read(config_path, encoding="utf-8")

if "Settings" not in config:
    config["Settings"] = {}

settings = config["Settings"]

folders_raw = settings.get("folder", "").strip()
folder_lines = [line.strip() for line in folders_raw.splitlines() if line.strip()]
for folder in folders:
    if folder not in folder_lines:
        folder_lines.append(folder)
settings["folder"] = "\n".join(folder_lines)

settings["backend"] = "none"
settings.setdefault("fill", "fill")
settings.setdefault("sort", "name")
settings["number_of_columns"] = "9"
settings["post_command"] = post_command
settings.setdefault("color", "#000000")
settings.setdefault("swww_transition_type", "random")
settings.setdefault("swww_transition_step", "63")
settings.setdefault("swww_transition_angle", "0")
settings.setdefault("swww_transition_duration", "2")
settings.setdefault("swww_transition_fps", "60")
settings.setdefault("zen_mode", "True")
settings.setdefault("show_path_in_tooltip", "True")
settings.setdefault("subfolders", "True")
settings.setdefault("all_subfolders", "True")
settings.setdefault("show_hidden", "False")
settings["stylesheet"] = str(pathlib.Path.home() / ".config/waypaper/style.css")

with config_path.open("w", encoding="utf-8") as f:
    config.write(f)
PY

waypaper --backend none --folder "$WALLPAPER_DIR" --state-file "$STATE_FILE"
