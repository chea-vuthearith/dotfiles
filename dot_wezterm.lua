local wezterm = require("wezterm")
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
config.window_background_opacity = 0.9
config.window_decorations = "RESIZE"
-- tab bar
local bar = wezterm.plugin.require("https://github.com/chea-vuthearith/bar.wezterm")
bar.apply_to_config(config, {
	separator = {
		space = 1,
		left_icon = wezterm.nerdfonts.cod_circle_filled,
		right_icon = wezterm.nerdfonts.cod_circle_filled,
	},
	padding = {
		tabs = {
			left = 1,
			right = 1,
		},
	},
	modules = {
		pane = { enabled = false },
		zoom = { enabled = true },
		username = { enabled = false },
		hostname = { enabled = false },
		cwd = { enabled = false },
		clock = { enabled = true, format = "%I:%M %p" },
	},
})
local bg_color = "#000"
config.colors = {
	background = bg_color,
	tab_bar = {
		background = "transparent",
		inactive_tab = {
			fg_color = "#CDD6F4",
			bg_color = "transparent",
		},
		new_tab = {
			fg_color = bg_color,
			bg_color = bg_color,
		},
	},
}
-- swap panes

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
			window:perform_action(action.CloseCurrentPane({ confirm = false }), p)
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
		{ key = "f", action = action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
		{
			key = "s",
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

local function is_vim(pane)
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
	RightArrow = "Right",
	DownArrow = "Down",
	UpArrow = "Up",
	LeftArrow = "Left",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action(action.AdjustPaneSize({ direction_keys[key], 3 }), pane)
				else
					win:perform_action(action.ActivatePaneDirection(direction_keys[key]), pane)
				end
			end
		end),
	}
end

local smart_splits_keys = {
	-- move between split panes
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	-- resize panes
	split_nav("resize", "RightArrow"),
	split_nav("resize", "DownArrow"),
	split_nav("resize", "UpArrow"),
	split_nav("resize", "LeftArrow"),
}

for _, x in pairs(smart_splits_keys) do
	table.insert(config.keys, x)
end

return config
