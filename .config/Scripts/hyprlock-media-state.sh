#!/bin/bash
set -euo pipefail
# Lecteurs autorisés pour l'affichage de la carte média
PLAYERS=("spotify" "spotifyd" "vlc" "mpd")
# Sources à masquer (ex. YouTube)
BLOCKED_PATTERNS=("youtube.com" "youtu.be" "ytimg.com" "googlevideo.com")

is_blocked_source() {
    local player="$1"
    local metadata lower
    metadata="$(playerctl --player="${player}" metadata --format '{{xesam:url}}\n{{mpris:artUrl}}\n{{mpris:trackid}}\n{{xesam:title}}\n{{xesam:album}}' 2>/dev/null || true)"
    lower="${metadata,,}"
    for pattern in "${BLOCKED_PATTERNS[@]}"; do
        if [[ -n "${pattern}" && "${lower}" == *"${pattern}"* ]]; then
            return 0
        fi
    done
    return 1
}
if ! command -v playerctl >/dev/null 2>&1; then
    exit 1
fi
for player in "${PLAYERS[@]}"; do
    status="$(playerctl --player="${player}" status 2>/dev/null || true)"
    if [[ "${status}" == "Playing" || "${status}" == "Paused" ]]; then
        if ! is_blocked_source "${player}"; then
            exit 0
        fi
    fi
done
exit 1
