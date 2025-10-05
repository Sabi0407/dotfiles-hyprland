#!/bin/bash
# Script d'intégration d'Obsidian et Zathura avec Hyprland

echo "📚 Configuration d'Obsidian et Zathura..."

# Configuration pour Obsidian
OBSIDIAN_DESKTOP="$HOME/.local/share/applications/obsidian.desktop"

if [ -f "/usr/bin/obsidian" ] || [ -f "/opt/obsidian/obsidian" ]; then
    echo "✅ Obsidian détecté"

    # Créer un lanceur personnalisé pour Obsidian
    mkdir -p "$(dirname "$OBSIDIAN_DESKTOP")"

    cat > "$OBSIDIAN_DESKTOP" << 'EOF'
[Desktop Entry]
Name=Obsidian
Comment=Knowledge base
GenericName=Note-taking app
Keywords=markdown;notes;knowledge;base;
Exec=obsidian %U
Icon=obsidian
Terminal=false
Type=Application
Categories=Office;TextEditor;Utility;
MimeType=text/markdown;text/x-markdown;
StartupWMClass=obsidian
EOF

    echo "   📝 Lanceur Obsidian créé"
else
    echo "⚠️ Obsidian non trouvé - installez-le d'abord"
fi

# Configuration pour Zathura
ZATHURA_CONFIG="$HOME/.config/zathura/zathurarc"

mkdir -p "$(dirname "$ZATHURA_CONFIG")"

cat > "$ZATHURA_CONFIG" << 'EOF'
# Configuration Zathura pour Wayland/Hyprland
set selection-clipboard clipboard
set guioptions ""
set statusbar-h-padding 10
set statusbar-v-padding 10
set page-padding 10

# Thème sombre
set font "JetBrains Mono 10"
set default-bg "#1e1e2e"
set default-fg "#cdd6f4"
set statusbar-bg "#11111b"
set statusbar-fg "#cdd6f4"
set inputbar-bg "#1e1e2e"
set inputbar-fg "#cdd6f4"
set notification-bg "#1e1e2e"
set notification-fg "#cdd6f4"
set notification-error-bg "#f38ba8"
set notification-error-fg "#1e1e2e"
set notification-warning-bg "#fab387"
set notification-warning-fg "#1e1e2e"
set highlight-color "#89b4fa"
set highlight-active-color "#cba6f7"
set completion-bg "#1e1e2e"
set completion-fg "#cdd6f4"
set completion-highlight-bg "#313244"
set completion-highlight-fg "#cdd6f4"
set recolor true
set recolor-keephue true
set recolor-darkcolor "#cdd6f4"
set recolor-lightcolor "#1e1e2e"

# Navigation rapide
map <C-Left> navigate previous
map <C-Right> navigate next
map <C-Up> zoom in
map <C-Down> zoom out
map <C-r> reload
map <C-f> search forward
map <C-b> search backward
map <C-d> scroll down
map <C-u> scroll up
map <C-j> scroll down
map <C-k> scroll up
EOF

echo "   📖 Configuration Zathura créée"

# Créer un script pour ouvrir rapidement des notes
cat > "$HOME/.config/Scripts/quick-note.sh" << 'EOF'
#!/bin/bash
# Créer et ouvrir une note rapide avec Obsidian

NOTE_DIR="$HOME/Documents/Notes/Quick"
NOTE_DATE=$(date +%Y%m%d_%H%M%S)
NOTE_FILE="$NOTE_DIR/note_$NOTE_DATE.md"

mkdir -p "$NOTE_DIR"

# Créer la note avec template
cat > "$NOTE_FILE" << EONOTE
# Note rapide - $(date)

## Description
Note prise rapidement

## Contenu



## Tags
#quick #$(date +%Y%m%d)

---
*Créée le $(date)*
EONOTE

# Ouvrir avec Obsidian
obsidian "$NOTE_FILE"
EOF

chmod +x "$HOME/.config/Scripts/quick-note.sh"

echo "   🚀 Script de note rapide créé"

# Ajouter des raccourcis Hyprland pour Obsidian et Zathura
HYPRLAND_CONFIG="$HOME/.config/hypr/configs/keybindings.conf"

if ! grep -q "obsidian\|zathura" "$HYPRLAND_CONFIG"; then
    echo "" >> "$HYPRLAND_CONFIG"
    echo "# ═══════════════════════════════════════════════════════════════════════════════" >> "$HYPRLAND_CONFIG"
    echo "# RACCOURCIS OBSIDIAN & ZATHURA" >> "$HYPRLAND_CONFIG"
    echo "# ═══════════════════════════════════════════════════════════════════════════════" >> "$HYPRLAND_CONFIG"

    echo "# Applications de lecture/écriture" >> "$HYPRLAND_CONFIG"
    echo "bind = SUPER, O, exec, obsidian" >> "$HYPRLAND_CONFIG"
    echo "bind = SUPER SHIFT, O, exec, ~/.config/Scripts/quick-note.sh" >> "$HYPRLAND_CONFIG"
    echo "bind = SUPER, Z, exec, zathura" >> "$HYPRLAND_CONFIG"
    echo "" >> "$HYPRLAND_CONFIG"

    echo "✅ Raccourcis ajoutés :"
    echo "   SUPER + O : Ouvrir Obsidian"
    echo "   SUPER + Shift + O : Créer une note rapide"
    echo "   SUPER + Z : Ouvrir Zathura"
else
    echo "ℹ️ Raccourcis déjà présents"
fi

echo ""
echo "✅ Intégration Obsidian et Zathura terminée :"
echo "   📖 Zathura configuré pour les PDF"
echo "   📝 Obsidian configuré pour les Markdown"
echo "   ⚡ Raccourcis clavier ajoutés"
echo "   🚀 Script de notes rapides créé"

echo ""
echo "💡 Utilisation :"
echo "   - Clic droit sur PDF → 'Ouvrir avec navigateur' → Zathura"
echo "   - Clic droit sur .md → 'Éditer avec Obsidian' → Obsidian"
echo "   - SUPER + O : Ouvrir Obsidian"
echo "   - SUPER + Shift + O : Créer une note rapide"
echo "   - ~/.config/Scripts/quick-note.sh : Créer une note manuellement"
