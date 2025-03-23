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
  pkill wf-recorder &
else
  notify-send "Starting recording" 'recording_'"$(getdate)"'.mp4' -a 'record-script.sh'
  file='/recording_'"$(getdate)"'.mp4'

  if [[ "$1" == "--sound" ]]; then
    wf-recorder --pixel-format yuv420p -f ".$file" -t --geometry "$(slurp)" --audio="$(getaudiooutput)" &
    disown
  elif [[ "$1" == "--fullscreen-sound" ]]; then
    wf-recorder -o $(getactivemonitor) --pixel-format yuv420p -f ".$file" -t --audio="$(getaudiooutput)" &
    disown
  elif [[ "$1" == "--fullscreen" ]]; then
    wf-recorder -o $(getactivemonitor) --pixel-format yuv420p -f ".$file" -t &
    disown
  else
    wf-recorder --pixel-format yuv420p -f ".$file" -t --geometry "$(slurp)" &
    disown
  fi
  wl-copy --type text/uri-list "file://$PWD$file"
fi
