#!/bin/bash

# Script de gestion automatique du rétroéclairage clavier
# - Intégration hypridle pour économiser la batterie
# - Activation automatique 19h-8h (horaires nocturnes)
# - Gestion intelligente selon l'heure et l'activité

KBD_DEVICE="asus::kbd_backlight"
STATE_FILE="/tmp/kbd_backlight_auto_state"
SCHEDULE_STATE="/tmp/kbd_schedule_state"
LOG_FILE="/tmp/auto-backlight.log"

# Fonction de log
log_message() {
    echo "$(date '+%H:%M:%S') - $1" >> "$LOG_FILE"
}

# Vérifier si on est dans les heures nocturnes (19h-8h)
is_night_hours() {
    local hour=$(date +%H)
    # 19h-23h59 OU 0h-7h59
    if [ "$hour" -ge 19 ] || [ "$hour" -lt 8 ]; then
        return 0  # Nuit
    else
        return 1  # Jour
    fi
}

# Obtenir le niveau par défaut selon l'heure
get_default_level() {
    if is_night_hours; then
        echo "1"  # Niveau par défaut la nuit
    else
        echo "0"  # Éteint le jour
    fi
}

# Fonctions de contrôle manuel (compatibilité backlight_setup.sh)
manual_up() {
    local current=$(brightnessctl -d "$KBD_DEVICE" get 2>/dev/null || echo "0")
    local max=$(brightnessctl -d "$KBD_DEVICE" max 2>/dev/null || echo "3")
    local new_level=$((current + 1))
    if [ $new_level -gt $max ]; then
        new_level=$max
    fi
    brightnessctl -d "$KBD_DEVICE" set "$new_level" >/dev/null 2>&1
    log_message "Contrôle manuel UP: $current → $new_level"
}

manual_down() {
    local current=$(brightnessctl -d "$KBD_DEVICE" get 2>/dev/null || echo "0")
    local new_level=$((current - 1))
    if [ $new_level -lt 0 ]; then
        new_level=0
    fi
    brightnessctl -d "$KBD_DEVICE" set "$new_level" >/dev/null 2>&1
    log_message "Contrôle manuel DOWN: $current → $new_level"
}

manual_toggle() {
    local current=$(brightnessctl -d "$KBD_DEVICE" get 2>/dev/null || echo "0")
    if [ "$current" -eq 0 ]; then
        brightnessctl -d "$KBD_DEVICE" set 1 >/dev/null 2>&1
        log_message "Contrôle manuel TOGGLE: OFF → ON (1)"
    else
        brightnessctl -d "$KBD_DEVICE" set 0 >/dev/null 2>&1
        log_message "Contrôle manuel TOGGLE: ON ($current) → OFF"
    fi
}

manual_cycle() {
    local current=$(brightnessctl -d "$KBD_DEVICE" get 2>/dev/null || echo "0")
    local max=$(brightnessctl -d "$KBD_DEVICE" max 2>/dev/null || echo "3")
    local levels=(0 1 2 3)
    local next_level=1
    
    for i in "${!levels[@]}"; do
        if [ "$current" -eq "${levels[$i]}" ]; then
            next_level=${levels[$((i + 1))]}
            if [ -z "$next_level" ]; then
                next_level=${levels[0]}
            fi
            break
        fi
    done
    
    brightnessctl -d "$KBD_DEVICE" set "$next_level" >/dev/null 2>&1
    log_message "Contrôle manuel CYCLE: $current → $next_level"
}

# Sauvegarder l'état actuel du rétroéclairage
save_current_state() {
    local current=$(brightnessctl -d "$KBD_DEVICE" get 2>/dev/null || echo "0")
    if [ "$current" -gt 0 ]; then
        echo "$current" > "$STATE_FILE"
        log_message "État sauvegardé: $current"
        return 0
    fi
    return 1
}

# Éteindre le rétroéclairage (inactivité)
turn_off() {
    # Ne pas éteindre pendant les heures de jour (déjà éteint normalement)
    if ! is_night_hours; then
        log_message "Inactivité détectée mais heures de jour - pas d'action"
        return
    fi
    
    log_message "Inactivité détectée (nuit) - extinction du rétroéclairage"
    
    # Sauvegarder seulement si le rétroéclairage est allumé
    if save_current_state; then
        brightnessctl -d "$KBD_DEVICE" set 0 >/dev/null 2>&1
        log_message "Rétroéclairage éteint"
    else
        log_message "Rétroéclairage déjà éteint"
    fi
}

# Rallumer le rétroéclairage (activité)
turn_on() {
    # Vérifier si on est dans les heures nocturnes
    if ! is_night_hours; then
        log_message "Activité détectée mais heures de jour - rétroéclairage reste éteint"
        return
    fi
    
    log_message "Activité détectée (nuit) - rallumage du rétroéclairage"
    
    if [ -f "$STATE_FILE" ]; then
        local saved_level=$(cat "$STATE_FILE")
        brightnessctl -d "$KBD_DEVICE" set "$saved_level" >/dev/null 2>&1
        rm -f "$STATE_FILE"
        log_message "Rétroéclairage restauré: $saved_level"
    else
        # Niveau par défaut selon l'heure
        local default_level=$(get_default_level)
        brightnessctl -d "$KBD_DEVICE" set "$default_level" >/dev/null 2>&1
        log_message "Rétroéclairage activé (niveau par défaut: $default_level)"
    fi
}

# Gestion horaire automatique (19h activation, 8h extinction)
schedule_check() {
    local hour=$(date +%H)
    local current=$(brightnessctl -d "$KBD_DEVICE" get 2>/dev/null || echo "0")
    
    if is_night_hours; then
        # Heures nocturnes (19h-8h) : activer si éteint
        if [ "$current" -eq 0 ]; then
            brightnessctl -d "$KBD_DEVICE" set 1 >/dev/null 2>&1
            log_message "Activation horaire nocturne (${hour}h)"
        fi
    else
        # Heures diurnes (8h-19h) : éteindre si allumé
        if [ "$current" -gt 0 ]; then
            echo "$current" > "$SCHEDULE_STATE"  # Sauvegarder pour le soir
            brightnessctl -d "$KBD_DEVICE" set 0 >/dev/null 2>&1
            log_message "Extinction horaire diurne (${hour}h) - niveau sauvé: $current"
        fi
    fi
}

# Vérifier le statut
status() {
    local current=$(brightnessctl -d "$KBD_DEVICE" get 2>/dev/null || echo "0")
    local hour=$(date +%H)
    local period="jour"
    is_night_hours && period="nuit"
    
    if [ "$current" -gt 0 ]; then
        echo "on ($current) - ${hour}h ($period)"
    else
        echo "off - ${hour}h ($period)"
    fi
}

# Actions selon le paramètre
case "${1:-}" in
    "off"|"idle")
        turn_off
        ;;
    "on"|"active")
        turn_on
        ;;
    "up")
        manual_up
        ;;
    "down")
        manual_down
        ;;
    "toggle")
        manual_toggle
        ;;
    "cycle")
        manual_cycle
        ;;
    "schedule"|"check")
        schedule_check
        ;;
    "status")
        status
        ;;
    "log")
        [ -f "$LOG_FILE" ] && tail -20 "$LOG_FILE" || echo "Pas de log disponible"
        ;;
    *)
        echo "Usage: $0 {off|on|up|down|toggle|cycle|schedule|status|log}"
        echo "  off/idle   - Éteindre le rétroéclairage (inactivité)"
        echo "  on/active  - Rallumer le rétroéclairage (activité)"
        echo "  up         - Augmenter le niveau (+1)"
        echo "  down       - Diminuer le niveau (-1)"
        echo "  toggle     - Basculer ON/OFF"
        echo "  cycle      - Cycler entre les niveaux (0→1→2→3→0)"
        echo "  schedule   - Vérification horaire (19h-8h)"
        echo "  status     - Afficher l'état actuel avec heure"
        echo "  log        - Afficher les derniers logs"
        exit 1
        ;;
esac
