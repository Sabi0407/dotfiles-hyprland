#!/bin/bash
# Script pour corriger les problèmes de miniatures dans Thunar

echo "🔧 Correction des miniatures Thunar..."

# Vérifier si tumbler est installé
if ! command -v tumbler &> /dev/null; then
    echo " Tumbler n'est pas installé. Installation nécessaire :"
    echo "   sudo pacman -S tumbler ffmpegthumbnailer"
    exit 1
fi

# Arrêter tumbler s'il est en cours d'exécution
echo " Arrêt du service tumbler..."
pkill -f tumbler 2>/dev/null

# Nettoyer le cache des miniatures
echo "Nettoyage du cache des miniatures..."
rm -rf ~/.cache/thumbnails/*
rm -rf ~/.thumbnails/* 2>/dev/null

# Redémarrer tumbler
echo " Redémarrage du service tumbler..."
tumbler -s &

# Attendre un peu
sleep 2

# Vérifier que tumbler fonctionne
if pgrep -f tumbler > /dev/null; then
    echo " Tumbler est maintenant actif"
else
    echo "  Problème avec tumbler, tentative de redémarrage..."
    tumbler -s &
fi

