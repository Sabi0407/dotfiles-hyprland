#!/bin/bash
# Nettoie et régénère les miniatures utilisées par Nautilus

set -euo pipefail

cache_dirs=(
    "$HOME/.cache/thumbnails"
    "$HOME/.cache/nautilus/thumbnails"
    "$HOME/.cache/gnome-software/thumbnails"
)

echo "╔══════════════════════════════════════════════════╗"
echo "║ Nettoyage des miniatures Nautilus                ║"
echo "╚══════════════════════════════════════════════════╝"

for dir in "${cache_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "• suppression du contenu : $dir"
        rm -rf "${dir:?}/"* 2>/dev/null
    fi
done

echo "╔══════════════════════════════════════════════════╗"
echo "║ Redémarrage de Nautilus                          ║"
echo "╚══════════════════════════════════════════════════╝"

nautilus -q 2>/dev/null || true
nohup nautilus >/dev/null 2>&1 &

echo "Miniatures nettoyées. Parcourez vos dossiers pour les régénérer."
