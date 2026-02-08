#!/usr/bin/env bash
set -euo pipefail

getdate() {
	date '+%Y-%m-%d_%H.%M.%S'
}

getaudiooutput() {
	pactl list sources | grep 'Name' | grep 'monitor' | cut -d ' ' -f2
}

getactivemonitor() {
	hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

# Ensure the Videos directory exists and move into it
VIDEOS_DIR="$(xdg-user-dir VIDEOS)"
mkdir -p "$VIDEOS_DIR"

# Set SLURP_ARGS if not already set (can be overridden by environment)
SLURP_ARGS="${SLURP_ARGS:-}"

# Use runtime dir for pid/out storage
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
PIDFILE="$XDG_RUNTIME_DIR/wf-recorder.pid"
OUTFILE="$XDG_RUNTIME_DIR/wf-recorder.out"

# If pidfile exists and process is alive, stop it
if [ -f "$PIDFILE" ]; then
	pid=$(cat "$PIDFILE" 2>/dev/null || true)
	if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
		notify-send "Recording Stopped" "Stopped" -a 'record-script.sh' &
		if [ -f "$OUTFILE" ]; then
			wl-copy --type text/uri-list "$(cat "$OUTFILE")"
		fi
		kill "$pid" || pkill -f wf-recorder
		rm -f "$PIDFILE" "$OUTFILE"
		exit 0
	else
		rm -f "$PIDFILE" "$OUTFILE"
	fi
fi

# Fallback: if wf-recorder is running without pidfile, stop all matching instances
if pgrep wf-recorder >/dev/null; then
	notify-send "Recording Stopped" "Stopped" -a 'record-script.sh' &
	# Iterate over all wf-recorder processes and kill them, copying their outputs if found
	pgrep -a wf-recorder | while read -r pid cmdline; do
		# try to extract file:// path from the command line
		filePath=$(echo "$cmdline" | sed -n 's/.*file:\/\///p' | awk '{print $1}')
		if [ -n "$filePath" ]; then
			wl-copy --type text/uri-list "$filePath"
		fi
		kill "$pid" 2>/dev/null || pkill -f "wf-recorder"
	done
	exit 0
fi

# Start recording
WORKSPACES="$(hyprctl monitors -j | jq -r 'map(.activeWorkspace.id)')"
WINDOWS="$(hyprctl clients -j | jq -r --argjson workspaces "$WORKSPACES" 'map(select([.workspace.id] | inside($workspaces)))')"
GEOM=$(echo "$WINDOWS" | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp $SLURP_ARGS)

if [[ -z "$GEOM" ]]; then
	exit 1
fi

OUT="$VIDEOS_DIR/recording_$(getdate).mp4"
notify-send "Starting recording" "Saving to $VIDEOS_DIR" -a 'record-script.sh'

case "$1" in
--sound)
	wf-recorder --pixel-format yuv420p -f "$OUT" -t --geometry "$GEOM" --audio="$(getaudiooutput)" &
	pid=$!
	;;
--fullscreen-sound)
	wf-recorder -o "$(getactivemonitor)" --pixel-format yuv420p -f "$OUT" -t --audio="$(getaudiooutput)" &
	pid=$!
	;;
--fullscreen)
	wf-recorder -o "$(getactivemonitor)" --pixel-format yuv420p -f "$OUT" -t &
	pid=$!
	;;
*)
	wf-recorder --pixel-format yuv420p -f "$OUT" -t --geometry "$GEOM" &
	pid=$!
	;;

esac

# Detach and record pid/outfile for later stopping
disown "$pid" 2>/dev/null || true
echo "$pid" >"$PIDFILE"
echo "$OUT" >"$OUTFILE"
