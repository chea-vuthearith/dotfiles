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
config.color_scheme = "Catppuccin Mocha"
config.enable_tab_bar = true
config.enable_wayland = false
config.tab_bar_at_bottom = true
config.window_background_opacity = 0.9

-- animations
config.max_fps = 120
config.animation_fps = 1
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

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

local bg_color = "#1E1E2E"
config.window_frame = {
	active_titlebar_bg = bg_color,
}
config.colors = {
	tab_bar = {
		inactive_tab = {
			bg_color = bg_color,
			fg_color = "#c0c0c0",
			intensity = "Normal",
			underline = "None",
			italic = false,
			strikethrough = false,
		},
		active_tab = {
			bg_color = "#2b2042",
			fg_color = "#c0c0c0",
			intensity = "Normal",
			underline = "None",
			italic = false,
			strikethrough = false,
		},
		new_tab = {
			bg_color = bg_color,
			fg_color = bg_color,
		},
	},
}

-- and finally, return the configuration to wezterm
return config
