#!/bin/bash
set -euo pipefail

# Enveloppe HyprCap : envoie une notification au démarrage et à l'arrêt.

REC_PID_PATH="${XDG_RUNTIME_DIR:-/run}/hyprcap_rec.pid"
OUTPUT_DIR="${HOME}/Vidéos"
DEFAULT_ARGS=(-w -n -A -o "$OUTPUT_DIR")

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    local title="$1" body="${2:-}"
    notify-send -a "HyprCap" "$title" "$body"
  fi
}

describe_selection() {
  case "$1" in
    region) echo "zone sélectionnée";;
    monitor:active) echo "moniteur actif";;
    monitor:*) echo "moniteur ${1#monitor:}";;
    window:active) echo "fenêtre active";;
    window:*) echo "fenêtre ${1#window:}";;
    *) echo "$1";;
  esac
}

usage() {
  cat <<'EOF'
Usage : hyprcap-record.sh <selection> [options...]
        hyprcap-record.sh stop

Exemples :
  hyprcap-record.sh region
  hyprcap-record.sh monitor:active
  hyprcap-record.sh stop
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

action="$1"
shift

if [[ "$action" == "stop" ]]; then
  if [[ ! -f "$REC_PID_PATH" ]]; then
    notify "HyprCap" "Aucun enregistrement en cours."
    exit 1
  fi
  notify "HyprCap" "Arrêt de l'enregistrement…"
  if hyprcap rec-stop "$@"; then
    notify "HyprCap" "Enregistrement terminé."
    if command -v thunar >/dev/null 2>&1; then
      thunar "$OUTPUT_DIR" >/dev/null 2>&1 &
    fi
  else
    notify "HyprCap" "Échec de l'arrêt."
    exit 1
  fi
  exit 0
fi

selection="$action"

mkdir -p "$OUTPUT_DIR"

if [[ -f "$REC_PID_PATH" ]]; then
  notify "HyprCap" "Enregistrement déjà en cours."
  exit 1
fi

desc=$(describe_selection "$selection")
notify "HyprCap" "Démarrage de l'enregistrement ($desc)…"

if hyprcap rec "$selection" "${DEFAULT_ARGS[@]}" "$@"; then
  :
else
  notify "HyprCap" "Échec du démarrage de l'enregistrement."
  exit 1
fi
