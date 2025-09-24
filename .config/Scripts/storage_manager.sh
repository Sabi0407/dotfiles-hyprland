#!/bin/bash

# Script pour gérer les périphériques de stockage dans Waybar
# Affiche les disques montés et permet de les ouvrir ou démonter

# Fonction pour obtenir les disques externes (montés et non montés)
get_external_disks() {
    # Obtenir tous les disques externes (exclure seulement le disque système nvme0n1)
    lsblk -o NAME,TYPE,SIZE,MODEL | awk '
    NR>1 && $2 == "disk" && $1 !~ /^nvme0n1$/ {
        # Inclure tous les disques sda, sdb, etc. (disques externes typiques)
        if ($1 ~ /^sd[a-z]$/) {
            print $1
        }
    }' | head -5
}

# Fonction pour obtenir les disques montés (excluant les partitions système)
get_mounted_disks() {
    # Lister les disques externes montés uniquement (exclure les disques système)
    df -h | awk 'NR>1 && !/\/dev\/loop/ && $1 ~ /^\/dev\/sd[a-z]/ && $6 !~ /^\/$/ && $6 !~ /^\/boot$/ && $6 !~ /^\/home$/ {print $1 "|" $6 "|" $3 "|" $5}' | head -5
}

# Fonction pour le format Waybar
format_for_waybar() {
    local mounted_disks=$(get_mounted_disks)
    local external_disks=$(get_external_disks)

    # Compter les disques
    local mounted_count=0
    local external_count=0

    if [ -n "$mounted_disks" ]; then
        mounted_count=$(echo "$mounted_disks" | wc -l)
    fi

    if [ -n "$external_disks" ]; then
        external_count=$(echo "$external_disks" | wc -l)
    fi

    if [ $external_count -eq 0 ]; then
        # Aucun disque externe détecté - faire disparaître le module complètement
        echo ''
        return
    fi

    local text="󰋊"
    local tooltip="Périphériques externes:\\n"

    # Ajouter les disques montés
    if [ $mounted_count -gt 0 ]; then
        while IFS='|' read -r device mountpoint size used; do
            local disk_name=$(basename "$device")
            tooltip+="[MONTÉ] $disk_name: $size ($used utilisé)\\n  Monté sur: $mountpoint\\n"
        done <<< "$mounted_disks"
    fi

    # Ajouter les disques non montés
    if [ $external_count -gt $mounted_count ]; then
        while IFS= read -r device; do
            if ! echo "$mounted_disks" | grep -q "$device"; then
                tooltip+="[NON MONTÉ] $device\\n"
            fi
        done <<< "$external_disks"
    fi

    # Affichage principal
    if [ $mounted_count -eq 1 ] && [ $external_count -eq 1 ]; then
        # Un seul disque, monté
        local first_disk=$(echo "$mounted_disks" | head -1)
        IFS='|' read -r device mountpoint size used <<< "$first_disk"
        local disk_name=$(basename "$device")
        echo "{\"text\": \"$text $disk_name\", \"tooltip\": \"${tooltip}\", \"class\": \"connected\"}"
    elif [ $mounted_count -gt 0 ]; then
        # Certains disques montés
        echo "{\"text\": \"$text $mounted_count/$external_count\", \"tooltip\": \"${tooltip}\", \"class\": \"connected\"}"
    else
        # Aucun disque monté mais disques détectés
        echo "{\"text\": \"$text $external_count disques\", \"tooltip\": \"${tooltip}\", \"class\": \"disconnected\"}"
    fi
}

# Fonction pour ouvrir le dossier avec Thunar
open_disk() {
    local disk_path="$1"
    if [ -d "$disk_path" ]; then
        thunar "$disk_path" &
    fi
}

# Fonction pour démonter/monter un disque avec notification
toggle_mount() {
    local device="$1"
    local mountpoint="$2"
    local disk_name=$(basename "$device")

    if mount | grep -q "$device"; then
        # Le disque est monté, le démonter
        if udisksctl unmount -b "$device" 2>/dev/null; then
            notify-send "Stockage" "Disque $disk_name démonté" -i drive-harddisk
        else
            notify-send "Stockage" "Erreur lors du démontage de $disk_name" -i error
        fi
    else
        # Le disque n'est pas monté, essayer de le monter
        if udisksctl mount -b "$device" 2>/dev/null; then
            notify-send "Stockage" "Disque $disk_name monté automatiquement" -i drive-harddisk
        else
            # Essayer avec pkexec (PolicyKit) pour les permissions graphiques
            if command -v pkexec >/dev/null 2>&1; then
                if pkexec mount "$device" "/run/media/$(whoami)/$disk_name" 2>/dev/null; then
                    notify-send "Stockage" "Disque $disk_name monté avec PolicyKit" -i drive-harddisk
                else
                    notify-send "Stockage" "Impossible de monter $disk_name (droits insuffisants)" -i error
                fi
            else
                # Fallback : informer l'utilisateur
                notify-send "Stockage" "Montage manuel requis pour $disk_name" -i dialog-warning
                notify-send "Stockage" "Commande: sudo mount $device /run/media/$(whoami)/$disk_name" -i dialog-information
            fi
        fi
    fi
}

# Gestion des arguments
case "$1" in
    "open")
        # Ouvrir le premier disque monté
        first_disk=$(get_mounted_disks | head -1)
        if [ -n "$first_disk" ]; then
            IFS='|' read -r device mountpoint size used <<< "$first_disk"
            open_disk "$mountpoint"
        fi
        ;;
    "toggle")
        # Basculer le montage du premier disque (monté ou non)
        mounted_disk=$(get_mounted_disks | head -1)
        external_disk=$(get_external_disks | head -1)

        if [ -n "$mounted_disk" ]; then
            # Il y a un disque monté, le démonter
            IFS='|' read -r device mountpoint size used <<< "$mounted_disk"
            toggle_mount "$device" "$mountpoint"
        elif [ -n "$external_disk" ]; then
            # Il n'y a pas de disque monté mais des disques détectés, monter le premier
            toggle_mount "/dev/$external_disk" ""
        fi
        ;;
    *)
        # Affichage par défaut pour Waybar
        format_for_waybar
        ;;
esac
