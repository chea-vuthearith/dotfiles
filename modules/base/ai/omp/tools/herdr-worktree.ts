// omp custom tool: herdr_worktree
// Creates a git worktree as a herdr workspace, moves this agent's herdr pane into it,
// moves this omp session there with /move once the current turn ends, then prompts
// "continue" so the agent resumes without user input.
// Guide: ~/dotfiles/modules/base/ai/omp/tools/README.md
import type { CustomToolFactory } from "@oh-my-pi/pi-coding-agent";
import { spawn } from "node:child_process";
import { closeSync, openSync } from "node:fs";

// Runs detached after the tool returns: /move is refused while a turn is running.
const MOVE_SCRIPT = `
p=$1; d=$2
sleep 3
herdr agent wait "$p" --until idle --timeout 600000 || { echo "agent never went idle; /move not sent"; exit 1; }
sleep 1
herdr pane send-keys "$p" ctrl+c     # clear any draft in the prompt (Up recalls it)
sleep 0.5
# The leading ':' makes omp's path completion find nothing, so no popup swallows the
# submit Enter; /move strips it (expandPath) and resolves the plain path.
herdr agent prompt "$p" "/move :$d"
sleep 3
if ! herdr pane read "$p" --lines 200 | grep -qF "Moved to $d"; then
  echo "'Moved to $d' not seen; check pane $p; continue not sent"
  exit 1
fi
echo "moved OK: $d"
herdr agent wait "$p" --until idle --timeout 60000 || { echo "agent not idle after /move; continue not sent"; exit 1; }
sleep 1
if herdr agent prompt "$p" "continue" --wait --until working --timeout 10000; then
  echo "continue sent"
else
  echo "continue did not start a turn; check pane $p"
  exit 1
fi
`;

type Pane = { pane_id: string; tab_id: string; workspace_id: string; terminal_id: string };

// Reads a nested field from parsed herdr JSON; undefined if any step is missing.
function get(value: unknown, ...path: string[]): unknown {
  let v = value;
  for (const key of path) {
    if (typeof v !== "object" || v === null) return undefined;
    const next: unknown = Reflect.get(v, key);
    v = next;
  }
  return v;
}

function str(value: unknown, ...path: string[]): string {
  const v = get(value, ...path);
  if (typeof v !== "string") throw new Error(`unexpected herdr reply: ${path.join(".")} missing`);
  return v;
}

function panesOf(result: unknown): Pane[] {
  const list = get(result, "panes");
  if (!Array.isArray(list)) throw new Error("unexpected herdr reply: panes missing");
  return list.map((p: unknown) => ({
    pane_id: str(p, "pane_id"),
    tab_id: str(p, "tab_id"),
    workspace_id: str(p, "workspace_id"),
    terminal_id: str(p, "terminal_id"),
  }));
}

function runsPid(info: unknown, pid: number): boolean {
  if (get(info, "foreground_process_group_id") === pid) return true;
  const procs = get(info, "foreground_processes");
  return Array.isArray(procs) && procs.some((f: unknown) => get(f, "pid") === pid);
}

const factory: CustomToolFactory = (pi) => {
  async function herdr(args: string[], signal?: AbortSignal): Promise<unknown> {
    const r = await pi.exec("herdr", args, { signal });
    if (r.killed) throw new Error("cancelled");
    let out: unknown;
    try {
      out = JSON.parse(r.stdout);
    } catch {
      throw new Error(`herdr ${args.join(" ")} failed (exit ${r.code}): ${(r.stderr || r.stdout).trim()}`);
    }
    const error = get(out, "error");
    if (r.code !== 0 || error !== undefined) {
      throw new Error(`herdr ${args.join(" ")} failed: ${JSON.stringify(error ?? out)}`);
    }
    return get(out, "result");
  }

  // The pane whose foreground process is this omp process. HERDR_PANE_ID is not used:
  // it goes stale when the pane is moved.
  async function ownPane(signal?: AbortSignal): Promise<Pane> {
    const panes = panesOf(await herdr(["pane", "list"], signal));
    const infos = await Promise.all(
      panes.map(async (p) => {
        const r = await herdr(["pane", "process-info", "--pane", p.pane_id], signal).catch(() => undefined);
        return { p, info: get(r, "process_info") };
      }),
    );
    const mine = infos.filter(({ info }) => runsPid(info, process.pid));
    if (mine.length !== 1) throw new Error(`expected 1 herdr pane running omp pid ${process.pid}, found ${mine.length}`);
    return mine[0].p;
  }

  return {
    name: "herdr_worktree",
    label: "Herdr Worktree",
    description:
      "Create a git worktree as a new herdr workspace, move this agent's herdr pane into it, " +
      "and move this omp session there (/move, sent automatically after the current turn ends), " +
      "then prompt the agent with \"continue\" so it resumes in the worktree. " +
      "Call it as the LAST action of a turn and end the turn: the session move runs only once the agent is idle. " +
      "Files you want in the worktree must be moved before calling. Requires running inside herdr.",
    parameters: pi.zod.object({
      branch: pi.zod.string().describe("New branch name, e.g. docs/milkrun"),
      base: pi.zod.string().optional().describe("Base ref for the branch (herdr default if omitted)"),
      label: pi.zod.string().optional().describe("Workspace label (default: herdr's choice)"),
      repo: pi.zod.string().optional().describe("Path inside the repo (default: current directory)"),
    }),

    async execute(_id, params, onUpdate, _ctx, signal) {
      if (!process.env.HERDR_ENV) throw new Error("not running inside herdr");
      const repo = params.repo ?? process.cwd();
      const step = (text: string) => onUpdate?.({ content: [{ type: "text", text }], details: {} });

      step("Finding this agent's pane…");
      const me = await ownPane(signal);

      step(`Creating worktree for ${params.branch}…`);
      const createArgs = ["worktree", "create", "--cwd", repo, "--branch", params.branch, "--no-focus"];
      if (params.base) createArgs.push("--base", params.base);
      if (params.label) createArgs.push("--label", params.label);
      const created = await herdr(createArgs, signal);
      const ws = str(created, "workspace", "workspace_id");
      const tab = str(created, "tab", "tab_id");
      const placeholder = str(created, "root_pane", "pane_id");
      const dest = str(created, "workspace", "worktree", "checkout_path");

      step(`Moving pane ${me.pane_id} to workspace ${ws}…`);
      await herdr(
        ["pane", "move", me.pane_id, "--tab", tab, "--split", "right", "--target-pane", placeholder, "--no-focus"],
        signal,
      );
      // Confirm by terminal id before closing the placeholder: closing the only pane of a
      // workspace closes the workspace.
      const panes = panesOf(await herdr(["pane", "list"], signal));
      const moved = panes.find((p) => p.terminal_id === me.terminal_id);
      if (!moved || moved.workspace_id !== ws) {
        throw new Error(`pane move not confirmed (pane now in ${moved?.workspace_id ?? "?"}); worktree ${dest} left open`);
      }
      if (moved.pane_id !== placeholder) await herdr(["pane", "close", placeholder], signal);

      const log = `/tmp/omp-herdr-worktree-${Date.now()}.log`;
      const fd = openSync(log, "w");
      const child = spawn("bash", ["-c", MOVE_SCRIPT, "_", moved.pane_id, dest], {
        detached: true,
        stdio: ["ignore", fd, fd],
      });
      child.unref();
      closeSync(fd);

      const text =
        `Worktree ${dest} (branch ${params.branch}) opened as herdr workspace ${ws}; ` +
        `this pane is now ${moved.pane_id}. When this turn ends, /move ${dest} will be sent, ` +
        `then "continue" (log: ${log}). End the turn now; resume the remaining work in the next turn.`;
      return {
        content: [{ type: "text", text }],
        details: { worktree: dest, branch: params.branch, workspace: ws, pane: moved.pane_id, log },
      };
    },
  };
};

export default factory;
