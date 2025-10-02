#!/bin/bash
# Script pour lancer KDE Connect en mode sombre
# Usage: kdeconnect-dark.sh

# Variables d'environnement pour forcer le thème sombre
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=kvantum-dark
export KDE_SESSION_VERSION=5
export KDE_FULL_SESSION=true
export DESKTOP_SESSION=KDE

# Forcer le thème sombre pour Qt
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DECORATION=adwaita
export QT_AUTO_SCREEN_SCALE_FACTOR=1

# Lancer KDE Connect avec le thème sombre
kdeconnect-app --style=breeze-dark &

echo " KDE Connect lancé en mode sombre"
