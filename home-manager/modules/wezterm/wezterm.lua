local wezterm = require("wezterm")
local config = wezterm.config_builder()
wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
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
	{
		key = "s",
		mods = "LEADER",
		action = action.ActivateKeyTable({ name = "workspace" }),
	},
	-- disable
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
	copy_mode = {
		{
			key = "/",
			action = action.Multiple({
				action.CopyMode("ClearPattern"),
				action.Search({ CaseInSensitiveString = "a" }),
				action.CopyMode("ClearPattern"), -- hack since setting it to just "" wont work
			}),
		},
		{
			key = "*",
			mods = "SHIFT",
			action = wezterm.action.Search("CurrentSelectionOrEmptyString"),
		},
		{
			key = "J",
			mods = "CTRL|SHIFT",
			action = action.DisableDefaultAssignment,
		},

		{
			key = "n",
			mods = "NONE",
			action = action.Multiple({ action.CopyMode("NextMatch"), action.CopyMode("ClearSelectionMode") }),
		},
		{
			key = "N",
			mods = "SHIFT",
			action = action.Multiple({ action.CopyMode("PriorMatch"), action.CopyMode("ClearSelectionMode") }),
		},
		{
			key = "i",
			action = action.Multiple({
				action.CopyMode("ClearPattern"),
				action.CopyMode("AcceptPattern"),
				action.CopyMode("Close"),
			}),
		},
		{
			key = "Escape",
			action = action.Multiple({
				action.CopyMode("ClearPattern"),
				action.CopyMode("AcceptPattern"),
				action.CopyMode("Close"),
			}),
		},
		{
			key = "y",
			action = action.Multiple({
				action.CopyTo("ClipboardAndPrimarySelection"),
				action.CopyMode("Close"),
			}),
		},
	},

	search_mode = {
		{
			key = "Enter",
			action = action.Multiple({
				action.CopyMode("AcceptPattern"),
				action.CopyMode("ClearSelectionMode"),
			}),
		},
		{
			key = "Escape",
			action = action.Multiple({
				action.CopyMode("ClearPattern"),
				action.CopyMode("AcceptPattern"),
				action.CopyMode("ClearSelectionMode"),
			}),
		},
	},
}

for _, v in pairs(wezterm.gui.default_key_tables()["search_mode"]) do
	-- skip esc and enter
	if v.key ~= "mapped:\27" and v.key ~= "mapped:\13" then
		table.insert(config.key_tables.search_mode, v)
	end
end

for _, v in pairs(wezterm.gui.default_key_tables()["copy_mode"]) do
	if v.key ~= "mapped:\27" and v.key ~= "mapped:\13" then
		table.insert(config.key_tables.copy_mode, v)
	end
end

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
