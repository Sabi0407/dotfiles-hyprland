#!/bin/bash
set -euo pipefail

if command -v walcord >/dev/null 2>&1; then
    walcord --json "$HOME/.cache/wal/colors.json" >/dev/null 2>&1 || true
else
    echo "[walcord-sync] Commande 'walcord' introuvable." >&2
fi
