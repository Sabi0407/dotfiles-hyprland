# Script VLC-keys pour mpv

Ce script Lua reproduit les raccourcis clavier familiers de VLC dans mpv.

## Installation

Le script est déjà installé dans `~/.config/mpv/vlc-keys.lua`. Il se chargera automatiquement au démarrage de mpv.

## Raccourcis disponibles

### Lecture/Contrôle
- **Espace** : Lecture/Pause
- **S** : Arrêt
- **Q** : Quitter
- **Ctrl+Q** : Quitter en sauvegardant la position

### Navigation temporelle
- **Flèche droite** : Avancer de 10 secondes
- **Flèche gauche** : Reculer de 10 secondes
- **Flèche haut** : Avancer de 1 minute
- **Flèche bas** : Reculer de 1 minute
- **Ctrl+Flèche droite** : Avancer de 5 minutes
- **Ctrl+Flèche gauche** : Reculer de 5 minutes

### Volume
- **Ctrl+Flèche haut** : Augmenter le volume (+5%)
- **Ctrl+Flèche bas** : Diminuer le volume (-5%)
- **M** : Couper/Rétablir le son

### Vitesse de lecture
- **=** (ou +) : Accélérer (×1.1)
- **-** : Ralentir (×0.9)
- **1** : Vitesse normale (1.0x)

### Affichage
- **F** : Basculer en plein écran
- **A** : Changer le ratio d'aspect (16:9, 4:3, 2.35:1, original)
- **R** : Rotation de l'image (90° par 90°)
- **Z** : Zoom avant
- **Shift+Z** : Zoom arrière
- **Ctrl+Z** : Réinitialiser le zoom

### Playlist
- **N** : Fichier suivant
- **P** : Fichier précédent

### Pistes
- **V** : Changer les sous-titres
- **B** : Changer la piste audio

### Utilitaires
- **I** : Afficher les informations du fichier
- **Shift+S** : Capture d'écran

## Fonctionnalités

- **Messages à l'écran** : Chaque action affiche un message informatif
- **Chargement automatique** : Le script se charge automatiquement avec mpv
- **Compatible VLC** : Reproduit fidèlement l'expérience VLC

## Désinstallation

Pour désactiver le script, renommez ou supprimez le fichier :
```bash
mv ~/.config/mpv/vlc-keys.lua ~/.config/mpv/vlc-keys.lua.disabled
```

## Personnalisation

Vous pouvez modifier les raccourcis en éditant le fichier `vlc-keys.lua`. Chaque raccourci est défini avec `mp.add_key_binding()`.

Exemple pour changer le raccourci de pause :
```lua
mp.add_key_binding("p", "toggle-pause", function()
    mp.commandv("cycle", "pause")
end)
```

Profitez de votre expérience mpv avec les raccourcis familiers de VLC ! 🎬
