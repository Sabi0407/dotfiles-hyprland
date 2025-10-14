#!/bin/bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: hyprlock-clock.sh <hour|minute|second>
Outputs formatted time fragments for Hyprlock.
EOF
}

if [[ $# -ne 1 ]]; then
    usage >&2
    exit 1
fi

part="$1"
case "${part}" in
    hour)
        format_string='<b><big>%s</big></b>'
        date_format='%H'
        ;;
    minute)
        format_string='<b><big>%s</big></b>'
        date_format='%M'
        ;;
    second)
        format_string='<b>%s</b>'
        date_format='%S'
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac

printf "${format_string}\n" "$(date +"${date_format}")"
