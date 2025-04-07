local wezterm = require("wezterm")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
local config = wezterm.config_builder()

-- hyprland support
config.enable_wayland = false

-- theme
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

config.color_scheme = "Catppuccin Mocha"
config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.window_background_opacity = 0.9
config.window_decorations = "RESIZE"
-- tab bar
config.hide_tab_bar_if_only_one_tab = true

local bg_color = "#000000"
local fg_color = "#D0DFEE"

config.window_frame = {
	active_titlebar_bg = bg_color,
	inactive_titlebar_bg = bg_color,
}

config.colors = {
	background = bg_color,
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

config.warn_about_missing_glyphs = false

-- key bindings
local action = wezterm.action
config.leader = { key = "w", mods = "ALT", timeout_milliseconds = math.maxinteger }
config.keys = {
	--tabs
	-- navigation
	{ key = "h", mods = "ALT", action = action.ActivateTabRelative(-1) },
	{ key = "l", mods = "ALT", action = action.ActivateTabRelative(1) },
	-- order
	{ key = "h", mods = "SHIFT|ALT", action = action.MoveTabRelative(-1) },
	{ key = "l", mods = "SHIFT|ALT", action = action.MoveTabRelative(1) },
	-- keytable
	{
		key = "Tab",
		mods = "LEADER",
		action = action.ActivateKeyTable({ name = "tab" }),
	},

	-- panes
	-- creation
	{
		key = "|",
		mods = "LEADER|SHIFT",
		action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	-- keytable
	-- w to be interchangable with nvim's window
	{
		key = "w",
		mods = "LEADER",
		action = action.ActivateKeyTable({ name = "pane" }),
	},

	--focus
	{ key = "z", mods = "ALT", action = action.TogglePaneZoomState },
	{ key = "v", mods = "LEADER", action = action.ActivateCopyMode },

	-- workspaces
	-- keytable
	{
		key = "s",
		mods = "LEADER",
		action = action.ActivateKeyTable({ name = "workspace" }),
	},
	-- disable
	{
		key = "H",
		mods = "CTRL|SHIFT",
		action = "DisableDefaultAssignment",
	},
	{
		key = "J",
		mods = "CTRL|SHIFT",
		action = "DisableDefaultAssignment",
	},
	{
		key = "K",
		mods = "CTRL|SHIFT",
		action = "DisableDefaultAssignment",
	},
	{
		key = "L",
		mods = "CTRL|SHIFT",
		action = "DisableDefaultAssignment",
	},
}

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "ALT",
		action = action.ActivateTab(i - 1),
	})
end

wezterm.on("close-all-other-panes", function(window, pane)
	local tab = pane:tab()
	local panes = tab:panes()

	for _, p in ipairs(panes) do
		if p:pane_id() ~= pane:pane_id() then
			p:activate()
			window:perform_action(wezterm.action.CloseCurrentPane({ confirm = false }), p)
		end
	end
end)

wezterm.on("close-all-other-tabs", function(window, pane)
	local tab = window:active_tab()
	local mux_window = window:mux_window()
	local tabs = mux_window:tabs()

	for _, t in ipairs(tabs) do
		if t:tab_id() ~= tab:tab_id() then
			t:activate()
			window:perform_action(wezterm.action.CloseCurrentTab({ confirm = false }), pane)
		end
	end
end)

config.key_tables = {

	pane = {
		{ key = "d", action = action.CloseCurrentPane({ confirm = true }) },
		{ key = "o", action = action.EmitEvent("close-all-other-panes") },
	},
	tab = {
		{ key = "Tab", action = action.SpawnTab("CurrentPaneDomain") },
		{ key = "d", action = action.CloseCurrentTab({ confirm = true }) },
		{ key = "o", action = action.EmitEvent("close-all-other-tabs") },
	},
	workspace = {
		{ key = "s", action = action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
		{
			key = "n",
			action = action.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter name for new workspace" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:perform_action(
							action.SwitchToWorkspace({
								name = line,
							}),
							pane
						)
					end
				end),
			}),
		},
	},
}

config.disable_default_mouse_bindings = true

smart_splits.apply_to_config(config, {
	direction_keys = {
		move = { "h", "j", "k", "l" },
		resize = { "LeftArrow", "DownArrow", "UpArrow", "RightArrow" },
		modifiers = {
			move = "CTRL",
			resize = "CTRL",
		},
	},
})

return config
