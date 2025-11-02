#!/bin/bash

set -euo pipefail

translate_uptime_fr() {
    local input="$1"
    local output="$input"

    # Handle plural forms before singular to avoid partial replacements
    output="${output//years/ans}"
    output="${output//year/an}"
    output="${output//months/mois}"
    output="${output//month/mois}"
    output="${output//weeks/semaines}"
    output="${output//week/semaine}"
    output="${output//days/jours}"
    output="${output//day/jour}"
    output="${output//hours/heures}"
    output="${output//hour/heure}"
    output="${output//minutes/minutes}"
    output="${output//minute/minute}"
    output="${output//seconds/secondes}"
    output="${output//second/seconde}"
    output="${output//up /}"

    echo "${output}"
}

# locate the first battery device exposed by the kernel (works with symlinks)
battery_dir="$(find /sys/class/power_supply -maxdepth 1 -mindepth 1 -name 'BAT*' -print | sort | head -n 1)"
uptime_pretty_raw="$(uptime -p | sed 's/^up //')"
uptime_pretty="$(translate_uptime_fr "${uptime_pretty_raw}")"

mode="full"
if [[ $# -gt 0 ]]; then
    case "$1" in
        --percentage) mode="percentage" ;;
        --icon) mode="icon" ;;
        --compact) mode="compact" ;;
        *) mode="full" ;;
    esac
fi

pick_icon() {
    local cap="$1"
    local status="$2"

    if ! [[ "${cap}" =~ ^[0-9]+$ ]]; then
        echo ""
        return
    fi

    if [[ "${status}" == "Charging" ]]; then
        echo ""
        return
    fi

    if (( cap >= 80 )); then
        echo ""
    elif (( cap >= 60 )); then
        echo ""
    elif (( cap >= 40 )); then
        echo ""
    elif (( cap >= 20 )); then
        echo ""
    else
        echo ""
    fi
}

if [[ -z "${battery_dir}" ]]; then
    case "${mode}" in
        percentage) echo "Secteur" ;;
        icon) echo " Secteur" ;;
        compact) echo " Secteur | ${uptime_pretty}" ;;
        *) echo "Secteur | ${uptime_pretty}" ;;
    esac
    exit 0
fi

capacity_file="${battery_dir}/capacity"
status_file="${battery_dir}/status"

capacity="$(cat "${capacity_file}" 2>/dev/null || echo "?")"
status="$(cat "${status_file}" 2>/dev/null || echo "Unknown")"

case "${status}" in
    Charging) status_word="Charge" ;;
    Discharging) status_word="" ;;
    Full) status_word="Plein" ;;
    Not\ charging) status_word="Repos" ;;
    *) status_word="${status}" ;;
esac

if [[ "${mode}" == "percentage" ]]; then
    printf "%s%%\n" "${capacity}"
    exit 0
fi

if [[ "${mode}" == "icon" ]]; then
    icon="$(pick_icon "${capacity}" "${status}")"
    printf "%s %s%%\n" "${icon}" "${capacity}"
    exit 0
fi

if [[ "${mode}" == "compact" ]]; then
    icon="$(pick_icon "${capacity}" "${status}")"
    printf "%s %s%% | %s\n" "${icon}" "${capacity}" "${uptime_pretty}"
    exit 0
fi

if [[ -n "${status_word}" ]]; then
    printf "%s %s%% | %s\n" "${status_word}" "${capacity}" "${uptime_pretty}"
else
    printf "%s%% | %s\n" "${capacity}" "${uptime_pretty}"
fi
