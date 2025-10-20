#!/bin/bash

# Script amélioré pour notifier l'utilisateur des niveaux de batterie
# Auteur: Amélioré par Assistant IA
# Version: 2.0

# Configuration par défaut
WARNING_LEVEL=20
CRITICAL_LEVEL=10
FULL_LEVEL=95
NOTIFICATION_COOLDOWN=300  # 5 minutes en secondes
LOG_FILE="/tmp/battery_notify.log"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction de logging
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

# Fonction pour vérifier si une notification a été envoyée récemment
check_cooldown() {
    local battery_id=$1
    local cooldown_file="/tmp/battery_notify_${battery_id}_cooldown"
    
    if [ -f "$cooldown_file" ]; then
        local last_notification=$(cat "$cooldown_file")
        local current_time=$(date +%s)
        local time_diff=$((current_time - last_notification))
        
        if [ $time_diff -lt $NOTIFICATION_COOLDOWN ]; then
            return 1  # Cooldown actif
        fi
    fi
    return 0  # Pas de cooldown
}

# Fonction pour mettre à jour le cooldown
update_cooldown() {
    local battery_id=$1
    local cooldown_file="/tmp/battery_notify_${battery_id}_cooldown"
    echo $(date +%s) > "$cooldown_file"
}

# Fonction pour obtenir les informations de batterie
get_battery_info() {
    local battery_path=$1
    local capacity_file="${battery_path}/capacity"
    local status_file="${battery_path}/status"
    local energy_now_file="${battery_path}/energy_now"
    local energy_full_file="${battery_path}/energy_full"
    local power_now_file="${battery_path}/power_now"
    
    if [ ! -f "$capacity_file" ] || [ ! -f "$status_file" ]; then
        return 1
    fi
    
    local capacity=$(cat "$capacity_file" 2>/dev/null || echo "0")
    local status=$(cat "$status_file" 2>/dev/null || echo "Unknown")
    local energy_now=$(cat "$energy_now_file" 2>/dev/null || echo "0")
    local energy_full=$(cat "$energy_full_file" 2>/dev/null || echo "1")
    local power_now=$(cat "$power_now_file" 2>/dev/null || echo "0")
    
    # Calculer le temps restant approximatif
    local time_remaining=""
    if [ "$status" = "Discharging" ] && [ "$power_now" -gt 0 ]; then
        local energy_remaining=$((energy_now - energy_full * capacity / 100))
        local hours=$((energy_remaining / power_now))
        local minutes=$(((energy_remaining % power_now) * 60 / power_now))
        time_remaining="${hours}h ${minutes}m"
    elif [ "$status" = "Charging" ] && [ "$power_now" -gt 0 ]; then
        local energy_needed=$((energy_full - energy_now))
        local hours=$((energy_needed / power_now))
        local minutes=$(((energy_needed % power_now) * 60 / power_now))
        time_remaining="${hours}h ${minutes}m"
    fi
    
    echo "$capacity|$status|$time_remaining"
}

# Fonction pour envoyer une notification
send_notification() {
    local urgency=$1
    local title=$2
    local message=$3
    local icon=$4
    local battery_id=$5
    
    dunstify -u "$urgency" "$title" "$message" -i "$icon" -t 10000
    log_message "NOTIFY" "Notification envoyée: $title - $message"
    update_cooldown "$battery_id"
}

# Fonction principale pour traiter une batterie
process_battery() {
    local battery_path=$1
    local battery_name=$(basename "$battery_path")
    
    log_message "INFO" "Traitement de la batterie: $battery_name"
    
    # Obtenir les informations de la batterie
    local battery_info=$(get_battery_info "$battery_path")
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Impossible de lire les informations de la batterie $battery_name"
        return 1
    fi
    
    IFS='|' read -r capacity status time_remaining <<< "$battery_info"
    
    log_message "INFO" "Batterie $battery_name: ${capacity}% - $status"
    
    # Vérifier les différents niveaux
    if [ "$status" = "Discharging" ]; then
        if [ "$capacity" -le "$CRITICAL_LEVEL" ]; then
            if check_cooldown "${battery_name}_critical"; then
                send_notification "critical" "🚨 Batterie critique !" \
                    "Batterie à ${capacity}%${time_remaining:+ (${time_remaining} restant)}" \
                    "battery-caution" "${battery_name}_critical"
            fi
        elif [ "$capacity" -le "$WARNING_LEVEL" ]; then
            if check_cooldown "${battery_name}_warning"; then
                send_notification "normal" "⚠️ Batterie faible" \
                    "Batterie à ${capacity}%${time_remaining:+ (${time_remaining} restant)}" \
                    "battery-low" "${battery_name}_warning"
            fi
        fi
    elif [ "$status" = "Charging" ]; then
        if [ "$capacity" -ge "$FULL_LEVEL" ]; then
            if check_cooldown "${battery_name}_full"; then
                send_notification "low" "🔋 Batterie chargée" \
                    "Batterie à ${capacity}%${time_remaining:+ (${time_remaining} pour charger)}" \
                    "battery-full" "${battery_name}_full"
            fi
        fi
    elif [ "$status" = "Full" ]; then
        if check_cooldown "${battery_name}_full"; then
            send_notification "low" "🔋 Batterie pleine" \
                "Batterie complètement chargée" \
                "battery-full" "${battery_name}_full"
        fi
    fi
}

# Fonction pour afficher l'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -w, --warning LEVEL    Niveau d'avertissement (défaut: $WARNING_LEVEL)"
    echo "  -c, --critical LEVEL   Niveau critique (défaut: $CRITICAL_LEVEL)"
    echo "  -f, --full LEVEL       Niveau de charge complète (défaut: $FULL_LEVEL)"
    echo "  -t, --timeout SECONDS  Délai entre notifications (défaut: $NOTIFICATION_COOLDOWN)"
    echo "  -l, --log FILE         Fichier de log (défaut: $LOG_FILE)"
    echo "  -s, --status           Afficher le statut de toutes les batteries"
    echo "  -h, --help             Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0                     # Utiliser les paramètres par défaut"
    echo "  $0 -w 25 -c 15         # Avertissement à 25%, critique à 15%"
    echo "  $0 -s                  # Afficher le statut des batteries"
}

# Fonction pour afficher le statut
show_status() {
    echo -e "${BLUE}=== Statut des batteries ===${NC}"
    
    for battery_path in /sys/class/power_supply/BAT*; do
        if [ -d "$battery_path" ]; then
            local battery_name=$(basename "$battery_path")
            local battery_info=$(get_battery_info "$battery_path")
            
            if [ $? -eq 0 ]; then
                IFS='|' read -r capacity status time_remaining <<< "$battery_info"
                echo -e "${GREEN}$battery_name:${NC} ${capacity}% - $status${time_remaining:+ (${time_remaining})}"
            else
                echo -e "${RED}$battery_name:${NC} Erreur de lecture"
            fi
        fi
    done
}

# Traitement des arguments de ligne de commande
while [[ $# -gt 0 ]]; do
    case $1 in
        -w|--warning)
            WARNING_LEVEL="$2"
            shift 2
            ;;
        -c|--critical)
            CRITICAL_LEVEL="$2"
            shift 2
            ;;
        -f|--full)
            FULL_LEVEL="$2"
            shift 2
            ;;
        -t|--timeout)
            NOTIFICATION_COOLDOWN="$2"
            shift 2
            ;;
        -l|--log)
            LOG_FILE="$2"
            shift 2
            ;;
        -s|--status)
            show_status
            exit 0
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validation des paramètres
if ! [[ "$WARNING_LEVEL" =~ ^[0-9]+$ ]] || [ "$WARNING_LEVEL" -lt 1 ] || [ "$WARNING_LEVEL" -gt 100 ]; then
    echo "Erreur: Le niveau d'avertissement doit être un nombre entre 1 et 100"
    exit 1
fi

if ! [[ "$CRITICAL_LEVEL" =~ ^[0-9]+$ ]] || [ "$CRITICAL_LEVEL" -lt 1 ] || [ "$CRITICAL_LEVEL" -gt 100 ]; then
    echo "Erreur: Le niveau critique doit être un nombre entre 1 et 100"
    exit 1
fi

if ! [[ "$FULL_LEVEL" =~ ^[0-9]+$ ]] || [ "$FULL_LEVEL" -lt 1 ] || [ "$FULL_LEVEL" -gt 100 ]; then
    echo "Erreur: Le niveau de charge complète doit être un nombre entre 1 et 100"
    exit 1
fi

if [ "$WARNING_LEVEL" -le "$CRITICAL_LEVEL" ]; then
    echo "Erreur: Le niveau d'avertissement doit être supérieur au niveau critique"
    exit 1
fi

# Initialisation du log
log_message "INFO" "Démarrage du script de surveillance de batterie"
log_message "INFO" "Configuration: Warning=$WARNING_LEVEL%, Critical=$CRITICAL_LEVEL%, Full=$FULL_LEVEL%"

# Traitement de toutes les batteries
battery_found=false
for battery_path in /sys/class/power_supply/BAT*; do
    if [ -d "$battery_path" ]; then
        battery_found=true
        process_battery "$battery_path"
    fi
done

if [ "$battery_found" = false ]; then
    log_message "WARNING" "Aucune batterie trouvée dans /sys/class/power_supply/"
    echo "Aucune batterie trouvée sur ce système"
    exit 1
fi

log_message "INFO" "Script terminé"