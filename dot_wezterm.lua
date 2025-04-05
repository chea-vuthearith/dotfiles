local wezterm = require("wezterm")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
local config = wezterm.config_builder()

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
config.color_scheme = "Catppuccin Mocha"
config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.window_background_opacity = 0.9
config.window_decorations = "RESIZE"

-- missing glyphs warning
config.warn_about_missing_glyphs = false

-- key bindings
local action = wezterm.action
config.leader = { key = "w", mods = "ALT", timeout_milliseconds = 2000 }
config.keys = {
	--tabs
	-- navigation
	{ key = "h", mods = "ALT", action = action.ActivateTabRelative(-1) },
	{ key = "l", mods = "ALT", action = action.ActivateTabRelative(1) },
	-- order
	{ key = "h", mods = "SHIFT|ALT", action = action.MoveTabRelative(-1) },
	{ key = "l", mods = "SHIFT|ALT", action = action.MoveTabRelative(1) },
	-- creation
	{ key = "t", mods = "LEADER", action = action.SpawnTab("CurrentPaneDomain") },

	-- panes
	-- creation
	{
		key = "|",
		mods = "LEADER|SHIFT",
		action = action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{ key = "-", mods = "LEADER", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	--focus
	{ key = "d", mods = "LEADER", action = action.CloseCurrentPane({ confirm = true }) },
	{ key = "z", mods = "ALT", action = action.TogglePaneZoomState },

	{ key = "v", mods = "LEADER", action = action.ActivateCopyMode },
	-- { key = "/", mods = "CTRL", action = wezterm.action.EmitEvent("toggle-terminal") },

	-- workspaces
	{ key = "w", mods = "LEADER", action = action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{
		key = "w",
		mods = "LEADER|SHIFT",
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

-- if focused tab is term
-- focus up & zoom
-- else
-- if bottom toggle term
-- botom:focus
-- else
-- split pane bottom
-- bottom:focus
-- local function is_toggle_term(pane)
-- 	return pane:get_user_vars().toggle_term
-- end
--
-- wezterm.on("toggle-terminal", function(window, pane)
-- 	local tab = pane:tab()
-- 	local panes = tab:panes()
--
-- 	local term_pane = nil
-- 	for _, p in ipairs(panes) do
-- 		if is_toggle_term(p) then
-- 			term_pane = p
-- 			break
-- 		end
-- 	end
--
-- 	if term_pane then
-- 		local is_term_pane_active = term_pane:get_dimensions().viewport_rows > 5
-- 		if is_term_pane_active then
-- 			window:perform_action(action.AdjustPaneSize({ "Down", 1000 }), term_pane)
-- 			local main_pane = tab:get_pane_direction("Up")
-- 			main_pane:activate()
-- 		else
-- 			window:perform_action(action.AdjustPaneSize({ "Up", 5 }), term_pane)
-- 			term_pane:activate()
-- 		end
-- 	else
-- 		local new_pane = pane:split({
-- 			direction = "Bottom",
-- 			domain = "CurrentPaneDomain",
-- 			size = 0.001,
-- 		})
-- 		window:perform_action(action.AdjustPaneSize({ "Up", 5 }), new_pane)
-- 		local cmd = [[printf "\033]1337;SetUserVar=toggle_term=]] .. "$(echo -n 1 | base64)" .. [[\007"]]
-- 		new_pane:send_text(cmd .. "\n")
-- 		-- new_pane:activate()
-- 	end
-- end)

-- wezterm.on("user-var-changed", function(window, pane, name, value)
-- 	-- wezterm.log_info("var", name, value)
-- 	window:toast_notification("wezterm", value, nil, 4000)
-- end)
-- if term_pane then
-- 	if term_pane:is_zoomed() then
-- term_pane:toggle_zoom() -- unzoom first
-- 		window:perform_action(wezterm.action.ActivatePaneDirection("Down"), pane)
-- 	else
-- 		window:perform_action(wezterm.action.ActivatePaneDirection("Up"), pane)
-- 		term_pane:toggle_zoom()
-- 	end
-- else
-- 	-- create a bottom pane
-- 	local new_pane = pane:split({
-- 		direction = "Bottom",
-- 		size = 0.3,
-- 	})
-- 	-- tag this pane
-- 	new_pane:set_title("toggle_terminal")
-- 	-- optional: run shell or something
-- 	-- new_pane:send_text("clear\n") -- or any init command

config.disable_default_mouse_bindings = true

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

smart_splits.apply_to_config(config, {
	direction_keys = {
		move = { "h", "j", "k", "l" },
		resize = { "LeftArrow", "DownArrow", "UpArrow", "RightArrow" },
	},
})

return config
