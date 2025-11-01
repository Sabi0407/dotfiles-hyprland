#!/bin/bash

# Script amélioré pour notifier l'utilisateur des niveaux de batterie
# Auteur: Amélioré par Assistant IA
# Version: 2.0

# Configuration par défaut
DEFAULT_WARNING_LEVELS=(20 15)
DEFAULT_CRITICAL_LEVELS=(10 5)
DEFAULT_ZENITY_LEVELS=(15 10 5)
CHARGE_NOTIFY_LEVELS=(90 100)
WARNING_LEVELS=("${DEFAULT_WARNING_LEVELS[@]}")
CRITICAL_LEVELS=("${DEFAULT_CRITICAL_LEVELS[@]}")
ZENITY_LEVELS=("${DEFAULT_ZENITY_LEVELS[@]}")
FULL_LEVEL=95
CHARGE_LEVELS=("${CHARGE_NOTIFY_LEVELS[@]}")
NOTIFICATION_COOLDOWN=300  # 5 minutes en secondes
CHECK_INTERVAL=60          # Vérification toutes les 60 secondes
LOG_FILE="/tmp/battery_notify.log"
ZENITY_THEME="catppuccin-mocha-red-standard+default"
ZENITY_MISSING_LOGGED=0

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

# Exécute zenity avec le thème Catppuccin et filtre les warnings GTK bruyants
run_zenity_theming() {
    if [ -n "$ZENITY_THEME" ]; then
        GTK_THEME="$ZENITY_THEME" zenity "$@" 2> >(grep -v "Adwaita-WARNING")
    else
        zenity "$@" 2> >(grep -v "Adwaita-WARNING")
    fi
}

# Vérifie si un niveau doit déclencher une alerte zenity persistante
should_show_zenity_alert() {
    local level=$1
    for zenity_level in "${ZENITY_LEVELS[@]}"; do
        if [ "$zenity_level" -eq "$level" ] 2>/dev/null; then
            return 0
        fi
    done
    return 1
}

# Lance une boîte de dialogue zenity persistante sans bloquer le script principal
trigger_zenity_alert() {
    local battery_name=$1
    local level=$2
    local capacity=$3
    local time_remaining=$4
    local alert_id="${battery_name}_zenity_${level}"
    local pid_file="/tmp/battery_notify_${alert_id}.pid"

    if ! command -v zenity >/dev/null 2>&1; then
        if [ "${ZENITY_MISSING_LOGGED:-0}" -eq 0 ]; then
            log_message "WARNING" "Zenity est introuvable: les alertes persistantes sont désactivées"
            ZENITY_MISSING_LOGGED=1
        fi
        return
    fi

    if [ -f "$pid_file" ]; then
        local existing_pid
        existing_pid=$(cat "$pid_file" 2>/dev/null)
        if [ -n "$existing_pid" ] && kill -0 "$existing_pid" 2>/dev/null; then
            return
        fi
        rm -f "$pid_file"
    fi

    log_message "INFO" "Déclenchement Zenity pour ${battery_name} à ${capacity}% (niveau ${level}%)"

    local severity="warning"
    for critical_level in "${CRITICAL_LEVELS[@]}"; do
        if [ "$critical_level" -eq "$level" ] 2>/dev/null; then
            severity="critical"
            break
        fi
    done

    local zenity_title="Batterie faible"
    [ "$severity" = "critical" ] && zenity_title="Batterie critique"

    local zenity_message="${capacity}% restant"

    (
        if ! GDK_BACKEND=wayland run_zenity_theming --warning \
            --title "${zenity_title}" \
            --text "${zenity_message}" \
            --ok-label "Compris" \
            --width=320 \
            --height=160 \
            --window-icon=dialog-warning; then
            log_message "ERROR" "Echec de la fenêtre Zenity (niveau ${level}%)"
        fi
    ) &
    local zenity_pid=$!
    echo "$zenity_pid" > "$pid_file"

    (
        wait "$zenity_pid" 2>/dev/null
        local status=$?
        if [ "$status" -eq 0 ]; then
            log_message "INFO" "Fenêtre Zenity fermée pour ${battery_name} (niveau ${level}%)"
        fi
        rm -f "$pid_file"
    ) &
}

# Fonction utilitaire pour afficher des listes de niveaux
format_levels() {
    local -n levels_ref=$1
    if [ ${#levels_ref[@]} -eq 0 ]; then
        echo "aucun"
        return
    fi
    local IFS=', '
    echo "${levels_ref[*]}"
}

format_levels_with_units() {
    local -n levels_ref=$1
    if [ ${#levels_ref[@]} -eq 0 ]; then
        echo "aucun"
        return
    fi
    local formatted=()
    for level in "${levels_ref[@]}"; do
        formatted+=("${level}%")
    done
    local IFS=', '
    echo "${formatted[*]}"
}

# Analyse une chaîne de niveaux séparés par des virgules et la stocke dans un tableau
parse_levels() {
    local input=$1
    local -n target_ref=$2
    target_ref=()

    IFS=',' read -ra raw_values <<< "$input"
    for value in "${raw_values[@]}"; do
        local cleaned=${value//[[:space:]]/}
        if [ -n "$cleaned" ]; then
            target_ref+=("$cleaned")
        fi
    done
}

# Trie les niveaux de la valeur la plus haute à la plus basse et supprime les doublons
normalize_levels() {
    local -n levels_ref=$1
    local normalized=()

    if [ ${#levels_ref[@]} -gt 0 ]; then
        while IFS= read -r level; do
            normalized+=("$level")
        done < <(printf '%s\n' "${levels_ref[@]}" | awk 'NF' | sort -nr | uniq)
    fi

    levels_ref=("${normalized[@]}")
}

# Valide que chaque niveau est un entier compris entre 1 et 100
validate_levels() {
    local -n levels_ref=$1
    local label=$2

    if [ ${#levels_ref[@]} -eq 0 ]; then
        echo "Erreur: Aucun niveau $label spécifié"
        exit 1
    fi

    for level in "${levels_ref[@]}"; do
        if ! [[ "$level" =~ ^[0-9]+$ ]] || [ "$level" -lt 1 ] || [ "$level" -gt 100 ]; then
            echo "Erreur: Le niveau $label '$level' doit être un nombre entre 1 et 100"
            exit 1
        fi
    done
}

# Vérifie qu'une valeur est un entier strictement positif
validate_positive_integer() {
    local value=$1
    local label=$2

    if ! [[ "$value" =~ ^[0-9]+$ ]] || [ "$value" -le 0 ]; then
        echo "Erreur: $label doit être un entier positif"
        exit 1
    fi
}

# Récupère le niveau le plus haut d'une liste
get_max_level() {
    local -n levels_ref=$1
    if [ ${#levels_ref[@]} -eq 0 ]; then
        echo 0
        return
    fi
    echo "${levels_ref[0]}"
}

# Récupère la dernière capacité connue pour une batterie
get_last_capacity() {
    local battery_name=$1
    local state_file="/tmp/battery_notify_${battery_name}_last_capacity"

    if [ -f "$state_file" ]; then
        local value=$(cat "$state_file" 2>/dev/null)
        if [[ "$value" =~ ^[0-9]+$ ]]; then
            echo "$value"
            return
        fi
    fi

    echo 101
}

# Met à jour la dernière capacité connue pour une batterie
update_last_capacity() {
    local battery_name=$1
    local capacity=$2
    local state_file="/tmp/battery_notify_${battery_name}_last_capacity"
    echo "$capacity" > "$state_file"
}

# Réinitialise la dernière capacité connue (lorsque la batterie est en charge)
reset_last_capacity() {
    local battery_name=$1
    local state_file="/tmp/battery_notify_${battery_name}_last_capacity"
    rm -f "$state_file"
}

# Détermine si un seuil vient d'être franchi vers le bas
crossed_threshold() {
    local last_capacity=$1
    local current_capacity=$2
    local threshold=$3

    if [ "$current_capacity" -le "$threshold" ] && [ "$last_capacity" -gt "$threshold" ]; then
        return 0
    fi
    return 1
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
    local battery_id=${5:-battery_notify}

    if command -v notify-send >/dev/null 2>&1; then
        notify-send \
            --app-name "Battery Monitor" \
            --urgency "$urgency" \
            --icon "$icon" \
            --expire-time=0 \
            --hint="string:x-dunst-stack-tag:${battery_id}" \
            "$title" "$message"
    else
        dunstify \
            -a "Battery Monitor" \
            -u "$urgency" \
            --stack-tag "${battery_id}" \
            "$title" "$message" \
            -i "$icon" \
            -t 3000
    fi

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
    
    # Mémoriser la dernière capacité pour détecter les franchissements de seuils
    local last_capacity=$(get_last_capacity "$battery_name")

    if [ "$status" = "Discharging" ]; then
        for level in "${CRITICAL_LEVELS[@]}"; do
            if crossed_threshold "$last_capacity" "$capacity" "$level"; then
                if check_cooldown "${battery_name}_critical_${level}"; then
                    send_notification "critical" "🚨 Batterie critique !" \
                        "Batterie à ${capacity}%" \
                        "battery-caution" "${battery_name}_critical_${level}"
                    if [ ${#ZENITY_LEVELS[@]} -gt 0 ] && should_show_zenity_alert "$level"; then
                        trigger_zenity_alert "$battery_name" "$level" "$capacity" ""
                    fi
                fi
            fi
        done

        for level in "${WARNING_LEVELS[@]}"; do
            if crossed_threshold "$last_capacity" "$capacity" "$level"; then
                if check_cooldown "${battery_name}_warning_${level}"; then
                    send_notification "normal" "⚠️ Batterie faible" \
                        "Batterie à ${capacity}%" \
                        "battery-low" "${battery_name}_warning_${level}"
                    if [ ${#ZENITY_LEVELS[@]} -gt 0 ] && should_show_zenity_alert "$level"; then
                        trigger_zenity_alert "$battery_name" "$level" "$capacity" ""
                    fi
                fi
            fi
        done

        update_last_capacity "$battery_name" "$capacity"
    else
        reset_last_capacity "$battery_name"

        if [ "$status" = "Charging" ]; then
            for level in "${CHARGE_LEVELS[@]}"; do
                if [ "$capacity" -ge "$level" ]; then
                    if check_cooldown "${battery_name}_charge_${level}"; then
                        send_notification "low" "🔋 Batterie en charge" \
                            "Batterie à ${capacity}%" \
                            "battery-good-charging" "${battery_name}_charge_${level}"
                    fi
                fi
            done
            if [ "$capacity" -ge "$FULL_LEVEL" ]; then
                if check_cooldown "${battery_name}_full"; then
                    send_notification "low" "🔋 Batterie chargée" \
                        "Batterie à ${capacity}%" \
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
    fi
}

# Fonction pour afficher l'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -w, --warning LEVELS   Niveaux d'avertissement (liste séparée par des virgules, défaut: $(format_levels DEFAULT_WARNING_LEVELS))"
    echo "  -c, --critical LEVELS  Niveaux critiques (liste séparée par des virgules, défaut: $(format_levels DEFAULT_CRITICAL_LEVELS))"
    echo "  -f, --full LEVEL       Niveau de charge complète (défaut: $FULL_LEVEL)"
    echo "  -l, --log FILE         Fichier de log (défaut: $LOG_FILE)"
    echo "  -i, --interval SECONDS Intervalle entre deux vérifications (défaut: $CHECK_INTERVAL)"
    echo "  -z, --zenity LEVELS    Niveaux pour alerte zenity persistante (défaut: $(format_levels DEFAULT_ZENITY_LEVELS), 'none' pour désactiver)"
    echo "      --no-zenity        Désactiver complètement les alertes zenity persistantes"
    echo "  -s, --status           Afficher le statut de toutes les batteries"
    echo "  -h, --help             Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0                     # Utiliser les paramètres par défaut"
    echo "  $0 -w 25,15 -c 10,5    # Avertissements à 25% et 15%, critiques à 10% et 5%"
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
            if [ -z "$2" ]; then
                echo "Erreur: --warning requiert une valeur"
                exit 1
            fi
            parse_levels "$2" WARNING_LEVELS
            normalize_levels WARNING_LEVELS
            shift 2
            ;;
        -c|--critical)
            if [ -z "$2" ]; then
                echo "Erreur: --critical requiert une valeur"
                exit 1
            fi
            parse_levels "$2" CRITICAL_LEVELS
            normalize_levels CRITICAL_LEVELS
            shift 2
            ;;
        -f|--full)
            FULL_LEVEL="$2"
            shift 2
            ;;
        -l|--log)
            LOG_FILE="$2"
            shift 2
            ;;
        -i|--interval)
            if [ -z "$2" ]; then
                echo "Erreur: --interval requiert une valeur"
                exit 1
            fi
            CHECK_INTERVAL="$2"
            shift 2
            ;;
        -z|--zenity)
            if [ -z "$2" ]; then
                echo "Erreur: --zenity requiert une valeur"
                exit 1
            fi
            if [ "$2" = "none" ]; then
                ZENITY_LEVELS=()
            else
                parse_levels "$2" ZENITY_LEVELS
                normalize_levels ZENITY_LEVELS
            fi
            shift 2
            ;;
        --no-zenity)
            ZENITY_LEVELS=()
            shift
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
normalize_levels WARNING_LEVELS
normalize_levels CRITICAL_LEVELS
normalize_levels ZENITY_LEVELS

validate_levels WARNING_LEVELS "d'avertissement"
validate_levels CRITICAL_LEVELS "critique"
if [ ${#ZENITY_LEVELS[@]} -gt 0 ]; then
    validate_levels ZENITY_LEVELS "pour Zenity"
fi

validate_levels CHARGE_LEVELS "de charge"

validate_positive_integer "$NOTIFICATION_COOLDOWN" "Le délai entre notifications"
validate_positive_integer "$CHECK_INTERVAL" "L'intervalle de vérification"

local_max_warning=$(get_max_level WARNING_LEVELS)
local_max_critical=$(get_max_level CRITICAL_LEVELS)

if [ "$local_max_warning" -le "$local_max_critical" ]; then
    echo "Erreur: Le niveau d'avertissement le plus élevé doit être supérieur au niveau critique le plus élevé"
    exit 1
fi

if ! [[ "$FULL_LEVEL" =~ ^[0-9]+$ ]] || [ "$FULL_LEVEL" -lt 1 ] || [ "$FULL_LEVEL" -gt 100 ]; then
    echo "Erreur: Le niveau de charge complète doit être un nombre entre 1 et 100"
    exit 1
fi

# Initialisation du log
log_message "INFO" "Démarrage du script de surveillance de batterie"
zenity_config="désactivé"
if [ ${#ZENITY_LEVELS[@]} -gt 0 ]; then
    zenity_config=$(format_levels_with_units ZENITY_LEVELS)
fi
log_message "INFO" "Configuration: Warning=$(format_levels_with_units WARNING_LEVELS) - Critical=$(format_levels_with_units CRITICAL_LEVELS) - Charge=$(format_levels_with_units CHARGE_LEVELS) - Full=${FULL_LEVEL}% - Cooldown=${NOTIFICATION_COOLDOWN}s - Interval=${CHECK_INTERVAL}s - Zenity=${zenity_config}"

trap 'log_message "INFO" "Arrêt du script de surveillance de batterie"; exit 0' SIGINT SIGTERM

while true; do
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

    sleep "$CHECK_INTERVAL"
done
