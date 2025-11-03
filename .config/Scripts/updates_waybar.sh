#!/bin/bash
set -euo pipefail

# Liste optionnelle de paquets/applications à ignorer.
# Ajoute simplement les identifiants dans ces tableaux si tu ne veux
# pas qu'ils apparaissent dans Waybar.
IGNORE_REPO_PACKAGES=(packettracer)
IGNORE_AUR_PACKAGES=()
IGNORE_FLATPAK_APPS=()

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
mkdir -p "$CACHE_DIR"

contains_element() {
    local needle="$1"; shift
    local element
    for element in "$@"; do
        if [[ "$needle" == "$element" ]]; then
            return 0
        fi
    done
    return 1
}

filter_updates() {
    local list="$1"; shift
    local -n ignore_ref=$1

    if [[ ${#ignore_ref[@]} -eq 0 ]]; then
        printf '%s' "$list"
        return
    fi

    local filtered=""
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue

        local candidate
        candidate="${line%% *}"
        [[ -z "$candidate" ]] && candidate="$line"

        if contains_element "$candidate" "${ignore_ref[@]}"; then
            continue
        fi

        filtered+="$line"$'\n'
    done <<<"$list"

    printf '%s' "$filtered"
}

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

collect_flatpak_updates() {
    if ! command -v flatpak >/dev/null 2>&1; then
        printf ''
        return
    fi

    local list=""

    list=$(flatpak remote-ls --updates --columns=application 2>/dev/null || true)
    list=$(printf '%s\n' "$list" | awk 'NF')

    if [ -z "$list" ]; then
        list=$(flatpak list --app --updates --columns=application 2>/dev/null || true)
        list=$(printf '%s\n' "$list" | awk 'NR==1 && tolower($0) ~ /application/ {next} NF')
    fi

    printf '%s\n' "$list"
}

repo_updates="$(collect_repo_updates)"
repo_updates="$(filter_updates "$repo_updates" IGNORE_REPO_PACKAGES)"

aur_updates="$(collect_aur_updates)"
aur_updates="$(filter_updates "$aur_updates" IGNORE_AUR_PACKAGES)"

flatpak_updates="$(collect_flatpak_updates)"
flatpak_updates="$(filter_updates "$flatpak_updates" IGNORE_FLATPAK_APPS)"

repo_count="$(printf '%s\n' "$repo_updates" | sed '/^\s*$/d' | wc -l)"
aur_count="$(printf '%s\n' "$aur_updates" | sed '/^\s*$/d' | wc -l)"
flatpak_count="$(printf '%s\n' "$flatpak_updates" | sed '/^\s*$/d' | wc -l)"

total=$((repo_count + aur_count + flatpak_count))

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
    icon=""
    label=""
    css_class="updates-hidden"
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
    [ "$flatpak_count" -gt 0 ] && tooltip+=$(build_section "Flatpak :" "$flatpak_updates")
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
