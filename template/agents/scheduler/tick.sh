#!/usr/bin/env bash
# Scheduler tick. Called by launchd or cron every hour at :07.
#
# Step 1 is a cheap gate (gate.py, no Claude): parse agents/scheduled-tasks.md and
# decide whether any enabled task is due right now. If none is, log one line and exit.
# Step 2 runs `claude -p` on agents/scheduler/prompt.md only when something is due.
#
# Usage: bash agents/scheduler/tick.sh           # normal tick
#        bash agents/scheduler/tick.sh --dry-run # print what is due, never call Claude
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/../.." && pwd)"
REGISTER="$WORKSPACE/agents/scheduled-tasks.md"
LOGS_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOGS_DIR"
cd "$WORKSPACE"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# nvm: launchd/cron start with a bare PATH; npx-based MCP servers need node.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# shellcheck disable=SC1091
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" >/dev/null 2>&1 || true

if ! command -v python3 >/dev/null; then
  echo "$(date '+%Y-%m-%d %H:%M') gate: python3 missing, cannot evaluate register" >> "$LOGS_DIR/cron.log"
  exit 1
fi

DUE="$(python3 "$SCRIPT_DIR/gate.py" "$REGISTER")" || rc=$?
rc=${rc:-0}
if [[ $rc -eq 2 ]]; then
  echo "$(date '+%Y-%m-%d %H:%M') gate: no register at agents/scheduled-tasks.md" >> "$LOGS_DIR/cron.log"
  exit 0
fi

if [[ -z "$DUE" ]]; then
  echo "$(date '+%Y-%m-%d %H:%M') gate: no tasks due" >> "$LOGS_DIR/cron.log"
  $DRY_RUN && echo "no tasks due"
  exit 0
fi

if $DRY_RUN; then
  echo "due: $DUE"
  exit 0
fi

# Find claude CLI
if command -v claude >/dev/null 2>&1; then CLAUDE_BIN="$(command -v claude)"
elif [[ -x "$HOME/.claude/bin/claude" ]]; then CLAUDE_BIN="$HOME/.claude/bin/claude"
elif [[ -x /usr/local/bin/claude ]]; then CLAUDE_BIN=/usr/local/bin/claude
else
  echo "$(date '+%Y-%m-%d %H:%M') gate: due=[$DUE] but claude CLI not found" >> "$LOGS_DIR/cron.log"
  exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M') gate: due=[$DUE] — starting claude" >> "$LOGS_DIR/cron.log"
"$CLAUDE_BIN" -p "Read agents/scheduler/prompt.md and follow its instructions exactly. The gate script found these tasks due now: $DUE. Verify against the register, then execute only due tasks." \
  --dangerously-skip-permissions --max-turns 50 >> "$LOGS_DIR/cron.log" 2>&1
