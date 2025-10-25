#!/bin/bash
# Installation basée sur les paquets réellement installés sur votre système

echo "🚀 Installation des paquets basée sur votre système actuel"

## 1. Paquets officiels (pacman) - Installés explicitement
sudo pacman -S --needed \
7zip base base-devel bat blueman bluez bluez-utils \
brightnessctl discord ffmpegthumbnailer \
firefox flatpak galculator git \
gnome-themes-extra grim gsimplecal gvfs htop eza \
hypridle hyprland imagemagick imv kitty kooha \
ly micro mousepad mpv ncdu pavucontrol plymouth \
power-profiles-daemon qbittorrent rofi slurp \
thunar thunar-archive-plugin waybar wofi \
network-manager-applet noto-fonts noto-fonts-emoji \
pipewire-pulse polkit-gnome qt5-wayland qt5ct qt6ct \
ttf-dejavu ttf-firacode-nerd ttf-jetbrains-mono \
ttf-jetbrains-mono-nerd ttf-liberation ttf-meslo-nerd \
ttf-nerd-fonts-symbols zenity zsh zsh-completions zsh-syntax-highlighting

## 2. Installer yay (si non installé)
if ! command -v yay &> /dev/null; then
    echo "📦 Installation de yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
fi

## 3. Paquets AUR - Installés sur votre système
yay -S --needed --noconfirm \
anki-bin brave-bin catppuccin-cursors-mocha \
catppuccin-gtk-theme-mocha gsconnect \
kvantum-theme-catppuccin-git localsend-bin \
nerdfetch onlyoffice-bin packettracer \
papirus-folders-git proton-pass-bin \
python-pywal16 python-pywalfox spotify \
virtualbox-ext-oracle vscodium-bin windsurf yay

## 4. Applications Flatpak - Installées sur votre système
echo "📦 Installation des applications Flatpak..."
flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux
flatpak install -y flathub me.timschneeberger.GalaxyBudsClient
flatpak install -y flathub org.dupot.easyflatpak

## 5. Paquets système essentiels (à vérifier/installer)
echo "📋 Installation des paquets système manquants..."
sudo pacman -S --needed \
virtualbox virtualbox-host-modules-lts \
jq rsync unrar papirus-icon-theme \
xdg-desktop-portal-hyprland

## 6. Configuration VirtualBox pour noyau LTS
echo "🔧 Configuration VirtualBox pour noyau LTS..."
echo "ℹ️  Noyau détecté: $(uname -r)"
sudo modprobe vboxdrv vboxnetadp vboxnetflt vboxpci 2>/dev/null || echo "⚠️  Modules VirtualBox non chargés (normal si pas installé)"
sudo usermod -aG vboxusers $USER

## 7. Configuration système
echo "🔧 Configuration des services..."
# Activer les services si nécessaire
# sudo systemctl enable ly
# sudo systemctl enable bluetooth

echo "✅ Installation terminée!"
echo "ℹ️  Ce script est basé sur vos paquets actuellement installés (121 paquets pacman + 20 AUR + 3 Flatpak)"
echo "⚠️  Redémarrez votre session pour que les groupes prennent effet"
