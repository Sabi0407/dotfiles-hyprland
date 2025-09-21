#!/bin/bash

# Surveillance USB simplifiée

USB_STATE_FILE="/tmp/usb_state"

get_usb_list() {
    for device in /dev/sd[a-z]; do
        [[ -b "$device" ]] && udevadm info --name="$device" 2>/dev/null | grep -q "ID_BUS=usb" && echo "$device"
    done
}

notify_usb() {
    DISPLAY=:0 notify-send "$1" "$2" -i drive-removable-media -t 4000 2>/dev/null
}

monitor_usb() {
    local current previous current_count previous_count
    
    current=$(get_usb_list | sort)
    current_count=$(echo "$current" | wc -l)
    [[ -z "$current" ]] && current_count=0
    
    if [[ -f "$USB_STATE_FILE" ]]; then
        previous=$(cat "$USB_STATE_FILE" | sort)
        previous_count=$(echo "$previous" | wc -l)
        [[ -z "$previous" ]] && previous_count=0
    else
        echo "$current" > "$USB_STATE_FILE"
        return
    fi
    
    if [[ $current_count -gt $previous_count ]]; then
        notify_usb "Disque USB branche" "Nouveau disque detecte"
    elif [[ $current_count -lt $previous_count ]]; then
        notify_usb "Disque USB debranche" "Disque retire"
    fi
    
    echo "$current" > "$USB_STATE_FILE"
}

case "${1:-}" in
    "start")
        echo "Démarrage surveillance USB..."
        get_usb_list > "$USB_STATE_FILE"
        while true; do monitor_usb; sleep 3; done &
        echo "Surveillance démarrée"
        ;;
    "stop")
        pkill -f "usb_notification.sh"
        rm -f "$USB_STATE_FILE"
        echo "Surveillance arrêtée"
        ;;
    "check")
        monitor_usb
        ;;
    *)
        echo "Usage: $0 {start|stop|check}"
        ;;
esac
