// Inbox for herdr-msg: delivers agent-to-agent messages straight into the session, so a
// draft the user is typing in the prompt is never touched (typing them into the pane
// would submit or clobber it).
// Listens on $XDG_RUNTIME_DIR/omp-inbox/<pid>.sock for the life of the process; herdr-msg
// finds the pid of the target pane's omp via `herdr pane process-info`. Each connection
// carries one message (UTF-8, closed by the sender); idle it starts a turn, while working
// it is queued as a steer.
// @ts-nocheck

import fs from "node:fs";
import net from "node:net";
import path from "node:path";

export default function (pi) {
  if (process.env.HERDR_ENV !== "1") return;
  const dir = path.join(process.env.XDG_RUNTIME_DIR || "/tmp", "omp-inbox");
  const sock = path.join(dir, `${process.pid}.sock`);
  fs.mkdirSync(dir, { recursive: true, mode: 0o700 });
  fs.rmSync(sock, { force: true });

  const server = net.createServer((conn) => {
    const chunks = [];
    conn.on("data", (c) => chunks.push(c));
    conn.on("end", () => {
      const text = Buffer.concat(chunks).toString("utf8").trim();
      if (text) pi.sendUserMessage(text);
      conn.end();
    });
    conn.on("error", () => {});
  });
  server.on("error", () => {});
  server.listen(sock);
  server.unref();
  process.on("exit", () => fs.rmSync(sock, { force: true }));
}
