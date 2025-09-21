#!/usr/bin/env bash

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

if pgrep wf-recorder >/dev/null; then
  # Stop recording
  notify-send "Recording Stopped" "Stopped" -a 'record-script.sh' &
  NAME="$(ps ax | grep 'wf-recorder' | head -n 1 | awk -F'wf-recorder:' '{print $2}' | awk '{print $1}')"
  wl-copy --type text/uri-list "$NAME"
  pkill wf-recorder
else
  # Start recording

  WORKSPACES="$(hyprctl monitors -j | jq -r 'map(.activeWorkspace.id)')"
  WINDOWS="$(hyprctl clients -j | jq -r --argjson workspaces "$WORKSPACES" 'map(select([.workspace.id] | inside($workspaces)))')"
  GEOM=$(echo "$WINDOWS" | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp "$SLURP_ARGS")

  if [[ -z "$GEOM" ]]; then
    exit 1
  fi

  OUT="$VIDEOS_DIR/recording_$(getdate).mp4"
  notify-send "Starting recording" "Saving to $VIDEOS_DIR" -a 'record-script.sh'

  case "$1" in
  --sound)
    exec -a "wf-recorder:file://$OUT" wf-recorder --pixel-format yuv420p -f "$OUT" -t --geometry "$GEOM" --audio="$(getaudiooutput)" &
    disown
    ;;
  --fullscreen-sound)
    exec -a "wf-recorder:file://$OUT" wf-recorder -o "$(getactivemonitor)" --pixel-format yuv420p -f "$OUT" -t --audio="$(getaudiooutput)" &
    disown
    ;;
  --fullscreen)
    exec -a "wf-recorder:file://$OUT" wf-recorder -o "$(getactivemonitor)" --pixel-format yuv420p -f "$OUT" -t &
    disown
    ;;
  *)
    exec -a "wf-recorder:file://$OUT" wf-recorder --pixel-format yuv420p -f "$OUT" -t --geometry "$GEOM" &
    disown
    ;;
  esac
fi
