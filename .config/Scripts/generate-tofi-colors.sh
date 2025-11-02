#!/bin/bash
set -euo pipefail

# Génère les couleurs Tofi à partir des couleurs pywal16.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pywal-common.sh
. "$SCRIPT_DIR/pywal-common.sh"

TOFI_CONFIG="$HOME/.config/tofi/config"

if ! COLORS_FILE="$(pywal_locate_file "colors.json")"; then
    echo "Erreur: fichier colors.json introuvable dans le cache pywal." >&2
    exit 1
fi

if [[ ! -f "$TOFI_CONFIG" ]]; then
    echo "[generate-tofi-colors] Configuration Tofi introuvable, rien à mettre à jour." >&2
    exit 0
fi

echo "Génération des couleurs Tofi depuis pywal16..."

COLOR0=$(grep '"color0"' "$COLORS_FILE" | sed 's/.*"color0": *"\([^"]*\)".*/\1/')
COLOR4=$(grep '"color4"' "$COLORS_FILE" | sed 's/.*"color4": *"\([^"]*\)".*/\1/')
COLOR11=$(grep '"color11"' "$COLORS_FILE" | sed 's/.*"color11": *"\([^"]*\)".*/\1/')
COLOR13=$(grep '"color13"' "$COLORS_FILE" | sed 's/.*"color13": *"\([^"]*\)".*/\1/')
COLOR15=$(grep '"color15"' "$COLORS_FILE" | sed 's/.*"color15": *"\([^"]*\)".*/\1/')

sed -i "s/background-color = .*/background-color = ${COLOR0}CC/" "$TOFI_CONFIG"
sed -i "s/text-color = .*/text-color = ${COLOR15}/" "$TOFI_CONFIG"
sed -i "s/prompt-color = .*/prompt-color = ${COLOR15}/" "$TOFI_CONFIG"
sed -i "s/prompt-background = .*/prompt-background = #00000000/" "$TOFI_CONFIG"
sed -i "s/selection-color = .*/selection-color = ${COLOR11}/" "$TOFI_CONFIG"
sed -i "s/outline-color = .*/outline-color = ${COLOR11}80/" "$TOFI_CONFIG"
sed -i "s/border-color = .*/border-color = ${COLOR11}60/" "$TOFI_CONFIG"
sed -i "s/text-cursor-color = .*/text-cursor-color = ${COLOR13}/" "$TOFI_CONFIG"

pkill -x tofi 2>/dev/null || true

echo "Configuration Tofi mise à jour avec les couleurs pywal16"
echo "Couleurs appliquées:"
echo "  - Fond: $COLOR0"
echo "  - Texte: $COLOR15"
echo "  - Accent: $COLOR11"
echo "  - Curseur: $COLOR13"
echo "Fichier config: $TOFI_CONFIG"
