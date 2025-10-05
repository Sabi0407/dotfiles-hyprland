#!/bin/bash
# Script de nettoyage système - Suppression des dépendances inutiles

echo "🧹 Nettoyage du système - Suppression des dépendances inutiles"
echo "================================================================"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher avec couleur
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

# 1. Lister les paquets orphelins (dépendances inutiles)
print_status "Recherche des paquets orphelins..."
ORPHANS=$(pacman -Qtdq)

if [ -z "$ORPHANS" ]; then
    print_success "Aucun paquet orphelin trouvé !"
else
    echo "Paquets orphelins trouvés :"
    echo "$ORPHANS"
    echo ""
    read -p "Voulez-vous supprimer ces paquets orphelins ? (o/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        print_status "Suppression des paquets orphelins..."
        sudo pacman -Rns $(pacman -Qtdq)
        print_success "Paquets orphelins supprimés !"
    else
        print_warning "Suppression annulée."
    fi
fi

echo ""

# 2. Nettoyer le cache pacman
print_status "Nettoyage du cache pacman..."
CACHE_SIZE_BEFORE=$(du -sh /var/cache/pacman/pkg/ | cut -f1)
print_status "Taille du cache avant : $CACHE_SIZE_BEFORE"

read -p "Voulez-vous nettoyer le cache pacman ? (o/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Oo]$ ]]; then
    # Garder seulement les 3 dernières versions
    sudo paccache -r
    # Supprimer les paquets désinstallés du cache
    sudo paccache -ruk0
    
    CACHE_SIZE_AFTER=$(du -sh /var/cache/pacman/pkg/ | cut -f1)
    print_success "Cache nettoyé ! Taille après : $CACHE_SIZE_AFTER"
else
    print_warning "Nettoyage du cache annulé."
fi

echo ""

# 3. Nettoyer le cache yay
print_status "Nettoyage du cache yay..."
if command -v yay &> /dev/null; then
    YAY_CACHE_SIZE_BEFORE=$(du -sh ~/.cache/yay/ 2>/dev/null | cut -f1 || echo "0")
    print_status "Taille du cache yay avant : $YAY_CACHE_SIZE_BEFORE"
    
    read -p "Voulez-vous nettoyer le cache yay ? (o/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        yay -Sc --noconfirm
        print_success "Cache yay nettoyé !"
    else
        print_warning "Nettoyage du cache yay annulé."
    fi
else
    print_warning "yay n'est pas installé."
fi

echo ""

# 4. Nettoyer les logs système (optionnel)
print_status "Nettoyage des logs système..."
JOURNAL_SIZE=$(journalctl --disk-usage | grep -o '[0-9.]*[KMGT]B')
print_status "Taille des logs système : $JOURNAL_SIZE"

read -p "Voulez-vous nettoyer les logs de plus de 7 jours ? (o/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Oo]$ ]]; then
    sudo journalctl --vacuum-time=7d
    print_success "Logs anciens supprimés !"
else
    print_warning "Nettoyage des logs annulé."
fi

echo ""

# 5. Résumé final
print_status "Résumé du nettoyage :"
echo "- Paquets orphelins : vérifiés"
echo "- Cache pacman : traité"
echo "- Cache yay : traité"
echo "- Logs système : traités"

print_success "Nettoyage terminé !"

# 6. Afficher l'espace disque libéré
echo ""
print_status "Espace disque actuel :"
df -h / | tail -1
