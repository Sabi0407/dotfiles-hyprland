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
ICON_PATH="/usr/share/icons/Papirus/32x32/apps/system-restart.svg"
[ -f "$ICON_PATH" ] || ICON_PATH="system-restart"
notify-send -a "reload-all" -i "$ICON_PATH" "Environnement recharge" "Hyprctl reload + Waybar, SwayNC et SwayOSD ont ete relances"

echo "Tous les composants ont ete recharges avec succes"
