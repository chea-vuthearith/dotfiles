# Worktrees

An owner spawned as an omp `task` subagent works in a worktree the orchestrator creates before the spawn with `herdr worktree create --cwd <repo checkout> --branch <branch> --base <base> --label <slug> --no-focus`. It prints JSON: the path is `.result.root_pane.cwd` (`~/.herdr/worktrees/<repo>/<branch-slug>`), the workspace id `.result.root_pane.workspace_id`. That pane stays an idle shell; the user sees the worktree in the Herdr sidebar. The subagent runs every command there, pushes its own branch and opens its own PR. Once the branch is pushed, retire it with `herdr worktree remove --workspace <id>` (`--force` only if the user agreed to drop local changes).

To move an interactive (Herdr pane) session itself into a worktree, ALWAYS use the `herdr_worktree` tool. NEVER do that by hand with `herdr pane move` or by typing `/move`.

- Move files the worktree needs before calling it; it does not copy files.
- Call it as the LAST action of the turn, then end the turn: the session move (`/move`) runs only once you are idle. After the move you receive a "continue" prompt in the worktree; resume the remaining work there.
- If the tool is unavailable (not running inside herdr), say so and stop; do not fall back to manual steps unless the user asks.

# Generated artifacts

Everything you or your subagents generate goes in `~/.local/state/omp-orchestrator/<repo>/`: notes, reviews, plans, PR bodies, reports, logs in `team/<owner>/`; throwaway clones, exports, sandboxes, venvs and downloads in `scratch/`. NEVER write them into a repo checkout (git-ignored dirs like `working/` included), `/tmp`, or ad-hoc dirs in `$HOME`. Worktrees are the only exception: they live where `herdr worktree create` puts them. Every subagent brief names its `team/<owner>/` path. Before an agent retires, it deletes its scratch or moves what is worth keeping into `team/<owner>/`.

# Reviewing subagent work

`task` subagents work from a short brief without your context, so their code can miss what you know. A subagent's report is a claim, not evidence.

- Before accepting a subagent's result, read its diff (`git diff` on the files it touched), not just its summary.
- Check it like your own work: matches existing patterns, no duplicated or dead code, edge cases handled, docs consistent, verification it claims actually ran.
- If you fix or redo anything it wrote, tell the user briefly what was wrong, so they can judge the subagent model setup.

# Telegram

The `telegram` tool messages the user's phone. It exists for one case: the user is away and you are blocked.

- When the user says they are leaving you unattended (going out, AFK, "keep going without me"), call `telegram` with `action: "away"`. When they say they are back, call `action: "back"`. Typing into any omp session on this machine also marks them back.
- `ping` ONLY when you cannot make progress without the user: a decision only they can make, credentials, a password/sudo prompt, an approval, a broken environment. First exhaust everything you can do or decide yourself; never ping for progress updates, finished work or questions you could answer.
- One ping per blocker: say what blocks you and exactly what you need, in one or two lines. Then end your turn; the user replies in the session, not on Telegram.
- The tool refuses while the user is at the computer (laptop lid open and no away flag). Never work around that; ask in the session instead.
