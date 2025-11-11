# Guide des raccourcis Hyprland

Touche principale : `Super` (`$mainMod`).  
Notation : `Super + X` signifie maintenir `Super`, puis frapper `X`. Les combinaisons peuvent cumuler `Shift`, `Ctrl` ou `Alt`.

---

## Lancement & utilitaires

### Applications principales
| Raccourci | Action |
|-----------|--------|
| `Super + Enter` | Terminal (`$terminal`) |
| `Super + E` | Gestionnaire de fichiers (`$fileManager`) |
| `Super + Tab` | Lanceur `tofi-drun` |

### Navigateurs
| Raccourci | Action |
|-----------|--------|
| `Super + B` | Firefox |
| `Super + Shift + B` | Firefox fenêtré privé |
| `Super + Ctrl + B` | Brave en mode incognito |

### Productivité & multimédia
| Raccourci | Action |
|-----------|--------|
| `Super + O` | Ouvrir le vault Obsidian **Cours** |
| `Super + Alt + O` | Ouvrir le vault Obsidian **Perso** |
| `Super + M` | Sélecteur de fichiers pour MPV |
| `Super + K` | Capture vidéo Kooha |
| `Super + Z` | Lecteur PDF Zathura |

### Presse-papiers
| Raccourci | Action |
|-----------|--------|
| `Super + Ctrl + V` | Gestionnaire d’historique (`clipboard-manager.sh`) |
| `Super + Alt + Delete` | Purger l’historique Cliphist |

---

## Fenêtres & disposition

### Commandes générales
| Raccourci | Action |
|-----------|--------|
| `Super + X` | Fermer la fenêtre active |
| `Super + V` | Basculer flottant ↔ tiling |
| `Super + F` | Plein écran préférentiel |
| `Super + D` | Masquer / afficher toutes les fenêtres (`toggle_show_desktop.sh`) |

### Groupes (onglets)
| Raccourci | Action |
|-----------|--------|
| `Super + G` | Créer / dissoudre un groupe |
| `Super + Shift + G` | Verrouiller / déverrouiller le groupe actif |
| `Super + Ctrl + G` | Extraire la fenêtre du groupe |
| `Super + Alt + G` | Ajouter la fenêtre au groupe de droite |
| `Alt + H / Alt + L` | Naviguer groupe précédent / suivant |
| `Super + ' (apostrophe)` | Alterner d’un onglet à l’autre |

### Navigation & déplacement
| Raccourci | Action |
|-----------|--------|
| `Super + ←/→/↑/↓` | Déplacer le focus |
| `Super + Shift + ←/→/↑/↓` | Déplacer la fenêtre (ou le groupe) |
| `Super + Alt + ←/→/↑/↓` | Déplacer uniquement la fenêtre flottante |

### Redimensionnement
| Raccourci | Action |
|-----------|--------|
| `Super + Ctrl + ←/→` | Redimensionner ±50 px horizontalement |
| `Super + Ctrl + ↑/↓` | Redimensionner ±50 px verticalement |
| `Super + clic milieu` | Redimensionnement vertical (drag) |
| `Super + Alt + clic milieu` | Redimensionnement horizontal (drag) |

### Contrôles souris
- `Super + clic gauche` : déplacer la fenêtre.
- `Super + clic droit` : redimensionner la fenêtre.

---

## Workspaces & scratchpad

| Raccourci | Action |
|-----------|--------|
| `Super + I` | Afficher / masquer le workspace spécial |
| `Super + Shift + I` | Envoyer la fenêtre sur le workspace spécial |
| `Super + 1…0` | Aller aux workspaces 1 → 10 |
| `Super + Shift + 1…0` | Envoyer la fenêtre vers workspace 1 → 10 |
| `Super + Shift + molette` | Naviguer workspace suivant / précédent |

---

## Session & scripts système

| Raccourci | Action |
|-----------|--------|
| `Super + Shift + L` | Quitter Hyprland |
| `Super + L` | Verrouiller (hyprlock + cover art) |
| `Super + Ctrl + R` | Recharger Hyprland + Waybar + SwayNC |
| `Super + N` | Afficher / masquer SwayNC |
| `Super + Shift + S` | Restaurer rapidement le thème Catppuccin |
| `Super + Ctrl + S` | Sélecteur complet de thème Catppuccin |
| `Super + Shift + O` | Lancer `backup-usb.sh` (sauvegarde USB) |
| `Super + Ctrl + Shift + R` | Redémarrer la machine |
| `Super + Ctrl + Shift + O` | Éteindre la machine |

---

## Captures & enregistrements

| Raccourci | Action |
|-----------|--------|
| `Super + T` | Capture de zone → presse-papiers (`grim + slurp`) |
| `Super + S` | Interface Flameshot |
| `Super + Shift + T` | Capture de zone sauvegardée dans les notes |
| `Super + F11` | Enregistrement plein écran (wf-recorder + audio) |
| `Super + F12` | Enregistrement d’une zone (wf-recorder + audio) |

---

## Apparence & fonds d’écran

| Raccourci | Action |
|-----------|--------|
| `Super + W` | Wallpaper aléatoire (`random_wallpapers.sh`) |
| `Super + Alt + W` | Lancer Waypaper GUI |

---

## Audio, luminosité & médias

### Touches multimédia physiques
- `XF86AudioRaiseVolume / LowerVolume / Mute` : volume principal ±5 %, mute.
- `XF86AudioMicMute` : mute micro.
- `XF86MonBrightnessUp / Down` : luminosité écran ±5 %.
- `XF86KbdBrightnessUp / Down` : rétroéclairage clavier ±1 via `auto-backlight.sh`.
- `XF86AudioPlay/Pause/Next/Prev` : commandes `playerctl`.

### Variantes avec `Super`
| Raccourci | Action |
|-----------|--------|
| `Super + F1` | Mute sortie audio |
| `Super + F2 / F3` | Volume −/+ 5 % |
| `Super + F5 / F6` | Luminosité écran −/+ 5 % |
| `Super + Space` | Basculer rétroéclairage clavier (`auto-backlight.sh`) |
| `Super + Shift + P` | Sélecteur de profil d’alimentation |

---

## Zoom curseur

| Raccourci | Action |
|-----------|--------|
| `Super + =` ou `Super + pavé +` | Zoom ×1.1 |
| `Super + -` ou `Super + pavé -` | Zoom ×0.9 |
| `Ctrl + molette` | Zoom ×1.1 / ×0.9 |
| `Super + Ctrl + Alt + molette` | Zoom ×1.1 / ×0.9 |
| `Super + Shift + molette` ou `Super + Shift + - / pavé -` ou `Super + Shift + 0` | Réinitialiser zoom (×1) |

---

## Raccourcis souris additionnels
- `Super + Shift + molette` : passer au workspace voisin.
- `Super + Shift + clic milieu` : reset zoom curseur (voir section dédiée).

---

> Tous les scripts référencés vivent dans `~/.config/Scripts/`.  
> Recharge la configuration (`Super + Ctrl + R`) après modification des binds.
