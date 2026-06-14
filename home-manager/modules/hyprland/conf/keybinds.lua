local hs = require("hyprsplit")

local mainMod = "SUPER"
local browserCmd =
	"brave-origin --hide-crash-restore-bubble --test-type -enable-features=UseOzonePlatform --ozone-platform=wayland"
local totalMonitors = #hl.get_monitors()

-- # Emoji picker
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("dms screenshot --no-file"))
hl.bind(mainMod .. " + SHIFT + ALT + S", hl.dsp.exec_cmd("dms screenshot --stdout | swappy -f -"))

-- OCR
hl.bind(
	mainMod .. " + SHIFT + T",
	hl.dsp.exec_cmd(
		'grim -g "$(slurp $SLURP_ARGS)" "tmp.png" && tesseract -l eng "tmp.png" - | wl-copy && rm "tmp.png"'
	)
)

-- Color picker
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- Recording stuff
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("dms ipc call screenRecorder toggleRecording"))

-- ##! Workspace navigation
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hs.dsp.focus({ workspace = i }), { submap_universal = true })
	hl.bind(mainMod .. " + SHIFT + " .. key, hs.dsp.window.move({ workspace = i }), { submap_universal = true })
end

hl.define_submap("overview", function()
	hl.bind("catchall", function()
		hl.dispatch(hl.dsp.exec_cmd("dms ipc call hypr toggleOverview"))
		hl.dispatch(hl.dsp.submap("reset"))
	end)
end)

hl.bind(mainMod .. " + Tab", function()
	hl.dispatch(hl.dsp.exec_cmd("dms ipc call hypr toggleOverview"))
	hl.dispatch(hl.dsp.submap("overview"))
end)

-- dynamic-cursors magnify
hl.bind(mainMod .. " + Z", hl.plugin.dynamic_cursors.dsp_magnify({ duration = 100, size = 4.0 }), { repeating = true })

-- ##! System Controls
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+"),
	{ locked = true, repeatable = true }
)
hl.bind(
	"SHIFT + XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_SOURCE@ 10%+"),
	{ locked = true, repeatable = true }
)
hl.bind(
	"SHIFT + XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_SOURCE@ 10%-"),
	{ locked = true, repeatable = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"),
	{ locked = true, repeatable = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +10%"), { locked = true, repeatable = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeatable = true })
hl.bind("SHIFT + XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +1%"), { locked = true, repeatable = true })
hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 1%-"), { locked = true, repeatable = true })
hl.bind("XF86Poweroff", hl.dsp.exec_cmd("wlogout"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("dms ipc call powermenu toggle"))
hl.bind("CTRL + ALT + Backspace", hl.dsp.exec_cmd("dms ipc call lock lock"))

hl.define_submap("dpms", "reset", function()
	hl.bind("1", function()
		hl.timer(function()
			hl.dispatch(hl.dsp.dpms({ action = "toggle", monitor = "DP-1" }))
		end, { timeout = 1, type = "oneshot" })
	end)
	hl.bind("2", function()
		hl.timer(function()
			hl.dispatch(hl.dsp.dpms({ action = "toggle", monitor = "DP-3" }))
		end, { timeout = 1, type = "oneshot" })
	end)

	hl.bind("a", function()
		hl.timer(function()
			hl.dispatch(hl.dsp.dpms({ action = "toggle" }))
		end, { timeout = 1, type = "oneshot" })
	end)

	hl.bind("catchall", hl.dsp.submap("reset"))
end)
hl.bind(mainMod .. " + M", hl.dsp.submap("dpms"))

-- ##! Apps
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("dms ipc call notifications toggle"))
hl.bind(mainMod .. " + D", function()
	hl.dispatch(hl.dsp.exec_cmd("dms ipc call notifications clearAll"))
	hl.dispatch(hl.dsp.exec_cmd("dms ipc call notifications dismissAllPopups"))
end)
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("dms ipc call settings toggle"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("ghostty -e yazi"))

hl.bind(mainMod .. " + Escape", function()
	for i = 0, totalMonitors - 1 do
		hl.dispatch(hl.dsp.exec_cmd(string.format("dms ipc call bar toggle index %d", i)))
	end
end)
hl.bind("CTRL + " .. mainMod .. " + V", hl.dsp.exec_cmd("pavucontrol"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("dms ipc call launcher toggle"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browserCmd .. ' --profile-directory="Default"'))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(browserCmd .. ' --profile-directory="Profile 1"'))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("ghostty"))

-- ##! Layout
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

-- Resize windows
hl.bind(mainMod .. " + Left", hl.dsp.window.resize({ x = -100, y = 0 }), { repeatable = true })
hl.bind(mainMod .. " + Right", hl.dsp.window.resize({ x = 100, y = 0 }), { repeatable = true })
hl.bind(mainMod .. " + Up", hl.dsp.window.resize({ x = 0, y = -100 }), { repeatable = true })
hl.bind(mainMod .. " + Down", hl.dsp.window.resize({ x = 0, y = 100 }), { repeatable = true })

-- Reposition Windows
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))

-- Mouse binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Testing
hl.bind(
	mainMod .. " + ALT + F12",
	hl.dsp.exec_cmd(
		'notify-send \'Test notification\' "Here\'s a really long message to test truncation and wrapping\\nYou can middle click or flick this notification to dismiss it!" -a \'Shell\' -A "Test1=I got it!" -A "Test2=Another action" -t 5000'
	)
)
hl.bind(
	mainMod .. " + ALT + Equal",
	hl.dsp.exec_cmd('notify-send "Urgent notification" "Ah hell no" -u critical -a \'Hyprland keybind\'')
)

-- ##! Media
hl.bind("CTRL + " .. mainMod .. "+ N", hl.dsp.exec_cmd("playerctl next"))
hl.bind("CTRL + " .. mainMod .. "+ P", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("CTRL + " .. mainMod .. "+ Space", hl.dsp.exec_cmd("playerctl play-pause"))
