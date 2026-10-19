#!/bin/bash
# Install the animated synthwave-oled splash (boot, LUKS unlock, shutdown) and make it the
# default Plymouth theme. Run as your user; it asks for sudo.
#
#   ./install.sh                 install with the pulsing logo glow
#   GLOW=static ./install.sh     steady glow (or GLOW=off for none); re-run to change it
#   ./install.sh --uninstall     go back to Omarchy's own splash and remove the theme
#
# The theme lives in its own directory that no package owns, so updates leave it alone.
# Omarchy's stock "omarchy" theme is not touched.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
name=synthwave-oled
dest=/usr/share/plymouth/themes/$name

if (( EUID == 0 )); then
  echo "Run as your user, not under sudo." >&2
  exit 1
fi

rebuild_initramfs() {
  echo "Rebuilding the initramfs so the splash is used at the next boot..."
  if command -v limine-mkinitcpio >/dev/null; then
    sudo limine-mkinitcpio
  else
    sudo mkinitcpio -P
  fi
}

if [[ ${1:-} == --uninstall ]]; then
  if [[ $(plymouth-set-default-theme) == "$name" ]]; then
    sudo plymouth-set-default-theme omarchy
    rebuild_initramfs
  fi
  sudo rm -rf "$dest"
  echo "Removed $name; the splash is back to Omarchy's default."
  exit 0
fi

t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
"$here/build.sh" "$t/$name"
sudo rm -rf "$dest"
sudo install -d -m755 "$dest"
sudo install -m644 "$t/$name"/* "$dest/"
sudo plymouth-set-default-theme "$name"
rebuild_initramfs
echo "Installed $name (glow: ${GLOW:-pulse}). It shows from the next boot."
