hl.window_rule({
	name = "dialog-open-file",
	match = { title = "^(Open File)(.*)$" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "dialog-select-file",
	match = { title = "^(Select a File)(.*)$" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "dialog-choose-wallpaper",
	match = { title = "^(Choose wallpaper)(.*)$" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "dialog-open-folder",
	match = { title = "^(Open Folder)(.*)$" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "dialog-save-as",
	match = { title = "^(Save As)(.*)$" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "dialog-library",
	match = { title = "^(Library)(.*)$" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "dialog-file-upload",
	match = { title = "^(File Upload)(.*)$" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "float-opacity",
	match = { float = true },
	opacity = "2",
})

-- Picture-in-Picture windows
hl.window_rule({
	name = "pip-window",
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	float = true,
	keep_aspect_ratio = true,
	move = "73% 72%",
	size = "25% 25%",
	pin = true,
})

-- Game rules
hl.window_rule({
	name = "game-immediate",
	match = { title = ".*\\.exe" },
	immediate = true,
})

hl.window_rule({
	name = "steam-app-immediate",
	match = { class = "^(steam_app)(.*)$" },
	immediate = true,
})

hl.window_rule({
	name = "steam-app-tile",
	match = { initial_class = "^(steam_app)(.*)$" },
	tile = true,
})

hl.window_rule({
	name = "vulkan-game",
	match = { title = ".*Vulkan.*" },
	idle_inhibit = "fullscreen",
	immediate = true,
})

-- No shadow for tiled windows
hl.window_rule({
	name = "tiled-no-shadow",
	match = { float = false },
	no_shadow = true,
})

hl.window_rule({
	name = "no-blur-all",
	match = { class = ".*" },
	no_blur = true,
})

-- Screenshare
hl.window_rule({
	name = "no-screen-share",
	match = { class = ".*(telegram|discord|slack|element|mattermost-desktop).*" },
	no_screen_share = true,
})

hl.layer_rule({
	name = "no-notifs-screenshare",
	match = {
		namespace = "dms:notification-center-popout|dms:notification-popup|dms:notification-center-modal",
	},
	no_screen_share = true,
})

hl.layer_rule({
	name = "no-anim-hyprpicker",
	match = { class = "hyprpicker" },
	no_anim = true,
})

hl.layer_rule({
	name = "ignore-alpha-notifications",
	match = { class = "notifications" },
	ignore_alpha = 0.69,
})

hl.layer_rule({
	name = "blur-wlogout",
	match = { class = "logout_dialog" },
	blur = true,
})

hl.layer_rule({
	name = "xray-all",
	match = { class = ".*" },
	xray = true,
})
