#!/bin/bash

set -euo pipefail

# Limit curl to 1 second to avoid blocking Hyprlock during lock
output="$(curl -s --max-time 1 'wttr.in?format=%t' | tr -d '+')"

if [[ -z "${output}" ]]; then
    echo "<b>Météo indisponible</b>"
    exit 0
fi

printf "<b>Ressenti<big> %s </big></b>\n" "${output}"
