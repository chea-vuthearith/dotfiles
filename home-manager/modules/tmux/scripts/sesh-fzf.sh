sesh list --icons | fzf-tmux -p 80%,70% \
  --no-sort \
  --ansi \
  --header "  ^a all ^t tmux ^x zoxide ^d kill" \
  --bind 'ctrl-a:reload(sesh list --icons)' \
  --bind 'ctrl-t:change-prompt(  )+reload(sesh list -t --icons)' \
  --bind 'ctrl-x:change-prompt(󰈞  )+reload(sesh list -z --icons)' \
  --bind 'ctrl-d:reload(
    name={2..}
    if sesh list -T | grep -qxF "$name"; then
      if output=$(tmuxinator stop "$name" 2>&1); then
        notify-send "Tmux" "Session stopped: $name"
      else
        notify-send -u critical "Tmux" "Failed to stop session: $name\n$output"
      fi
    else
      if output=$(tmux kill-session -t "$name" 2>&1); then
        notify-send "Tmux" "Session killed: $name"
      else
        notify-send -u critical "Tmux" "Failed to kill session: $name\n$output"
      fi
    fi
    sesh list --icons
  )' \
  --preview-window "right:55%" \
  --preview "sesh preview {}"
