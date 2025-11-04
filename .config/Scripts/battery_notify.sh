#!/bin/bash

# Script amélioré pour notifier l'utilisateur des niveaux de batterie
# Auteur: Amélioré par Assistant IA
# Version: 2.0

# Configuration par défaut
DEFAULT_WARNING_LEVELS=(20 15)
DEFAULT_CRITICAL_LEVELS=(10 5)
DEFAULT_ZENITY_LEVELS=(10 5)
CHARGE_NOTIFY_LEVELS=(80)
WARNING_LEVELS=("${DEFAULT_WARNING_LEVELS[@]}")
CRITICAL_LEVELS=("${DEFAULT_CRITICAL_LEVELS[@]}")
ZENITY_LEVELS=("${DEFAULT_ZENITY_LEVELS[@]}")
FULL_LEVEL=95
CHARGE_LEVELS=("${CHARGE_NOTIFY_LEVELS[@]}")
NOTIFICATION_COOLDOWN=300  # 5 minutes en secondes
CHECK_INTERVAL=60          # Vérification toutes les 60 secondes
ZENITY_THEME="catppuccin-mocha-red-standard+default"
ZENITY_MISSING_LOGGED=0

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
        [ "${ZENITY_MISSING_LOGGED:-0}" -eq 0 ] && ZENITY_MISSING_LOGGED=1
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

    GDK_BACKEND=wayland run_zenity_theming --warning \
        --title "${zenity_title}" \
        --text "${zenity_message}" \
        --ok-label "Compris" \
        --width=320 \
        --height=160 \
        --window-icon=dialog-warning &
    local zenity_pid=$!
    echo "$zenity_pid" > "$pid_file"

    (
        wait "$zenity_pid" 2>/dev/null
        local status=$?
        :
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

# Gestion des rappels de charge
get_last_charge_level() {
    local battery_name=$1
    local state_file="/tmp/battery_notify_${battery_name}_last_charge"

    if [ -f "$state_file" ]; then
        local value
        value=$(cat "$state_file" 2>/dev/null)
        if [[ "$value" =~ ^[0-9]+$ ]]; then
            echo "$value"
            return
        fi
    fi

    echo 0
}

update_last_charge_level() {
    local battery_name=$1
    local level=$2
    local state_file="/tmp/battery_notify_${battery_name}_last_charge"
    echo "$level" > "$state_file"
}

reset_last_charge_level() {
    local battery_name=$1
    local state_file="/tmp/battery_notify_${battery_name}_last_charge"
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

    update_cooldown "$battery_id"
}

# Fonction principale pour traiter une batterie
process_battery() {
    local battery_path=$1
    local battery_name=$(basename "$battery_path")
    
    # Obtenir les informations de la batterie
    local battery_info=$(get_battery_info "$battery_path")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    IFS='|' read -r capacity status time_remaining <<< "$battery_info"
    # Mémoriser la dernière capacité pour détecter les franchissements de seuils
    local last_capacity=$(get_last_capacity "$battery_name")
    local last_charge_level=$(get_last_charge_level "$battery_name")

    if [ "$status" = "Discharging" ]; then
        for level in "${CRITICAL_LEVELS[@]}"; do
            if crossed_threshold "$last_capacity" "$capacity" "$level"; then
                local cooldown_id="${battery_name}_critical_${level}"
                if check_cooldown "$cooldown_id"; then
                    local suppress_notify=false
                    if [ "$level" -eq 10 ]; then
                        suppress_notify=true
                    fi
                    if [ "$suppress_notify" = false ]; then
                        send_notification "critical" "🚨 Batterie critique !" \
                            "Batterie à ${capacity}%" \
                            "battery-caution" "$cooldown_id"
                    else
                        log_message "INFO" "Seuil ${level}% atteint pour ${battery_name} (notification standard ignorée, Zenity uniquement)"
                        update_cooldown "$cooldown_id"
                    fi
                    if [ ${#ZENITY_LEVELS[@]} -gt 0 ] && should_show_zenity_alert "$level"; then
                        trigger_zenity_alert "$battery_name" "$level" "$capacity" ""
                    fi
                fi
            fi
        done

        for level in "${WARNING_LEVELS[@]}"; do
            if crossed_threshold "$last_capacity" "$capacity" "$level"; then
                if check_cooldown "${battery_name}_warning_${level}"; then
                    local warning_title="⚠️ Batterie faible"
                    local warning_message="Batterie à ${capacity}%"
                    if [ "$level" -eq 15 ]; then
                        warning_message="Branche le chargeur (batterie à ${capacity}%)"
                    fi
                    send_notification "normal" "$warning_title" \
                        "$warning_message" \
                        "battery-low" "${battery_name}_warning_${level}"
                    if [ ${#ZENITY_LEVELS[@]} -gt 0 ] && should_show_zenity_alert "$level"; then
                        trigger_zenity_alert "$battery_name" "$level" "$capacity" ""
                    fi
                fi
            fi
        done

        update_last_capacity "$battery_name" "$capacity"
        reset_last_charge_level "$battery_name"
    else
        reset_last_capacity "$battery_name"

        if [ "$status" = "Charging" ]; then
            for level in "${CHARGE_LEVELS[@]}"; do
                if [ "$capacity" -ge "$level" ] && [ "$level" -gt "$last_charge_level" ]; then
                    local charge_id="${battery_name}_charge_${level}"
                    if check_cooldown "$charge_id"; then
                        local title="🔌 Charge à ${capacity}%"
                        local message="Tu peux débrancher le chargeur (batterie à ${capacity}%)"
                        send_notification "low" "$title" "$message" \
                            "battery-good-charging" "$charge_id"
                        last_charge_level="$level"
                        update_last_charge_level "$battery_name" "$last_charge_level"
                    fi
                fi
            done
            if [ "$capacity" -ge "$FULL_LEVEL" ] && [ "$last_charge_level" -lt "$FULL_LEVEL" ]; then
                local near_full_id="${battery_name}_near_full"
                if check_cooldown "$near_full_id"; then
                    send_notification "low" "🔌 Batterie presque pleine" \
                        "Tu peux débrancher le chargeur (batterie à ${capacity}%)" \
                        "battery-full" "$near_full_id"
                    last_charge_level="$FULL_LEVEL"
                    update_last_charge_level "$battery_name" "$last_charge_level"
                fi
            fi
        elif [ "$status" = "Full" ]; then
            if [ "$last_charge_level" -lt 101 ]; then
                local full_id="${battery_name}_full"
                if check_cooldown "$full_id"; then
                    send_notification "low" "🔌 Batterie pleine" \
                        "Tu peux débrancher le chargeur (batterie à ${capacity}%)" \
                        "battery-full" "$full_id"
                    last_charge_level=101
                    update_last_charge_level "$battery_name" "$last_charge_level"
                fi
            fi
        else
            reset_last_charge_level "$battery_name"
        fi
    fi
}

# Traitement des arguments de ligne de commande
while [[ $# -gt 0 ]]; do
    case $1 in
        -w|--warning)
            parse_levels "$2" WARNING_LEVELS
            normalize_levels WARNING_LEVELS
            shift 2
            ;;
        -c|--critical)
            parse_levels "$2" CRITICAL_LEVELS
            normalize_levels CRITICAL_LEVELS
            shift 2
            ;;
        -f|--full)
            FULL_LEVEL="$2"
            shift 2
            ;;
        -i|--interval)
            CHECK_INTERVAL="$2"
            shift 2
            ;;
        -z|--zenity)
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
        *)
            shift
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

if [ ${#ZENITY_LEVELS[@]} -gt 0 ]; then
    zenity_config=$(format_levels_with_units ZENITY_LEVELS)
fi

trap 'exit 0' SIGINT SIGTERM

while true; do
    battery_found=false
    for battery_path in /sys/class/power_supply/BAT*; do
        if [ -d "$battery_path" ]; then
            battery_found=true
            process_battery "$battery_path"
        fi
    done

    if [ "$battery_found" = false ]; then
        echo "Aucune batterie trouvée sur ce système"
        exit 1
    fi

    sleep "$CHECK_INTERVAL"
done
