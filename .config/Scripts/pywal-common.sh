#!/bin/bash
# shellcheck shell=bash
#
# Helpers partagés pour retrouver la palette Pywal et effectuer
# les conversions nécessaires.

set -euo pipefail

: "${PYWAL_CACHE_DIR:=$HOME/.config/Scripts/wal-cache}"
PYWAL_DEFAULT_CACHE="$HOME/.cache/wal"
PYWAL_EXTRA_CACHE="$HOME/.config/wal/cache"

mkdir -p "$PYWAL_CACHE_DIR"

pywal__cache_candidates() {
    printf '%s\n' "$PYWAL_CACHE_DIR"
    printf '%s\n' "$PYWAL_EXTRA_CACHE"
    printf '%s\n' "$PYWAL_DEFAULT_CACHE"
}

pywal_locate_file() {
    local filename="$1"
    local candidate
    while IFS= read -r candidate; do
        if [[ -f "$candidate/$filename" ]]; then
            printf '%s/%s\n' "$candidate" "$filename"
            return 0
        fi
    done < <(pywal__cache_candidates)
    return 1
}

pywal_source_colors() {
    if [[ "${PYWAL_COLORS_LOADED:-0}" -eq 1 ]]; then
        return "${PYWAL_COLORS_STATUS:-0}"
    fi

    local colors_file
    if colors_file="$(pywal_locate_file "colors.sh")"; then
        set +u
        # shellcheck disable=SC1090
        . "$colors_file"
        set -u
        PYWAL_ACTIVE_COLORS="$colors_file"
        PYWAL_COLORS_STATUS=0
    else
        PYWAL_COLORS_STATUS=1
    fi
    PYWAL_COLORS_LOADED=1
    return "${PYWAL_COLORS_STATUS}"
}

pywal_hex_to_rgba() {
    local hex="${1:-#ffffff}"
    local alpha="${2:-1.0}"
    hex="${hex#\#}"
    if [[ ${#hex} -ne 6 ]]; then
        printf 'rgba(255,255,255,%s)\n' "$alpha"
        return 0
    fi
    printf 'rgba(%d,%d,%d,%s)\n' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}" "$alpha"
}

pywal_hex_to_rgb() {
    local hex="${1:-#000000}"
    hex="${hex#\#}"
    if [[ ${#hex} -ne 6 ]]; then
        printf '0,0,0\n'
        return 0
    fi
    printf '%d,%d,%d\n' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

pywal_warn() {
    printf '[pywal-common] %s\n' "$*" >&2
}

export -f pywal_locate_file pywal_source_colors pywal_hex_to_rgba \
    pywal_hex_to_rgb pywal_warn
