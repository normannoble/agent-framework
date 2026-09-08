#!/usr/bin/env bash
set -euo pipefail

# Idempotent launchd installer for the agent scheduler (macOS).
# Ships with the `agents` plugin; copy agents/scheduler/ into the workspace first.
#
# Why launchd instead of cron: launchd runs a missed StartCalendarInterval job
# ON WAKE. A closed/asleep laptop that skips the :07 slot runs the job as soon as
# it wakes, so the cycle survives a closed laptop. Plain cron just silently skips.
#
# Why the command sources nvm: launchd starts with a bare environment and no login
# shell config (nvm init usually lives in ~/.zshrc, which bash never reads). Without
# node/npx on PATH, every npx-based MCP server (Airtable, Slack) fails ENOENT inside a
# tick. Sourcing ~/.nvm/nvm.sh puts the nvm `default` node on PATH — and because it
# resolves the alias, it survives node version bumps.
#
# This DRAFT is not run automatically. Review it, then run it yourself:
#   bash agents/scheduler/install-launchd.sh
# To remove:
#   launchctl unload -w ~/Library/LaunchAgents/com.<workspace>.agent-scheduler.plist

# Resolve workspace root (two levels up from this script) and derive the label from its folder name
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/../.." && pwd)"
SLUG="$(basename "$WORKSPACE" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9\n' '-')"
LABEL="com.${SLUG}.agent-scheduler"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

if [[ ! -f "$WORKSPACE/agents/scheduled-tasks.md" ]]; then
    echo "Error: Cannot find agents/scheduled-tasks.md in $WORKSPACE"
    exit 1
fi

# Find claude CLI
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

LOGS_DIR="$WORKSPACE/agents/scheduler/logs"
mkdir -p "$LOGS_DIR"

echo "Workspace:  $WORKSPACE"
echo "Claude CLI: $CLAUDE_BIN"
echo "Plist:      $PLIST"

# Unload any existing job so this is idempotent
if [[ -f "$PLIST" ]]; then
    launchctl unload -w "$PLIST" 2>/dev/null || true
fi

mkdir -p "$(dirname "$PLIST")"

cat > "$PLIST" <<PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-lc</string>
        <string>cd "$WORKSPACE" &amp;&amp; export NVM_DIR="\$HOME/.nvm" &amp;&amp; [ -s "\$NVM_DIR/nvm.sh" ] &amp;&amp; . "\$NVM_DIR/nvm.sh" ; "$CLAUDE_BIN" -p "Read agents/scheduler/prompt.md and follow its instructions exactly." --dangerously-skip-permissions --max-turns 50 &gt;&gt; "$LOGS_DIR/cron.log" 2&gt;&amp;1</string>
    </array>

    <!-- Fire hourly at :07. launchd runs a missed slot on next wake. -->
    <key>StartCalendarInterval</key>
    <dict>
        <key>Minute</key>
        <integer>7</integer>
    </dict>

    <key>RunAtLoad</key>
    <false/>

    <key>StandardOutPath</key>
    <string>$LOGS_DIR/launchd.out.log</string>
    <key>StandardErrorPath</key>
    <string>$LOGS_DIR/launchd.err.log</string>
</dict>
</plist>
PLIST_EOF

launchctl load -w "$PLIST"

echo ""
echo "Installed and loaded. Scheduler fires at :07 every hour (catches up on wake)."
echo "Verify: launchctl list | grep $LABEL"
echo "Logs:   $LOGS_DIR/cron.log"
