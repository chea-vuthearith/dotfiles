# herdr-chord tab|pane|workspace|worktree: tmux-style second key after the prefix. Bound in config.toml
# as a popup on prefix+tab / prefix+w / prefix+s / prefix+g; reads one key and acts on the
# tab/pane/workspace that was focused when the popup opened (herdr passes HERDR_ACTIVE_* to popup
# commands, not HERDR_PANE_ID).
target=${1:?usage: herdr-chord tab|pane|workspace|worktree}
ws=${HERDR_ACTIVE_WORKSPACE_ID:?not started from a herdr keybinding}
tab=${HERDR_ACTIVE_TAB_ID:?}
pane=${HERDR_ACTIVE_PANE_ID:?}
cwd=${HERDR_ACTIVE_PANE_CWD:-$HOME}

case $target in
tab) hint='tab new · d close · r rename · h close left · l close right · esc cancel' ;;
pane) hint='w split right · d close · r rename · esc cancel' ;;
workspace) hint='s new · d close · r rename · esc cancel' ;;
worktree) hint='g new · o open · d remove · esc cancel' ;;
*)
  echo "unknown target: $target" >&2
  exit 2
  ;;
esac

printf ' %s' "$hint"
IFS= read -rsn1 key || exit 0
printf '\r\e[K'

rename() {
  local label
  IFS= read -rep " rename $1: " label || exit 0
  if [[ -n $label ]]; then herdr "$1" rename "$2" "$label" >/dev/null; fi
}

# Create (new) or open (open) a worktree of the focused workspace's repo for a prompted branch.
worktree() {
  local branch
  IFS= read -rep " $1 worktree branch: " branch || exit 0
  [[ -n $branch ]] || exit 0
  if [[ $1 == new ]]; then
    herdr worktree create --workspace "$ws" --cwd "$cwd" --branch "$branch" --focus >/dev/null
  else
    herdr worktree open --branch "$branch" --workspace "$ws" --cwd "$cwd" --focus >/dev/null
  fi
}

# Close every tab of this workspace left (h) or right (l) of the current one.
close_side() {
  local ids t
  mapfile -t ids < <(herdr tab list --workspace "$ws" | jq -r --arg t "$tab" --arg side "$1" '
    .result.tabs | map(.tab_id) | index($t) as $i
    | (if $side == "h" then .[:$i] else .[$i + 1:] end)[]')
  for t in "${ids[@]}"; do herdr tab close "$t" >/dev/null; done
}

case $target:$key in
tab:$'\t') herdr tab create --workspace "$ws" --cwd "$cwd" --focus >/dev/null ;;
tab:d) herdr tab close "$tab" >/dev/null ;;
tab:r) rename tab "$tab" ;;
tab:h | tab:l) close_side "$key" ;;
pane:w) herdr pane split --pane "$pane" --direction right --cwd "$cwd" --focus >/dev/null ;;
pane:d) herdr pane close "$pane" >/dev/null ;;
pane:r) rename pane "$pane" ;;
workspace:s) herdr workspace create --cwd "$cwd" --focus >/dev/null ;;
workspace:d) herdr workspace close "$ws" >/dev/null ;;
workspace:r) rename workspace "$ws" ;;
worktree:g) worktree new ;;
worktree:o) worktree open ;;
worktree:d) herdr worktree remove --workspace "$ws" >/dev/null ;;
esac
