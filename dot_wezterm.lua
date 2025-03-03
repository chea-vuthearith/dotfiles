-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.font_size = 12
config.font = wezterm.font("FiraCode Nerd Font")
config.font_rules = {
	{
		intensity = "Bold",
		font = wezterm.font("FiraCode Nerd Font", { weight = "Bold" }),
	},
	{
		italic = true,
		font = wezterm.font("VictorMono Nerd Font", { weight = "Regular", style = "Italic" }),
	},
	{
		italic = true,
		intensity = "Bold",
		font = wezterm.font("VictorMono Nerd Font", { weight = "DemiBold", style = "Italic" }),
	},
}

-- For example, changing the color scheme:
config.color_scheme = "rose-pine-moon"
config.enable_tab_bar = false

config.enable_wayland = false

config.window_background_opacity = 0.90
-- animations
config.max_fps = 120
config.animation_fps = 1
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- missing glyphs warning
config.warn_about_missing_glyphs = false
-- and finally, return the configuration to wezterm
return config
