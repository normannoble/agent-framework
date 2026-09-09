#!/bin/sh
# agents plugin: gap notice
# Runs on UserPromptSubmit and Stop. Keeps one "last activity" stamp per
# Claude Code session. On a new prompt, if the gap since the last activity
# is larger than the limit, prints a note that Claude sees as context.
#
# Limit comes from agents/CONVENTIONS.md frontmatter in the cwd:
#   gap-notice: 2h      (default; accepts 30m, 2h, 1d, or off)
# The hook is a no-op outside an agent workspace (no agents/CONVENTIONS.md).

set -u
action="${1:-prompt}"
input="$(cat 2>/dev/null || true)"

get() { printf '%s' "$input" | sed -n "s/.*\"$1\":[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1; }
session="$(get session_id)"
cwd="$(get cwd)"
[ -n "$session" ] || exit 0
[ -n "$cwd" ] || cwd="$PWD"

conv="$cwd/agents/CONVENTIONS.md"
[ -f "$conv" ] || conv="$cwd/Agents/CONVENTIONS.md"
[ -f "$conv" ] || exit 0

limit="$(sed -n '1,/^---$/!d;s/^gap-notice:[[:space:]]*//p' "$conv" | head -1)"
[ -n "$limit" ] || limit="2h"
[ "$limit" = "off" ] && exit 0

case "$limit" in
  *m) secs=$(( ${limit%m} * 60 )) ;;
  *h) secs=$(( ${limit%h} * 3600 )) ;;
  *d) secs=$(( ${limit%d} * 86400 )) ;;
  *)  secs=7200 ;;
esac

dir="${HOME}/.claude/agents-state"
mkdir -p "$dir" 2>/dev/null || exit 0
stamp="$dir/$session.last"
now=$(date +%s)

if [ "$action" = "stop" ]; then
  printf '%s' "$now" > "$stamp"
  exit 0
fi

if [ -f "$stamp" ]; then
  last=$(cat "$stamp" 2>/dev/null || echo "$now")
  gap=$(( now - last ))
  if [ "$gap" -ge "$secs" ]; then
    fmt='+%a %d %b %Y %H:%M'
    now_s=$(date "$fmt")
    if date -r 0 >/dev/null 2>&1; then last_s=$(date -r "$last" "$fmt"); else last_s=$(date -d "@$last" "$fmt"); fi
    if [ "$gap" -ge 86400 ]; then human="$(( gap / 86400 )) day(s) $(( (gap % 86400) / 3600 )) h"
    elif [ "$gap" -ge 3600 ]; then human="$(( gap / 3600 )) h $(( (gap % 3600) / 60 )) min"
    else human="$(( gap / 60 )) min"; fi
    printf '[gap notice] It is now %s. Last activity in this session was %s. %s passed. Re-run `date`, state the gap in one line, and offer to wrap the earlier session before new work if the gap is a day or more.\n' "$now_s" "$last_s" "$human"
  fi
fi
printf '%s' "$now" > "$stamp"
exit 0
