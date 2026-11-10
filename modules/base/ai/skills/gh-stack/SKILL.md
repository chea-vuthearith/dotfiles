---
name: gh-stack
description: "Inspect, rebase, sync or merge GitHub stacked pull requests with the official gh stack extension (github/gh-stack) instead of gh pr merge or the REST merge, which refuse stacked PRs"
---

# GitHub stacked PRs: use `gh stack`

## When
A PR belongs to a GitHub stack (chain of PRs, each based on the one below). Signs:
- `gh pr merge N` fails: "This pull request is part of a stack and must be merged using the asynchronous merge REST API".
- REST `PUT /repos/O/R/pulls/N/merge` returns 403 "Merging stacked PRs via this endpoint is not supported".

Check the tool: `gh stack --help` (extension `github/gh-stack`; install with `gh extension install github/gh-stack`).
Run every command from inside the repo (a worktree, never a checkout the user forbids touching).

## Commands
| Need | Command |
|---|---|
| see the stack and PR states (✓ merged, ◎ queued, ○ open, ⚠ needs rebase) | `gh stack view --short` (or `--json`) |
| link existing branches/PRs into a GitHub stack, bottom to top, no local tracking | `gh stack link <pr-or-branch> ...` |
| cascade rebase each branch onto the one below | `gh stack rebase` (`--downstack` / upstack variants) |
| fetch, rebase, push (`--force-with-lease --atomic`), sync PR state | `gh stack sync` |
| merge up to and including PR N, all or nothing | `gh stack merge N` |

## Rules (merging is irreversible)
1. Never merge, rebase-push or sync without the user's explicit go for that exact action.
2. Always `gh stack view` first; tell the user exactly which PRs will merge.
3. `gh stack merge` merges the chosen PR AND every open PR below it, atomically. Pick the PR deliberately.
4. A bare number is read first as a STACK number, then as a PR number: confirm in `gh stack view` which it resolves to.
5. Never run `gh stack merge` with no argument or with `--yes` from a non-interactive shell: without a terminal it
   merges the WHOLE stack without asking.
6. `sync`/`rebase` force-push every branch (with lease): only when no other agent is pushing to those branches.
7. Branch protection and rules are evaluated only when the merge runs; a failure is reported afterwards, nothing merged.
8. Bypassing merge requirements is not supported for stacks.

## Fallback (no extension)
Async merge API, pinned to the head commit:
```
gh api -X PUT repos/O/R/pulls/N/merge-async -f merge_method=merge -f merge_action=direct_merge -f sha=<head-sha>
gh api repos/O/R/pulls/N/merge-async/<uuid>
```
Poll the second until `status` is `merged` (gives the merge sha) or `failed`.

## After a merge
GitHub retargets the next PR in the stack onto the base branch; PRs above it are unchanged.
