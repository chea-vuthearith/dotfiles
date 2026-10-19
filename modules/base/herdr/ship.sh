# herdr-ship: move omp sessions out of local herdr panes onto another machine's herdr server, so
# they keep running while this machine is off. Per pane:
#   1. stop omp here: /exit when it is idle, SIGKILL when it is mid-turn or blocked
#   2. mirror its files to the same paths on the target with rsync: the git repo of the session's
#      cwd (main checkout plus worktree) and every --path. Gitignored files are included;
#      dependency/cache dirs like node_modules and .venv are skipped and left as they are there;
#      anything overwritten or deleted there is kept under ~/.local/state/herdr-ship/backup
#   3. hand the session file over (omp session pack / unpack) and mark the local copy moved
#   4. start `omp --restore` in a new tab of the target's workspace with the same label;
#      --restore also finishes a turn that step 1 cut off
# --ask ships nothing itself: it asks each agent to work out the files it needs and ship itself.
# An agent can ship itself: the script detaches, waits for its turn to end, ships it, and
# prompts "continue" on the target.
# Bound in config.toml: prefix+m asks the focused agent, prefix+shift+m ships every omp pane now.
usage="usage: herdr-ship [--to MACHINE] [--path PATH]... [--ask] [--all | PANE...]
  MACHINE  a saved herdr machine (herdr machine list), default server
  PATH     extra file or dir the work needs, mirrored to the same path (the cwd's git repo is automatic)
  --ask    prompt the agents to pick their paths and ship themselves instead of shipping them now
  PANE     default: the focused pane from a herdr keybinding, else the calling agent's own pane"

machine=server
all=0
ask=0
panes=()
paths=()
while (($#)); do
  case $1 in
  --to) machine=${2:?$usage} && shift ;;
  --path) paths+=("$(realpath -m "${2:?$usage}")") && shift ;;
  --ask) ask=1 ;;
  --all) all=1 ;;
  -h | --help) echo "$usage" && exit 0 ;;
  -*) echo "$usage" >&2 && exit 2 ;;
  *) panes+=("$1") ;;
  esac
  shift
done

say() { printf '%s\n' "$*" >&2; }
die() {
  say "herdr-ship: $*"
  exit 1
}
# Started from a keybinding popup: keep the output on screen until a key is pressed.
popup=0
[[ -n ${HERDR_ACTIVE_PANE_ID:-} && -t 0 ]] && popup=1
pause() { if ((popup)); then read -rsn1 -p "any key to close" || true; fi; }
trap pause EXIT

[[ ${HERDR_ENV:-} == 1 || -n ${HERDR_SOCKET_PATH:-} ]] || die "run it inside herdr"
[[ $machine != "$(hostname)" ]] || die "already on $machine; pass --to <machine>"

# The calling agent's pane (live id; HERDR_PANE_ID goes stale after a pane move). A keybinding
# popup is not an agent pane: its target is HERDR_ACTIVE_PANE_ID.
me=
[[ -n ${HERDR_ACTIVE_PANE_ID:-} ]] ||
  me=$(herdr pane current --current 2>/dev/null | jq -r '.result.pane.pane_id // empty' || true)

if ((all)); then
  mapfile -t panes < <(herdr agent list | jq -r '.result.agents[] | select(.agent == "omp") | .pane_id')
elif ((${#panes[@]} == 0)); then
  panes=("${HERDR_ACTIVE_PANE_ID:-$me}")
  [[ -n ${panes[0]} ]] || die "no pane given; $usage"
fi
((${#panes[@]})) || die "no omp panes to ship"
for p in "${paths[@]}"; do
  [[ -e $p ]] || die "--path $p does not exist"
  # --delete on a parent of home would wipe the target's home
  [[ $HOME/ != "${p%/}"/* ]] || die "--path $p contains your home dir; name the folders inside it"
done

if ((ask)); then
  for p in "${panes[@]}"; do
    msg="[herdr-ship] The user wants this session moved to $machine so it keeps running there. "
    msg+="Work out which files and folders the remaining work needs on $machine: the git repo of your "
    msg+="working directory is mirrored automatically, so list anything else (other repos, data, notes, "
    msg+="files outside a repo). Then, as the LAST action of your turn, run "
    msg+="\`herdr-ship --to $machine --path <path> ...\` (no --path if the repo is enough) and end the turn; "
    msg+="a \"continue\" prompt arrives on $machine."
    if herdr agent prompt "$p" "$msg" >/dev/null; then say "$p: asked"; else say "$p: not asked (blocked or no agent)"; fi
  done
  exit 0
fi

# The target: a saved herdr machine (herdr --machine) whose SSH target also carries rsync/omp.
target=$(herdr machine list --json | jq -r --arg m "$machine" 'first(.[] | select(.label == $m or .id == $m) | .target) // empty')
[[ -n $target ]] || die "no saved herdr machine '$machine' (herdr machine list)"
remote=(herdr --machine "$machine")
ssh_() { ssh -o BatchMode=yes "$target" "$@"; }
q() { printf '%q' "$1"; }

# An agent shipping its own pane: detach first, since stopping omp kills its tool processes.
if [[ -n $me && " ${panes[*]} " == *" $me "* && -z ${HERDR_SHIP_DETACHED:-} ]]; then
  mkdir -p "$HOME/.local/state/herdr-ship"
  log=$HOME/.local/state/herdr-ship/$(date +%Y%m%d-%H%M%S).log
  args=(--to "$machine")
  for p in "${paths[@]}"; do args+=(--path "$p"); done
  HERDR_SHIP_DETACHED=1 setsid -f "$0" "${args[@]}" "${panes[@]}" >"$log" 2>&1 </dev/null
  say "shipping ${panes[*]} to $machine once this turn ends (log: $log)"
  exit 0
fi

say "checking $machine…"
herdr machine status "$machine" --json | jq -e --arg m "$machine" 'any(.[]; .label == $m and .status == "reachable")' >/dev/null ||
  die "$machine is not reachable (herdr machine status $machine)"
# shellcheck disable=SC2016 # $HOME expands on the target
rhome=$(ssh_ 'command -v omp >/dev/null && command -v rsync >/dev/null && echo "$HOME"') ||
  die "$machine needs omp and rsync on PATH"
stamp=$(date +%Y%m%d-%H%M%S)

status_of() { herdr pane get "$1" | jq -r '.result.pane.agent_status'; }

# Pids of a process and all its descendants, collected before anything is killed (orphans get reparented).
descendants() {
  local pid
  echo "$1"
  for pid in $(ps -o pid= --ppid "$1"); do descendants "$pid"; done
}

stop_omp() {
  local pane=$1 pid=$2 status=$3 i
  if [[ $status == idle || $status == "done" ]]; then
    herdr pane send-keys "$pane" ctrl+c >/dev/null # clear a draft so /exit is the whole input
    sleep 0.5
    herdr agent prompt "$pane" /exit >/dev/null || true
    for i in {1..30}; do
      kill -0 "$pid" 2>/dev/null || return 0
      sleep 0.5
    done
    say "  omp did not exit; killing it"
  fi
  # shellcheck disable=SC2046 # word splitting of the pid list is intended
  kill -KILL $(descendants "$pid") 2>/dev/null || true
  while kill -0 "$pid" 2>/dev/null; do sleep 0.2; done
}

# The repo a session works in. A linked worktree's .git file points into the main checkout's .git,
# and that .git (HEAD, index, refs) has to match the main checkout's files, so a worktree session
# mirrors the main checkout and the worktree; other worktrees of the repo stay as they are.
repo_dirs() {
  local top common
  top=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null) || return 0
  common=$(git -C "$1" rev-parse --path-format=absolute --git-common-dir)
  dirname "$common"
  [[ $top == "$(dirname "$common")" ]] || echo "$top"
}

# Regenerable dirs: not worth the transfer, and often machine-specific (venvs, nix store links).
# Excluded dirs are also protected from --delete, so the target keeps its own copies.
skip=(
  node_modules .venv venv __pycache__ .direnv .devenv
  .pytest_cache .mypy_cache .ruff_cache .tox .next .nuxt .turbo .parcel-cache .gradle .terraform
  /target /result # cargo, nix build output: only at the repo root
)

declare -A synced=()
# A dir is mirrored (--delete); a file is copied over. Backups keep their absolute path.
mirror() {
  local path=$1 s root opts
  [[ -z ${synced[$path]:-} ]] || return 0
  say "  mirroring $path"
  if [[ -d $path ]]; then
    root=$path
    opts=(--delete "$path/" "$target:$path/")
    for s in "${skip[@]}"; do opts+=(--exclude="$s/"); done
  else
    root=$(dirname "$path")
    opts=("$path" "$target:$path")
  fi
  ssh_ "mkdir -p $(q "$root")"
  rsync -a --info=progress2 --backup --backup-dir="$rhome/.local/state/herdr-ship/backup/$stamp$root" "${opts[@]}"
  synced[$path]=1
}

ship() {
  local pane=$1 info sess status name label ws wlabel pid cwd dir dirs tar rtar out rsess rws rp i
  info=$(herdr pane get "$pane" | jq -c '.result.pane')
  [[ $(jq -r .agent <<<"$info") == omp ]] || die "$pane: no omp running"
  sess=$(jq -r 'select(.agent_session.kind == "path") | .agent_session.value' <<<"$info")
  [[ -f $sess ]] || die "$pane: omp has not reported its session file (herdr integration status)"
  ws=$(jq -r .workspace_id <<<"$info")
  label=$(jq -r '.label // empty' <<<"$info")
  wlabel=$(herdr workspace get "$ws" | jq -r .result.workspace.label)
  name=$(herdr agent list | jq -r --arg p "$pane" '.result.agents[] | select(.pane_id == $p) | .name // empty')
  pid=$(herdr pane process-info --pane "$pane" |
    jq -r 'first(.result.process_info.foreground_processes[] | select(.name == "omp") | .pid) // empty')
  [[ -n $pid ]] || die "$pane: omp process not found"
  say "$pane: $(jq -r .terminal_title_stripped <<<"$info")"

  if [[ $pane == "$me" ]]; then
    say "  waiting for this agent's turn to end"
    # Two settled reads in a row; `agent wait --until idle` misses a pane that stays `done`.
    i=0
    while ((i < 2)); do
      status=$(status_of "$pane")
      if [[ $status == idle || $status == "done" ]]; then i=$((i + 1)); else i=0; fi
      sleep 1
    done
  fi
  status=$(status_of "$pane")
  say "  stopping omp ($status)"
  stop_omp "$pane" "$pid" "$status"
  # From here the session runs nowhere until it starts on the target.
  trap 'say "herdr-ship: failed; the session still lives here: omp --restore=$(q "$sess")"; pause' EXIT

  cwd=$(grep -m1 '"type":"session"' "$sess" | jq -r .cwd)
  [[ -d $cwd ]] || die "session cwd $cwd is missing"
  mapfile -t dirs < <(repo_dirs "$cwd")
  ((${#dirs[@]})) || say "  $cwd is not in a git repo"
  ((${#dirs[@]} + ${#paths[@]})) || say "  no files mirrored: no git repo and no --path"
  for dir in "${dirs[@]}" "${paths[@]}"; do mirror "$dir"; done
  ssh_ "mkdir -p $(q "$cwd")"

  say "  handing over the session"
  tar=$(mktemp --suffix=.tar)
  omp session pack "$sess" "$tar" >/dev/null
  rtar=/tmp/herdr-ship-$stamp-$RANDOM.tar
  rsync -q "$tar" "$target:$rtar"
  rm -f "$tar"
  out=$(ssh_ "omp session unpack $(q "$rtar") --cwd $(q "$cwd"); rm -f $(q "$rtar")")
  rsess=$(grep -m1 '\.jsonl$' <<<"$out") || die "omp session unpack failed on $machine: $out"

  rws=$("${remote[@]}" workspace list |
    jq -r --arg l "$wlabel" 'first(.result.workspaces[] | select(.label == $l) | .workspace_id) // empty')
  if [[ -n $rws ]]; then
    rp=$("${remote[@]}" tab create --workspace "$rws" --cwd "$cwd" --no-focus | jq -r .result.root_pane.pane_id)
  else
    rp=$("${remote[@]}" workspace create --cwd "$cwd" --label "$wlabel" --no-focus | jq -r .result.root_pane.pane_id)
  fi
  [[ -z $label ]] || "${remote[@]}" pane rename "$rp" "$label" >/dev/null
  "${remote[@]}" pane run "$rp" "omp --restore=$(q "$rsess")" >/dev/null
  for i in {1..120}; do
    [[ $("${remote[@]}" pane get "$rp" | jq -r .result.pane.agent) == omp ]] && break
    ((i < 120)) || die "omp did not start in $machine pane $rp"
    sleep 0.5
  done
  [[ -z $name ]] || "${remote[@]}" agent rename "$rp" "$name" >/dev/null || say "  could not rename it to $name"

  omp session moved "$sess" --to "$machine" >/dev/null
  trap pause EXIT
  say "  running on $machine: pane $rp (workspace $wlabel)"

  # A self-ship ended its turn on purpose; prompt the resumed agent so it goes on with the rest.
  if [[ $pane == "$me" ]]; then
    for i in {1..120}; do
      status=$("${remote[@]}" pane get "$rp" | jq -r .result.pane.agent_status)
      [[ $status == idle || $status == "done" ]] && break
      ((i < 120)) || die "resumed agent on $machine never went idle; continue not sent"
      sleep 0.5
    done
    "${remote[@]}" agent prompt "$rp" "continue: this session now runs on $machine (moved by herdr-ship); resume the remaining work here" >/dev/null
    say "  continue sent"
  fi
}

for pane in "${panes[@]}"; do ship "$pane"; done
