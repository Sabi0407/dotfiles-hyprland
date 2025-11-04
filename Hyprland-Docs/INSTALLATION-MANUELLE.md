# Inventaire maintenance (Arch Linux, noyau LTS)

## Gestionnaire officiel : pacman
### Maintenance courante
`pacman` est configuré lors de l'installation manuelle d'Arch. Pour garder le système propre et à jour :
```bash
sudo pacman -Syu
sudo pacman -Sc    # Nettoyage des anciens paquets (optionnel)
```

### Miroirs recommandés (France + voisins)
Privilégier les miroirs français et limitrophes :
```bash
sudo reflector --country France \
  --country Belgium \
  --country Luxembourg \
  --country Germany \
  --country Switzerland \
  --protocol https \
  --latest 10 \
  --sort rate \
  --save /etc/pacman.d/mirrorlist
```

### Paquets installés avec pacman
Liste des paquets explicitement installés depuis les dépôts officiels (commande `pacman -Qqent`) :
```bash
sudo pacman -S --needed \
  base bat blueman bluez-utils brightnessctl btop cliphist cronie \
  eza fastfetch firefox flameshot flatpak galculator gsimplecal hypridle \
  hyprland hyprlock hyprpicker imv intel-ucode kooha libxcrypt-compat ly \
  micro mousepad ncdu numlockx nwg-look obsidian openssl-1.1 pacman-contrib \
  pavucontrol plymouth polkit-gnome power-profiles-daemon proton-vpn-gtk-app qbittorrent \
  qemu-guest-agent qt5ct qt6ct reflector sassc spice-vdagent swaync syncthing \
  terminus-font thunar tree ttf-firacode-nerd ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-meslo-nerd \
  veracrypt virt-viewer virtualbox-guest-utils waybar woff2-font-awesome xarchiver xf86-video-qxl yazi \
  zsh-completions zsh-syntax-highlighting
```


### Paquets installés depuis l'AUR
Résultat de `pacman -Qqm` (paquets « foreign ») :
```bash
yay -S --needed \
  anki-bin catppuccin-cursors-mocha catppuccin-gtk-theme-mocha cursor-bin electron39-bin \
  gtk-engine-murrine gtk-engines gtk2 kvantum-theme-catppuccin-git librewolf-bin localsend-bin \
  onlyoffice-bin packettracer papirus-folders-git proton-pass-bin python-imageio-ffmpeg \
  python-pywal16-git python-pywalfox python-screeninfo spicetify-cli walcord \
  spicetify-extensions-rxri-git spicetify-marketplace-bin \
  spotify tofi-git touchpad-toggle ttf-all-the-icons vesktop-bin \
  vscodium-bin walcord waypaper yay yay-debug
```
- Cette configuration s'appuie sur `python-pywal16-git` (version de développement minimaliste maintenue via l'AUR). En cas de réinstallation, utiliser `yay -S python-pywal16-git` puis relancer les scripts Pywal dépendants pour régénérer les palettes.

## Packet Tracer
- Télécharger le paquet `.deb` Linux 64 bits depuis https://www.computernetworkingnotes.com/ccna-study-guide/download-packet-tracer-for-windows-and-linux.html (ex. `CiscoPacketTracer_900_Ubuntu_64bit.deb`).
- Installer via l'AUR (versions 9.x) :
  ```bash
  yay -S packettracer900-bin
  ```
- Si `yay` demande l'archive, la déposer dans `~/.cache/yay/<paquet>/` avant de relancer l'installation.

## Flatpak
```bash
sudo pacman -S --needed flatpak
flatpak update
flatpak list --app --columns=application,ref
com.github.IsmaelMartinez.teams_for_linux  com.github.IsmaelMartinez.teams_for_linux/x86_64/stable
me.timschneeberger.GalaxyBudsClient       me.timschneeberger.GalaxyBudsClient/x86_64/stable
org.dupot.easyflatpak                     org.dupot.easyflatpak/x86_64/stable
```

## VirtualBox (hôte noyau LTS)
```bash
sudo pacman -S --needed virtualbox virtualbox-host-modules-lts virtualbox-guest-utils
yay -S --needed virtualbox-ext-oracle
sudo usermod -aG vboxusers "$USER"
sudo modprobe vboxdrv
```
- Redémarrer la session après modification des groupes.
- Après une mise à jour du noyau LTS, relancer `sudo modprobe vboxdrv` pour s'assurer que les modules recompilés sont chargés. Si besoin, relancer l'installation de `virtualbox-host-modules-lts`.

## Commandes utiles
```bash
sudo pacman -Syu                 # Mise à jour officielle
yay -Syu                         # Mise à jour AUR + dépôts
flatpak update                   # Mise à jour Flatpak
sudo pacman -Sc                  # Nettoyage cache pacman
yay -Scc                         # Nettoyage cache yay
flatpak uninstall --unused       # Nettoyage Flatpak
```

## Rétroéclairage clavier
- Script utilisé : `~/.config/Scripts/auto-backlight.sh`.
- Super + Espace (`$mainMod + SPACE`) fait défiler les niveaux de luminosité.
- Un cron relance automatiquement le rétroéclairage à 18 h et l'éteint à 6 h du matin :
  ```cron
  0 18 * * * ~/.config/Scripts/auto-backlight.sh cycle
  0 6  * * * ~/.config/Scripts/auto-backlight.sh off
  ```

## Spicetify : installation & configuration

### 1. Installer les paquets
```bash
yay -S spicetify-cli spicetify-marketplace-bin spotify
```

### 2. Préparer Spotify
```bash
spicetify backup apply enable-devtools
spicetify config inject-css 1 replace-colors 1
```

### 3. Ouvrir le Marketplace
```bash
spicetify config custom_apps marketplace
spicetify config current_theme marketplace
spicetify apply
```
- Dans Spotify, `Ctrl + Shift + L` ouvre le Marketplace pour installer thèmes et extensions (le paquet `spicetify-custom-apps-and-extensions-git` n'est plus nécessaire).

### 4. Passer sur un thème personnalisé (optionnel)
```bash
spicetify config current_theme MonTheme
spicetify apply
```
- Pour revenir au Marketplace : `spicetify config current_theme marketplace && spicetify apply`

## Dépannage rapide
- Miroirs pacman lents : `sudo reflector --sort rate --latest 20 --save /etc/pacman.d/mirrorlist`
- Paquet AUR bloqué : `rm -rf ~/.cache/yay/<paquet>` puis `yay -S <paquet>`
- Modules VirtualBox après MAJ noyau : `sudo modprobe vboxdrv`
