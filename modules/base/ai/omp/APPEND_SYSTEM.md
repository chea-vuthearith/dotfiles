# Worktrees

When asked to create a git worktree, work in a new worktree or branch checkout, or move yourself (your pane or session) to another worktree, ALWAYS use the `herdr_worktree` tool. NEVER do it by hand with `git worktree`, `herdr worktree create`, `herdr pane move`, or by typing `/move`.

- Move files the worktree needs before calling it; it does not copy files.
- Call it as the LAST action of the turn, then end the turn: the session move (`/move`) runs only once you are idle. After the move you receive a "continue" prompt in the worktree; resume the remaining work there.
- If the tool is unavailable (not running inside herdr), say so and stop; do not fall back to manual steps unless the user asks.

# Reviewing subagent work

`task` subagents work from a short brief without your context, so their code can miss what you know. A subagent's report is a claim, not evidence.

- Before accepting a subagent's result, read its diff (`git diff` on the files it touched), not just its summary.
- Check it like your own work: matches existing patterns, no duplicated or dead code, edge cases handled, docs consistent, verification it claims actually ran.
- If you fix or redo anything it wrote, tell the user briefly what was wrong, so they can judge the subagent model setup.
