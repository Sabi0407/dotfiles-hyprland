#!/bin/bash
set -euo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
mkdir -p "$CACHE_DIR"

collect_repo_updates() {
    local list=""
    if command -v checkupdates >/dev/null 2>&1; then
        list="$(checkupdates 2>/dev/null || true)"
    else
        if command -v pacman >/dev/null 2>&1; then
            list="$(pacman -Qu --dbpath /tmp/checkup-db-$$ 2>/dev/null || true)"
        fi
    fi
    printf '%s' "$list"
}

collect_aur_updates() {
    if command -v yay >/dev/null 2>&1; then
        yay -Qua 2>/dev/null || true
    elif command -v paru >/dev/null 2>&1; then
        paru -Qua 2>/dev/null || true
    else
        printf ''
    fi
}

repo_updates="$(collect_repo_updates)"
aur_updates="$(collect_aur_updates)"

repo_count="$(printf '%s\n' "$repo_updates" | sed '/^\s*$/d' | wc -l)"
aur_count="$(printf '%s\n' "$aur_updates" | sed '/^\s*$/d' | wc -l)"

total=$((repo_count + aur_count))

if [ "$total" -gt 0 ]; then
    icon="󰏔"
    label="$total"
    if [ "$total" -ge 25 ]; then
        css_class="updates-many"
    elif [ "$total" -ge 10 ]; then
        css_class="updates-some"
    else
        css_class="updates-few"
    fi
else
    icon="󰄬"
    label="0"
    css_class="updates-none"
fi

build_section() {
    local title="$1" list="$2"
    [ -z "$list" ] && return
    printf '%s\n' "$title"
    printf '%s\n' "$list" | sed 's/^/  • /' | head -n 8
    local remaining
    remaining=$(printf '%s\n' "$list" | sed '/^\s*$/d' | wc -l)
    if [ "$remaining" -gt 8 ]; then
        printf '  • … (%d de plus)\n' "$((remaining - 8))"
    fi
    printf '\n'
}

tooltip=""
if [ "$total" -gt 0 ]; then
    tooltip=$(printf 'Mises à jour disponibles : %d\n\n' "$total")
    [ "$repo_count" -gt 0 ] && tooltip+=$(build_section "Référentiels :" "$repo_updates")
    [ "$aur_count" -gt 0 ] && tooltip+=$(build_section "AUR :" "$aur_updates")
else
    tooltip="Système à jour."
fi

printf '{'
printf '"text":"%s",' "$label"
printf '"icon":"%s",' "$icon"
printf '"tooltip":"%s",' "$(printf '%s' "$tooltip" | sed ':a;N;$!ba;s/\n/\\n/g')"
printf '"alt":"updates",'
printf '"class":"%s"' "$css_class"
printf '}\n'
