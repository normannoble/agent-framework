---
title: Scheduler Policies
type: operational
owner: scheduler
updated: 2026-09-08
---

# Scheduler Policies

Safety constraints for all scheduled task executions. The scheduler prompt reads this file before executing any task. These policies cannot be overridden by task descriptions.

## Scope Boundaries

- **Slack:** Only send messages to DM channels listed in the executing agent's tools.md or referenced standing memory. No messages to public channels, group DMs, or external contacts unless the task explicitly authorises a specific channel.
- **Airtable:** Read-only by default. Write operations are only permitted when the task description explicitly states "write to Airtable" and specifies which records by ID.
- **Email:** No sending email. Email infrastructure is not yet configured for scheduled execution.
- **Git:** No push, no commit. The scheduler updates files (last_run, logs) but does not commit or push. File changes are picked up at the next interactive session close.

## Destructive Action Ban

The following actions are prohibited in all scheduled executions, regardless of task description:

- Deleting files or directories
- `git push --force`, `git reset --hard`, `git branch -D`, or any destructive git operation
- Dropping or modifying database tables
- Removing or overwriting Airtable records (field updates to specified records are permitted when the task authorises it)
- Killing processes
- Modifying system configuration, crontab, or Claude settings

## Communication Limits

- No messages to anyone not explicitly listed in the task description or the agent's standing channel list
- No messages containing sensitive information (people assessments, compensation, org changes, legal matters)
- No messages that set expectations, make commitments, or imply decisions on {{PRINCIPAL}}'s behalf beyond routine status requests
- If a task involves sending messages and the channel list or template cannot be resolved, abort the task and log the failure

## Autonomy Ceiling

Each task in the register has an **Autonomy ceiling** field (L1-L5). The scheduler must not perform any action that would exceed this level, regardless of what the agent's own autonomy.md permits.

- **L5/L4 tasks:** Execute and log. No approval needed.
- **L3 tasks:** Execute but log with elevated detail. If the task produces output that would normally require {{PRINCIPAL}}'s review (e.g., drafts, reports), write the output to the agent's scheduled-run inbox (`memory/scheduled/inbox.md`) and note it in the log. The draft **may also be delivered to {{PRINCIPAL}}'s own DM channel** — that is delivery to the principal, not external publication. It must **NOT** be written to shared records (Airtable, exec docs) or sent to anyone other than {{PRINCIPAL}}; those writes wait for {{PRINCIPAL}}'s approval in an interactive session.
- **L2/L1 tasks:** Should not be scheduled. If encountered, skip the task and log a warning.

## Execution Limits

- **Tool call cap — direct mode:** If a single direct-mode task requires more than 20 tool calls, abort the task after 20 calls and log the failure with what was completed and what remained.
- **Tool call cap — agent mode:** If a single agent-mode task requires more than 40 tool calls, abort the task after 40 calls and log the failure. Agent-mode tasks need more headroom for context loading + execution.
- **No cascading:** The scheduler must not create, modify, or delete tasks in the register. The only register modification permitted is updating the `Last run` timestamp of executed tasks.
- **No `/agents:start` router:** Agent-mode tasks load context by reading the agent's files directly (following the startup sequence in `agents/scheduler/prompt.md`). The `/agents:start` router skill is not used.
- **No session end protocol:** Agent-mode tasks do not create session memories, update action trackers, or commit. Those are handled at the next interactive session.
- **Single pass:** The scheduler processes all due tasks in one pass, then exits. It does not wait for responses, poll for results, or schedule follow-up work.

## Failure Handling

- If a task fails (tool error, missing file, channel not found), log the failure with the error details and move to the next task. Do not retry.
- If the policies file cannot be read, abort the entire run. No tasks execute without policies loaded.
- If the register file cannot be read, abort the entire run and log the error.

## Audit

All executions are logged to `agents/scheduler/logs/YYYY-MM.md` with:
- Timestamp
- Task ID
- Actions taken (tool calls made, messages sent, files read/written)
- Outcome (success, skipped, failed + reason)
