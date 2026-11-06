// omp extension: Telegram notification when a root session finishes a long turn.
// Installed by modules/base/ai/telegram-notify.nix, which substitutes the @…@ placeholders.
// @ts-nocheck
import { readFileSync } from "node:fs";
import { hostname } from "node:os";
import path from "node:path";

const TOKEN_FILE = "@tokenFile@";
const CHAT_ID = "@chatId@";
// Turns shorter than this are assumed to be watched at the keyboard.
const MIN_TURN_MS = Number(process.env.OMP_TELEGRAM_MIN_TURN_MS ?? @minTurnMs@);
// Nested omp (spawned from another session's shell) is not a root session.
const nested = process.env.OMPCODE === "1";

function token(): string | undefined {
  try {
    return readFileSync(TOKEN_FILE, "utf8").trim() || undefined;
  } catch {
    return undefined; // secret not deployed (bootstrap): stay silent
  }
}

type TextPart = { type: "text"; text: string };
type Message = { role?: string; content?: unknown };

function lastAssistantText(messages: readonly Message[] = []): string {
  for (let i = messages.length - 1; i >= 0; i--) {
    const m = messages[i];
    if (m.role !== "assistant" || !Array.isArray(m.content)) continue;
    const text = m.content
      .filter((c): c is TextPart => c?.type === "text" && typeof c.text === "string")
      .map((c) => c.text)
      .join("\n")
      .trim();
    if (text) return text;
  }
  return "";
}

async function send(text: string): Promise<void> {
  const t = token();
  if (!t) return;
  try {
    await fetch(`https://api.telegram.org/bot${t}/sendMessage`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ chat_id: CHAT_ID, text, disable_web_page_preview: true }),
      signal: AbortSignal.timeout(10_000),
    });
  } catch {
    // offline: a missed notification must never break the session
  }
}

export default function (pi) {
  if (nested) return;
  let startedAt: number | undefined;

  pi.on("agent_start", () => {
    startedAt ??= Date.now();
  });

  pi.on("agent_end", (event, ctx) => {
    if (event?.willContinue === true || startedAt === undefined) return;
    const elapsed = Date.now() - startedAt;
    startedAt = undefined;
    if (elapsed < MIN_TURN_MS) return;

    const cwd = ctx?.cwd ?? process.cwd();
    const where = `${hostname()} · ${path.basename(cwd)}`;
    const mins = Math.round(elapsed / 60_000);
    let body = lastAssistantText(event?.messages);
    if (body.length > 3500) body = `${body.slice(0, 3500)}…`;
    void send(`✅ ${where} (${mins} min)\n\n${body || "turn finished"}`);
  });
}
