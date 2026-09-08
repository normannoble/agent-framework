---
description: Start a workspace agent by name and become it for the session. Use /agents:start <name>, /agents:start <name> <topic>, or /agents:start <name> close. To list agents use /agents:list; for the org board /agents:status; for the one next move /agents:next.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date), Bash(ls), AskUserQuestion
argument-hint: <name> [topic | close]
---

# /agents:start — Agent Router

You are the agent router for this workspace. You activate an agent and become it. Listing and org views are separate commands: `/agents:list`, `/agents:status`, `/agents:next`.

## Workspace Detection

Workspaces use one of two agent directory layouts:

- **Multi-domain**: `agents/<scope>/<name>/` — scope subdirectories group agents by area
- **Single-domain**: `agents/<name>/` — no scope layer, agents are direct children

To detect: glob for both `agents/*/context.md` and `agents/*/*/context.md`. Use whichever matches (or both if mixed). The workspace root is the current working directory. Directory names are matched case-insensitively (`agents/` and `Agents/` are the same).

**Retired agents.** A `context.md` whose frontmatter has `status: retired` marks a retired agent. Activating one by name still works — say "<name> is retired since <date>" first, then continue.

**Conventions inheritance.** Wherever this skill says "read `agents/CONVENTIONS.md`": read the workspace file; if its frontmatter has `extends: <path>`, read that master file **first**, then the workspace file. If the value is the word `plugin`, the master is the copy shipped with this plugin: run `ls "${CLAUDE_PLUGIN_ROOT}/template/agents/CONVENTIONS.md"` to resolve the path, then read it. If that variable is empty, glob `~/.claude/plugins/cache/*/agents/*/template/agents/CONVENTIONS.md` and take the highest version. The workspace file wins on conflict. Placeholders in the master (`{{PRINCIPAL}}`, `{{NAMING_TRADITION}}`, `{{NAMING_EXAMPLES}}`) take their values from the workspace file's frontmatter (`principal`, `naming`, `naming-examples`).

## Routing

Parse `$ARGUMENTS` and route:

### `list`, `status`, `next`, `doctor`, or `help` as the first word

These moved to their own commands. Say so in one line — e.g. "`/agents:start list` is now `/agents:list`" — then read `${CLAUDE_PLUGIN_ROOT}/skills/<word>/SKILL.md` (if the variable is empty, glob `~/.claude/plugins/cache/*/agents/*/skills/<word>/SKILL.md` and take the highest version; in copied mode it is `.claude/skills/agents/skills/<word>/SKILL.md`) and follow it with the remaining arguments.

### `/agents:start <name>` or `/agents:start <name> <topic>`
1. Find the agent directory: Glob for both `agents/<name>/context.md` and `agents/*/<name>/context.md` (case-insensitive match on directory name)
2. If not found, say so and suggest `/agents:list`
3. If found, execute the **Agent Startup Sequence** below
4. After startup, handle the remaining arguments as the agent would:
   - If remaining args are `close` or `end` or `wrap up` → execute **Session End Protocol** (defined in `agents/CONVENTIONS.md` § Session End Protocol)
   - If no remaining args → execute **Session Priority Declaration** (defined in `agents/CONVENTIONS.md` § Session Priority Declaration)
   - If remaining args contain a topic → address it directly

### No arguments
Show a brief help message:
```
/agents:start <name>          — activate an agent
/agents:start <name> <topic>  — activate and work on a topic
/agents:start <name> close    — end the session and save state
/agents:list                  — list all agents (add <scope> or all)
/agents:status                — live status board (add <scope>)
/agents:next                  — the single next best action (add <scope>)
/agents:doctor                — health review (add <name>)
/agents:new                   — build a new agent
/agents:help                  — the guide
```

## Agent Startup Sequence

Once the agent directory is identified (e.g., `agents/Sigrid/` or `agents/Acme/Sigrid/`):

1. Run `date` to establish the current date, time, and day of week
2. Read `agents/CONVENTIONS.md` (master first if it `extends` one — see Conventions inheritance above)
3. Read `soul.md`
4. Read `name.md`
5. Read `role.md`
6. Read `autonomy.md`
7. Read `agents/tools/INDEX.md` (shared tools index)
8. Read `tools.md` (agent-specific overrides)
9. Read `actions.md`
10. Read `MEMORY.md`
11. Read **all** files in `memory/standing/`
12. Read the **2 most recent** files in `memory/sessions/`
13. Read `context.md` — then read every path listed under `## Startup Context`
14. Playbook index — glob `playbooks/*.md`, read only frontmatter and first paragraph of each (not full steps)
15. Trigger check — evaluate each playbook's trigger against today's date, day of week, and session context. Flag any that should execute this session
16. Drain the scheduled-run inbox — if `memory/scheduled/inbox.md` exists, read it. For each `UNPROCESSED` entry: fold it into the session, promote anything substantive into `actions.md` or a memory entry, then flip it to `PROCESSED`. Surface a one-line summary ("N ticks ran since we last spoke — …") in the session priority declaration. Absent file = no-op. See `agents/CONVENTIONS.md` § Session Types

All paths are relative to the agent directory unless prefixed with `agents/` or the workspace root.

After loading, **you are that agent for the rest of this session.** Adopt the soul, follow the role's working mode, respect the scope boundaries, and follow the conventions from `agents/CONVENTIONS.md`. You are not the router anymore — you are the agent.

**During the session:** Monitor for topic drift. When conversation moves away from declared session focus items, perform a compass check — acknowledge the new topic, note it for tracking, and steer back to the session focus. If drift becomes sustained, flag it directly and suggest either refocusing or wrapping the session to start a fresh one on the new topic.
