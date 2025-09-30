# Environnement Hyprland – Documentation des paquets



https://youtu.be/zQ3K9oAn1vE



Ce document regroupe les paquets nécessaires au fonctionnement d’un environnement Hyprland complet sous Arch Linux.  
Chaque section présente les logiciels, leur rôle et la source d’installation (dépôts officiels via pacman ou AUR via yay).

---

## 1. Base du système

- base, base-devel : paquets de base indispensables  
- linux-firmware, linux-lts, linux-lts-headers, intel-ucode : microcodes et noyau LTS  
- sudo : gestion des droits administrateur  
- rsync : synchronisation de fichiers  
- git : gestion de versions  
- zsh, zsh-completions, zsh-syntax-highlighting : shell Zsh avec complétions et coloration  



---

## 2. Gestionnaire de fenêtres Hyprland

- hyprland  
- hypridle (AUR)  
- hyprlock (AUR)  
- hyprpicker (AUR)  
- xdg-desktop-portal-hyprland  
- swww (AUR)  

---

## 3. Interface graphique et barres

- waybar  
- wofi, rofi  
- nwg-look (AUR)  
- kitty  
- micro, mousepad  
- zenity  
- obsidian  
- windsurf (AUR)  

---

## 4. Notifications et calendrier

- swaync (AUR)  
- gsimplecal  

---

## 5. Thèmes, icônes et polices

- gnome-themes-extra, papirus-icon-theme  
- papirus-folders-git (AUR)  
- catppuccin-gtk-theme-* (AUR)  
- catppuccin-cursors-* (AUR)  
- kvantum-theme-catppuccin-git (AUR)  
- terminus-font  
- noto-fonts, noto-fonts-emoji  
- ttf-dejavu, ttf-liberation, ttf-firacode-nerd, ttf-jetbrains-mono  
- ttf-jetbrains-mono-nerd, ttf-meslo-nerd (AUR)  
- ttf-nerd-fonts-symbols, ttf-nerd-fonts-symbols-common  
- woff2-font-awesome (AUR)  

---

## 6. Réseau et connectivité

- networkmanager, network-manager-applet  
- bluez, bluez-utils, blueman  
- localsend-bin (AUR)  
- proton-vpn-gtk-app (AUR)  

---

## 7. Audio et multimédia

- pavucontrol, pipewire-pulse  
- mpv, qbittorrent  
- flameshot (AUR)  
- grim, slurp, wf-recorder  
- imagemagick, imv  

---

## 8. Gestion de fichiers et archives

- thunar, thunar-archive-plugin  
- file-roller, xarchiver  
- 7zip, unrar, unzip  
- gvfs  
- yazi (AUR)  

---

## 9. Sécurité et utilitaires

- polkit-gnome  
- veracrypt  
- proton-pass-bin (AUR)  
- numlockx  

---

## 10. Démarrage et thèmes

- sddm  
- sddm-sugar-candy-git (AUR)  
- plymouth  
- plymouth-theme-connect-git (AUR)  
- plymouth-theme-flame-git (AUR)  

---

## 11. Navigateurs et outils divers

- firefox  
- brave-bin (AUR)  
- packettracer (AUR)  
- htop, jq, galculator  
- nerdfetch (AUR)  

---

## 12. Virtualisation

- virtualbox, virtualbox-guest-utils, virtualbox-host-dkms  
- virtualbox-ext-oracle (AUR)  

---

## 13. Thèmes et intégrations Pywal

- python-pywal16 (AUR)  
- python-pywalfox (AUR)  

---

# Commandes d’installation

### Installation des paquets officiels (pacman)

```bash
sudo pacman -S --needed \
7zip base base-devel blueman bluez bluez-utils brightnessctl \
file-roller firefox flatpak galculator git gnome-themes-extra grim \
gsimplecal gvfs htop hyprland imagemagick imv intel-ucode jq kitty \
linux-firmware linux-lts linux-lts-headers micro mousepad mpv \
networkmanager network-manager-applet noto-fonts noto-fonts-emoji \
numlockx obsidian papirus-icon-theme pavucontrol pipewire-pulse \
plymouth polkit-gnome power-profiles-daemon qbittorrent qt5ct qt6ct \
rofi rsync sddm slurp sudo thunar thunar-archive-plugin \
terminus-font ttf-dejavu ttf-firacode-nerd ttf-jetbrains-mono \
ttf-liberation ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common \
unrar unzip veracrypt virtualbox virtualbox-guest-utils \
virtualbox-host-dkms waybar wf-recorder wofi xarchiver \
xdg-desktop-portal-hyprland xdg-user-dirs zenity \
zsh zsh-completions zsh-syntax-highlighting
```




```bash
## 1. Installer yay (si non installé)

```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```


```bash
yay -S --needed \
brave-bin catppuccin-cursors-frappe catppuccin-cursors-latte \
catppuccin-cursors-macchiato catppuccin-cursors-mocha \
catppuccin-gtk-theme-frappe catppuccin-gtk-theme-latte \
catppuccin-gtk-theme-macchiato catppuccin-gtk-theme-mocha \
flameshot hypridle hyprlock hyprpicker kvantum-theme-catppuccin-git \
localsend-bin nerdfetch nwg-look packettracer papirus-folders-git \
plymouth-theme-connect-git plymouth-theme-flame-git proton-pass-bin \
proton-vpn-gtk-app python-pywal16 python-pywalfox \
sddm-sugar-candy-git swaync swww ttf-jetbrains-mono-nerd \
ttf-meslo-nerd windsurf woff2-font-awesome virtualbox-ext-oracle \
yazi
```

