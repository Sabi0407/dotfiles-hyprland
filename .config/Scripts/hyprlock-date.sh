#!/bin/bash

set -euo pipefail

locale="${LC_TIME:-fr_FR.UTF-8}"

if [[ $# -gt 0 ]]; then
    locale="$1"
fi

LC_TIME="${locale}" date +"%d %B %Y"
