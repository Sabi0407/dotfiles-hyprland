#!/bin/bash

# Script de configuration SDDM - Clavier français + NumLock
# Auteur: sabi
# Usage: ./setup_sddm_keyboard.sh

echo "Configuration SDDM - Clavier français + NumLock"
echo "================================================"

# Vérifier les permissions sudo
if ! sudo -n true 2>/dev/null; then
    echo "ERREUR: Ce script nécessite les permissions sudo"
    exit 1
fi

# Créer le répertoire de configuration SDDM
echo "Création du répertoire de configuration..."
sudo mkdir -p /etc/sddm.conf.d

# Créer la configuration clavier
echo "Configuration du clavier français..."
sudo tee /etc/sddm.conf.d/keyboard.conf << 'EOF'
[General]
Numlock=on

[X11]
ServerArguments=-nolisten tcp -keeptty
DisplayCommand=/etc/sddm/Xsetup

[Wayland]
SessionDir=/usr/share/wayland-sessions
EOF

# Créer le script Xsetup
echo "Création du script Xsetup..."
sudo mkdir -p /etc/sddm
sudo tee /etc/sddm/Xsetup << 'EOF'
#!/bin/sh
# Configuration clavier français et NumLock pour SDDM
setxkbmap fr
numlockx on
EOF

# Rendre le script exécutable
sudo chmod +x /etc/sddm/Xsetup

# Vérifier que numlockx est installé
echo "Vérification de numlockx..."
if ! command -v numlockx &> /dev/null; then
    echo "ATTENTION: numlockx n'est pas installé. Installation..."
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm numlockx
    elif command -v apt &> /dev/null; then
        sudo apt install -y numlockx
    else
        echo "ERREUR: Gestionnaire de paquets non reconnu. Installez numlockx manuellement."
        exit 1
    fi
fi

echo "Configuration terminée !"
echo ""
echo "Pour appliquer les changements :"
echo "   sudo systemctl restart sddm"
echo ""
echo "Résultat attendu :"
echo "   - Clavier français (AZERTY) dans SDDM"
echo "   - NumLock activé automatiquement"
