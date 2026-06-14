hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 0,
		gaps_workspaces = 50,
		border_size = 0,

		resize_on_border = true,
		no_focus_fallback = true,
		layout = "dwindle",

		allow_tearing = true,
	},

	dwindle = {
		preserve_split = true,
		smart_split = false,
		smart_resizing = false,
	},

	decoration = {
		rounding = 16,

		blur = {
			enabled = true,
			new_optimizations = true,
			popups = true,
			popups_ignorealpha = 0.6,
			xray = true,
		},

		shadow = {
			enabled = true,
			range = 20,
			offset = { 0, 2 },
			render_power = 4,
		},

		active_opacity = 1.0,
		inactive_opacity = 0.95,

		dim_inactive = false,
		dim_strength = 0.2,
		dim_special = 0,
	},

	cursor = {
		no_hardware_cursors = false,
		hide_on_key_press = true,
		inactive_timeout = 3,
	},

	animations = {
		enabled = true,
	},
	misc = {
		vrr = 0,
		animate_manual_resizes = true,
		animate_mouse_windowdragging = false,
		enable_swallow = false,
		swallow_regex = "(foot|kitty|allacritty|Alacritty)",
		disable_hyprland_logo = true,
		force_default_wallpaper = 0,
		allow_session_lock_restore = true,
		initial_workspace_tracking = 1,
		mouse_move_focuses_monitor = false,
	},

	render = {
		cm_enabled = false,
	},
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "caps:swapescape",
		kb_rules = "",

		follow_mouse = 0,
		accel_profile = "flat",
		sensitivity = 0,

		numlock_by_default = true,
		repeat_delay = 250,
		repeat_rate = 35,

		special_fallthrough = true,

		touchpad = {
			drag_lock = true,
			natural_scroll = true,
			disable_while_typing = true,
			clickfinger_behavior = true,
			scroll_factor = 0.5,
		},
	},
	debug = {
		disable_logs = false,
		enable_stdout_logs = true,
	},
})

hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })

-- Animations
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "liner", style = "loop" })
hl.animation({ leaf = "fade", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "wind", style = "slidefade 20%" })

if hl.plugin.dynamic_cursors then
	hl.config({
		plugin = {
			dynamic_cursors = {
				mode = "stretch",
				shake = {
					threshold = 99999, -- disable shake to magnify but enable by keybind
				},
			},
		},
	})
end
