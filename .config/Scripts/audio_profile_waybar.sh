#!/usr/bin/env bash
set -euo pipefail
PROFILE_FILE="$HOME/.cache/waybar-audio-profile"
DEFAULT_PROFILE="speakers"
get_status(){
    local profile=${1:-$DEFAULT_PROFILE}
    case "$profile" in
        speakers) echo '{"text":"HD","class":"speakers","alt":"speakers","tooltip":"Profile Haut-parleurs"}' ;;
        headset) echo '{"text":"BT","class":"headset","alt":"headset","tooltip":"Profile Casque"}' ;;
        softer) echo '{"text":"SO","class":"softer","alt":"soft","tooltip":"Profile Doux"}' ;;
        *) echo '{"text":"??","class":"unknown","alt":"unknown"}' ;;
    esac
}
read_profile(){
    if [[ -f "$PROFILE_FILE" ]]; then
        cat "$PROFILE_FILE"
    else
        echo "$DEFAULT_PROFILE"
    fi
}
write_profile(){
    echo "$1" > "$PROFILE_FILE"
}
cycle_profile(){
    local current=$(read_profile)
    local next
    case "$current" in
        speakers) next="headset" ;;
        headset) next="softer" ;;
        softer) next="speakers" ;;
        *) next="$DEFAULT_PROFILE" ;;
    esac
    write_profile "$next"
}
toggle_profile(){
    local current=$(read_profile)
    if [[ "$current" == "speakers" ]]; then
        write_profile "headset"
    else
        write_profile "speakers"
    fi
}
case "${1:-status}" in
    status)
        get_status "$(read_profile)"
        ;;
    toggle)
        toggle_profile
        get_status "$(read_profile)"
        ;;
    cycle)
        cycle_profile
        get_status "$(read_profile)"
        ;;
    *)
        get_status "$(read_profile)"
        ;;
 esac
