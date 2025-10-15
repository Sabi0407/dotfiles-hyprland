#!/bin/bash
# Générer les couleurs Tofi à partir des couleurs pywal16
# Ce script met à jour la configuration Tofi avec les couleurs actuelles

LOCAL_CACHE_DIR="$HOME/.config/Scripts/wal-cache"
PYWAL_CACHE_DIR="${PYWAL_CACHE_DIR:-$LOCAL_CACHE_DIR}"
DEFAULT_PYWAL_CACHE="$HOME/.cache/wal"
COLORS_FILE="$PYWAL_CACHE_DIR/colors.json"

mkdir -p "$PYWAL_CACHE_DIR"

if [ ! -f "$COLORS_FILE" ] && [ -f "$DEFAULT_PYWAL_CACHE/colors.json" ]; then
    COLORS_FILE="$DEFAULT_PYWAL_CACHE/colors.json"
fi
TOFI_CONFIG="$HOME/.config/tofi/config"

if [ ! -f "$COLORS_FILE" ]; then
    echo "Erreur: Fichier $COLORS_FILE introuvable"
    exit 1
fi

echo "Génération des couleurs Tofi depuis pywal16..."

# Extraire les couleurs du fichier JSON
COLOR0=$(grep '"color0"' "$COLORS_FILE" | sed 's/.*"color0": *"\([^"]*\)".*/\1/')
COLOR4=$(grep '"color4"' "$COLORS_FILE" | sed 's/.*"color4": *"\([^"]*\)".*/\1/')
COLOR8=$(grep '"color8"' "$COLORS_FILE" | sed 's/.*"color8": *"\([^"]*\)".*/\1/')
COLOR11=$(grep '"color11"' "$COLORS_FILE" | sed 's/.*"color11": *"\([^"]*\)".*/\1/')
COLOR13=$(grep '"color13"' "$COLORS_FILE" | sed 's/.*"color13": *"\([^"]*\)".*/\1/')
COLOR15=$(grep '"color15"' "$COLORS_FILE" | sed 's/.*"color15": *"\([^"]*\)".*/\1/')

# Mettre à jour les couleurs dans le fichier config existant
sed -i "s/background-color = .*/background-color = ${COLOR0}CC/" "$TOFI_CONFIG"
sed -i "s/text-color = .*/text-color = ${COLOR15}/" "$TOFI_CONFIG"
sed -i "s/prompt-color = .*/prompt-color = ${COLOR15}/" "$TOFI_CONFIG"
sed -i "s/prompt-background = .*/prompt-background = #00000000/" "$TOFI_CONFIG"
sed -i "s/selection-color = .*/selection-color = ${COLOR11}/" "$TOFI_CONFIG"
sed -i "s/selection-text-color = .*/selection-text-color = ${COLOR0}/" "$TOFI_CONFIG"
sed -i "s/outline-color = .*/outline-color = ${COLOR11}80/" "$TOFI_CONFIG"
sed -i "s/border-color = .*/border-color = ${COLOR11}60/" "$TOFI_CONFIG"
sed -i "s/selection-match-color = .*/selection-match-color = ${COLOR11}/" "$TOFI_CONFIG"
sed -i "s/match-color = .*/match-color = ${COLOR11}/" "$TOFI_CONFIG"
sed -i "s/text-cursor-color = .*/text-cursor-color = ${COLOR13}/" "$TOFI_CONFIG"

# Tuer les instances de Tofi en cours pour forcer le rechargement
pkill tofi 2>/dev/null

echo "Configuration Tofi mise à jour avec les couleurs pywal16"
echo "Couleurs appliquées:"
echo "  - Fond: $COLOR0"
echo "  - Texte: $COLOR15" 
echo "  - Accent: $COLOR11"
echo "  - Curseur: $COLOR13"
echo "Fichier config: $TOFI_CONFIG"
echo "Fichier config: $TOFI_CONFIG"
