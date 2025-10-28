#!/bin/bash
set -euo pipefail

AVAILABLE_COLORS=(blue green pink red mauve peach teal lavender yellow rosewater sapphire sky maroon flamingo)
ENV_FILE="$HOME/.config/hypr/configs/env.conf"
CACHE_FILE="$HOME/.cache/current-cursor"
KVANTUM_CONF="$HOME/.config/Kvantum/kvantum.kvconfig"
KVANTUM_PREFIX="$HOME/.config/Kvantum"
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

select_color_with_tofi() {
    if ! command -v tofi >/dev/null 2>&1; then
        echo "Usage: $0 <couleur>" >&2
        echo "Couleurs disponibles: ${AVAILABLE_COLORS[*]}" >&2
        echo "(Installez tofi pour profiter de la sélection graphique)" >&2
        exit 1
    fi

    local cfg colors_file bg fg accent selection
    cfg=$(mktemp)
    colors_file="$PYWAL_CACHE_DIR/colors.sh"
    [ -f "$colors_file" ] || colors_file="$DEFAULT_PYWAL_CACHE/colors.sh"
    if [ -f "$colors_file" ]; then
        set +u
        # shellcheck disable=SC1090
        . "$colors_file"
        set -u
    fi
    bg="${color0:-#0f172a}"
    fg="${color15:-#f4f4f5}"
    accent="${color4:-#82aaff}"
    cat > "$cfg" <<EOF_CFG
width = 40%
height = 55%
anchor = center
border-width = 2
border-color = ${accent}AA
outline-width = 0
background-color = ${bg}E6
text-color = ${fg}
selection-color = ${accent}
font = JetBrainsMono Nerd Font
font-size = 22
result-spacing = 8
corner-radius = 12
hide-cursor = false
num-results = 12
EOF_CFG
    selection=$(printf '%s
' "${AVAILABLE_COLORS[@]}" | tofi --config "$cfg" --prompt-text "Thème Catppuccin" --require-match=true)
    rm -f "$cfg"
    [ -z "$selection" ] && exit 0
    printf '%s' "$selection"
}

if [ "${1:-}" = "--quick" ]; then
    COLOR="$(detect_current_color)"
else
    COLOR="${1:-}"
    if [ -z "$COLOR" ]; then
        COLOR="$(select_color_with_tofi)"
    fi
fi

if [[ ! " ${AVAILABLE_COLORS[*]} " =~ " ${COLOR} " ]]; then
    echo "Couleur invalide: $COLOR" >&2
    exit 1
fi

THEME="catppuccin-mocha-${COLOR}-standard+default"
KVANTUM_THEME="catppuccin-mocha-${COLOR}"
CURSOR="catppuccin-mocha-dark-cursors"

if [ ! -d "/usr/share/themes/$THEME" ]; then
    echo "Erreur: Le theme $THEME n'existe pas" >&2
    exit 1
fi

if [ ! -d "/usr/share/icons/$CURSOR" ]; then
    echo "Erreur: Le curseur $CURSOR n'existe pas" >&2
    exit 1
fi

if [ ! -d "$KVANTUM_PREFIX/$KVANTUM_THEME" ]; then
    echo "Avertissement: Thème Kvantum $KVANTUM_THEME introuvable, utilisation de catppuccin-mocha-teal" >&2
    KVANTUM_THEME="catppuccin-mocha-teal"
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

sed -i "s|^env = GTK_THEME,.*|env = GTK_THEME,$THEME|" "$ENV_FILE"
sed -i "s|^env = HYPRCURSOR_THEME,.*|env = HYPRCURSOR_THEME,$CURSOR|" "$ENV_FILE"
sed -i "s|^env = XCURSOR_THEME,.*|env = XCURSOR_THEME,$CURSOR|" "$ENV_FILE"
sed -i "s|^env = HYPRCURSOR_SIZE,.*|env = HYPRCURSOR_SIZE,24|" "$ENV_FILE"
sed -i "s|^env = XCURSOR_SIZE,.*|env = XCURSOR_SIZE,24|" "$ENV_FILE"

echo "$CURSOR 24" > "$CACHE_FILE"

hyprctl setcursor "$CURSOR" 24
hyprctl setoption cursor inactive_timeout 0 >/dev/null 2>&1 || true

if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR" >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.interface cursor-size 24 >/dev/null 2>&1 || true
fi

apply_prop "gtk-theme-name" "$THEME" "$HOME/.config/gtk-3.0/settings.ini"
apply_prop "gtk-cursor-theme-name" "$CURSOR" "$HOME/.config/gtk-3.0/settings.ini"
apply_prop "gtk-theme-name" "$THEME" "$HOME/.config/gtk-4.0/settings.ini"
apply_prop "gtk-cursor-theme-name" "$CURSOR" "$HOME/.config/gtk-4.0/settings.ini"

if [ -f "$HOME/.gtkrc-2.0" ]; then
    sed -i "s|^gtk-theme-name=.*|gtk-theme-name="$THEME"|" "$HOME/.gtkrc-2.0"
    sed -i "s|^gtk-cursor-theme-name=.*|gtk-cursor-theme-name="$CURSOR"|" "$HOME/.gtkrc-2.0"
fi

mkdir -p "$KVANTUM_PREFIX"
cat > "$KVANTUM_CONF" <<EOF_KV
[General]
theme=$KVANTUM_THEME

[Applications]
Default=$KVANTUM_THEME
EOF_KV

if command -v kvantummanager >/dev/null 2>&1; then
    kvantummanager --set "$KVANTUM_THEME" >/dev/null 2>&1 || true
fi

YAZI_CONF_FILE="$HOME/.config/yazi/conf"
YAZI_THEME_DIR="$HOME/.config/yazi/themes/mocha"
if [ -f "$YAZI_CONF_FILE" ] && [ -d "$YAZI_THEME_DIR" ]; then
    YAZI_THEME_FILE="catppuccin-mocha-${COLOR}.toml"
    if [ -f "$YAZI_THEME_DIR/$YAZI_THEME_FILE" ]; then
        python3 - "$YAZI_CONF_FILE" "mocha/${YAZI_THEME_FILE%.toml}" <<'PY'
import sys
from pathlib import Path

conf_path = Path(sys.argv[1])
theme_value = sys.argv[2]

text = conf_path.read_text(encoding="utf-8").splitlines()
out_lines = []
in_theme = False
inserted = False

for line in text:
    stripped = line.strip()
    if stripped.startswith("[") and stripped.lower() == "[theme]":
        in_theme = True
        out_lines.append(line)
        continue
    if stripped.startswith("[") and stripped.lower() != "[theme]" and in_theme and not inserted:
        out_lines.append(f'theme = "{theme_value}"')
        inserted = True
        in_theme = False
    if in_theme and stripped.startswith("theme") and "=" in stripped and not inserted:
        out_lines.append(f'theme = "{theme_value}"')
        inserted = True
        in_theme = False
        continue
    out_lines.append(line)

if not inserted:
    out_lines.append("[theme]")
    out_lines.append(f'theme = "{theme_value}"')

conf_path.write_text("\n".join(out_lines) + "\n", encoding="utf-8")
PY
        echo "Thème Yazi appliqué : mocha/${YAZI_THEME_FILE%.toml}"
    else
        echo "Avertissement: thème Yazi catppuccin-mocha-${COLOR} introuvable" >&2
    fi
fi

echo "Theme change en $COLOR"
echo "Curseur utilisé : $CURSOR"
notify-send "Catppuccin" "Thème $COLOR
• Curseur: $CURSOR
• Kvantum: $KVANTUM_THEME" -i preferences-desktop-theme
