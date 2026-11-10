---
name: writing
description: "House rules for prose humans read: docs, READMEs, PR bodies, commit messages, UI text, reports. Use before writing or editing any of these; run Vale on doc/UI files you wrote."
---

# Writing

Based on [blader/humanizer](https://github.com/blader/humanizer) (AI-tell patterns) and Strunk's
*The Elements of Style* (omit needless words, active voice, definite statements).

## Rules
- Plain words. Short sentences; one idea each. Active voice.
- Lead with the answer or the change; reasons after.
- Cut filler (just, really, basically, in order to) and hedges. Unknown? Say what is unknown.
- No hype or AI tells: seamless, robust, powerful, leverage, delve, elevate, crucial, "not just X but Y",
  rule-of-three lists, closing summaries that repeat the text.
- Concrete over abstract: name the file, command, number, error.
- Comparisons go in a table, not paragraphs.
- No emoji, no exclamation marks, no headings for a three-line answer.

## Check
Run Vale on docs and UI text files you wrote or changed (global config at `~/.config/vale/.vale.ini`):

```sh
vale <files>
```

Fix warnings; a suggestion may stay if the rewrite reads worse. Vale does not check code; keep code comments
short by hand.
