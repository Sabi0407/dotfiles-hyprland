#!/bin/bash
# Nettoyage rapide du système

echo " Nettoyage rapide du système..."

# Supprimer les paquets orphelins
echo "🗑️  Suppression des paquets orphelins..."
sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || echo "Aucun paquet orphelin."

# Nettoyer le cache pacman (garder 3 versions)
echo " Nettoyage du cache pacman..."
sudo paccache -r

# Nettoyer le cache yay
echo " Nettoyage du cache yay..."
yay -Sc --noconfirm 2>/dev/null || echo "yay non disponible."

# Nettoyer les logs (garder 7 jours)
echo " Nettoyage des logs système..."
sudo journalctl --vacuum-time=7d

echo "✅ Nettoyage rapide terminé !"
