fzf-history-backward() {
  local selected
  selected=$(fc -l 1 | sed 's/^[ ]*[0-9]\+\**[ ]*//' | fzf --tac +s --query "$LBUFFER")
  if [[ -n $selected ]]; then
    BUFFER="$selected"
    CURSOR=${#BUFFER}
    zle redisplay
  fi
}
zle -N fzf-history-backward

fzf-history-forward() {
  local selected
  selected=$(fc -l 1 | sed 's/^[ ]*[0-9]\+\**[ ]*//' | fzf +s --query "$LBUFFER")
  if [[ -n $selected ]]; then
    BUFFER="$selected"
    CURSOR=${#BUFFER}
    zle redisplay
  fi
}
zle -N fzf-history-forward

# Conditional history navigation
history-backwards-or-complete() {
  if [[ $LBUFFER == *[![:space:]]* ]]; then
    zle menu-select
  else
    fzf-history-backward
  fi
}
zle -N history-backwards-or-complete

history-forwards-or-complete() {
  if [[ $LBUFFER == *[![:space:]]* ]]; then
    zle menu-select
  else
    fzf-history-forward
  fi
}
zle -N history-forwards-or-complete
