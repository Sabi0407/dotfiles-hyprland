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

# Redemarrer SwayOSD
echo "Redemarrage de SwayOSD..."
systemctl --user restart swayosd.service

# Notification de confirmation
notify-send "Environnement recharge" "Hyprctl reload + Waybar, SwayNC et SwayOSD ont ete relances" -i system-restart

echo "Tous les composants ont ete recharges avec succes"
