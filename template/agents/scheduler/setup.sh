#!/usr/bin/env bash
set -euo pipefail

# Idempotent cron installer for the agent scheduler (Linux, or macOS without launchd).
# Ships with the `agents` plugin; copy agents/scheduler/ into the workspace first.
# On macOS prefer install-launchd.sh: cron silently skips slots while the machine sleeps.
# Adds an hourly cron entry that fires a Claude session to check
# the task register and execute due tasks.
#
# Usage: bash agents/scheduler/setup.sh

# Resolve workspace root (two levels up from this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/../.." && pwd)"
SLUG="$(basename "$WORKSPACE" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9\n' '-')"
MARKER="${SLUG}-agent-scheduler"

# Verify we're in the right place
if [[ ! -f "$WORKSPACE/agents/scheduled-tasks.md" ]]; then
    echo "Error: Cannot find agents/scheduled-tasks.md in $WORKSPACE"
    echo "Copy scheduled-tasks.md from the plugin template to agents/ first."
    exit 1
fi

# Find claude CLI
CLAUDE_BIN=""
if command -v claude &>/dev/null; then
    CLAUDE_BIN="$(command -v claude)"
elif [[ -x "$HOME/.claude/bin/claude" ]]; then
    CLAUDE_BIN="$HOME/.claude/bin/claude"
elif [[ -x "/usr/local/bin/claude" ]]; then
    CLAUDE_BIN="/usr/local/bin/claude"
else
    echo "Error: Cannot find claude CLI. Install it or add it to PATH."
    exit 1
fi

echo "Workspace: $WORKSPACE"
echo "Claude CLI: $CLAUDE_BIN"

# Check if cron entry already exists
if crontab -l 2>/dev/null | grep -q "$MARKER"; then
    echo "Already installed. Scheduler cron entry exists."
    echo ""
    echo "Current entry:"
    crontab -l | grep "$MARKER"
    exit 0
fi

# Build the cron entry
LOGS_DIR="$WORKSPACE/agents/scheduler/logs"
mkdir -p "$LOGS_DIR"

CRON_ENTRY="7 * * * * cd $WORKSPACE && $CLAUDE_BIN -p \"Read agents/scheduler/prompt.md and follow its instructions exactly.\" --dangerously-skip-permissions --max-turns 50 >> $LOGS_DIR/cron.log 2>&1 # $MARKER"

# Append to crontab
(crontab -l 2>/dev/null || true; echo "$CRON_ENTRY") | crontab -

echo "Installed. Scheduler will run at :07 every hour."
echo ""
echo "Entry:"
crontab -l | grep "$MARKER"
echo ""
echo "To remove: crontab -e and delete the line with '$MARKER'"
echo "Logs: $LOGS_DIR/cron.log"
