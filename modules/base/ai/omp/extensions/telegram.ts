// omp extension: `telegram` tool. Agents ping kuro on Telegram (@cheaserverbot) only while he is away
// from this machine. Installed by modules/base/ai/telegram.nix, which substitutes the @…@ placeholders.
//
// Away = laptop lid closed (only where Nix sets checkLid, i.e. the laptop; the server is a laptop that stays shut),
// or the away flag set via `telegram away` after kuro says he is leaving.
// The flag is per machine (shared by all omp sessions) and is cleared by `telegram back` or by
// kuro typing into any omp session on this machine.
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { hostname } from "node:os";
import path from "node:path";

const TOKEN_FILE = "@tokenFile@";
const CHAT_ID = "@chatId@";
const CHECK_LID = "@checkLid@" === "true";
const LID_DIR = "/proc/acpi/button/lid";
const AWAY_FILE = path.join(process.env.XDG_STATE_HOME ?? path.join(process.env.HOME ?? "", ".local/state"), "omp/away");

function lidClosed(): boolean {
  if (!CHECK_LID) return false;
  try {
    return readdirSync(LID_DIR).some((d) => readFileSync(path.join(LID_DIR, d, "state"), "utf8").includes("closed"));
  } catch {
    return false; // no lid
  }
}

function awayReason(): string | undefined {
  if (lidClosed()) return "laptop lid closed";
  try {
    return `away: ${readFileSync(AWAY_FILE, "utf8").trim() || "user said so"}`;
  } catch {
    return undefined;
  }
}

async function sendTelegram(text: string, signal?: AbortSignal): Promise<string | undefined> {
  let token: string;
  try {
    token = readFileSync(TOKEN_FILE, "utf8").trim();
  } catch {
    return `token missing at ${TOKEN_FILE}`;
  }
  const res = await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ chat_id: CHAT_ID, text, disable_web_page_preview: true }),
    signal: signal ?? AbortSignal.timeout(15_000),
  });
  return res.ok ? undefined : `Telegram API ${res.status}: ${await res.text()}`;
}

const result = (text: string) => ({ content: [{ type: "text" as const, text }] });

export default function (pi: ExtensionAPI) {
  const { z } = pi.zod;

  // kuro typing into a session means he is at this machine. Agent-to-agent herdr messages and the
  // herdr_worktree "continue" are typed into the pane too, so they do not count.
  pi.on("input", (event) => {
    if (event.source !== "interactive") return;
    const text = event.text.trim();
    if (text.startsWith("[herdr from:") || text === "continue") return;
    rmSync(AWAY_FILE, { force: true });
  });

  pi.registerTool({
    name: "telegram",
    label: "Telegram",
    loadMode: "essential",
    approval: "write",
    description:
      "Reach the user on Telegram while they are away from this machine. " +
      "`ping`: send an urgent message ONLY when you are blocked and cannot continue without the user " +
      "(a decision, credentials, approval, a broken environment). Never for progress, results or anything you can decide yourself. " +
      "The tool refuses unless the user is away (laptop lid closed, or the away flag is set); then ask in the session instead. " +
      "`away`: call when the user says they are leaving you unattended. " +
      "`back`: call when the user says they are back. " +
      "`status`: check whether the user is away.",
    parameters: z.object({
      action: z.enum(["ping", "away", "back", "status"]),
      message: z
        .string()
        .optional()
        .describe("ping: what blocks you and exactly what you need from the user, one or two lines; away: optional note"),
    }),
    async execute(_id, { action, message }, signal, _onUpdate, ctx) {
      switch (action) {
        case "away":
          mkdirSync(path.dirname(AWAY_FILE), { recursive: true });
          writeFileSync(AWAY_FILE, `${message ?? "left unattended"} (${new Date().toISOString()})\n`);
          return result("Away flag set: urgent blocking pings will reach the user on Telegram until they return.");
        case "back":
          rmSync(AWAY_FILE, { force: true });
          return result("Away flag cleared; no Telegram pings.");
        case "status":
          return result(awayReason() ?? "User is at the computer; Telegram pings are refused.");
        case "ping": {
          const reason = awayReason();
          if (!reason) return result("Not sent: the user is at the computer. Ask in this session instead.");
          if (!message?.trim()) throw new Error("ping needs a message");
          const where = `${hostname()} · ${path.basename(ctx.cwd)}`;
          const error = await sendTelegram(`🚨 ${where}\n\n${message.trim()}`, signal);
          if (error) throw new Error(`Telegram ping failed: ${error}`);
          return result(`Sent (${reason}). Telegram is one-way: end your turn; the user answers in this session.`);
        }
      }
    },
  });
}
