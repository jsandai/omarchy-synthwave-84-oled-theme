-- Synthwave '84 OLED window glow: a magenta halo from coloured Hyprland shadows.
-- Installed into ~/.config/hypr by glow/install.sh; remove with --uninstall.
--
-- It only applies while synthwave-84-oled is the current theme. Omarchy reloads
-- Hyprland on every theme switch, so switching away turns the glow off.
--
-- The glow lives in per-window shadows on purpose: a screen_shader runs over the
-- whole output and posterized video and photos.
local file = io.open(os.getenv("HOME") .. "/.local/state/omarchy/current/theme.name", "r")
local theme = file and file:read("l")
if file then file:close() end

if theme == "synthwave-84-oled" then
  hl.config({
    decoration = {
      shadow = {
        enabled = true,
        range = 16,
        render_power = 4,
        color = "rgba(ff7edb88)",
        color_inactive = "rgba(49549555)",
      },
    },
  })
end
