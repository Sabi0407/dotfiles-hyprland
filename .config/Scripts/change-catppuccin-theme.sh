#!/bin/bash
set -euo pipefail

AVAILABLE_COLORS=(blue green pink red mauve peach teal lavender yellow rosewater sapphire sky maroon flamingo)
ENV_FILE="$HOME/.config/hypr/configs/env.conf"
CACHE_FILE="$HOME/.cache/current-cursor"
PYWAL_CACHE_DIR="${PYWAL_CACHE_DIR:-$HOME/.config/Scripts/wal-cache}"
DEFAULT_PYWAL_CACHE="$HOME/.cache/wal"

detect_current_color() {
    if [ -f "$ENV_FILE" ]; then
        theme_line=$(grep -E '^env = GTK_THEME,' "$ENV_FILE" | tail -n1 || true)
        if [ -n "$theme_line" ]; then
            theme_val=${theme_line##*,}
            color=${theme_val#catppuccin-mocha-}
            color=${color%-standard+default}
            [ -n "$color" ] && printf '%s' "$color" && return
        fi
    fi
    if [ -s "$CACHE_FILE" ]; then
        read -r cached_cursor _ < "$CACHE_FILE"
        color=${cached_cursor#catppuccin-mocha-}
        color=${color%-cursors}
        [ -n "$color" ] && printf '%s' "$color" && return
    fi
    printf 'blue'
}

if [ "${1:-}" = "--quick" ]; then
    set -- "$(detect_current_color)"
elif [ -z "${1:-}" ]; then
    if ! command -v tofi >/dev/null 2>&1; then
        echo "Usage: $0 <couleur>" >&2
        echo "Couleurs disponibles: ${AVAILABLE_COLORS[*]}" >&2
        echo "(Installez tofi pour profiter de la sélection graphique)" >&2
        exit 1
    fi
    TOFI_CFG=$(mktemp)
    COLORS_FILE="$PYWAL_CACHE_DIR/colors.sh"
    [ -f "$COLORS_FILE" ] || COLORS_FILE="$DEFAULT_PYWAL_CACHE/colors.sh"
    if [ -f "$COLORS_FILE" ]; then
        set +u
        # shellcheck disable=SC1090
        . "$COLORS_FILE"
        set -u
    fi
    BG_COLOR="${color0:-#111111}"
    FG_COLOR="${color15:-#f4f4f5}"
    ACCENT_COLOR="${color4:-#82aaff}"
    cat > "$TOFI_CFG" <<EOF
width = 40%
height = 55%
anchor = center
border-width = 2
border-color = ${ACCENT_COLOR}AA
outline-width = 0
background-color = ${BG_COLOR}E6
text-color = ${FG_COLOR}
selection-color = ${ACCENT_COLOR}
font = JetBrainsMono Nerd Font
font-size = 22
result-spacing = 8
corner-radius = 12
hide-cursor = false
num-results = 9
EOF
    selection=$(printf '%s\n' "${AVAILABLE_COLORS[@]}" | tofi --config "$TOFI_CFG" --prompt-text "Thème Catppuccin" --require-match=true)
    rm -f "$TOFI_CFG"
    [ -z "$selection" ] && exit 0
    set -- "$selection"
fi

COLOR="$1"
THEME="catppuccin-mocha-${COLOR}-standard+default"
CURSOR="catppuccin-mocha-dark-cursors"

map_papirus_variant() {
    case "$1" in
        blue) echo "blue" ;;
        green) echo "green" ;;
        pink) echo "pink" ;;
        red) echo "red" ;;
        mauve|mauve*) echo "violet" ;;
        peach) echo "orange" ;;
        teal) echo "teal" ;;
        lavender) echo "indigo" ;;
        yellow) echo "yellow" ;;
        rosewater) echo "paleorange" ;;
        sapphire) echo "bluegrey" ;;
        sky) echo "cyan" ;;
        maroon) echo "carmine" ;;
        flamingo) echo "magenta" ;;
        *) echo "" ;;
    esac
}

PAPIRUS_VARIANT=$(map_papirus_variant "$COLOR")

if [ ! -d "/usr/share/themes/$THEME" ]; then
    echo "Erreur: Le theme $THEME n'existe pas"
    exit 1
fi

if [ ! -d "/usr/share/icons/$CURSOR" ]; then
    echo "Erreur: Le curseur $CURSOR n'existe pas"
    exit 1
fi

echo "Changement du theme vers: $COLOR"

apply_prop() {
    local key="$1" value="$2" file="$3"
    [ -f "$file" ] || return
    if grep -q "^$key=" "$file"; then
        sed -i "s|^$key=.*|$key=$value|" "$file"
    else
        echo "$key=$value" >> "$file"
    fi
}

sed -i "s|^env = GTK_THEME,.*|env = GTK_THEME,$THEME|" ~/.config/hypr/configs/env.conf
sed -i "s|^env = HYPRCURSOR_THEME,.*|env = HYPRCURSOR_THEME,$CURSOR|" ~/.config/hypr/configs/env.conf
sed -i "s|^env = XCURSOR_THEME,.*|env = XCURSOR_THEME,$CURSOR|" ~/.config/hypr/configs/env.conf
sed -i "s|^env = HYPRCURSOR_SIZE,.*|env = HYPRCURSOR_SIZE,24|" ~/.config/hypr/configs/env.conf
sed -i "s|^env = XCURSOR_SIZE,.*|env = XCURSOR_SIZE,24|" ~/.config/hypr/configs/env.conf

echo "$CURSOR 24" > "$CACHE_FILE"

hyprctl setcursor "$CURSOR" 24
hyprctl setoption cursor inactive_timeout 0 >/dev/null 2>&1 || true

if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR" >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.interface cursor-size 24 >/dev/null 2>&1 || true
fi

apply_prop "gtk-theme-name" "$THEME" ~/.config/gtk-3.0/settings.ini
apply_prop "gtk-cursor-theme-name" "$CURSOR" ~/.config/gtk-3.0/settings.ini
apply_prop "gtk-theme-name" "$THEME" ~/.config/gtk-4.0/settings.ini
apply_prop "gtk-cursor-theme-name" "$CURSOR" ~/.config/gtk-4.0/settings.ini

if [ -f ~/.gtkrc-2.0 ]; then
    sed -i "s|^gtk-theme-name=.*|gtk-theme-name=\"$THEME\"|" ~/.gtkrc-2.0
    sed -i "s|^gtk-cursor-theme-name=.*|gtk-cursor-theme-name=\"$CURSOR\"|" ~/.gtkrc-2.0
fi

if command -v papirus-folders >/dev/null 2>&1 && [ -n "$PAPIRUS_VARIANT" ]; then
    available_variants=$(papirus-folders -l | tr -d '>' | awk '{ $1=$1; print $1 }')
    if printf '%s\n' "$available_variants" | grep -qw "$PAPIRUS_VARIANT"; then
        if papirus-folders -t "$PAPIRUS_VARIANT" --theme Papirus-Dark >/dev/null 2>&1; then
            echo "Papirus folders applique: $PAPIRUS_VARIANT"
            gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark >/dev/null 2>&1 || true
        else
            echo "Papirus folders: commande echouee (droits sudo requis ?)" >&2
        fi
    else
        echo "Papirus folders: pas de variante '$PAPIRUS_VARIANT', valeur conservée." >&2
    fi
elif command -v papirus-folders >/dev/null 2>&1; then
    echo "Papirus folders: aucune variante definie pour la couleur '$COLOR'." >&2
else
    echo "Papirus folders n'est pas installé. Installez le paquet papirus-folders."
fi

echo "Theme change en $COLOR"
echo "Curseur utilisé : $CURSOR"
notify-send "Catppuccin" "Thème $COLOR 
• Curseur $CURSOR
• Papirus ${PAPIRUS_VARIANT:-n/a}
Astuce: redémarre Thunar si besoin." -i preferences-desktop-theme
