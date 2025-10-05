#!/bin/sh

# Générer les couleurs CSS pour Wofi à partir des couleurs pywal
# Ce script lit colors.json et génère les variables CSS attendues par wofi

COLORS_FILE="$HOME/.cache/wal/colors.json"
WOFI_COLORS_FILE="$HOME/.config/wofi/colors.css"

if [ ! -f "$COLORS_FILE" ]; then
    echo "Erreur: Fichier $COLORS_FILE introuvable"
    exit 1
fi

# Vérifier si l'utilisateur a des couleurs personnalisées
# Si le fichier contient des couleurs orange/rouge (nouvelles), ne pas l'écraser
if grep -q "A23B30\|E56537\|DB694C\|F49E51\|F7A748" "$WOFI_COLORS_FILE" 2>/dev/null; then
    echo "Couleurs personnalisées détectées, préservation du fichier colors.css"
    echo "Mise à jour uniquement de style-full.css"
else
    echo "Génération des couleurs wofi depuis pywal..."

    # Extraire les couleurs du fichier JSON en utilisant grep et sed
    COLOR0=$(grep '"color0"' "$COLORS_FILE" | sed 's/.*"color0": *"\([^"]*\)".*/\1/')
    COLOR1=$(grep '"color1"' "$COLORS_FILE" | sed 's/.*"color1": *"\([^"]*\)".*/\1/')
    COLOR2=$(grep '"color2"' "$COLORS_FILE" | sed 's/.*"color2": *"\([^"]*\)".*/\1/')
    COLOR3=$(grep '"color3"' "$COLORS_FILE" | sed 's/.*"color3": *"\([^"]*\)".*/\1/')
    COLOR4=$(grep '"color4"' "$COLORS_FILE" | sed 's/.*"color4": *"\([^"]*\)".*/\1/')
    COLOR5=$(grep '"color5"' "$COLORS_FILE" | sed 's/.*"color5": *"\([^"]*\)".*/\1/')
    COLOR6=$(grep '"color6"' "$COLORS_FILE" | sed 's/.*"color6": *"\([^"]*\)".*/\1/')
    COLOR7=$(grep '"color7"' "$COLORS_FILE" | sed 's/.*"color7": *"\([^"]*\)".*/\1/')
    COLOR8=$(grep '"color8"' "$COLORS_FILE" | sed 's/.*"color8": *"\([^"]*\)".*/\1/')
    COLOR9=$(grep '"color9"' "$COLORS_FILE" | sed 's/.*"color9": *"\([^"]*\)".*/\1/')
    COLOR10=$(grep '"color10"' "$COLORS_FILE" | sed 's/.*"color10": *"\([^"]*\)".*/\1/')
    COLOR11=$(grep '"color11"' "$COLORS_FILE" | sed 's/.*"color11": *"\([^"]*\)".*/\1/')
    COLOR12=$(grep '"color12"' "$COLORS_FILE" | sed 's/.*"color12": *"\([^"]*\)".*/\1/')
    COLOR13=$(grep '"color13"' "$COLORS_FILE" | sed 's/.*"color13": *"\([^"]*\)".*/\1/')
    COLOR14=$(grep '"color14"' "$COLORS_FILE" | sed 's/.*"color14": *"\([^"]*\)".*/\1/')
    COLOR15=$(grep '"color15"' "$COLORS_FILE" | sed 's/.*"color15": *"\([^"]*\)".*/\1/')

    # Fonction pour convertir hex en RGB
    hex_to_rgb() {
        hex=$1
        r=$(printf '%d' 0x${hex:1:2})
        g=$(printf '%d' 0x${hex:3:2})
        b=$(printf '%d' 0x${hex:5:2})
        echo "$r, $g, $b"
    }

    # Générer le fichier CSS avec les variables wofi
    cat > "$WOFI_COLORS_FILE" << EOF
/* Couleurs générées par pywal pour Wofi */

:root {
  --wofi-color0: ${COLOR0};
  --wofi-color1: ${COLOR1};
  --wofi-color2: ${COLOR2};
  --wofi-color3: ${COLOR3};
  --wofi-color4: ${COLOR4};
  --wofi-color5: ${COLOR5};
  --wofi-color6: ${COLOR6};
  --wofi-color7: ${COLOR7};
  --wofi-color8: ${COLOR8};
  --wofi-color9: ${COLOR9};
  --wofi-color10: ${COLOR10};
  --wofi-color11: ${COLOR11};
  --wofi-color12: ${COLOR12};
  --wofi-color13: ${COLOR13};
  --wofi-color14: ${COLOR14};
  --wofi-color15: ${COLOR15};

  --wofi-rgb-color0: $(hex_to_rgb ${COLOR0});
  --wofi-rgb-color1: $(hex_to_rgb ${COLOR1});
  --wofi-rgb-color2: $(hex_to_rgb ${COLOR2});
  --wofi-rgb-color3: $(hex_to_rgb ${COLOR3});
  --wofi-rgb-color4: $(hex_to_rgb ${COLOR4});
  --wofi-rgb-color5: $(hex_to_rgb ${COLOR5});
  --wofi-rgb-color6: $(hex_to_rgb ${COLOR6});
  --wofi-rgb-color7: $(hex_to_rgb ${COLOR7});
  --wofi-rgb-color8: $(hex_to_rgb ${COLOR8});
  --wofi-rgb-color9: $(hex_to_rgb ${COLOR9});
  --wofi-rgb-color10: $(hex_to_rgb ${COLOR10});
  --wofi-rgb-color11: $(hex_to_rgb ${COLOR11});
  --wofi-rgb-color12: $(hex_to_rgb ${COLOR12});
  --wofi-rgb-color13: $(hex_to_rgb ${COLOR13});
  --wofi-rgb-color14: $(hex_to_rgb ${COLOR14});
  --wofi-rgb-color15: $(hex_to_rgb ${COLOR15});
}
EOF
fi

# Générer également un fichier style.css complet avec les couleurs intégrées
cat > "$HOME/.config/wofi/style-full.css" << EOF
/* Wofi - Style avec couleurs pywal intégrées */

:root {
  --wofi-color0: ${COLOR0};
  --wofi-color1: ${COLOR1};
  --wofi-color2: ${COLOR2};
  --wofi-color3: ${COLOR3};
  --wofi-color4: ${COLOR4};
  --wofi-color5: ${COLOR5};
  --wofi-color6: ${COLOR6};
  --wofi-color7: ${COLOR7};
  --wofi-color8: ${COLOR8};
  --wofi-color9: ${COLOR9};
  --wofi-color10: ${COLOR10};
  --wofi-color11: ${COLOR11};
  --wofi-color12: ${COLOR12};
  --wofi-color13: ${COLOR13};
  --wofi-color14: ${COLOR14};
  --wofi-color15: ${COLOR15};

  --wofi-rgb-color0: $(hex_to_rgb ${COLOR0});
  --wofi-rgb-color1: $(hex_to_rgb ${COLOR1});
  --wofi-rgb-color2: $(hex_to_rgb ${COLOR2});
  --wofi-rgb-color3: $(hex_to_rgb ${COLOR3});
  --wofi-rgb-color4: $(hex_to_rgb ${COLOR4});
  --wofi-rgb-color5: $(hex_to_rgb ${COLOR5});
  --wofi-rgb-color6: $(hex_to_rgb ${COLOR6});
  --wofi-rgb-color7: $(hex_to_rgb ${COLOR7});
  --wofi-rgb-color8: $(hex_to_rgb ${COLOR8});
  --wofi-rgb-color9: $(hex_to_rgb ${COLOR9});
  --wofi-rgb-color10: $(hex_to_rgb ${COLOR10});
  --wofi-rgb-color11: $(hex_to_rgb ${COLOR11});
  --wofi-rgb-color12: $(hex_to_rgb ${COLOR12});
  --wofi-rgb-color13: $(hex_to_rgb ${COLOR13});
  --wofi-rgb-color14: $(hex_to_rgb ${COLOR14});
  --wofi-rgb-color15: $(hex_to_rgb ${COLOR15});

  /* Variables CSS pour une cohérence globale */
  --primary: var(--wofi-color2);
  --primary-rgb: var(--wofi-rgb-color2);
  --text: var(--wofi-color15);
  --text-rgb: var(--wofi-rgb-color15);
  --bg: var(--wofi-color0);
  --surface: var(--wofi-color8);
  --surface-hover: var(--wofi-color2);
  --border: var(--wofi-color8);
}

/* Configuration de base */
* {
  font-family: "JetBrains Mono", "Fira Code", monospace;
  font-weight: 500;
  outline: none;
}

window {
  background-color: var(--bg);
  border: 1px solid var(--border);
  border-radius: 12px;
  color: var(--text);
  margin: 12px;
  padding: 16px;
  opacity: 0.98;
}

#input {
  background-color: var(--surface);
  border: 1px solid var(--border);
  border-radius: 6px;
  color: var(--text);
  font-size: 13px;
  margin: 0 0 8px 0;
  padding: 10px 14px;
  min-height: 38px;
}

#entry {
  background-color: var(--surface);
  border-radius: 8px;
  color: var(--text);
  margin: 2px 0;
  padding: 6px 10px;
  min-height: 38px;
  border: 1px solid var(--border);
}

#entry:hover {
  background-color: var(--surface-hover);
  border-color: var(--surface-hover);
}

#entry:selected {
  background-color: var(--surface-hover);
  color: var(--text);
  font-weight: 600;
  border-color: var(--surface-hover);
}

#text {
  font-size: 12px;
  font-weight: 500;
  color: var(--text);
  margin: 0;
  padding: 0 8px;
}

#image {
  width: 24px;
  height: 24px;
  margin: 0;
  border-radius: 6px;
}
EOF

if grep -q "A23B30\|E56537\|DB694C\|F49E51\|F7A748" "$WOFI_COLORS_FILE" 2>/dev/null; then
    echo "Couleurs personnalisées préservées dans colors.css"
else
    echo "Couleurs Wofi générées avec succès dans ~/.config/wofi/colors.css"
fi
echo "Style complet généré dans ~/.config/wofi/style-full.css"

# Copier le template pywal généré si disponible
if [ -f "$HOME/.cache/wal/wofi-style.css" ]; then
    cp "$HOME/.cache/wal/wofi-style.css" "$HOME/.config/wofi/style.css"
    echo "Style pywal copié vers ~/.config/wofi/style.css"
fi 