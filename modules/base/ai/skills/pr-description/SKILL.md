---
name: pr-description
description: "How to write or rewrite a PR description, and how to add before/after proof screenshots and screen recordings. Use before drafting any PR body, editing an existing one, or capturing proof images or videos for one."
---

# PR descriptions

A PR body says what changed, why, and shows proof when the change is visible. Keep it simple.
Follow the `writing` skill for prose.

## Sections, in this order

1. `## What`: 1–3 sentences on what the PR changes.
2. `## Why`: 1–3 sentences on the problem it solves.
3. `## Changes` (optional): short bullets with concrete names (files, components, flags). Only what a reviewer needs.
4. `## Behaviour changes` or `## Notes for the reviewer` (optional): intended behaviour changes, known limits, what's left to another PR (#N), and the test file that covers it.
5. `## Proof`: only when the change is visible.
   - Before/after image tables: `| Before | After |`, with a row label column when there are several pages.
   - Outline the changed element in red. Light theme, 1440 px; add 390 px for phone changes.
   - One-line caption naming what actually differs.
   - At most about 6 pairs. Drop pairs that look the same. Never put the same image in both cells.
   - Before is the base build, After is the PR head, on the same page and state.
   - Interactions (hover, drag, animation) get a short screen recording instead of a still.
   - Non-visual PRs have no Proof section; name the covering test in Notes instead.

## Uploading proof

Upload every proof image and video with `gh attach` (see the `gh-attach` skill). Never commit
them to the repo or put them in a gist.

- Images: png, jpeg, gif, webp, svg, up to 10 MiB. Videos: mp4, mov, webm, up to 100 MiB.
- `gh attach <file> --markdown` prints a ready Markdown reference.
- In table cells or `<img width="800" src="...">`, use the bare URL that `gh attach <file>` prints.

## Banned in the body

- SHA tables and old→new commit maps
- "Review fixes" sections, changelogs, history notes
- check, CI or e2e result tables
- capture-method lines (build, port, seed, browser)
- gist link lines and skipped-shot notes
- stack-order prose: GitHub shows the base
- agent wording, AI tells, emoji, marketing words, hedging

## Body vs comments

The body holds what, why, notes and proof only. Test runs, logs, e2e comparisons and rerun
evidence go in PR comments, and only when the user approves posting them.

## Tone

Plain, short, concrete. Fragments are fine. Tables only for before/after images. Reference
other PRs as #N.

## Before publishing

- After embedding, every image and video URL downloads (`gh attach download <url> -O - >/dev/null`).
  Don't check with anonymous `curl`: upload-only URLs 404 until embedded, and private-repo URLs 404 without auth.
- Open each before/after pair and check it shows the change.
- Re-read the body against the live diff (`gh pr diff`) so every claim matches the code.

## Example

```markdown
## What
FilterBar keeps the selected filters when you switch tabs.

## Why
Switching tabs reset every filter, so users had to set them again.

## Notes for the reviewer
- Date range still resets; that's #881.
- Covered by `e2e/filter-bar.spec.ts`.

## Proof
Selected chips survive the tab switch.

| | Before | After |
|---|---|---|
| Assets, 1440 px | ![](before.png) | ![](after.png) |
```

Live references: GinaV2 #862 (visual) and #880 (non-visual).
