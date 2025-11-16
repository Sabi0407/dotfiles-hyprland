#!/bin/bash
set -euo pipefail

# Orchestrateur exécuté après un `wal` pour aligner tous les composants.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pywal-common.sh
. "$SCRIPT_DIR/pywal-common.sh"

TASKS=(
    "update-pywalfox.sh"
    "wal2swaync.sh"
    "generate-swaync-colors.sh"
    "generate-pywal-waybar-style.sh"
    "generate-tofi-colors.sh"
    "walcord-sync.sh"
    "generate-kitty-colors.sh"
    "generate-hyprland-colors.sh"
    "generate-hyprlock-colors.sh"
    "generate-swayosd-colors.sh"
)

failures=()

for task in "${TASKS[@]}"; do
    task_path="${SCRIPT_DIR}/${task}"
    if [[ ! -x "$task_path" ]]; then
        pywal_warn "script ${task} introuvable ou non exécutable."
        failures+=("${task} (absent)")
        continue
    fi
    echo "[pywal-sync] ${task}"
    if ! "$task_path"; then
        failures+=("${task}")
    fi
done

# Relancer les applis dépendantes des nouvelles couleurs
echo "[pywal-sync] Reloading swaync/waybar/swayosd"
pkill swaync 2>/dev/null || true
swaync & disown
pkill waybar 2>/dev/null || true
waybar & disown
pkill swayosd-server 2>/dev/null || true
swayosd-server >/tmp/swayosd.log 2>&1 & disown

if (( ${#failures[@]} > 0 )); then
    echo "[pywal-sync] Attention : certains modules ont échoué :" >&2
    for item in "${failures[@]}"; do
        echo "  - ${item}" >&2
    done
    exit 1
fi
