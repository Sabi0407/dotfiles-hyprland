

## Voici la version 2 de ma configuration Hyprland

## Composants principaux

| Composant | Utilisation |
|-----------|-------------|
| **Hyprland** | Gestionnaire de fenêtres |
| **Waybar** | Barre d'état |
| **SwayNC** | Centre de notifications |
| **Hyprlock** | Verrouillage d'écran |
| **Hypridle** | Gestionnaire d'inactivité |
| **Yazi** | Gestionnaire de fichiers terminal |
| **Tofi** | Lanceur d'applications |
| **Kitty** | Terminal |
| **Micro** | Éditeur texte ligne de commande |
| **Fastfetch** | Informations système |
| **Thème** | Catppuccin Mocha |
| **Icônes** | Papirus Icon Pack |
| **Pywal** | Génération de couleurs |
| **Pywalfox** | Thème Firefox dynamique |

---

## Structure de configuration Hyprland

### Organisation des fichiers
```
~/.config/hypr/
├── hyprland.conf          # Configuration principale
├── hypridle.conf          # Gestionnaire d'inactivité
├── hyprlock.conf          # Verrouillage d'écran
├── colors_temp.conf       # Couleurs temporaires
├── configs/
│   ├── env.conf           # Variables d'environnement
│   ├── input.conf         # Configuration clavier/souris
│   ├── autostart.conf     # Applications au démarrage
│   ├── keybindings.conf   # Raccourcis clavier
│   ├── look.conf          # Apparence et décoration
│   ├── monitors.conf      # Configuration des écrans
│   ├── plugins.conf       # Plugins et extensions
│   └── windowrules.conf   # Règles de fenêtres
└── colors/
    └── hyprlock-colors.conf # Couleurs pour hyprlock
```

### Import des configurations
```
source = ~/.config/hypr/configs/env.conf
source = ~/.config/hypr/configs/input.conf
source = ~/.config/hypr/configs/autostart.conf
source = ~/.config/hypr/configs/keybindings.conf
source = ~/.config/hypr/configs/look.conf
source = ~/.config/hypr/configs/monitors.conf
source = ~/.config/hypr/configs/plugins.conf
source = ~/.config/hypr/configs/windowrules.conf
```

---

## Waybar - Barre d'état

Barre d'état moderne pour Wayland. Affiche les informations système et les notifications.

### Fichiers de configuration
```
~/.config/waybar/
├── config                 # Configuration principale
└── style.css             # Styles et apparence
```

---

## Tofi - Lanceur d'applications

Lanceur d'applications rapide et léger. Permet de lancer des programmes et de naviguer dans les fichiers.

### Fichiers de configuration
```
~/.config/tofi/
└── config                 # Configuration du lanceur
```

---

## SwayNC - Centre de notifications

Centre de notifications pour Wayland. Gère l'affichage et l'historique des notifications système.

### Fichiers de configuration
```
~/.config/swaync/
├── config.json           # Configuration principale
└── style.css             # Styles et apparence
```

---

## Hyprlock - Verrouillage d'écran

Écran de verrouillage pour Hyprland. Sécurise la session avec un mot de passe.

### Fichiers de configuration
```
~/.config/hypr/
└── hyprlock.conf          # Configuration du verrouillage
```

---

## Hypridle - Gestionnaire d'inactivité

Gestionnaire d'inactivité pour Hyprland. Verrouille automatiquement l'écran après une période d'inactivité.

### Fichiers de configuration
```
~/.config/hypr/
└── hypridle.conf          # Configuration de l'inactivité
```

---

## Kitty - Terminal

Terminal moderne avec support des images et des polices. Configuration flexible et performances élevées.

### Fichiers de configuration
```
~/.config/kitty/
├── kitty.conf             # Configuration principale
└── colors.conf            # Couleurs et thème
```

---

## Pywal - Génération de couleurs

Génère automatiquement des palettes de couleurs à partir d'images. Crée des thèmes cohérents pour tout le système.

### Fichiers de configuration
```
~/.cache/wal/
├── colors.json            # Palette de couleurs
├── colors.sh              # Script shell
└── colors.css             # Styles CSS
```

---

## Fastfetch - Informations système

Affiche les informations système .

### Fichiers de configuration
```
~/.config/fastfetch/
├── config.jsonc           # Configuration principale
└── logo/                  # Logos personnalisés
    ├── akatsuki.png       # Logo Akatsuki
    ├── itachi.png         # Logo Itachi
    └── sasukeyyy.png      # Logo Sasuke
```

---

## Scripts - Scripts personnalisés

Collection de scripts personnalisés .

### Fichiers de configuration
```
~/.config/Scripts/
```

---

## Script d'installation

Script automatisé pour installer tous les composants nécessaires. Installe les paquets pacman, AUR et Flatpak.

Le script d'installation est disponible dans `package-base.sh`

### Utilisation
```bash
chmod +x package-base-V2.sh
./package-base.sh
```

---
