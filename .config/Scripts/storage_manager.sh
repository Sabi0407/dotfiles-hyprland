#!/bin/bash

ICON="󰋊"

open_manager() {
  if command -v thunar >/dev/null 2>&1; then
    thunar "$1" >/dev/null 2>&1 &
  elif command -v nautilus >/dev/null 2>&1; then
    nautilus "$1" >/dev/null 2>&1 &
  else
    xdg-open "$1" >/dev/null 2>&1 &
  fi
}

notify() {
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send "$@"
}

escape_json() {
  local input=${1//\\/\\\\}
  input=${input//\"/\\\"}
  input=${input//$'\n'/\\n}
  echo "$input"
}

first_external_partition() {
  local current_disk=""
  local current_tran=""

  while read -r name type tran; do
    if [ "$type" = "disk" ]; then
      current_disk="$name"
      current_tran="$tran"
      continue
    fi

    [ "$type" = "part" ] || continue

    case "$current_disk" in
      /dev/nvme0*|/dev/mmcblk0*) continue ;;
    esac

    if [[ "$current_disk" =~ ^/dev/sd ]] || [[ "$current_tran" = "usb" && "$current_disk" =~ ^/dev/nvme ]]; then
      echo "$name"
      return 0
    fi
  done < <(lsblk -rpo NAME,TYPE,TRAN)

  return 1
}

get_label() {
  local part="$1"
  local label

  label=$(lsblk -no LABEL "$part" 2>/dev/null | head -n1)
  [ -n "$label" ] || label=$(basename "$part")
  echo "$label"
}

mountpoint_for() {
  local part="$1"
  findmnt -rn -S "$part" -o TARGET 2>/dev/null
}

print_status() {
  local part label mountpoint class tooltip

  part=$(first_external_partition) || { echo ''; return; }
  label=$(get_label "$part")
  mountpoint=$(mountpoint_for "$part")

  if [ -n "$mountpoint" ]; then
    class="connected"
    tooltip=$(printf "%s monté sur %s\nClic gauche : ouvrir\nClic droit : démonter" "$label" "$mountpoint")
  else
    class="disconnected"
    tooltip=$(printf "%s non monté\nClic droit : monter" "$label")
  fi

  printf '{"text":"%s %s","tooltip":"%s","class":"%s"}\n' \
    "$ICON" "$(escape_json "$label")" "$(escape_json "$tooltip")" "$class"
}

toggle_mount() {
  local part label mountpoint

  part=$(first_external_partition) || {
    notify "Stockage" "Aucun disque externe détecté" -i dialog-information -t 3000
    return 1
  }

  label=$(get_label "$part")
  mountpoint=$(mountpoint_for "$part")

  if [ -n "$mountpoint" ]; then
    if udisksctl unmount -b "$part" --no-user-interaction >/dev/null 2>&1; then
      notify "Stockage" "Disque $label démonté" -i drive-harddisk -t 3000
    else
      notify "Stockage" "Échec du démontage de $label" -i error -t 3000
      return 1
    fi
  else
    if udisksctl mount -b "$part" --no-user-interaction >/dev/null 2>&1; then
      notify "Stockage" "Disque $label monté" -i drive-harddisk -t 3000
    else
      notify "Stockage" "Impossible de monter $label" -i error -t 3000
      notify "Stockage" "Exécutez ~/.config/Scripts/setup-storage-mount.sh pour autoriser l'utilisateur" -i dialog-information -t 3000
      return 1
    fi
  fi
}

open_disk() {
  local part label mountpoint

  part=$(first_external_partition) || {
    notify "Stockage" "Aucun disque externe détecté" -i dialog-information -t 3000
    return 1
  }

  label=$(get_label "$part")
  mountpoint=$(mountpoint_for "$part")

  if [ -z "$mountpoint" ]; then
    if udisksctl mount -b "$part" --no-user-interaction >/dev/null 2>&1; then
      mountpoint=$(mountpoint_for "$part")
    fi
  fi

  if [ -n "$mountpoint" ]; then
    open_manager "$mountpoint"
    notify "Stockage" "Ouverture de $label" -i folder-open -t 3000
  else
    notify "Stockage" "Aucun point de montage pour $label" -i dialog-information -t 3000
    return 1
  fi
}

case "$1" in
  toggle) toggle_mount ;;
  open) open_disk ;;
  *) print_status ;;
esac
