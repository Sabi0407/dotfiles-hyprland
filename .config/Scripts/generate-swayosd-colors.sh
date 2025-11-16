#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/pywal-common.sh"
css_file="$HOME/.config/swayosd/style.css"
pywal_source_colors >/dev/null || true
template=$(cat <<'EOF'
@define-color theme_bg_color {color0};
@define-color theme_fg_color {color15};
@define-color accent_primary {color4};
@define-color accent_secondary {color5};
@define-color muted_color {color8};

window#osd {
  font-family: "Inter", "SF Pro Text", "Noto Sans", sans-serif;
  border-radius: 18px;
  border: none;
  background: alpha(@theme_bg_color, 0.94);
  margin: 12px 24px 0 24px;
  min-width: 300px;
}

.osd-volume {
  background: transparent;
  padding: 16px 20px;
  box-shadow: none;
}

.osd-volume image {
  min-width: 38px;
  min-height: 38px;
  margin-right: 14px;
  background: alpha(@theme_fg_color, 0.15);
  border-radius: 12px;
  padding: 8px;
}

.osd-volume scale trough {
  background: alpha(@muted_color, 0.45);
  border-radius: 8px;
}

.osd-volume scale slider {
  border-radius: 8px;
  background: @accent_primary;
  box-shadow: none;
}

.osd-volume scale slider:disabled {
  background: alpha(@accent_primary, 0.6);
}
EOF
)
for key in color0 color4 color5 color8 color15; do
    value=${!key:-#000000}
    template=${template//\{$key\}/$value}
done
printf "%s\n" "${template}" > "$css_file"
