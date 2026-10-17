# omp custom tools

Deployed by `modules/base/ai/default.nix` to `~/.omp/agent/tools/`. omp loads
them at startup; restart omp (or start a new session) after `nixos-rebuild switch`.

## `herdr_worktree`

Moves the calling omp agent into a new git worktree, in one call:

1. `herdr worktree create` opens the worktree as a new herdr workspace.
2. The agent's herdr pane is moved into that workspace, and the workspace's starting
   pane is closed.
3. After the turn ends, `/move <worktree>` is sent to the agent, which moves the omp
   session (history and session folder) to the worktree.
4. Once the move is confirmed, the agent is prompted with `continue`, so it resumes
   the task in the worktree without user input.

Ask the agent, for example: "move yourself to a worktree on branch docs/milkrun".
Parameters: `branch` (required), `base`, `label`, `repo` (default: current folder).
Move any files the worktree needs before the call; the tool does not copy files.

### How step 3 works

omp refuses `/move` while a turn is running ("Wait for the current response to finish
or abort it before moving"). The tool starts a detached job that:

| Step | Why |
|------|-----|
| `sleep 3`, then `herdr agent wait <pane> --until idle` | waits for the turn to end (gives up after 10 minutes) |
| `herdr pane send-keys <pane> ctrl+c` | clears any draft in the prompt; `Up` recalls it |
| `herdr agent prompt <pane> "/move <dir>"` | types and submits the command |
| `herdr pane send-keys <pane> enter` | the first Enter only picks `/move` in the command picker; this one runs it |
| `herdr pane read` for `Moved to <dir>` | confirms the move; stops here if not seen |
| `herdr agent wait <pane> --until idle` | waits for omp to settle after `/move` (1 minute max) |
| `herdr agent prompt <pane> continue --wait --until working` | resumes the agent; fails if no turn starts within 10 s |

Log: `/tmp/omp-herdr-worktree-<time>.log`.

### Finding the agent's pane

The pane is the one whose foreground process is the omp process (`herdr pane
process-info`). `HERDR_PANE_ID` is not used: it keeps the old ID after a pane move.

### Manual fallback

```bash
herdr worktree create --cwd <repo> --branch <branch> --no-focus      # note workspace, tab, root pane
herdr pane move <pane> --tab <tab> --split right --target-pane <root> --focus
herdr pane list            # confirm the pane is in the new workspace, THEN:
herdr pane close <root>    # closing the only pane of a workspace closes the workspace
```

Then type `/move <worktree>` in omp while it is idle, then `continue`.

### Notes

- herdr's `cwd` for the pane may keep showing the old folder; `foreground_cwd` shows
  the new one.
- Tested 13 Oct 2026 with herdr 0.9.1 and omp 18.3.2: pane lookup and error path via
  a harness; the delayed `/move` on the agent's own pane by hand. A full run of the
  tool has not been done yet.
