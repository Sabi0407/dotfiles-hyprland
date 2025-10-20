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
        use_pywal_color='false'
        ;;
    minute)
        format_string='<b><big>%s</big></b>'
        date_format='%M'
        use_pywal_color='false'
        ;;
    second)
        format_string='<b>%s</b>'
        date_format='%S'
        use_pywal_color='false'
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac

value="$(date +"${date_format}")"

if [[ "${use_pywal_color}" == 'true' ]]; then
    palette_file="${HOME}/.cache/wal/colors"
    fallback_color="#c3c4c4"
    pywal_color="${fallback_color}"

    if [[ -r "${palette_file}" ]]; then
        mapfile -t palette < "${palette_file}"
        # Remove empty entries
        cleaned_palette=()
        for entry in "${palette[@]}"; do
            if [[ -n "${entry// }" ]]; then
                cleaned_palette+=("${entry//[$'\r\n']}")
            fi
        done

        palette_size=${#cleaned_palette[@]}
        if (( palette_size > 1 )); then
            # Skip the first color (background) and cycle through the rest
            second_value=$((10#${value}))
            usable_size=$((palette_size - 1))
            index=$((second_value % usable_size + 1))
            pywal_color="${cleaned_palette[index]}"
        fi
    fi

    printf "${format_string}\n" "${pywal_color}" "${value}"
else
    printf "${format_string}\n" "${value}"
fi
