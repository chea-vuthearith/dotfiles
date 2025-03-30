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

-- hyprland support
config.enable_wayland = false

-- theme
config.color_scheme = "Dark Violet (base16)"
config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.window_background_opacity = 0.9

-- missing glyphs warning
config.warn_about_missing_glyphs = false

-- key bindings
config.keys = {
	{ key = "h", mods = "SHIFT|CTRL", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "l", mods = "SHIFT|CTRL", action = wezterm.action.ActivateTabRelative(1) },
}

config.disable_default_mouse_bindings = true

-- tab bar
config.hide_tab_bar_if_only_one_tab = true
config.color_scheme = "Black Metal (Dark Funeral) (base16)"

local bg_color = "#000000"
local fg_color = "#D0DFEE"

config.window_frame = {
	active_titlebar_bg = bg_color,
	inactive_titlebar_bg = bg_color,
}

config.colors = {
	tab_bar = {
		inactive_tab = {
			bg_color = bg_color,
			fg_color = fg_color,
		},
		active_tab = {
			bg_color = fg_color,
			fg_color = bg_color,
		},
		new_tab = {
			bg_color = bg_color,
			fg_color = bg_color,
		},
	},
}

-- and finally, return the configuration to wezterm
return config
