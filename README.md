# Synthwave '84 OLED

An Omarchy theme: Synthwave '84 colours on an OLED-black base, with neon-sunrise and
synthwave-grid backgrounds and a neon-bloom Hyprland shader.

## Install

```bash
omarchy theme install https://github.com/jsandai/omarchy-synthwave-84-oled-theme.git
```

## pi

`pi.json` is a hand-tuned pi theme. `omarchy-theme-set` copies it to
`~/.pi/agent/themes/omarchy-system.json` on every theme switch when `~/.pi/agent`
exists, so pi follows the desktop with no extra setup.

It carries two colour keys that stock pi ignores and extensions read:

- `toolPanelBorder` — tool panel outline colour for
  [pi-tool-display](https://github.com/jsandai/pi-tool-display) (`toolPanelBorderColor` or `diffPanelBorderColor`).
- `spinner` — the working-spinner colour, for pi-tool-display's
  `workingIndicatorColor`. Without it pi uses `accent` for the spinner.

The matching pi-tool-display `config.json`:

```json
{
  "toolPanelStyle": "outline",
  "diffPanelBorderColor": "toolPanelBorder",
  "diffRowBackground": "transparent",
  "workingIndicatorColor": "spinner"
}
```
