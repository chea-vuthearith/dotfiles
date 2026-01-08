history-or-complete() {
  if [[ $LBUFFER == *[![:space:]]* ]]; then
    zle menu-select
  else
    fzf-history-widget
  fi
}
zle -N history-or-complete
