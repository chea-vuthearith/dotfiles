sesh list --icons | fzf-tmux -p 80%,70% \
  --no-sort \
  --ansi \
  --header "  ^a all ^t tmux ^x zoxide ^d kill" \
  --bind 'tab:down,btab:up' \
  --bind 'ctrl-a:reload(sesh list --icons)' \
  --bind 'ctrl-t:change-prompt(  )+reload(sesh list -t --icons)' \
  --bind 'ctrl-x:change-prompt(󰈞  )+reload(sesh list -z --icons)' \
  --bind 'ctrl-d:reload(
    name={2..}
    notify-send "sesh debug" "selected: $name"
    if sesh list -T | grep -qxF "$name"; then
      notify-send "sesh debug" "tmuxinator stopping [$name]"
      if output=$(tmuxinator stop "$name" 2>&1); then
        notify-send "sesh debug" "tmuxinator OK: $name\n$output"
      else
        notify-send -u critical "sesh debug" "tmuxinator FAIL: $name\n$output"
      fi
    else
      notify-send "sesh debug" "killing tmux session $name"
      if output=$(tmux kill-session -t "$name" 2>&1); then
        notify-send "sesh debug" "tmux OK: $name\n$output"
      else
        notify-send -u critical "sesh debug" "tmux FAIL: $name\n$output"
      fi
    fi
    notify-send "sesh debug" "reloading session list"
    sesh list --icons
  )' \
  --preview-window "right:55%" \
  --preview "sesh preview {}"
