# Worktrees

When asked to create a git worktree, work in a new worktree or branch checkout, or move yourself (your pane or session) to another worktree, ALWAYS use the `herdr_worktree` tool. NEVER do it by hand with `git worktree`, `herdr worktree create`, `herdr pane move`, or by typing `/move`.

- Move files the worktree needs before calling it; it does not copy files.
- Call it as the LAST action of the turn, then end the turn: the session move (`/move`) runs only once you are idle. After the move you receive a "continue" prompt in the worktree; resume the remaining work there.
- If the tool is unavailable (not running inside herdr), say so and stop; do not fall back to manual steps unless the user asks.

# Moving to another machine

When asked to move yourself (your session or pane) to the server or another machine, or when a `[herdr-ship]` message asks you to, use `herdr-ship` with bash. It detaches and returns at once.

- First decide which files and folders the remaining work needs there. The git repo of your working directory (main checkout plus worktree, gitignored files included, dependency dirs like `node_modules`/`.venv` skipped) is mirrored automatically; pass everything else with `--path` (repeatable): other repos, data, notes, work that is not in a git repo. A dir is mirrored with deletion, so name specific folders, never broad ones like `~`, `~/.config`, or `~/code`.
- Run `herdr-ship --to <machine> [--path <path>]...` (default machine `server`; list: `herdr machine list`) as the LAST action of the turn, then end the turn. It waits for your turn to end, stops this omp, mirrors the files, and resumes the session there.
- After the move you receive a "continue" prompt on the target machine; do the remaining work there. Running processes and anything you did not pass did not move.
- Its log path is printed; if no "continue" arrives, the user reads that log. If not running inside herdr, say so and stop.
