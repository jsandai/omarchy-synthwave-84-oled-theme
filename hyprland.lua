-- Synthwave '84 OLED: neon glow via colored Hyprland shadows.
-- Active window gets a magenta halo + pink/cyan gradient border;
-- inactive windows get a faint nebula-purple shadow.
local active_border_color = { colors = { "rgba(ff7edbee)", "rgba(03edf9ee)" }, angle = 45 }
local inactive_border_color = "rgba(495495aa)"

-- Points at the theme source rather than the applied copy so edits to the
-- shader take effect on `hyprctl reload` without re-applying the theme.
local bloom_shader = os.getenv("HOME") .. "/.config/omarchy/themes/synthwave-84-oled/neon-bloom.glsl"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    screen_shader = bloom_shader,
    shadow = {
      enabled = true,
      range = 16,
      render_power = 4,
      color = "rgba(ff7edb88)",
      color_inactive = "rgba(49549555)",
    },
  },
})
