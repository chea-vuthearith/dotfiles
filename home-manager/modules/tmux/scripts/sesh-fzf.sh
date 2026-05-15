sesh list --icons | fzf-tmux -p 80%,70% \
  --no-sort \
  --ansi \
  --header "  ^a all ^t tmux ^x zoxide ^d kill" \
  --bind 'ctrl-a:reload(sesh list --icons)' \
  --bind 'ctrl-t:change-prompt(  )+reload(sesh list -t --icons)' \
  --bind 'ctrl-x:change-prompt(󰈞  )+reload(sesh list -z --icons)' \
  --bind 'ctrl-d:execute-silent(
    name={2..};

    if sesh list -T | grep -qxF "$name"; then
      notify-send "Tmuxinator" "Stopping $name"

      nohup sh -c '\''

        if output=$(tmuxinator stop "$1" 2>&1); then
          notify-send "Tmux" "Stopped tmuxinator project: $1"
        else
          notify-send -u critical "Tmuxinator" "Failed to stop $1 \n$output"
        fi

      '\'' sh "$name" >/dev/null 2>&1 &
    else
      if ! output=$(tmux kill-session -t "$name" 2>&1); then
        notify-send -u critical "Tmux" "Failed to kill session: $name\n$output"
      fi
    fi
  )+reload(sesh list --icons)' \
  --preview-window "right:55%" \
  --preview "sesh preview {}"
