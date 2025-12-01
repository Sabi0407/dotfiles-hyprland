#!/bin/bash
set -euo pipefail
PLAYERS=("spotify" "spotifyd" "firefox" "chromium" "vlc" "mpd")
if ! command -v playerctl >/dev/null 2>&1; then
    exit 1
fi
for player in "${PLAYERS[@]}"; do
    status="$(playerctl --player="${player}" status 2>/dev/null || true)"
    if [[ "${status}" == "Playing" || "${status}" == "Paused" ]]; then
        exit 0
    fi
done
exit 1
