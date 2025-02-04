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

-- animations
config.max_fps = 170
config.animation_fps = 170
-- and finally, return the configuration to wezterm
return config
