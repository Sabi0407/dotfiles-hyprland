#!/bin/bash

# Wrapper pour appliquer le thème Catppuccin Mocha Red
run_zenity_dark() {
  # Appliquer le thème Catppuccin Mocha Red à Zenity
  GTK_THEME="catppuccin-mocha-red-standard+default" zenity "$@" 2> >(grep -v "Adwaita-WARNING")
}

# Seuils de notification
THRESHOLDS=(20 15 10 5 3)
# Fichier pour mémoriser le dernier seuil notifié
STATE_FILE="$HOME/.cache/battery_notify.last"

# Fonction pour obtenir le pourcentage batterie
get_battery() {
  cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1
}

# Fonction pour savoir si on est sur batterie
on_battery() {
  grep -q Discharging /sys/class/power_supply/BAT*/status 2>/dev/null
}

# Fonction pour savoir si on est en charge
on_charging() {
  grep -q Charging /sys/class/power_supply/BAT*/status 2>/dev/null
}

# Récupérer le dernier seuil notifié
LAST_NOTIFIED=100
[ -f "$STATE_FILE" ] && LAST_NOTIFIED=$(cat "$STATE_FILE")

while true; do
  CAPACITY=$(get_battery)
  
  # Vérifier que CAPACITY est un nombre valide
  if ! [[ "$CAPACITY" =~ ^[0-9]+$ ]]; then
    sleep 60
    continue
  fi
  
  if on_battery; then
    for TH in "${THRESHOLDS[@]}"; do
      if [ "$CAPACITY" -le "$TH" ] && [ "$LAST_NOTIFIED" -gt "$TH" ]; then
        case $TH in
          20)
            notify-send -u normal -i battery-low "🔋 Batterie faible" "Il reste $CAPACITY% de batterie\nPensez à brancher votre chargeur"
            ;;
          15)
            notify-send -u normal -i battery-caution "⚠️ Batterie faible" "Il reste $CAPACITY% de batterie\nBranchez votre chargeur rapidement"
            ;;
          10)
            # Utiliser zenity pour une alerte plus visible (forcer le thème sombre)
            run_zenity_dark --warning --title "Batterie très faible" --text "Il ne reste que $CAPACITY% de batterie !\n\nBranchez votre chargeur immédiatement" --window-icon=battery-low
            ;;
          5)
            # Utiliser zenity pour une alerte critique (forcer le thème sombre)
            run_zenity_dark --error --title "Batterie critique" --text "Il ne reste que $CAPACITY% de batterie !\n\nBRANCHEZ VOTRE CHARGEUR MAINTENANT !" --window-icon=battery-caution
            ;;
          3)
            # Utiliser zenity pour une alerte ultra critique (forcer le thème sombre)
            run_zenity_dark --error --title "Batterie ultra critique" --text "Seulement $CAPACITY% restants !\n\nArrêtez ou branchez immédiatement." --window-icon=battery-empty
            ;;
        esac
        echo "$TH" > "$STATE_FILE"
        LAST_NOTIFIED=$TH
        break
      fi
    done
  else
    # Si on recharge, reset le seuil
    if [ "$LAST_NOTIFIED" -lt 100 ]; then
      echo 100 > "$STATE_FILE"
      LAST_NOTIFIED=100
    fi
    # Notification batterie pleine à 79% si en charge
    if [ "$CAPACITY" -eq 79 ] && on_charging; then
      notify-send -u normal -i battery-full "✅ Batterie pleine" "Votre batterie est à $CAPACITY%\nVous pouvez débrancher votre chargeur"
  fi
  fi
  sleep 10
done 