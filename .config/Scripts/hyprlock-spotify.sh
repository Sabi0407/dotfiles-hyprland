#!/bin/bash

set -euo pipefail

PLAYER="spotify"

if ! command -v playerctl >/dev/null 2>&1; then
    echo "<span font='JetBrainsMono NFM Bold 16'>Spotify indisponible</span>"
    exit 0
fi

status="$(playerctl --player="${PLAYER}" status 2>/dev/null || true)"

if [[ -z "${status}" || "${status}" == "No players found" ]]; then
    echo "<span font='JetBrainsMono NFM Bold 16'>Spotify inactif</span>"
    exit 0
fi

if [[ "${status}" != "Playing" && "${status}" != "Paused" ]]; then
    echo "<span font='JetBrainsMono NFM Bold 16'>Spotify ${status}</span>"
    exit 0
fi

title="$(playerctl --player="${PLAYER}" metadata --format '{{title}}' 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]\+$//')"
artist="$(playerctl --player="${PLAYER}" metadata --format '{{artist}}' 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]\+$//')"
[[ -z "${title}" ]] && title="Titre inconnu"
[[ -z "${artist}" ]] && artist="Artiste inconnu"

printf "<span font='JetBrainsMono NFM Bold 18'>%s</span>\n<span font='JetBrainsMono NFM 14'>%s</span>" "${title}" "${artist}"
