#!/bin/bash
# Script pour recharger tous les composants de l'environnement Hyprland

# Recharger Hyprland
echo "Rechargement de Hyprland..."
hyprctl reload

# Redemarrer Waybar
echo "Redemarrage de Waybar..."
killall waybar 2>/dev/null
sleep 0.3
waybar &

# Redemarrer SwayNC
echo "Redemarrage de SwayNC..."
killall swaync 2>/dev/null
sleep 0.3
swaync &

# Notification de confirmation
notify-send "Environnement recharge" "Hyprland, Waybar et SwayNC ont ete recharges" -i system-restart

echo "Tous les composants ont ete recharges avec succes"

