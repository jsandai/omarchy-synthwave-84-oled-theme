# Synthwave '84 OLED

An Omarchy theme: Synthwave '84 colours on an OLED-black base, with a neon-sunrise
background, neon window glow from coloured Hyprland shadows and gradient borders, a neon
text glow in Ghostty, and an optional animated boot and unlock splash.

![Animated splash: the logo's pink glow pulses](screenshots/splash-glow-pulse.gif)

## Install

```bash
omarchy theme install https://github.com/jsandai/omarchy-synthwave-84-oled-theme.git
```

## Terminal glow

Ghostty gets a neon text glow from `neon-glow.glsl`: coloured text spreads a soft halo,
while black and white stay crisp. It only runs on the terminal, so video and photos
elsewhere are untouched.

To turn it off, create `~/.config/ghostty/synthwave-84-oled.conf` containing:

```
custom-shader =
```

Ghostty reads that file after the theme, so it wins, and theme updates leave it alone.
Delete the file to get the glow back.

## Boot and unlock splash

Omarchy themes can only recolour Omarchy's stock splash. This theme does that too: pick
it in Omarchy's unlock-screen switcher, or run
`omarchy plymouth set-by-theme synthwave-84-oled`, and the splash gets the sunset logo
on black.

The full version is an animated Plymouth theme of its own, covering boot, the disk
unlock prompt, shutdown and reboot:

- the logo in a yellow-to-pink sunset gradient with a pulsing pink glow
- a cyan password box with square bullets that flash white as you type, a block caret,
  and a red flash and shake on a wrong passphrase
- a pink-to-cyan progress bar after unlock, and the glow fading out on shutdown

| Unlock prompt | Wrong passphrase |
| --- | --- |
| ![Unlock prompt with typed bullets and caret](screenshots/splash-unlock.png) | ![Box flashes red and shakes on a wrong passphrase](screenshots/splash-wrong-passphrase.png) |
| **Booting** | **Shutdown** |
| ![Progress bar after unlock](screenshots/splash-boot.png) | ![Shutdown: logo with the glow fading out](screenshots/splash-shutdown.png) |

Captured from a real `plymouthd` (x11 renderer). On HiDPI panels it scales up with the
display.

It needs sudo and rebuilds your initramfs, so it is a separate step:

```bash
cd ~/.config/omarchy/themes/synthwave-84-oled/plymouth
./install.sh                # pulsing glow
GLOW=static ./install.sh    # steady glow; GLOW=off for none. Re-run to change it.
./install.sh --uninstall    # back to Omarchy's splash
```

It installs to `/usr/share/plymouth/themes/synthwave-oled`, which no package owns, so
system updates leave it in place. Omarchy's own splash is not modified. Needs
`imagemagick` and `librsvg` to build the images.

## pi

`pi.json` is a hand-tuned pi theme. `omarchy-theme-set` copies it to
`~/.pi/agent/themes/omarchy-system.json` on every theme switch when `~/.pi/agent`
exists, so pi follows the desktop with no extra setup.

It carries two colour keys that stock pi ignores and extensions read:

- `toolPanelBorder` — tool panel outline colour for
  [pi-tool-frame](https://github.com/jsandai/pi-tool-frame) (`toolPanelBorderColor` or `diffPanelBorderColor`).
- `spinner` — the working-spinner colour, for pi-tool-frame's
  `workingIndicatorColor`. Without it pi uses `accent` for the spinner.

The matching pi-tool-frame config (`~/.pi/agent/extensions/pi-tool-display/config.json`):

```json
{
  "toolPanelStyle": "outline",
  "diffPanelBorderColor": "toolPanelBorder",
  "diffRowBackground": "transparent",
  "workingIndicatorColor": "spinner"
}
```
