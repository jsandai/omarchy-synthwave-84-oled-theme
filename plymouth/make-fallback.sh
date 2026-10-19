#!/bin/bash
# Regenerate the theme's unlock.png and preview-unlock.png, which Omarchy's own unlock
# switcher uses to recolour its stock splash. Run after changing the logo in build.sh.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=$(dirname "$here")
lock_src=${LOCK_SRC:-${OMARCHY_PATH:-/usr/share/omarchy}/default/plymouth/lock.png}
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
"$here/build.sh" "$t/out" >/dev/null

# unlock.png: the gradient logo, as Omarchy's theme layout expects
cp "$t/out/logo.png" "$root/unlock.png"

# preview-unlock.png: approximates what `omarchy plymouth set-by-theme` draws at 1920x1080 —
# black background, the logo, and the stock lock and entry box tinted white
W=1920 H=1080
lx=$(( (W-810)/2 )) ly=$(( (H-190)/2 ))
ey=$(( ly+190+40 )) ex=$(( (W-286)/2 ))
magick "$lock_src" -resize 33x38! -channel RGB +level-colors white,white +channel "$t/lock.png"
magick -size ${W}x${H} xc:black \
  "$t/out/logo.png" -geometry +$lx+$ly -composite \
  -fill none -stroke white -strokewidth 2 -draw "rectangle $ex,$ey $((ex+285)),$((ey+47))" \
  "$t/lock.png" -geometry +$((ex-33-15))+$((ey+5)) -composite \
  -strip -depth 8 "$root/preview-unlock.png"
echo "wrote $root/unlock.png and $root/preview-unlock.png"
