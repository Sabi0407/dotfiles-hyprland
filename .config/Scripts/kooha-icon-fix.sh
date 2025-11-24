#!/usr/bin/env bash
set -euo pipefail

# Install missing Kooha symbolic icons into the local hicolor override.

RESOURCE="/usr/share/kooha/resources.gresource"
ICON_ROOT="${HOME}/.local/share/icons/hicolor"
ACTION_DIR="${ICON_ROOT}/symbolic/actions"
STATUS_DIR="${ICON_ROOT}/symbolic/status"

if [[ ! -f "$RESOURCE" ]]; then
  echo "Kooha resource not found: $RESOURCE" >&2
  exit 1
fi

mkdir -p "$ACTION_DIR"

python3 - <<'PY'
import gi
from gi.repository import Gio
from pathlib import Path

icons = [
    '/io/github/seadve/Kooha/icons/scalable/actions/audio-volume-high-symbolic.svg',
    '/io/github/seadve/Kooha/icons/scalable/actions/audio-volume-muted-symbolic.svg',
    '/io/github/seadve/Kooha/icons/scalable/actions/checkmark-symbolic.svg',
    '/io/github/seadve/Kooha/icons/scalable/actions/microphone-disabled-symbolic.svg',
    '/io/github/seadve/Kooha/icons/scalable/actions/microphone2-symbolic.svg',
    '/io/github/seadve/Kooha/icons/scalable/actions/mouse-wireless-disabled-symbolic.svg',
    '/io/github/seadve/Kooha/icons/scalable/actions/mouse-wireless-symbolic.svg',
    '/io/github/seadve/Kooha/icons/scalable/actions/refresh-symbolic.svg',
    '/io/github/seadve/Kooha/icons/scalable/actions/selection-symbolic.svg',
    '/io/github/seadve/Kooha/icons/scalable/actions/source-pick-symbolic.svg',
    '/io/github/seadve/Kooha/icons/scalable/actions/warning-symbolic.svg',
]

resource = Gio.Resource.load('/usr/share/kooha/resources.gresource')
out_dir = Path(Path.home(), '.local/share/icons/hicolor/symbolic/actions')
out_dir.mkdir(parents=True, exist_ok=True)

for icon in icons:
    data = resource.lookup_data(icon, Gio.ResourceLookupFlags.NONE)
    dest = out_dir / Path(icon).name
    dest.write_bytes(bytes(data.get_data()))
    print(f'wrote {dest}')
PY

mkdir -p "$STATUS_DIR"
cp "$ACTION_DIR"/*.svg "$STATUS_DIR"/

cat > "${ICON_ROOT}/index.theme" <<'EOF'
[Icon Theme]
Name=Hicolor (Local)
Comment=Local overrides for the hicolor fallback
Inherits=hicolor
Directories=symbolic/actions,symbolic/status

[symbolic/actions]
Size=16
MinSize=8
MaxSize=512
Type=Scalable
Context=Actions

[symbolic/status]
Size=16
MinSize=8
MaxSize=512
Type=Scalable
Context=Status
EOF

gtk-update-icon-cache -f "$ICON_ROOT"

echo "Kooha icon override installed. Restart Kooha (ou la session) pour voir les pictos."
