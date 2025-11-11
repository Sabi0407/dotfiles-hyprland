# Configuration Hyprland - Version 2

> Consulte la documentation détaillée dans [`Hyprland-Docs/`](Hyprland-Docs/README.md)

## Composants principaux

| Composant | Utilisation                       |
| --------- | --------------------------------- |
| Hyprland  | Gestionnaire de fenêtres          |
| Waybar    | Barre d'état                      |
| SwayNC    | Centre de notifications           |
| SwayOSD   | Indicateurs volume/luminosité     |
| Hyprlock  | Verrouillage d'écran              |
| Hypridle  | Gestionnaire d'inactivité         |
| Yazi      | Gestionnaire de fichiers terminal |
| Tofi      | Lanceur d'applications            |
| Kitty     | Terminal                          |
| Micro     | Éditeur texte ligne de commande   |
| Fastfetch | Informations système              |
| Thème     | Catppuccin Mocha                  |
| Icônes    | Papirus Icon Pack                 |
| Pywal-16  | Génération de couleurs            |
| Pywalfox  | Thème Firefox dynamique           |

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
source = configs/env.conf
source = configs/input.conf
source = configs/autostart.conf
source = configs/keybindings.conf
source = configs/look.conf
source = configs/monitors.conf
source = configs/plugins.conf # Plugins non utilisé
source = configs/windowrules.conf
```

---

## Waybar 

### Fichiers de configuration

```
~/.config/waybar/
├── config                 # Configuration principale
└── style.css              # Styles et apparence
```

---

## Tofi 

### Fichiers de configuration

```
~/.config/tofi/
└── config                 # Configuration du lanceur
```

---

## SwayNC 
### Fichiers de configuration

```
~/.config/swaync/
├── config.json            # Configuration principale
└── style.css              # Styles et apparence
```

---

## SwayOSD

Affiche les barres de volume, luminosité et notifications système visuelles.

```
~/.config/swayosd/
├── config.toml            # Paramètres (appareils suivis, commandes associées)
└── style.css              # Styles (couleurs, typographie, ombres)
```

---

## Hyprlock
### Fichiers de configuration

```
~/.config/hypr/
└── hyprlock.conf          # Configuration du verrouillage
```

---

## Hypridle 
### Fichiers de configuration

```
~/.config/hypr/
└── hypridle.conf          # Configuration de l'inactivité
```

---

## Kitty 

Terminal moderne avec support des images et des polices. Configuration flexible et performances élevées.

### Fichiers de configuration

```
~/.config/kitty/
├── kitty.conf             # Configuration principale
└── colors.conf            # Couleurs et thème
```

---

## Pywal-16


### Fichiers de configuration

```
~/.cache/wal/
├── colors.json            # Palette de couleurs
├── colors.sh              # Script shell
└── colors.css             # Styles CSS
```

---

## Fastfetch 



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

Collection de scripts personnalisés.

### Fichiers de configuration

```
~/.config/Scripts/
```
