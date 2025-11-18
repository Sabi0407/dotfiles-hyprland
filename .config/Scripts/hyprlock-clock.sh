#!/bin/bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: hyprlock-clock.sh <hour|minute|second|full>
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
        format_string='%s'
        date_format='%H'
        color_mode='pywal16'
        ;;
    minute)
        format_string='%s'
        date_format='%M'
        color_mode='pywal16'
        ;;
    second)
        format_string='<b>%s</b>'
        date_format='%S'
        color_mode='plain'
        ;;
    full)
        format_string='%s'
        date_format='%H:%M'
        color_mode='plain'
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac

value="$(date +"${date_format}")"

build_gradient_markup() {
    local text="$1"
    shift
    local palette=("$@")

    if [[ ${#palette[@]} -eq 0 ]]; then
        palette=("#f5c2e7" "#b4befe")
    fi

    local output=""
    local idx=0
    local text_length=${#text}
    (( text_length < 1 )) && text_length=1
    local palette_count=${#palette[@]}
    (( palette_count < 1 )) && palette_count=1

    local char
    while IFS= read -r -n1 char; do
        [[ -z "${char}" ]] && continue
        local color_index
        if (( text_length == 1 || palette_count == 1 )); then
            color_index=0
        else
            color_index=$(( (palette_count - 1) * idx / (text_length - 1) ))
        fi
        (( color_index < 0 )) && color_index=0
        (( color_index >= palette_count )) && color_index=$((palette_count - 1))
        local color="${palette[color_index]}"
        output+="<span foreground='${color}'><b>${char}</b></span>"
        ((idx++))
    done <<< "${text}" || true

    printf "%s" "${output}"
}

generate_linear_gradient() {
    local start="$1"
    local end="$2"
    local steps="${3:-10}"

    python3 - "$start" "$end" "$steps" <<'PY'
import sys

def to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    if len(hex_color) != 6:
        raise ValueError("invalid hex color")
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def lerp(a, b, t):
    return tuple(round(a[i] * (1 - t) + b[i] * t) for i in range(3))

def fmt(rgb):
    return "#{:02x}{:02x}{:02x}".format(*rgb)

start = to_rgb(sys.argv[1])
end = to_rgb(sys.argv[2])
steps = max(int(sys.argv[3]), 2)

for i in range(steps):
    t = i / (steps - 1)
    print(fmt(lerp(start, end, t)))
PY
}

if [[ "${color_mode}" == 'pywal16' ]]; then
    palette_file_pywal="${HOME}/.cache/wal/colors.sh"
    pywal_palette=()
    if [[ -r "${palette_file_pywal}" ]]; then
        set +u
        # shellcheck source=/dev/null
        source "${palette_file_pywal}"
        set -u
        primary="${color3:-${color4:-${color5:-#f5c2e7}}}"
        secondary="${color11:-${color6:-${color2:-#89b4fa}}}"
        mapfile -t pywal_palette < <(generate_linear_gradient "$primary" "$secondary" 12)
    fi
    build_gradient_markup "${value}" "${pywal_palette[@]}"
    printf '\n'
elif [[ "${color_mode}" == 'deep-dark' ]]; then
    deep_palette=( "#0d0d0f" "#111115" "#17171c" "#1d1d22" "#24242b" "#1d1d22" "#17171c" "#111115" )
    build_gradient_markup "${value}" "${deep_palette[@]}"
    printf '\n'
else
    printf "${format_string}\n" "${value}"
fi
