local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.enable_wayland = true

-- theme
config.window_decorations = "NONE"

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_frame = {
	active_titlebar_bg = "transparent",
	inactive_titlebar_bg = "transparent",
}

config.tab_bar_at_bottom = true
-- swap panes

-- key bindings
local action = wezterm.action
config.keys = {
	{
		key = "H",
		mods = "CTRL|SHIFT",
		action = action.DisableDefaultAssignment,
	},
	{
		key = "J",
		mods = "CTRL|SHIFT",
		action = action.DisableDefaultAssignment,
	},
	{
		key = "K",
		mods = "CTRL|SHIFT",
		action = action.DisableDefaultAssignment,
	},
	{
		key = "L",
		mods = "CTRL|SHIFT",
		action = action.DisableDefaultAssignment,
	},
}

config.disable_default_mouse_bindings = true
