# Spicetify × Pywal : installation et configuration

Ce guide décrit toutes les étapes pour intégrer Spotify (Spicetify) dans ton workflow Pywal (wallpaper → palette → applications). Les commandes supposent un environnement Arch/Manjaro avec `yay`.

---

## 1. Installation des paquets

```bash
sudo pacman -S spicetify-cli                      # outil principal
yay -S pywal-spicetify                            # pont Pywal → Spicetify
yay -S spicetify-marketplace-bin                  # GUI pour thèmes/extensions (optionnel mais pratique)
yay -S walcord                                    # Vesktop/Vencord → palette Pywal
yay -S zathura-pywal-git                          # Zathura → palette Pywal
```

---

## 2. Initialisation Spicetify (à faire une fois)

Spotify doit être fermé pendant cette étape.

```bash
spicetify backup apply enable-devtools
spicetify config inject-css 1 replace-colors 1
```

Si Spotify se met à jour plus tard, re-lance simplement `spicetify apply`.

---

## 3. Installer/Choisir un thème

Deux options :

1. **Marketplace**  
   - `spicetify config custom_apps marketplace`  
   - `spicetify apply`  
   - Ouvre Spotify → `Ctrl+Shift+L` → installe un thème (ex. *Sleek*).

2. **Cloner un pack**  
   ```bash
   git clone https://github.com/spicetify/spicetify-themes ~/.config/spicetify/Themes
   ```

Le script détecte automatiquement le thème actif (`spicetify config current_theme`). Si tu veux en forcer un, exporte `SPICETIFY_THEME="NomDuTheme"` avant d’exécuter `pywal-sync.sh`.

---

## 4. Script Pywal → Spicetify

Le script dédié est déjà présent : `~/.config/Scripts/pywal-spicetify.sh`.  
Il s’occupe de :

- récupérer la palette Wal (`~/.config/wal/cache`) ;
- mettre à jour `color.ini` du thème Spotify courant ;
- rappeler d’exécuter `spicetify apply --no-restart` si Spotify est actif.

Assure-toi qu’il est exécutable :

```bash
chmod +x ~/.config/Scripts/pywal-spicetify.sh
```

⚠️ Spotify doit pouvoir être patché : applique les permissions une seule fois après installation du client officiel.

```bash
sudo chmod a+wr /opt/spotify
sudo chmod -R a+wr /opt/spotify/Apps
```

---

## 5. Intégration avec `pywal-sync.sh`

Le dépôt contient un script `~/.config/Scripts/pywal-spicetify.sh`. Il est déjà ajouté dans la liste des tâches de `pywal-sync.sh` :

```bash
TASKS=(
    ...
    "pywal-spicetify.sh"
    ...
)
```

Ce script :

1. Lit le thème Spotify courant (`spicetify config current_theme`) ;
2. Copie la palette Pywal générée vers `~/.cache/wal/colors-spicetify.ini` (emplacement attendu par `pywal-spicetify`) ;
3. Met à jour `color.ini` du thème et sync le `color_scheme` ;
4. **N’exécute plus** `spicetify apply` automatiquement quand Spotify est ouvert (pour éviter qu’il se rouvre). Il affiche simplement :

```
[pywal-spicetify] Palette mise à jour pour le thème 'Pywal' (schéma 'pywal').
[pywal-spicetify] Lancez 'spicetify apply --no-restart' quand vous souhaitez appliquer la mise à jour.
```

---

## 6. Cycle quotidien

- Change de fond d’écran via `SUPER + W` (ou `wal -i ...`)  
- `wallpaper-manager.sh` appelle `pywal-sync.sh`, qui met à jour toutes les apps (Waybar, Hyprlock, Spicetify, etc.)  
- SI Spotify est fermé → la palette est appliquée automatiquement.  
- SI Spotify est ouvert → tape `spicetify apply --no-restart` quand tu veux appliquer la nouvelle palette, sans redémarrage.

 Pour forcer l’application du thème après un changement de fond :
```bash
~/.config/Scripts/pywal-spicetify.sh   # met à jour color.ini
spicetify apply --no-restart          # applique immédiatement, même si Spotify est ouvert
```

---

## 7. Rappels utiles

- Rétablir Spotify d’origine : `spicetify restore`  
- Vérifier la config courante : `spicetify config`  
- Changer temp. de thème : `spicetify config current_theme NomTheme && spicetify apply`
- Empêcher Spotify de se rouvrir : déjà géré par `pywal-spicetify.sh`.

---

Pywal, Hypr, Waybar et Spotify sont désormais synchronisés : un simple changement de fond d’écran suffit à propager les couleurs sur l’ensemble de ton setup. 

---

## Annexe : commandes utiles par application

- **Spotify** : `~/.config/Scripts/pywal-spicetify.sh` (relancé par `pywal-sync.sh`).
- **Vesktop/Vencord** : `walcord apply` (ou automatiquement via `pywal-sync.sh` si ajouté).
- **Vesktop/Vencord** : `walcord --json ~/.config/wal/cache/colors.json` (déjà intégré à `pywal-sync.sh`).
  > Assure-toi ensuite de sélectionner `~/.config/vesktop/themes/walcord.theme.css` dans les paramètres Vesktop.
- **Zathura** : `zathura-pywal` (également déclenché dans `pywal-sync.sh`).
