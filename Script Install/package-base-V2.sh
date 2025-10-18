#!/bin/bash
# Script d'installation simple pour Arch Linux avec Hyprland

echo "=== Installation Arch Linux avec Hyprland ==="
echo "Total: 142 paquets pacman + 20 AUR + 3 Flatpak = 165 applications"
echo ""

# Vérifier si on est root
if [[ $EUID -eq 0 ]]; then
   echo "ERREUR: Ce script ne doit pas être exécuté en tant que root"
   exit 1
fi

# Mettre à jour la liste des paquets dispo
echo "Mise à jour de la base de données des paquets..."
sudo pacman -Sy

echo ""
echo "=== 1. Installation des paquets via pacman ==="
# Installer tous les paquets officiels d'Arch Linux

sudo pacman -S --needed --noconfirm \
7zip base base-devel bat blueman bluez bluez-utils \
brightnessctl clang cmake compiler-rt cppdap cronie \
djvulibre enchant evince fastfetch ffmpegthumbnailer \
firefox flameshot flatpak galculator git \
gnome-themes-extra grim gsimplecal gspell \
gtk-engine-murrine gtk-engines gvfs htop hypridle \
hyprland hyprlock hyprpicker imagemagick imv intel-ucode \
jq kitty kvantum-theme-catppuccin-git libuv libxcrypt-compat \
linux-firmware linux-lts linux-lts-headers llvm localsend-bin \
ly meson micro mpv networkmanager \
network-manager-applet noto-fonts noto-fonts-emoji numlockx \
nwg-look obsidian onlyoffice-bin openssl-1.1 packettracer \
pacman-contrib papirus-folders-git papirus-icon-theme \
pavucontrol pipewire-alsa pipewire-jack pipewire-pulse \
plymouth polkit-gnome poppler poppler-glib \
power-profiles-daemon proton-pass-bin proton-vpn-gtk-app \
python-pip python-pywal16 python-pywalfox qbittorrent \
qt5ct qt5-wayland qt6-connectivity qt6ct rhash rofi \
rsync slurp spotify sudo swaync swww syncthing \
terminus-font thunar thunar-archive-plugin tofi-git tree \
ttf-all-the-icons ttf-dejavu ttf-firacode-nerd \
ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-liberation \
ttf-meslo-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common \
tumbler unrar unzip veracrypt virtualbox \
virtualbox-ext-oracle virtualbox-guest-utils virtualbox-host-dkms \
virt-viewer vscodium-bin waybar wf-recorder wl-clipboard \
woff2-font-awesome xarchiver xdg-desktop-portal-gtk \
xdg-desktop-portal-hyprland xdg-user-dirs xorg-xauth \
yazi zathura zenity \
zip zsh zsh-completions zsh-syntax-highlighting

echo ""
echo "=== 2. Installation de yay  ==="

# Vérifier si yay est déjà installé
if command -v yay &> /dev/null; then
    echo "yay est déjà installé"
else
    echo "Installation de yay..."
    
    # Créer un dossier temporaire pour télécharger yay
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Télécharger yay depuis l'AUR
    git clone https://aur.archlinux.org/yay.git
    cd yay
    # Compiler et installer yay
    makepkg -si --noconfirm
    
    # Nettoyer le dossier temporaire
    cd /
    rm -rf "$TEMP_DIR"
    
    echo "yay installé avec succès"
fi

echo ""
echo "=== 3. Installation des paquets AUR (20 paquets) ==="
# Installer les paquets depuis l'AUR (Arch User Repository)
yay -S --needed --noconfirm \
anki-bin catppuccin-cursors-mocha catppuccin-gtk-theme-mocha \
cursor-bin kvantum-theme-catppuccin-git \
librewolf-bin localsend-bin onlyoffice-bin \
packettracer papirus-folders-git proton-pass-bin \
python-pywal16 python-pywalfox spotify tofi-git \
ttf-all-the-icons virtualbox-ext-oracle \
vscodium-bin yay yay-debug

echo ""
echo "=== 4. Installation des applications Flatpak (3 applications) ==="

# Ajouter le dépôt Flathub si nécessaire
if ! flatpak remote-list | grep -q flathub; then
    echo "Ajout du dépôt Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Installer les applications Flatpak
flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux
flatpak install -y flathub me.timschneeberger.GalaxyBudsClient
flatpak install -y flathub org.dupot.easyflatpak

echo ""
echo "=== 5. Configuration système ==="

# Activer les services au démarrage
echo "Activation des services..."
sudo systemctl enable ly 2>/dev/null || echo "Service ly non trouvé"
sudo systemctl enable bluetooth 2>/dev/null || echo "Service bluetooth non trouvé"
sudo systemctl enable NetworkManager 2>/dev/null || echo "Service NetworkManager non trouvé"

# Ajouter l'utilisateur aux groupes nécessaires
echo "Ajout aux groupes utilisateur..."
sudo usermod -aG wheel,audio,video,optical,storage,network,users,vboxusers $USER 2>/dev/null || echo "Impossible d'ajouter aux groupes"

echo ""
echo "=== Installation terminée! ==="
echo ""
echo "ACTIONS REQUISES:"
echo "1. Redémarrez votre session pour que les groupes prennent effet"
echo "2. Redémarrez votre système pour activer tous les services"
echo "3. Configurez Hyprland selon vos préférences"
echo ""
echo "Votre système Arch Linux avec Hyprland est prêt!"