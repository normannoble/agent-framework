---
description: Ask another agent in this workspace for a review, a fact, or a draft. Opens a fresh Herdr pane, runs the target as a peer session, waits for its written reply, closes the pane. Same workspace only. Use /agents:ask <name> "<request>". Requires Herdr (HERDR_ENV=1).
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Grep, Bash(date), Bash(pwd), Bash(mkdir), Bash(herdr agent list), Bash(herdr agent start), Bash(herdr agent prompt), Bash(herdr agent read), Bash(herdr agent get), Bash(herdr pane split), Bash(herdr pane rename), Bash(herdr pane layout), Bash(herdr pane close)
argument-hint: <name> "<request>"
---

# /agents:ask — Peer Request

You ask one agent in this workspace to do one bounded thing for the agent you currently are (or for the principal, if no agent is active). The full protocol is `${CLAUDE_PLUGIN_ROOT}/template/agents/reference/peer.md` (glob `~/.claude/plugins/cache/*/agents/*/template/agents/reference/peer.md`, highest version, if the variable is empty). Read it once, then follow it.

## Preconditions

1. `HERDR_ENV` must be `1` and `HERDR_PANE_ID` set. Otherwise say `Not inside Herdr — /agents:ask needs a Herdr pane.` and stop.
2. Workspace root = current working directory; it must contain `agents/`. Glob `agents/<name>/context.md` or `agents/*/<name>/context.md` (case-insensitive). Not found, or `status: retired` → say so, suggest `/agents:list`, stop. **Never** look outside this root and never mention agents from other roots.
3. Caller = the agent currently active in this session, else `principal`.

## Steps

1. `date` → stamp `YYYY-MM-DD-HHMM`. `mkdir -p agents/<Target>/peer`. Write `agents/<Target>/peer/<stamp>-from-<caller>.md` with the frontmatter and `## Request` from peer.md (`status: open`, `caller_pane: $HERDR_PANE_ID`). The request text must be self-contained: name every file, ID, and constraint the target needs. Do not rely on anything only this session knows.
2. `herdr pane layout --pane "$HERDR_PANE_ID"` → wide → `right`, tall → `down`. `herdr pane split --current --direction <dir> --cwd "$PWD" --no-focus` → read `.result.pane.pane_id`.
3. `herdr pane rename <id> "<Target> - Peer"`.
4. `herdr agent start <target>-peer --kind claude --pane <id>`. If it returns `agent_not_ready`, wait once with `herdr agent get`; if still blocked, read the pane, tell the principal, stop (pane stays open).
5. `herdr agent prompt <target>-peer "/agents:start <target> peer agents/<Target>/peer/<file>" --wait --timeout 600000`.
6. On `blocked`: `herdr agent read <target>-peer --source recent-unwrapped --lines 60`, report the prompt to the principal, stop. Never answer it.
7. Read the file. If `## Reply` exists: `herdr pane close <id>`, then present the reply in ≤ 10 lines and any `Needs <principal>:` lines verbatim. If not: say the peer produced no reply, leave the pane open, stop.

## Rules

- One request per call. No chains (a peer must not `/agents:ask`).
- Do not commit. The file is committed by the caller's session end.
- Do not add the exchange to any tracker unless the principal says so.
