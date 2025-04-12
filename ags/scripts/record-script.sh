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

mkdir -p "$(xdg-user-dir VIDEOS)"
cd "$(xdg-user-dir VIDEOS)" || exit
if pgrep wf-recorder >/dev/null; then
  notify-send "Recording Stopped" "Stopped" -a 'record-script.sh' &
  NAME="$(ps ax | grep 'wf-recorder' | head -n 1 | awk -F'wf-recorder:' '{print $2}' | awk '{print $1}')"
  wl-copy --type text/uri-list "$NAME"
  pkill wf-recorder

else
  FILE='/recording_'"$(getdate)"'.mp4'
  notify-send "Starting recording" "saving to $FILE" -a 'record-script.sh'
  WORKSPACES="$(hyprctl monitors -j | jq -r 'map(.activeWorkspace.id)')"
  WINDOWS="$(hyprctl clients -j | jq -r --argjson workspaces "$WORKSPACES" 'map(select([.workspace.id] | inside($workspaces)))')"
  GEOM=$(echo "$WINDOWS" | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp "$SLURP_ARGS")

  if [[ "$1" == "--sound" ]]; then
    exec -a "wf-recorder:file://$PWD$FILE" wf-recorder --pixel-format yuv420p -f ".$FILE" -t --geometry "$GEOM" --audio="$(getaudiooutput)" &
    disown
  elif [[ "$1" == "--fullscreen-sound" ]]; then
    exec -a "wf-recorder:file://$PWD$FILE" wf-recorder -o "$(getactivemonitor)" --pixel-format yuv420p -f ".$FILE" -t --audio="$(getaudiooutput)" &
    disown
  elif [[ "$1" == "--fullscreen" ]]; then
    exec -a "wf-recorder:file://$PWD$FILE" wf-recorder -o "$(getactivemonitor)" --pixel-format yuv420p -f ".$FILE" -t &
    disown
  else
    exec -a "wf-recorder:file://$PWD$FILE" wf-recorder --pixel-format yuv420p -f ".$FILE" -t --geometry "$GEOM" &
    disown
  fi
fi
