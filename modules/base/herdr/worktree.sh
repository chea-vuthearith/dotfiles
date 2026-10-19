# herdr-worktree: fuzzy-find a branch of the focused workspace's repo and go to its worktree. Bound in
# config.toml as a popup on prefix+g. Existing worktrees are opened (herdr reuses an open workspace),
# local and remote branches get a worktree created, and a query matching nothing creates a new branch
# from herdr's default base. ctrl-x removes the selected linked worktree.
cwd=${HERDR_ACTIVE_PANE_CWD:?not started from a herdr keybinding}

fail() {
  read -rsn1 -p " $1 failed, any key to close" || true
  exit 1
}

# One line per branch: name<TAB>kind, kind = worktree | checkout (primary) | branch | <remote>/<name>.
# First occurrence wins, so worktrees shadow branches and local branches shadow remote ones.
candidates() {
  {
    herdr worktree list --cwd "$cwd" | jq -r '.result.worktrees[] | select(.branch != null)
      | "\(.branch)\t\(if .is_linked_worktree then "worktree" else "checkout" end)"'
    git -C "$cwd" for-each-ref --format='%(refname:short)%09branch' refs/heads
    git -C "$cwd" for-each-ref --format='%(refname:lstrip=3)%09%(refname:lstrip=2)' refs/remotes
  } | awk -F'\t' '$1 != "HEAD" && !seen[$1]++'
}

rc=0
out=$(candidates | fzf --delimiter='\t' --print-query --expect=ctrl-x --prompt='worktree> ' \
  --header='enter go/create · ctrl-x remove · esc cancel') || rc=$?
# 1 = no match: the query alone names a new branch.
((rc <= 1)) || exit 0

mapfile -t lines <<<"$out"
query=${lines[0]:-}
key=${lines[1]:-}
sel=${lines[2]:-}
if [[ -n $sel ]]; then
  branch=${sel%%$'\t'*}
  kind=${sel#*$'\t'}
else
  branch=$query
  kind=new
fi
[[ -n $branch ]] || exit 0

if [[ $key == ctrl-x ]]; then
  [[ $kind == worktree ]] || fail "remove: $branch has no linked worktree,"
  id=$(herdr worktree open --cwd "$cwd" --branch "$branch" --no-focus |
    jq -r .result.workspace.workspace_id) || fail open
  herdr worktree remove --workspace "$id" >/dev/null || fail remove
  exit 0
fi

case $kind in
worktree | checkout) herdr worktree open --cwd "$cwd" --branch "$branch" --focus >/dev/null || fail open ;;
branch | new) herdr worktree create --cwd "$cwd" --branch "$branch" --focus >/dev/null || fail create ;;
*) herdr worktree create --cwd "$cwd" --branch "$branch" --base "$kind" --focus >/dev/null || fail create ;;
esac
