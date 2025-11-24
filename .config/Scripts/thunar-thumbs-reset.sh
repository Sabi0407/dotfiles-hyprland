#!/bin/bash

THUNAR_CACHE=("$HOME/.cache/thumbnails" "$HOME/.cache/thunar" "$HOME/.cache/Thunar")

for dir in "${THUNAR_CACHE[@]}"; do
    [ -d "$dir" ] && rm -rf "${dir:?}/"*
done

pkill -x tumblerd >/dev/null 2>&1 && tumblerd >/dev/null 2>&1 &

pgrep -x thunar >/dev/null 2>&1 && thunar -q >/dev/null 2>&1

echo "Caches Thunar effacer . Les miniatures se régénéreront au prochain passage."
