# Environnement Hyprland




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

