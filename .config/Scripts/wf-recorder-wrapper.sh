#!/bin/bash
set -euo pipefail

# Assistant wf-recorder : lance/arrête un enregistrement (plein écran ou zone)

OUT_DIR="$HOME/Vidéos"
STATE_DIR="$HOME/.cache/wf-recorder-wrapper"
PID_FILE="$STATE_DIR/pid"
INFO_FILE="$STATE_DIR/info"
LOG_FILE="$STATE_DIR/wf-recorder.log"

mkdir -p "$OUT_DIR" "$STATE_DIR"
umask 077

send_notification() {
  local title="$1" body="${2:-}"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "wf-recorder" "$title" "$body"
  fi
}

usage() {
  cat <<'EOF'
Usage : wf-recorder-wrapper.sh <mode> [options]

Modes :
  full [moniteur]    Démarre ou arrête l'enregistrement du moniteur (par défaut : 1er Hyprland)
  zone               Démarre ou arrête un enregistrement d'une zone sélectionnée (slurp requis)
  stop               Arrête manuellement l'enregistrement en cours (alias d'un deuxième appel)

Options :
  --audio            Capture l'audio PipeWire par défaut
  --filename nom     Définit le nom de fichier (extension MP4 ajoutée automatiquement)

Remarques :
  - Relancer la commande (ou le raccourci) pendant une capture arrête l'enregistrement.
  - Les fichiers sont sauvegardés dans ~/Vidéos.
  - L'enregistrement brut est en WebM et est converti automatiquement en MP4 à l'arrêt.

Exemples :
  wf-recorder-wrapper.sh full --audio
  wf-recorder-wrapper.sh zone --audio
  wf-recorder-wrapper.sh full DP-1 --audio
EOF
}

cleanup_state() {
  rm -f "$PID_FILE" "$INFO_FILE"
}

stop_recording() {
  local pid="" format="mp4" record_file="" output_file="" description="" previous_log="$LOG_FILE" audio=0

  if [[ -f "$INFO_FILE" ]]; then
    set +u
    source "$INFO_FILE"
    set -u
  fi
  if [[ -z "$pid" && -f "$PID_FILE" ]]; then
    pid=$(cat "$PID_FILE")
  fi

  if [[ -z "$pid" ]]; then
    send_notification "wf-recorder" "Aucun enregistrement en cours."
    echo "Aucun enregistrement en cours."
    cleanup_state
    return 1
  fi

  local still_running=0
  if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
    still_running=1
  fi

  if (( still_running )); then
    send_notification "wf-recorder" "Arrêt de l'enregistrement…"
    kill -INT "$pid" 2>/dev/null || true
    for _ in {1..80}; do
      if ! kill -0 "$pid" 2>/dev/null; then
        break
      fi
      sleep 0.1
    done
    if kill -0 "$pid" 2>/dev/null; then
      kill -TERM "$pid" 2>/dev/null || true
      sleep 0.3
    fi
    if kill -0 "$pid" 2>/dev/null; then
      kill -KILL "$pid" 2>/dev/null || true
    fi
  fi

  rm -f "$PID_FILE"

  local final_path="" conversion_note=""
  if [[ -n "$record_file" && -f "$record_file" ]]; then
    if [[ "$format" == "mp4" ]]; then
      if command -v ffmpeg >/dev/null 2>&1; then
        send_notification "wf-recorder" "Conversion MP4 en cours…"
        local ff_args=(-y -loglevel error -i "$record_file" -c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p)
        if [[ "$audio" == "1" ]]; then
          ff_args+=(-c:a aac)
        else
          ff_args+=(-an)
        fi
        ff_args+=("$output_file")

        if ffmpeg "${ff_args[@]}" >> "$LOG_FILE" 2>&1; then
          final_path="$output_file"
          rm -f "$record_file"
        else
          conversion_note="Conversion MP4 échouée, WebM conservé"
          final_path="$record_file"
        fi
      else
        conversion_note="ffmpeg absent, WebM conservé"
        final_path="$record_file"
      fi
    else
      final_path="$record_file"
    fi
  fi

  rm -f "$INFO_FILE"

  if [[ -n "$final_path" && -f "$final_path" ]]; then
    send_notification "wf-recorder" "Enregistrement terminé" "$(basename "$final_path")"
    echo "Enregistrement terminé : $final_path"
  else
    send_notification "wf-recorder" "Aucun fichier généré." "Consultez $previous_log"
    echo "Aucun fichier généré. Voir $previous_log" >&2
  fi

  if [[ -n "$conversion_note" ]]; then
    send_notification "wf-recorder" "$conversion_note"
    echo "$conversion_note"
  fi

  return 0
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

case "$1" in
  -h|--help)
    usage
    exit 0
    ;;
  stop)
    stop_recording
    exit 0
    ;;
esac

if ! command -v wf-recorder >/dev/null 2>&1; then
  echo "wf-recorder est introuvable. Installez-le (sudo pacman -S wf-recorder)." >&2
  exit 1
fi

mode="$1"
shift

if [[ -f "$PID_FILE" || -f "$INFO_FILE" ]]; then
  stop_recording
  exit 0
fi

audio=0
output_name="capture_$(date +%Y%m%d_%H%M%S)"
format="mp4"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --audio)
      audio=1
      shift
      ;;
    --filename)
      [[ $# -lt 2 ]] && { echo "Option --filename nécessite une valeur." >&2; exit 1; }
      output_name="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

monitor_arg=""
if [[ "$mode" == "full" ]]; then
  monitor_arg="${1:-}"
  [[ -n "$monitor_arg" ]] && shift
elif [[ "$mode" != "zone" ]]; then
  echo "Mode inconnu : $mode" >&2
  usage
  exit 1
fi

record_file="$OUT_DIR/${output_name}.webm"
output_file="$OUT_DIR/${output_name}.mp4"

if [[ -e "$output_file" || -e "$record_file" ]]; then
  echo "Un fichier portant ce nom existe déjà : changez --filename." >&2
  exit 1
fi

declare -a wf_args=(-f "$record_file" -m webm -c libvpx-vp9)
(( audio )) && wf_args+=(-a -C libopus)

description=""
if [[ "$mode" == "full" ]]; then
  if [[ -z "$monitor_arg" ]]; then
    if ! command -v hyprctl >/dev/null 2>&1; then
      echo "hyprctl introuvable : impossible de détecter un moniteur." >&2
      exit 1
    fi
    monitor_arg=$(hyprctl monitors | sed -n 's/^Monitor \(.*\) (ID [0-9]\+):$/\1/p' | head -n1)
  fi
  if [[ -z "$monitor_arg" ]]; then
    echo "Impossible de détecter un moniteur Hyprland." >&2
    exit 1
  fi
  wf_args+=(-o "$monitor_arg")
  description="Plein écran (${monitor_arg}) → $(basename "$output_file")"
else
  if ! command -v slurp >/dev/null 2>&1; then
    echo "slurp est requis pour la sélection de zone." >&2
    exit 1
  fi
  geometry=$(slurp -f '%wx%h+%x+%y')
  if [[ -z "$geometry" ]]; then
    send_notification "wf-recorder" "Sélection annulée."
    exit 1
  fi
  wf_args+=(-g "$geometry")
  description="Zone ${geometry} → $(basename "$output_file")"
fi

[[ $audio -eq 1 ]] && description+=" + audio"

: > "$LOG_FILE"
setsid wf-recorder "${wf_args[@]}" >> "$LOG_FILE" 2>&1 &
wf_pid=$!
sleep 0.3
if ! kill -0 "$wf_pid" 2>/dev/null; then
  send_notification "wf-recorder" "Échec du démarrage." "Voir $LOG_FILE"
  echo "wf-recorder n'a pas démarré. Consultez $LOG_FILE." >&2
  cleanup_state
  exit 1
fi

{
  printf 'pid=%q\n' "$wf_pid"
  printf 'mode=%q\n' "$mode"
  printf 'format=%q\n' "$format"
  printf 'audio=%q\n' "$audio"
  printf 'record_file=%q\n' "$record_file"
  printf 'output_file=%q\n' "$output_file"
  printf 'description=%q\n' "$description"
} > "$INFO_FILE"
echo "$wf_pid" > "$PID_FILE"

send_notification "wf-recorder" "Enregistrement démarré" "$description"
echo "Enregistrement démarré (PID $wf_pid) : $description"
echo "Relancez la commande / le raccourci pour arrêter."
