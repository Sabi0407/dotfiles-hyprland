#!/bin/bash

# Script simplifié pour afficher les disques USB dans Waybar

get_usb_drives() {
    local total=0
    
    # Compter les disques USB (montés et non montés)
    for device in /dev/sd[a-z]; do
        [[ -b "$device" ]] && udevadm info --name="$device" 2>/dev/null | grep -q "ID_BUS=usb" && ((total++))
    done
    
    if [[ $total -eq 0 ]]; then
        echo '{"text": "", "tooltip": "Aucun disque USB détecté", "class": "no-usb"}'
    else
        local class="usb-connected"
        [[ $total -gt 3 ]] && class="usb-many"
        echo "{\"text\": \"󰋊 $total\", \"tooltip\": \"$total disque(s) USB connecté(s)\", \"class\": \"$class\"}"
    fi
}

get_usb_drives
