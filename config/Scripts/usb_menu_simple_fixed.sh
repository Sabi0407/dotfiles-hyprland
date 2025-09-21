#!/bin/bash

# Menu USB simplifié

get_usb_info() {
    # Chercher le premier disque USB monté
    local mounted=$(findmnt -t vfat,ntfs,ext4,ext3,ext2,exfat -o SOURCE,TARGET --noheadings 2>/dev/null | while read device mountpoint; do
        [[ "$device" =~ ^/dev/sd[a-z] ]] && udevadm info --name="${device%[0-9]*}" 2>/dev/null | grep -q "ID_BUS=usb" && echo "$device|$mountpoint" && break
    done)
    
    if [[ -n "$mounted" ]]; then
        echo "mounted|$mounted"
    else
        # Chercher un disque USB non monté
        for device in /dev/sd[a-z]; do
            [[ -b "$device" ]] && udevadm info --name="$device" 2>/dev/null | grep -q "ID_BUS=usb" && echo "unmounted|$device" && return
        done
        echo "none"
    fi
}

open_folder() {
    local folder="$1"
    [[ ! -d "$folder" || ! -r "$folder" ]] && folder="$HOME"
    
    for fm in thunar nautilus pcmanfm dolphin; do
        command -v "$fm" >/dev/null 2>&1 && { "$fm" "$folder" 2>/dev/null & return; }
    done
    zenity --error --title="Erreur" --text="Aucun gestionnaire de fichiers trouve" --width=300
}

show_menu() {
    local info=$(get_usb_info)
    IFS='|' read -r status device mountpoint <<< "$info"
    
    case "$status" in
        "mounted")
            if zenity --question --title="Disque USB" --text="Que veux-tu faire ?" --ok-label="Acceder" --cancel-label="Demonter" --width=300; then
                open_folder "$mountpoint"
            else
                udisksctl unmount -b "$device" 2>/dev/null && notify-send "USB" "Disque demonte !" -i drive-removable-media -t 3000
            fi
            ;;
        "unmounted")
            if zenity --question --title="Disque USB" --text="Disque non monte. Que faire ?" --ok-label="Monter" --cancel-label="Dossier home" --width=300; then
                if udisksctl mount -b "${device}1" 2>/dev/null; then
                    notify-send "USB" "Disque monte !" -i drive-removable-media -t 3000
                    sleep 1
                    local mp=$(findmnt -S "${device}1" -o TARGET --noheadings 2>/dev/null)
                    [[ -n "$mp" ]] && open_folder "$mp"
                fi
            else
                open_folder "$HOME"
            fi
            ;;
        *)
            zenity --info --title="USB" --text="Aucun disque USB detecte" --timeout=2 --width=200
            ;;
    esac
}

show_menu
