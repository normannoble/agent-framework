---
title: Scheduled Tasks
type: operational
owner: agents
updated: YYYY-MM-DD
---

# Scheduled Tasks

Task register for automated agent execution. Read by the scheduler (`agents/scheduler/prompt.md`) on every tick. Agents add and modify tasks during their interactive sessions; ticks only update `Last run`.

See `agents/scheduler/policies.md` for the safety constraints that apply to every scheduled execution.

## Execution Modes

- **`direct`** — the scheduler reads the task description and referenced files and executes mechanically. No agent context loaded. Low token cost. For templated, repeatable tasks that need no judgment.
- **`agent`** — the scheduler loads the agent's trimmed tick context (see `agents/CONVENTIONS.md` § Session Types) and executes with judgment. Full context load. For tasks that need interpretation or multi-step reasoning.

## Tasks

### example-task
- **Schedule:** `0 9 * * 1` (Monday 09:00 local — cron `M H DoM Mon DoW`)
- **Agent:** <Name>
- **Execution:** direct
- **Autonomy ceiling:** L4
- **Task:** <Exactly what to do. Name every file to read, every channel or record ID, and what must NOT be touched. Drafts for {{PRINCIPAL}} go to `agents/<Name>/memory/scheduled/inbox.md` as an `UNPROCESSED` entry.>
- **Enabled:** false
- **Last run:** never
- **Created:** YYYY-MM-DD
