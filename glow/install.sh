#!/bin/bash
# Turn on the neon glow: a magenta halo around windows (Hyprland shadows) and a text
# glow in Ghostty. Omarchy won't load Lua or terminal configs from a theme installed
# with `omarchy theme install`, so this adds them to your own config instead.
#
#   ./install.sh                 turn the glow on (re-run after a theme update)
#   ./install.sh --uninstall     turn it off and remove what install.sh added
#
# Both pieces only apply while synthwave-84-oled is the current theme, so switching
# to another theme turns the glow off without uninstalling.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)

hypr_dir=$HOME/.config/hypr
hypr_main=$hypr_dir/hyprland.lua
hypr_glow=$hypr_dir/synthwave-84-oled-glow.lua
module=hypr.synthwave-84-oled-glow
hypr_lines="-- synthwave-84-oled glow: added by glow/install.sh, remove with --uninstall
if package.searchpath(\"$module\", package.path) then require(\"$module\") end"

ghostty_dir=$HOME/.config/ghostty
ghostty_lines='# synthwave-84-oled glow: added by glow/install.sh, remove with --uninstall
config-file = ?"~/.local/state/omarchy/current/theme/ghostty-glow.conf"'
marker='synthwave-84-oled glow'

if (( EUID == 0 )); then
  echo "Run as your user, not under sudo." >&2
  exit 1
fi

# Ghostty 1.2+ prefers config.ghostty; Omarchy ships the older plain `config`.
ghostty_config=$ghostty_dir/config
[[ -f $ghostty_dir/config.ghostty ]] && ghostty_config=$ghostty_dir/config.ghostty

# Removes each marker comment, the line after it, and the blank line install added
# before it. Writes in place so a symlinked config stays a symlink.
drop_marked_lines() {
  local file=$1
  [[ -f $file ]] && grep -qF -- "$marker" "$file" || return 0
  local tmp
  tmp=$(mktemp)
  awk -v m="$marker" '
    skip { skip = 0; next }
    index($0, m) { held = 0; skip = 1; next }
    held { print ""; held = 0 }
    /^$/ { held = 1; next }
    { print }
    END { if (held) print "" }
  ' "$file" >"$tmp"
  cat "$tmp" >"$file"
  rm -f "$tmp"
}

reload() {
  if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && command -v hyprctl >/dev/null; then
    hyprctl reload >/dev/null || true
  fi
  pkill -USR2 -x ghostty 2>/dev/null || true
}

if [[ ${1:-} == --uninstall ]]; then
  drop_marked_lines "$hypr_main"
  rm -f "$hypr_glow"
  drop_marked_lines "$ghostty_config"
  reload
  echo "Glow removed."
  exit 0
fi

if [[ ! -f $hypr_main ]]; then
  echo "No $hypr_main; this expects an Omarchy Hyprland config." >&2
  exit 1
fi

install -m644 "$here/hyprland.lua" "$hypr_glow"
grep -qF -- "$marker" "$hypr_main" || printf '\n%s\n' "$hypr_lines" >>"$hypr_main"

mkdir -p "$ghostty_dir"
touch "$ghostty_config"
grep -qF -- "$marker" "$ghostty_config" || printf '\n%s\n' "$ghostty_lines" >>"$ghostty_config"

reload
echo "Glow on. It shows while synthwave-84-oled is the current theme."
