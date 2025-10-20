#!/bin/bash
# Nettoie et régénère les miniatures utilisées par Thunar

set -euo pipefail

cache_dirs=(
    "$HOME/.cache/thumbnails"
    "$HOME/.cache/thunar"
    "$HOME/.cache/Thunar"
)

echo "╔══════════════════════════════════════════════════╗"
echo "║ Nettoyage des miniatures Thunar                  ║"
echo "╚══════════════════════════════════════════════════╝"

for dir in "${cache_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "• suppression du contenu : $dir"
        rm -rf "${dir:?}/"* 2>/dev/null
    fi
done

echo "╔══════════════════════════════════════════════════╗"
echo "║ Redémarrage des services de miniatures           ║"
echo "╚══════════════════════════════════════════════════╝"

thunar_was_running=false
if pgrep -x thunar >/dev/null 2>&1; then
    thunar_was_running=true
    thunar -q 2>/dev/null || true
fi

tumblerd_was_running=false
if pgrep -x tumblerd >/dev/null 2>&1; then
    tumblerd_was_running=true
    pkill tumblerd 2>/dev/null || true
fi

if [ "$tumblerd_was_running" = true ]; then
    nohup tumblerd >/dev/null 2>&1 &
fi

if [ "$thunar_was_running" = true ]; then
    nohup thunar >/dev/null 2>&1 &
fi

echo "Miniatures Thunar nettoyées. Parcourez vos dossiers pour les régénérer."
