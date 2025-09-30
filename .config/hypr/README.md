# 🏗️ Configuration Hyprland Organisée

## 📁 Structure des fichiers

Votre configuration Hyprland a été réorganisée de manière professionnelle avec des noms anglais et des commentaires français détaillés.

### 📋 Fichiers principaux

| Fichier | Description | Contenu |
|---------|-------------|---------|
| `hyprland.conf` | **Configuration principale** | Point d'entrée avec imports organisés |
| `environment.conf` | **Variables d'environnement** | Thèmes, programmes par défaut, localisation |
| `appearance.conf` | **Apparence visuelle** | Décorations, animations, couleurs, layouts |
| `input.conf` | **Périphériques d'entrée** | Clavier, souris, touchpad, gestes |
| `windows.conf` | **Gestion des fenêtres** | Règles, workspaces, transparence |
| `keybindings.conf` | **Raccourcis clavier** | Tous les raccourcis organisés par catégorie |
| `plugins.conf` | **Extensions** | Configuration des plugins Hyprland |
| `startup.conf` | **Démarrage automatique** | Applications lancées au boot |
| `monitors.conf` | **Configuration écrans** | Résolution, position des moniteurs |

## 🎨 Améliorations apportées

### ✨ **Organisation**
- **Noms anglais** pour les fichiers (standard international)
- **Commentaires français** détaillés et explicatifs
- **Sections thématiques** avec séparateurs visuels
- **Documentation intégrée** avec liens vers la doc officielle

### 🚀 **Fonctionnalités**
- **Animations optimisées** pour de meilleures performances
- **Raccourcis supplémentaires** (Super+Q, Super+D, etc.)
- **Organisation automatique** des applications par workspace
- **Règles de fenêtres** améliorées pour gaming et productivité
- **Transparence intelligente** par application

### 🔧 **Optimisations**
- **Configuration touchpad** complète avec gestes
- **Gestion d'énergie** améliorée
- **Support gaming** avec mode immédiat
- **Thèmes unifiés** Qt/GTK

## 📖 Guide d'utilisation

### 🔄 Recharger la configuration
```bash
Super + Shift + C    # Raccourci clavier
# ou
hyprctl reload       # Commande terminal
```

### 🎯 Raccourcis principaux
- `Super + Return` : Terminal
- `Super + E` : Gestionnaire de fichiers
- `Super + D` : Menu d'applications
- `Super + L` : Verrouiller la session
- `Super + Q` : Fermer fenêtre
- `Super + V` : Mode flottant/tiling

### 🪟 Organisation des workspaces
- **Workspace 1** : Général
- **Workspace 2** : Navigation web (Brave)
- **Workspace 3** : Communication (Discord)
- **Workspace 4** : Musique (Spotify)
- **Workspace 5** : Gaming (Steam)
- **Workspace 6** : Notes (Obsidian)

## 🛠️ Personnalisation

### Modifier les thèmes
Éditez `environment.conf` pour changer :
- Thèmes GTK/Qt
- Curseurs
- Programmes par défaut

### Ajuster l'apparence
Éditez `appearance.conf` pour modifier :
- Couleurs des bordures
- Animations
- Transparence
- Effets de flou

### Personnaliser les raccourcis
Éditez `keybindings.conf` pour :
- Ajouter de nouveaux raccourcis
- Modifier les existants
- Organiser par catégories

## 📞 Support

Pour toute question ou personnalisation supplémentaire, consultez :
- [Documentation officielle Hyprland](https://wiki.hyprland.org/)
- [Configuration des variables](https://wiki.hyprland.org/Configuring/Variables/)
- [Guide des raccourcis](https://wiki.hyprland.org/Configuring/Binds/)

---
*Configuration créée et organisée par Cascade AI*
*Dernière mise à jour : 30 septembre 2025*
