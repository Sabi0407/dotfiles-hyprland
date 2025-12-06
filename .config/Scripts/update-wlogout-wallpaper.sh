#!/usr/bin/env bash
set -euo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
OUTPUT_IMAGE="$CACHE_DIR/wlogout_wallpaper_blur.png"
TEMP_OUTPUT="${OUTPUT_IMAGE}.tmp"
MPVPAPER_SHOT="$CACHE_DIR/mpvpaper-wallpaper/pywal/wallpaper.png"
MPVPAPER_STATE_FILE="$CACHE_DIR/mpvpaper-wallpaper/state"
METADATA_FILE="$CACHE_DIR/wlogout_wallpaper_meta"
LAST_WALL_FILE="$HOME/.config/dernier_wallpaper.txt"
WAYPAPER_STATE="$HOME/.config/waypaper/state.ini"
WAL_COLORS_JSON="$HOME/.cache/wal/colors.json"
WLOGOUT_COLOR_FILE="$HOME/.config/wlogout/colors.css"
DEFAULT_ACCENT="#7f5af0"
DEFAULT_TEXT="#f0f0f0"
DEFAULT_STRONG="#ffffff"
SPECIAL_WALLPAPERS=(
	"$HOME/Images/wallpapers/guts-berserk-dark.jpg"
	"$HOME/Images/wallpapers/berserk-guts-colored-5k-1920x1080-13633.jpg"
	"$HOME/Images/wallpapers/guts-berserk-dark-1920x1080-13650.jpg"
)
SPECIAL_ACCENT="#d60f2c"
SPECIAL_TEXT="#c1c0c0"
SPECIAL_STRONG="#f7f7f7"

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

cleanup() {
	if [ -f "$TEMP_OUTPUT" ]; then
		rm -f "$TEMP_OUTPUT"
	fi
	if [ -n "${TEMP_SOURCE:-}" ] && [ -f "$TEMP_SOURCE" ]; then
		rm -f "$TEMP_SOURCE"
	fi
}
trap cleanup EXIT

log() {
	printf '[wlogout-wallpaper] %s\n' "$*" >&2
}

trim() {
	local value="${1:-}"
	value="${value#"${value%%[![:space:]]*}"}"
	value="${value%"${value##*[![:space:]]}"}"
	printf '%s' "$value"
}

expand_path() {
	local raw
	raw=$(trim "${1:-}")
	raw="${raw%\"}"
	raw="${raw#\"}"
	raw="${raw%\'}"
	raw="${raw#\'}"
	raw="${raw/#\~/$HOME}"
	printf '%s' "$raw"
}

existing_file() {
	local path
	path=$(expand_path "$1")
	if [ -n "$path" ] && [ -f "$path" ]; then
		printf '%s\n' "$path"
		return 0
	fi
	return 1
}

mpvpaper_is_active() {
	if [ -n "${WLOGOUT_FORCE_STATIC:-}" ]; then
		return 1
	fi
	if ! pgrep -x mpvpaper >/dev/null 2>&1; then
		return 1
	fi
	if [ -f "$MPVPAPER_STATE_FILE" ]; then
		local mode
		mode=$(tr '[:upper:]' '[:lower:]' <"$MPVPAPER_STATE_FILE" 2>/dev/null | head -n1 | tr -d '\r')
		if [ "$mode" != "video" ]; then
			return 1
		fi
	fi
	return 0
}

source_from_mpvpaper() {
	if mpvpaper_is_active && [ -s "$MPVPAPER_SHOT" ]; then
		printf '%s\n' "$MPVPAPER_SHOT"
		return 0
	fi
	return 1
}

source_from_last_wallpaper() {
	if [ -f "$LAST_WALL_FILE" ]; then
		local candidate
		candidate=$(<"$LAST_WALL_FILE")
		existing_file "$candidate" && return 0
	fi
	return 1
}

source_from_waypaper() {
	if [ -f "$WAYPAPER_STATE" ]; then
		local candidate
		candidate=$(awk -F '=' '/^wallpaper/ {print $2; exit}' "$WAYPAPER_STATE" 2>/dev/null || true)
		if [ -n "$candidate" ]; then
			existing_file "$candidate" && return 0
		fi
	fi
	return 1
}

source_from_swww() {
	if ! command -v swww >/dev/null 2>&1; then
		return 1
	fi
	local data raw
	if ! data=$(swww query 2>/dev/null); then
		return 1
	fi
	raw=$(printf '%s\n' "$data" | awk -F': ' '/[Ii]mage/ {print $2; exit}')
	if [ -z "$raw" ]; then
		return 1
	fi
	raw=${raw%% (resized*}
	raw=$(trim "$raw")
	existing_file "$raw" && return 0
	return 1
}

source_from_screenshot() {
	if ! command -v grim >/dev/null 2>&1; then
		return 1
	fi
	mkdir -p "$CACHE_DIR"
	TEMP_SOURCE=$(mktemp "$CACHE_DIR/wlogout_sourceXXXXXX.png")
	if grim "$TEMP_SOURCE"; then
		printf '%s\n' "$TEMP_SOURCE"
		return 0
	fi
	rm -f "$TEMP_SOURCE"
	unset TEMP_SOURCE
	return 1
}

resolve_wallpaper() {
	source_from_mpvpaper && return 0
	source_from_last_wallpaper && return 0
	source_from_waypaper && return 0
	source_from_swww && return 0
	source_from_screenshot && return 0
	return 1
}

blur_image() {
	local src="$1"
	if command -v magick >/dev/null 2>&1; then
		magick "$src" -blur 0x30 "$TEMP_OUTPUT"
	elif command -v convert >/dev/null 2>&1; then
		convert "$src" -blur 0x30 "$TEMP_OUTPUT"
	else
		log "ImageMagick (magick ou convert) est requis mais introuvable."
		return 1
	fi
}

update_color_palette() {
	mkdir -p "$(dirname "$WLOGOUT_COLOR_FILE")"
	local accent="$DEFAULT_ACCENT"
	local text="$DEFAULT_TEXT"
	local strong="$DEFAULT_STRONG"
	if [ -f "$WAL_COLORS_JSON" ]; then
		if mapfile -t wal_values < <(
			python3 - "$WAL_COLORS_JSON" <<'PY'
import json, sys
path = sys.argv[1]
try:
    data = json.load(open(path, encoding="utf-8"))
except Exception:
    sys.exit(1)
colors = data.get("colors", {})
special = data.get("special", {})
accent = colors.get("color10") or colors.get("color11") or colors.get("color9") or colors.get("color4") or special.get("foreground")
text = special.get("foreground") or colors.get("color7")
strong = colors.get("color15") or text
print(accent or "")
print(text or "")
print(strong or "")
PY
		); then
			[ -n "${wal_values[0]:-}" ] && accent="${wal_values[0]}"
			[ -n "${wal_values[1]:-}" ] && text="${wal_values[1]}"
			[ -n "${wal_values[2]:-}" ] && strong="${wal_values[2]}"
		fi
	fi
	if [[ -n "${SOURCE_PATH:-}" ]] && is_special_wallpaper "$SOURCE_PATH"; then
		accent="$SPECIAL_ACCENT"
		text="$SPECIAL_TEXT"
		strong="$SPECIAL_STRONG"
	fi
	cat >"$WLOGOUT_COLOR_FILE" <<EOF
@define-color accent-color ${accent};
@define-color text-color ${text};
@define-color strong-text ${strong};
EOF
	log "Palette wlogout mise à jour (accent ${accent})"
}

load_metadata() {
	if [ -f "$METADATA_FILE" ]; then
		# shellcheck disable=SC1090
		. "$METADATA_FILE"
	fi
}

save_metadata() {
	printf 'LAST_SOURCE=%q\nLAST_MTIME=%q\n' "$SOURCE_PATH" "$SOURCE_MTIME" >"$METADATA_FILE"
}

maybe_skip_refresh() {
	if [ -n "${WLOGOUT_NO_CACHE:-}" ]; then
		return 1
	fi
	if [ ! -f "$OUTPUT_IMAGE" ] || [ -z "${LAST_SOURCE:-}" ] || [ -z "${LAST_MTIME:-}" ]; then
		return 1
	fi
	if [ -z "$SOURCE_PATH" ] || [ -z "$SOURCE_MTIME" ] || [ "$SOURCE_MTIME" = "0" ]; then
		return 1
	fi
	if [ "$LAST_SOURCE" != "$SOURCE_PATH" ]; then
		return 1
	fi
	if [ "$LAST_MTIME" != "$SOURCE_MTIME" ] || [ "$LAST_MTIME" = "0" ]; then
		return 1
	fi
	return 0
}

main() {
	mkdir -p "$CACHE_DIR"
	load_metadata
	if ! SOURCE_PATH=$(resolve_wallpaper); then
		log "Impossible de déterminer le wallpaper actuel."
		exit 1
	fi
	SOURCE_MTIME=$(stat -c %Y "$SOURCE_PATH" 2>/dev/null || echo 0)
	if maybe_skip_refresh; then
		log "Fond wlogout déjà à jour (source inchangée)"
		exit 0
	fi
	if ! blur_image "$SOURCE_PATH"; then
		exit 1
	fi
	mv "$TEMP_OUTPUT" "$OUTPUT_IMAGE"
	update_color_palette
	save_metadata
	log "Fond wlogout mis à jour depuis $SOURCE_PATH"
}

main "$@"
