#!/bin/bash
# Build the synthwave-oled Plymouth theme (boot, LUKS unlock, shutdown) from the Omarchy
# wordmark SVG and the synthwave-84-oled palette.
#
# Usage: build.sh <outdir>
#   GLOW=pulse|static|off   logo glow (default pulse)
# Assets are in LOGICAL pixels: Plymouth's script plugin upscales them by its device scale.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
out=${1:?usage: build.sh <outdir>}; mkdir -p "$out"
GLOW=${GLOW:-pulse}
case $GLOW in pulse|static|off) ;; *) echo "GLOW must be pulse, static or off (got '$GLOW')" >&2; exit 2 ;; esac
LOCK_SRC=${LOCK_SRC:-${OMARCHY_PATH:-/usr/share/omarchy}/default/plymouth/lock.png}
for dep in magick rsvg-convert; do
  command -v $dep >/dev/null || { echo "missing $dep (pacman -S imagemagick librsvg)" >&2; exit 1; }
done
[[ -r $LOCK_SRC ]] || { echo "lock icon not found at $LOCK_SRC (set LOCK_SRC)" >&2; exit 1; }
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT

YEL='#fede5d' ORA='#f97e72' PINK='#ff7edb' CYAN='#36f9f6' RED='#fe4450' TRACK='#241b2f'
C=10                        # logical px per wordmark grid cell (81x19 grid)
LW=$((81*C)) LH=$((19*C))
png() { magick "${@:1:$#-1}" -strip -depth 8 -define png:color-type=6 "${@: -1}"; }   # RGBA, last arg = output

# --- logo: wordmark mask -> sunset gradient with sun-stripe cuts in the lower third
sed 's/#9ece6a/#ffffff/' "$here/omarchy-wordmark.svg" > "$t/w.svg"
rsvg-convert -w 81 -h 19 "$t/w.svg" -o "$t/grid.png"
magick "$t/grid.png" -filter point -resize ${LW}x${LH}! -alpha extract -threshold 50% "$t/mask.png"
magick "$t/mask.png" -fill black \
  -draw "rectangle 0,$((LH*68/100)) $LW,$((LH*68/100+2))" \
  -draw "rectangle 0,$((LH*78/100)) $LW,$((LH*78/100+4))" \
  -draw "rectangle 0,$((LH*88/100)) $LW,$((LH*88/100+6))" "$t/mask-cut.png"
magick -size ${LW}x$((LH/2)) gradient:"$YEL"-"$ORA" -size ${LW}x$((LH-LH/2)) gradient:"$ORA"-"$PINK" \
  -append "$t/grad.png"
png "$t/grad.png" "$t/mask-cut.png" -alpha off -compose CopyOpacity -composite "$out/logo.png"

# --- glow sprite (pink, two blur radii); the script pulses its opacity
P=60
png "$t/mask.png" -bordercolor black -border $P -background "$PINK" -alpha shape \
  \( +clone -blur 0x20 -channel A -evaluate multiply 0.55 +channel \) \
  \( -clone 0 -blur 0x5 -channel A -evaluate multiply 0.7 +channel \) \
  -delete 0 -background none -compose over -flatten "$out/glow.png"

# --- entry box: 286x48 outline + glow, padded 20 on every side (cyan normal, red error flash)
EW=286 EH=48 EP=20
entry() {
  magick -size $((EW+2*EP))x$((EH+2*EP)) xc:none -fill none -stroke "$1" -strokewidth 2 \
    -draw "roundrectangle $EP,$EP $((EW+EP-1)),$((EH+EP-1)) 3,3" "$t/box.png"
  png "$t/box.png" \( +clone -blur 0x7 \) -compose screen -composite "$t/box.png" \
    -compose over -composite "$2"
}
entry "$CYAN" "$out/entry.png"
entry "$RED" "$out/entry-error.png"

# --- lock: pink, 80% of the entry height, soft glow, padded 12
LKH=$((EH*8/10)) LKP=12
LKW=$((84*LKH/96))
png "$LOCK_SRC" -resize ${LKW}x${LKH}! -channel RGB +level-colors "$PINK","$PINK" +channel \
  -bordercolor none -border $LKP \( +clone -blur 0x4 -channel A -evaluate multiply 0.7 +channel \) \
  +swap -compose over -composite "$out/lock.png"

# --- bullets (8x8 squares), white keystroke flash, block caret
png -size 8x8 xc:"$CYAN" "$out/bullet.png"
png -size 8x8 xc:'#ffffff' "$out/bullet-flash.png"
png -size 6x20 xc:"$CYAN" "$out/caret.png"

# --- progress: 300x4 track; pink->cyan fill and its glow (both scaled by the script)
PW=300 PH=4 PP=15
png -size ${PW}x${PH} xc:"$TRACK" "$out/progress_box.png"
magick -size ${PH}x${PW} gradient:"$PINK"-"$CYAN" -rotate -90 "$t/fill.png"
png "$t/fill.png" "$out/progress_bar.png"
png -size $((PW+2*PP))x$((PH+2*PP)) xc:none "$t/fill.png" -geometry +$PP+$PP -composite +geometry \
  -blur 0x5 "$out/progress_glow.png"

# --- theme files
sed "s/@GLOW@/$GLOW/" "$here/synthwave-oled.script" > "$out/synthwave-oled.script"
cat > "$out/synthwave-oled.plymouth" <<'EOF'
[Plymouth Theme]
Name=Synthwave OLED
Description=Synthwave '84 OLED splash: boot, LUKS unlock and shutdown.
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/synthwave-oled
ScriptFile=/usr/share/plymouth/themes/synthwave-oled/synthwave-oled.script
ConsoleLogBackgroundColor=0x000000
MonospaceFont=Cantarell 11
Font=Cantarell 11
EOF
echo "built $(ls "$out" | wc -l) files in $out (glow: $GLOW)"
