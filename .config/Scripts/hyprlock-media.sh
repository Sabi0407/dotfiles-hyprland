#!/bin/bash
set -euo pipefail

if ! command -v playerctl >/dev/null 2>&1; then
    echo ""
    exit 0
fi

PLAYERS=("spotify" "spotifyd" "firefox" "chromium" "vlc" "mpd")
ACTIVE_PLAYER=""
for player in "${PLAYERS[@]}"; do
    status="$(playerctl --player="${player}" status 2>/dev/null || true)"
    if [[ "${status}" == "Playing" || "${status}" == "Paused" ]]; then
        ACTIVE_PLAYER="${player}"
        break
    fi
done

if [[ -z "${ACTIVE_PLAYER}" ]]; then
    echo ""
    exit 0
fi

title="$(playerctl --player="${ACTIVE_PLAYER}" metadata --format '{{title}}' 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]\+$//')"
artist="$(playerctl --player="${ACTIVE_PLAYER}" metadata --format '{{artist}}' 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]\+$//')"
album="$(playerctl --player="${ACTIVE_PLAYER}" metadata --format '{{album}}' 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]\+$//')"
cell_width=16
[ ${#title} -gt $cell_width ] && title="${title:0:$cell_width}…"
[ ${#album} -gt $cell_width ] && album="${album:0:$cell_width}…"
[ ${#artist} -gt $cell_width ] && artist="${artist:0:$cell_width}…"
[[ -z "${title}" ]] && title="Titre inconnu"
[[ -z "${artist}" ]] && artist="Artiste inconnu"
[[ -z "${album}" ]] && album="Album inconnu"

printf "<span font='JetBrainsMono NFM Bold 16'>%s</span>\n<span font='JetBrainsMono NFM 12'>%s</span>\n<span font='JetBrainsMono NFM Italic 11'>%s</span>" "${title}" "${album}" "${artist}"
