# Testing and screenshots

These scripts run the splash in a real `plymouthd` on an Xvfb display, without changing the
boot configuration. A private `plymouthd.conf` is bind-mounted in a mount namespace. Needs
sudo, `xorg-server-xvfb`, `xdotool`, `imagemagick` and `ffmpeg`, and the theme copied to
`/usr/share/plymouth/themes/synthwave-oled` first (remove it afterwards if this isn't the
installed theme).

- `run.sh <outdir> boot|shutdown`: walks through prompt, wrong passphrase, unlock and
  progress, saving a screenshot at each step.
- `readme-shots.sh <outdir>`: the frames used in the README, at 1920x1080.
- `gif.sh <out.mkv>`: records 9 s of the glow pulse at 20 fps for the README GIF.

`plymouth.theme=` on the fake kernel command line is ignored, which is why the theme is
chosen through the bind-mounted config.
