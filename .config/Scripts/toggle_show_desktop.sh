#!/usr/bin/env bash

# Toggle hiding all windows on the current workspace by moving them to a special workspace.

set -uo pipefail

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr_showdesktop_state"
SPECIAL_WS="special:showdesktop"

restore_windows() {
    while IFS=' ' read -r address workspace || [ -n "${address:-}" ]; do
        [[ -z "${address:-}" ]] && continue
        hyprctl dispatch movetoworkspacesilent "$workspace,address:$address" >/dev/null 2>&1 || true
    done < "$STATE_FILE"
    rm -f "$STATE_FILE"
    # Ensure the special workspace is hidden if it was left open.
    if hyprctl -j activeworkspace | jq -r '.name' | grep -qx "special:showdesktop"; then
        hyprctl dispatch togglespecialworkspace showdesktop >/dev/null 2>&1 || true
    fi
}

hide_windows() {
    local active_workspace
    active_workspace="$(hyprctl -j activeworkspace | jq -r '.name')"

    # Do not try to hide from a special workspace.
    if [[ "$active_workspace" =~ ^special: ]]; then
        exit 0
    fi

    local clients
    clients="$(hyprctl -j clients | jq -r --arg ws "$active_workspace" \
        '.[] | select(.workspace.name == $ws) | "\(.address) \(.workspace.id)"')"

    [[ -z "$clients" ]] && exit 0

    printf '%s\n' "$clients" > "$STATE_FILE"

    while IFS=' ' read -r address _ || [ -n "${address:-}" ]; do
        [[ -z "${address:-}" ]] && continue
        hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$address" >/dev/null 2>&1 || true
    done <<< "$clients"

    # Make sure the special workspace stays hidden.
    if hyprctl -j activeworkspace | jq -r '.name' | grep -qx "special:showdesktop"; then
        hyprctl dispatch togglespecialworkspace showdesktop >/dev/null 2>&1 || true
    fi
}

if [[ -f "$STATE_FILE" ]]; then
    restore_windows
else
    hide_windows
fi
