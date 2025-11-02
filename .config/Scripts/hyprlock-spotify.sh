#!/bin/bash

set -euo pipefail

# Liste des lecteurs à essayer par ordre de priorité
PLAYERS=("spotify" "spotifyd" "firefox" "chromium" "vlc" "mpd")

if ! command -v playerctl >/dev/null 2>&1; then
    echo ""
    exit 0
fi

# Trouver le premier lecteur actif
ACTIVE_PLAYER=""
for player in "${PLAYERS[@]}"; do
    status="$(playerctl --player="${player}" status 2>/dev/null || true)"
    if [[ "${status}" == "Playing" || "${status}" == "Paused" ]]; then
        ACTIVE_PLAYER="${player}"
        break
    fi
done

# Si aucun lecteur actif, ne rien afficher
if [[ -z "${ACTIVE_PLAYER}" ]]; then
    echo ""
    exit 0
fi

title="$(playerctl --player="${ACTIVE_PLAYER}" metadata --format '{{title}}' 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]\+$//')"
artist="$(playerctl --player="${ACTIVE_PLAYER}" metadata --format '{{artist}}' 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]\+$//')"
[[ -z "${title}" ]] && title="Titre inconnu"
[[ -z "${artist}" ]] && artist="Artiste inconnu"

position="$(playerctl --player="${ACTIVE_PLAYER}" position 2>/dev/null || echo 0)"
length_output="$(playerctl --player="${ACTIVE_PLAYER}" metadata --format '{{mpris:length}}' 2>/dev/null || echo 0)"
if [[ "$length_output" =~ ^[0-9]+$ ]]; then
    length_micro="$length_output"
else
    length_micro="0"
fi

progress_line=""
if [[ "${length_micro}" =~ ^[0-9]+$ ]] && (( length_micro > 0 )); then
    progress_line="$(python3 - "$position" "$length_micro" <<'PY'
import sys
position = float(sys.argv[1])
length = float(sys.argv[2]) / 1_000_000
bar_len = 24
ratio = 0 if length <= 0 else min(max(position / length, 0), 1)
filled = int(round(bar_len * ratio))
bar = "━" * filled + "┄" * (bar_len - filled)
def fmt(sec):
    sec = max(sec, 0)
    m = int(sec // 60)
    s = int(sec % 60)
    return f"{m:02d}:{s:02d}"
print(f"<span font='JetBrainsMono NFM 12'>{bar}</span>  <span font='JetBrainsMono NFM 12'>{fmt(position)} · {fmt(length)}</span>")
PY
)"
fi

printf "<span font='JetBrainsMono NFM Bold 18'>%s</span>\n<span font='JetBrainsMono NFM 14'>%s</span>\n%s" "${title}" "${artist}" "${progress_line}"
