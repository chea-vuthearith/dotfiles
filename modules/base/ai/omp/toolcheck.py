# Session-start tool check in one eval cell: `%load ~/.omp/agent/toolcheck.py` (see APPEND_SYSTEM.md).
# Calls every session tool once, read-only, in parallel; then a `sonic` subagent runs this same file
# (SUBAGENT = True) to catch tools missing from subagents. Prints one table: tool, ok/missing/broken, detail.
import asyncio

SUBAGENT = globals().get("SUBAGENT", False)
FILE = __file__ if "__file__" in globals() else "~/.omp/agent/toolcheck.py"
BAD = ("error", "not found", "unknown tool", "failed")


async def call(name, args):
    fn = getattr(tool, name, None)
    if fn is None:
        return "missing", "not in this session"
    try:
        text = str(await fn({"i": "Checking tool", **args}))
    except Exception as e:
        return ("missing" if "Unknown tool" in str(e) else "broken"), f"{type(e).__name__}: {e}"[:160]
    head = text[:300].lower()
    return ("broken" if any(b in head for b in BAD) else "ok"), text[:100].replace("\n", " ")


def first_def():
    """(file, line, name) of the first top-level def in a git-tracked .py file of the cwd, or None."""
    import ast
    import subprocess
    from pathlib import Path

    ls = subprocess.run(["git", "ls-files", "*.py"], capture_output=True, text=True, check=False)
    for path in ls.stdout.split()[:50]:
        try:
            tree = ast.parse(Path(path).read_text(encoding="utf-8"))
        except (OSError, SyntaxError, ValueError):
            continue
        for node in tree.body:
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                return path, node.lineno, node.name
    return None


async def lsp_pair():
    rows = [("lsp status", *await call("lsp", {"action": "status"}))]
    target = first_def()
    if target is None:
        rows.append(("lsp references", "ok", "no tracked .py file here: not checked"))
    else:
        path, line, name = target
        rows.append(("lsp references", *await call("lsp", {"action": "references", "file": path, "line": line,
                                                          "symbol": name, "timeout": 30})))
    return rows


CHECKS = {
    "read": ("read", {"path": FILE + ":1"}),
    "bash": ("bash", {"command": "true"}),
    "glob": ("glob", {"path": "*", "limit": 1}),
    "grep": ("grep", {"pattern": "toolcheck", "path": FILE}),
    "todo": ("todo", {"op": "view"}),
    "context_notes": ("context_notes", {}),
    "web_search": ("web_search", {"query": "example", "limit": 1, "max_tokens": 50}),
    "proc://": ("read", {"path": "proc://"}),
    "cfg://": ("read", {"path": "cfg://task/enableLsp"}),
    "recall": ("recall", {"query": "tool check"}),
}
if not SUBAGENT:
    CHECKS["telegram"] = ("telegram", {"action": "status"})


async def main():
    names = list(CHECKS)
    got = await asyncio.gather(*(call(*CHECKS[n]) for n in names), lsp_pair())
    rows = [(n, *r) for n, r in zip(names, got[:-1])] + got[-1]
    rows.append(("eval", "ok", "this cell ran"))
    if not SUBAGENT:
        sub = await agent(f"Run exactly one eval cell (python): `SUBAGENT = True` then `%load {FILE}`. "
                          "Reply with its printed table only, nothing else.", agent="sonic", label="ToolCheck")
        rows.append(("subagent", "ok" if "|" in str(sub) else "broken", ""))
        print(f"## main session\n{table(rows)}\n\n## sonic subagent\n{sub}")
    else:
        print(table(rows))


def table(rows):
    out = ["| tool | status | detail |", "|---|---|---|"]
    out += [f"| {n} | {s} | {'' if s == 'ok' else d} |" for n, s, d in rows]
    return "\n".join(out)


await main()
