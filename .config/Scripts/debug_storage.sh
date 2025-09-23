#!/bin/bash
echo "Test de debug:"
disks=$(df -h | awk 'NR>1 && !/\/dev\/loop/ && $1 ~ /^\/dev\/sd[b-z]/ {print $1 "|" $6 "|" $3 "|" $5}' | head -5)
echo "Disques trouvés: '$disks'"
count=$(echo "$disks" | wc -l)
echo "Nombre de disques: $count"

if [ $count -eq 0 ]; then
    echo "Aucun disque externe détecté"
else
    echo "Premier disque:"
    first_disk=$(echo "$disks" | head -1)
    echo "Raw: '$first_disk'"
    IFS='|' read -r device mountpoint size used <<< "$first_disk"
    echo "Device: '$device'"
    echo "Mountpoint: '$mountpoint'"
    echo "Size: '$size'"
    echo "Used: '$used'"
fi
