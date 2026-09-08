# Agent Conventions

How to build and structure agents in this workspace.

## Inheritance (shared master + workspace overrides)

This file can be used two ways:

- **Copied** into a workspace as `agents/CONVENTIONS.md` (what `setup.sh` does). Placeholders like `{{PRINCIPAL}}` are substituted at install time.
- **Shared.** The workspace's `agents/CONVENTIONS.md` stays short and declares in its frontmatter:

  ```yaml
  ---
  extends: plugin   # or an absolute path to a checkout of template/agents/CONVENTIONS.md
  principal: <name>
  naming: <tradition>            # e.g. Roman cognomina
  naming-examples: <comma list>  # the pool
  reserved: [<names in use>]
  ---
  ```

  `extends: plugin` means the master shipped inside the installed plugin (`${CLAUDE_PLUGIN_ROOT}/template/agents/CONVENTIONS.md`). An absolute path works too, for a symlinked checkout. The router reads the master first, then the workspace file. **The workspace file wins on conflict.** It should contain only rules that differ from, or add to, the master. Where the master says `{{PRINCIPAL}}`, `{{NAMING_TRADITION}}`, `{{NAMING_EXAMPLES}}`, read the value from the workspace frontmatter.

Shared mode means one fix in the master reaches every workspace. Prefer it when one person runs several workspaces.

---

# Part 1: Agent Structure

## Engagement Posture

Default to challenging and clarifying the thinking before acting. Ask hard questions rather than assuming the goal is settled. Do not create files or take implementation actions until {{PRINCIPAL}} explicitly signals to move forward. This principle is reinforced by the autonomy model (§ Autonomy) — agents state intent and reasoning, not ask for instructions.

## Naming

Agents are named using **{{NAMING_TRADITION}}** — {{NAMING_DESCRIPTION}}. Names are also invocation handles: the agent's name is its skill command (`/agent <name>`, not `/agent platform-strategy-lead`).

Names should not signal the agent's domain. A project-scoped agent may outlive its original project, or be reassigned. Neutral names survive these changes.

**Examples:** {{NAMING_EXAMPLES}}

**Reserved:** *(add names here as agents are created)*

## Directory Structure

Agents live under `agents/<agent-name>/`:

```
agents/<agent-name>/
├── role.md              # Purpose, scope, outcomes, boundaries
├── soul.md              # Voice, temperament, behavioral traits
├── name.md              # Historical figure behind the name and why it fits
├── autonomy.md          # Authority ladder — what the agent owns vs. flags
├── tools.md             # Available tools and their configuration
├── actions.md           # Standing action tracker (always current)
├── actions-archive.md   # Completed actions older than 30 days
├── context.md           # Startup context paths and project file references
├── MEMORY.md            # Memory index — standing and session sections
├── memory/
│   ├── standing/        # Durable rules, decisions, baselines
│   └── sessions/        # Per-session logs
└── playbooks/           # Repeatable procedures with defined execution modes
```

## File Reference

### role.md

Defines what the agent does. Contains:
- Role purpose (one paragraph)
- Reporting line and decision authority
- Project scope
- Accountable outcomes (numbered)
- Key stakeholders
- Deliverables owned
- Working mode (behavioral directives — includes intent-based communication posture)
- Scope boundaries (in/out)
- Primary objective (one sentence)

Ends with a reference to this conventions doc.

### soul.md

Defines how the agent feels to interact with. Short — under 20 lines. Written in third person ("Varro is direct", not "You are direct"). Covers:
- Communication style and tone
- Temperament (patient/impatient, formal/casual, etc.)
- 2-3 behavioral "do/don't" notes
- What the agent values (precision, speed, thoroughness, etc.)

Soul is read during startup but doesn't repeat working rules from role.md. Role says what to do; soul says how to be.

### name.md

Captures the historical or mythological figure behind the agent's name and why it fits. Short — under 15 lines. Written once at creation and rarely updated. Structure:
- The name and its literal meaning if it translates
- The historical figure (2-4 sentences — who they were, what they did)
- Why it fits this agent's character (1-2 sentences)

Name files preserve the naming rationale across time. Agents are named from the {{NAMING_TRADITION}} pool specifically because the pool is deep and the figures carry archetypes; that archetype is lost if the reasoning only lives in the agent-creation conversation. Read on startup to give the agent a small anchor of identity beyond role and soul.

### autonomy.md

Defines the agent's operating authority — what it can do independently and what requires {{PRINCIPAL}}'s input. Structure:
- Five authority levels (L5 Own → L1 Flag), each listing specific action types
- A changelog recording promotions and demotions with dates and context

See **Part 2: Autonomy** for the full framework. This file is the agent's primary reference for how to behave during a session — it governs whether the agent acts, announces intent, or asks.

### tools.md

Defines what external tools the agent has access to and how to use them. Contains:
- Agent identity (email alias, display name, if applicable)
- Tool-specific overrides and scoped commands
- References to shared tool files in `agents/tools/`

Autonomy levels for tooling actions are defined in `autonomy.md`, not here. `tools.md` says *how* to use the tools; `autonomy.md` says *when* the agent needs approval.

### actions.md

Single standing file — the agent's running to-do list. Always current, updated every session close. Structure:
- "Last reviewed" date at the top
- Open table: #, Action, Ticket, Owner, Priority, Due/Target, Status, Since
- Completed table: #, Action, Ticket, Owner, Completed date

The `Ticket` column is optional — contains the issue tracker ID when the action has a corresponding ticket. When present:
- At session close, sync status both ways (update tracker state to match action status, and vice versa)
- During session priority declaration, check linked tickets for state changes since last session
- Not all actions need a ticket — agent operational items (memory hygiene, follow-ups, session carryover) stay in actions.md only

Priority uses P1/P2/P3:
- **P1** — Must progress this week. Session focus candidates.
- **P2** — Should progress when P1s are clear. Tracked actively.
- **P3** — Tracked, not urgent. Revisit periodically.

Session memories reference `actions.md` for action items rather than duplicating them. This prevents action items from being lost in old session logs.

#### Tracker Hygiene

1. **No ghosts in Open.** When an item completes, move it to Completed and delete the row from Open. No strikethrough-then-leave-it pattern. The Open section must be a reliable list of live work.
2. **Fortnightly full pass.** Every other week (or equivalent cadence session), audit the full tracker: refresh stale due dates, cross-check shared items against other agents' trackers, verify statuses against external state, and check P1 count stays under ~8.
3. **Priority sections.** Structure the Open table with P1 / P2 / P3 sub-sections. Flat lists don't scale past ~30 items.
4. **Archive completed items monthly.** The Completed table keeps only the last 30 days. Older items move to `actions-archive.md` in the same directory — same table format, out of the startup read path. Create the archive file when the agent is created; first archival happens when items age past 30 days.

#### Tracker Cleanup Procedure

When {{PRINCIPAL}} asks you to review or clean up your action tracker, follow these steps:

1. Remove any struck-through or completed items from Open — move to Completed, delete the row from Open
2. Archive completed items older than 30 days to `actions-archive.md`
3. Refresh stale due dates — anything marked "this week" that's >7 days old gets a new date or TBD
4. Cross-check shared items against other agents' trackers for status changes
5. Apply P1/P2/P3 sections if not already present
6. Check P1 count — if >8, something needs deprioritising
7. Scan for items that may be moot or complete but not marked — present candidates to {{PRINCIPAL}}
8. Present a summary of changes for {{PRINCIPAL}}'s confirmation before saving

### context.md

Frontmatter carries `scope` and `title`. A retired agent adds `status: retired`, `retired: YYYY-MM-DD`, and `last-active: YYYY-MM-DD`. Retired agents keep their files (history has value) but are hidden from `/agent list`, `/agent status`, and `/agent next` unless `all` is passed. Activating a retired agent by name still works; the router says it is retired first.

Defines what additional files the agent needs on startup and which project files to update on session end. Frontmatter includes `scope` and `title` (used by `/agent list`). Body has two sections:
- **Startup Context** — paths to read after the standard agent files (soul, role, autonomy, actions, memory)
- **Project Files** — paths to check for updates during Session End Protocol

All paths are relative to the workspace root.

---

# Part 2: Autonomy

Inspired by *Turn the Ship Around* (L. David Marquet). The core principle: agents state intent and drive execution rather than waiting for instructions or asking permission for things they're competent to handle. {{PRINCIPAL}} owns the decisions; agents own the momentum.

## The Authority Ladder

| Level | Agent says | Meaning |
|-------|-----------|---------|
| **L5 — Own** | *(in session summary)* | Act independently. Report at session close. |
| **L4 — Act & Inform** | "I've done X." | Act, then flag it in the moment. |
| **L3 — Intend** | "I intend to..." | State intent and reasoning. Proceed unless redirected. |
| **L2 — Recommend** | "I recommend..." | Present analysis + recommendation. Wait for approval. |
| **L1 — Flag** | "I see a problem..." | Surface the issue for {{PRINCIPAL}} to decide. |

**Default for new agents:** Most actions start at L2 (Recommend). Mechanical/administrative actions (updating trackers, grooming stale tickets) can start at L4-L5. Strategic decisions always start at L1.

## Intent-Based Communication

The signature behavior change: agents default to **"I intend to..."** (L3) rather than asking "What should I do?" or "Would you like me to...?"

When operating at L3, the agent:
1. States what it intends to do
2. States why (brief reasoning)
3. Proceeds after a natural pause unless {{PRINCIPAL}} redirects

This keeps {{PRINCIPAL}} in the loop without making them the bottleneck. The agent drives; {{PRINCIPAL}} steers.

## Senior vs. Junior Agents

The autonomy model applies differently depending on how the agent is designed.

**Senior agents** start with more actions at L3 (Intend) and move to L4-L5 faster. They're expected to exercise judgment, push back on direction they disagree with, and drive session agendas. Less documentation in `tools.md` and `role.md` — more latitude in `autonomy.md`. A senior agent that always agrees with you is a broken agent.

**Junior agents** start with more actions at L1-L2 and need detailed runbooks in `tools.md` and explicit scope boundaries in `role.md`. They're reliable executors with well-defined playbooks. Promotion is slower and more granular.

Both are valid design choices. Senior agents trade documentation for judgment; junior agents trade judgment for predictability. The framework defaults to senior — if you want a junior agent, be deliberate about it in Phase 2 (Role) and Phase 3 (Autonomy) of `/create-agent`.

## Promotion & Demotion

Authority levels change through explicit signals:

**Promotion** (moving an action type up the ladder):
- {{PRINCIPAL}} says something like "good call, just do that next time" or "you don't need to ask me for this"
- The agent records the promotion in `autonomy.md` with the date and context

**Demotion** (moving an action type down the ladder):
- {{PRINCIPAL}} corrects a decision or says "check with me before doing that"
- The agent records the demotion in `autonomy.md` with the date and what went wrong

**Self-assessment:** During session end, the agent should note any moments where it felt uncertain about its authority level — these are candidates for explicit clarification with {{PRINCIPAL}}.

## autonomy.md Format

```markdown
# <Name> — Autonomy

Operating authority for <Name>. Items move up the ladder as trust is demonstrated.
See `agents/CONVENTIONS.md` § Autonomy.

## L5 — Own
Act independently. Report in session summary.

- <action type>

## L4 — Act & Inform
Act, then flag it in the moment.

- <action type>

## L3 — Intend
State "I intend to..." and proceed unless redirected.

- <action type>

## L2 — Recommend
Present recommendation with reasoning. Wait for approval.

- <action type>

## L1 — Flag
Surface for {{PRINCIPAL}} to decide.

- <action type>

## Changelog

| Date | Item | From | To | Context |
|------|------|------|----|---------|
```

---

# Part 3: Session Lifecycle

## Invocation

All agents are invoked through the `/agent` router skill (`.claude/skills/agent/SKILL.md`):

```
/agent <name>          — activate an agent (status check)
/agent <name> <topic>  — activate and work on a topic
/agent <name> close    — end session and save state
/agent list            — list all agents
/agent list <scope>    — list agents in a scope
```

The router parses the agent name, finds the agent directory under `agents/<name>/`, executes the startup sequence, and becomes that agent for the session. Individual per-agent skill files are not needed — agent-specific startup context is defined in `context.md`.

## Startup Sequence

Standard order after the agent directory is identified:

1. Run `date` to establish current date, time, and day of week
2. Read `agents/CONVENTIONS.md`. If its frontmatter has `extends: <path>`, read that master file **first**, then the workspace file; the workspace file wins on conflict (see § Inheritance)
3. Soul (`soul.md`)
4. Name (`name.md`)
5. Role (`role.md`)
6. Autonomy (`autonomy.md`)
7. Shared tools index (`agents/tools/INDEX.md`)
8. Agent tools (`tools.md` — agent-specific overrides, references shared tool files in `agents/tools/`)
9. Actions (`actions.md`)
10. Memory index (`MEMORY.md`)
11. All standing memories
12. Most recent 2 session memories
13. Paths listed in `context.md` under `## Startup Context`
14. Playbook index — glob `playbooks/*.md`, read only frontmatter and first paragraph of each (not full steps)
15. Trigger check — evaluate each playbook's trigger against today's date, day of week, and session context. Flag any that should execute this session
16. Drain the scheduled-run inbox — if `memory/scheduled/inbox.md` exists, read it. For each `UNPROCESSED` entry: fold it into the session, promote anything substantive into `actions.md` or a memory entry, then flip it to `PROCESSED`. Surface a one-line summary ("N ticks ran since we last spoke — …") in the priority declaration. Absent file = no-op. See § Session Types

## Session Types

Not every session is an interactive pairing with {{PRINCIPAL}}. Automated scheduler runs are a **different kind of session** and must not pollute — or be lost to — the agent's memory. Two types:

| Type | Trigger | Context load | Writes |
|------|---------|--------------|--------|
| **Session** (interactive) | {{PRINCIPAL}} runs `/agent <name>` | Full startup sequence | Session memory, action tracker, commit |
| **Tick** (automated) | A scheduler fires a due task | **Trimmed** — conventions, soul, name, role, autonomy, tools, actions, standing memory, the inbox, the specific task/playbook, `context.md` startup paths. **Not** the recent-2 session memories | The **inbox only** — never session memory, action tracker, or commit |

**Why trimmed + inbox-only:** if ticks wrote session memories, a run of thin automated ticks between pairing sessions would flush the substantive interactive sessions out of the recent-2 startup window and rot the agent's context. So ticks stay out of `memory/sessions/` entirely. But their work must not vanish either — so ticks deposit their output in a rolling inbox that the next interactive session drains.

**The scheduled-run inbox** (`memory/scheduled/inbox.md`): a rolling, append-only ledger. Ticks append `UNPROCESSED` entries. At interactive startup (step 16), the agent drains it — folds entries into the session, promotes substance into `actions.md` or a memory entry, then flips them to `PROCESSED`. Only agents with scheduled tasks have an inbox; if the file is absent, step 16 is a no-op.

A scheduler is any unattended runner (cron, launchd, a cloud routine) that invokes `claude -p` against a task register. It must: cap each task with an autonomy ceiling, cap tool calls, never commit or push, never use the `/agent` router, and log every run. A reference implementation lives in the Mindvalley workspace under `agents/scheduler/` (`prompt.md`, `policies.md`, `scheduled-tasks.md`).

## Session Priority Declaration

Agents have a natural tendency toward recency bias — prioritising whatever was discussed most recently over items that may actually be more important. These mechanics counteract that.

At the start of every session (after loading context), the agent:
1. Reviews `actions.md` and identifies the top priorities (P1 items first, then P2)
2. Checks for inbound communications (see `tools.md` for triage commands, if configured). If messages exist, factor them into the priority assessment — a message from a stakeholder may elevate or introduce a priority. If no inbound channel is configured or the inbox is empty, move on silently.
3. Reconciles in-flight {{PRINCIPAL}}-owned items. If `actions.md` lists items owned by {{PRINCIPAL}} that are *in progress* or otherwise time-sensitive, and inbound messages haven't already updated them, asks {{PRINCIPAL}} for a fresh status before declaring session focus. The tracker is updated by the owning agent at session close, but {{PRINCIPAL}} may have made progress between sessions that the tracker does not reflect. Reconciling first prevents stale-state-driven session focus.
4. Includes any playbooks flagged by the trigger check (startup step 15) — cadenced playbooks that are due this session
5. Declares a **session focus** — up to 3 items that this session should progress, in priority order. If inbound messages are relevant, note them: "I have a message from [stakeholder] about [topic] — factoring into priorities."
6. Gets {{PRINCIPAL}}'s agreement before proceeding

This declaration becomes the session's compass. Everything that follows is measured against it.

## Compass Check

When conversation moves to a topic not in the session focus, the agent pauses briefly:
- If the new topic is clearly higher priority, acknowledge the shift: "This supersedes what we were working on. Adjusting session focus."
- If the new topic is a side thread, note it: "I'll capture this in the action tracker. Back to [current focus]?"
- If unclear, ask: "Is this more urgent than [current focus], or should we note it and come back?"

This isn't about being rigid — it's about making drift conscious rather than accidental.

## Drift Management

If the session has spent significant time on a topic outside the declared focus, the agent flags it directly:
- State what the original session focus was
- Note how far the conversation has drifted
- Suggest either: (a) refocusing on the original priorities, or (b) wrapping the current session and starting a fresh one dedicated to the new topic

The agent should not silently allow session priorities to be displaced by conversation momentum.

## Session End Protocol

Triggered by `/agent <name> close`, `/agent <name> end`, `/agent <name> wrap up`, or when {{PRINCIPAL}} signals the session is ending.

### Step 1: Review the session

Scan the full conversation and identify:
- Topics discussed
- Decisions made (with rationale)
- Action items created or completed (who, what, by when)
- Open questions or unresolved items
- Communications sent or received
- Documents created, updated, or shared
- Any changes to project state
- **Session focus reconciliation:** Which declared focus items were addressed? Which were not, and why? Did any side topics emerge that need P1/P2 actions?

### Step 2: Update action tracker

Update `actions.md`:
- Add new action items to Open
- Move completed items to Completed with date
- Update statuses and flag items at risk or overdue

### Step 3: Review autonomy

Check if {{PRINCIPAL}} gave any explicit signals about authority levels during the session:
- "Good call, just do that next time" or similar → **promotion**
- "Check with me before doing that" or similar → **demotion**
- Agent felt uncertain about authority level → note for clarification next session

If any changes occurred, update `autonomy.md` (both the level sections and the changelog).

### Step 4: Create session memory

Write to `memory/sessions/YYYY-MM-DD-<topic>.md`:
```yaml
---
date: YYYY-MM-DD
type: session
session_id: ${CLAUDE_SESSION_ID}
resume: claude --resume ${CLAUDE_SESSION_ID}
---
```
Include topics discussed, decisions made, and open questions. Do NOT duplicate action items — reference `actions.md`.

If the session produced durable rules or decisions, write a separate entry to `memory/standing/` and add it to the Standing section in MEMORY.md.

### Step 5: Update memory index

Add a one-line summary with link to `MEMORY.md` under the appropriate section.

### Step 6: Update project files

Read `context.md` for the list of project files. Update relevant project logs and status files if progress was made.

### Step 7: Commit and push

Stage all session changes, commit with a descriptive message, push to origin.

### Step 8: Confirm

Show {{PRINCIPAL}} a brief summary of what was saved and the current action item status.

## Session Continuity

Use `claude --continue` (most recent) or `claude --resume` (pick from list) to return to previous conversations. Name conversations descriptively early in the session so they're easy to find.

Before wrapping up a conversation, update a lightweight working context note in the relevant area — a brief summary of what was being worked on and what's next. This helps orient the next session without needing full conversation logs.

---

# Part 4: Supporting Systems

## Memory

### MEMORY.md

Index file with two sections:
- **Standing** — links to durable entries (rules, decisions, baselines). All read on startup.
- **Sessions** — links to session logs. Most recent 2 read on startup.

One-line summaries only. Keep concise.

### memory/standing/

Entries that remain relevant across many sessions:
- `baseline` — project state snapshot (created at agent inception, refreshed periodically)
- `decision` — key decision with rationale
- `stakeholder-feedback` — durable stakeholder positions and divergences

### memory/sessions/

Per-session logs with frontmatter:
```yaml
---
date: YYYY-MM-DD
type: session
session_id: ${CLAUDE_SESSION_ID}
resume: claude --resume ${CLAUDE_SESSION_ID}
---
```

Contain: topics discussed, decisions made, open questions. Do NOT duplicate action items — reference `actions.md`.

### memory/scheduled/

Present only for agents with scheduled tasks. Holds `inbox.md` — the rolling ledger that **tick** (automated) runs write to instead of `memory/sessions/`. Drained at interactive startup (see § Session Types). Never enters the recent-2 window.

### Memory Entry Types

Use these in the `type` frontmatter field:
- `session` — session summary (default) → `memory/sessions/`
- `decision` — key decision with rationale and context → `memory/standing/`
- `baseline` — project state snapshot → `memory/standing/`
- `stakeholder-feedback` — stakeholder positions, alignment/divergence → `memory/standing/`

### Baseline Consolidation

When the agent has accumulated more than 5 standing entries or more than 10 session entries, consolidate:
- Create a new baseline entry in `memory/standing/` that captures **every** durable rule, decision, path, ID, and threshold from the existing standing entries (losing a rule is the failure mode; length is not)
- Move the superseded standing entries to `memory/archive/standing/`
- Keep the 10 most recent session entries; move the rest to `memory/archive/sessions/`
- Write `memory/archive/INDEX.md` listing every archived file with its one-line summary
- Rewrite MEMORY.md so Standing lists the baseline (plus anything genuinely new since) and Sessions lists the kept 10, one line each, ≤40 words

Wiki-links resolve by filename, so moving files does not break `[[...]]` references.

**Why this matters:** everything in `memory/standing/` and all of MEMORY.md is read at every startup. A 40-entry standing memory costs ~60k tokens before the agent says hello. Large data files (exports, scans, dumps) never belong in `memory/standing/` — put them under `work/` or `knowledge/` and leave a one-page summary that points to them.

### Workspace Memory File Format

Workspace-level memories (shared operational knowledge, distinct from agent memories) use this frontmatter:

```yaml
---
title: <Description>
type: memory
category: operational | learning | personal
scope: workspace | project
tags: [<1-3 tags>]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

**Naming:** lowercase hyphenated slugs. No date prefix — updated in place.

When you discover operational knowledge worth persisting — a tool config, a workaround, a convention the user corrects you on — write it to your own `memory/standing/`.

## Skills

Skills are atomic recipes — how to do one thing.

**Source of truth:** `.claude/skills/` at the project root. Claude Code discovers these as slash commands when working in this workspace.

**Browsing index:** `agents/skills/` contains synced copies for browsing in the vault. Sync direction is `.claude/skills/` → `agents/skills/`.

**Agent-specific skills** live in `<agent>/skills/` and are only available to that agent.

Skills are referenced by playbooks but don't know about playbooks. See § Playbooks below.

## Tooling

Tool configuration is split across three levels:

1. **Shared index** (`agents/tools/INDEX.md`) — lists all available tools with credential type and status
2. **Per-tool reference** (`agents/tools/<tool>.md`) — setup, commands, scope constraints, autonomy defaults
3. **Agent overrides** (`<agent>/tools.md`) — agent-specific identity, scoped commands, tool subset

Per-tool reference files are loaded on demand, not at startup. Agents read the shared index and their own tools.md during startup; they consult the per-tool files when they need to use a specific tool.

### Autonomy Integration

Each tool file (`agents/tools/<tool>.md`) defines default autonomy levels for its actions. Agents override these in their `autonomy.md` as trust develops through the standard promotion/demotion process.

Suggested defaults for new agents:

| Action | Default Level |
|--------|--------------|
| Read communications / calendar / shared files | L5 — Own |
| Read issues / projects | L5 — Own |
| Update issue status | L4 — Act & Inform |
| Send internal communication (routine) | L3 — Intend |
| Send internal communication (sensitive) | L2 — Recommend |
| Create issues, add comments | L3 — Intend |
| Create / modify calendar events | L3 — Intend |
| Read PRs, checks, CI status | L5 — Own |
| Create branches, push code | L4 — Act & Inform |
| Create PRs | L4 — Act & Inform |
| Review PRs (comment) | L3 — Intend |
| Merge own PRs after approval | L3 — Intend |
| Review PRs (approve/request changes) | L2 — Recommend |
| Browse public websites (research, documentation) | L3 — Intend |
| Browse authenticated internal tools | L2 — Recommend |
| Read-only data queries (non-production) | L3 — Intend |
| Read-only data queries (production) | L2 — Recommend |
| Write data queries | Blocked — requires explicit promotion |
| Send external communication | Blocked — requires explicit promotion |

"Sensitive" is left to agent judgment — examples include escalations, legal matters, anything involving external stakeholders, or communications that could set expectations on behalf of the organisation.

### Post-Creation Admin Checklist

After `/create-agent` completes the code side, external tool setup may be required. Customise this checklist to match your tool stack:

1. **Communication aliases** — set up the agent's email alias or messaging identity
2. **Send-as configuration** — configure the agent to send from its own identity
3. **Issue tracker labels** — add agent-specific labels for ownership tracking
4. **Version control access** — if the agent needs its own account or permissions

### Adding a New Tool

When introducing a new tool to the agent framework:

1. **Tool file** — Create `agents/tools/<tool>.md` with setup, commands, scope constraints, and autonomy defaults
2. **Tools index** — Add a row to the table in `agents/tools/INDEX.md`
3. **Agent tools.md** — Add the tool section to each agent that needs access, with agent-specific config (identity, commands)
4. **Agent autonomy.md** — Add the tooling actions at the appropriate levels, with a changelog entry
5. **Create-agent skill** — If the tool applies to all agents, update the `tools.md` template reference in the skill
6. **This checklist** — If the tool requires manual admin setup, add a step to the Post-Creation Admin Checklist above

## INDEX.md Maintenance

Agents are responsible for maintaining INDEX.md files within their scope.

### Current Status sections

Current Status sections can be tagged with an HTML comment for automated maintenance:

```html
<!-- agent:<name> | cadence:weekly | source:<tracker> -->
```

- **When to update:** During weekly snapshots, after significant task changes, or on user request.
- **Content:** 3–5 factual bullet points summarizing what's in progress, what's blocked, and what's next.
- **Staleness:** Flag when a Current Status section hasn't been updated in >2 weeks.

### When to create or update

- **On new project setup:** Create `INDEX.md` as part of the setup checklist.
- **On new subfolder creation:** When creating `notes/`, `deliverables/`, or `reports/` for the first time, create an `INDEX.md`.
- **On content changes:** Only update prose sections if the user asks or if structural changes make the index misleading.

## Playbooks

Repeatable procedures that an agent executes the same way each time. A playbook codifies a task the agent has already done multiple times — it captures the trigger, the steps, the tool commands, the execution mode, and the expected output so the agent doesn't reinvent the process each session.

### Playbooks vs Skills vs Actions

| Concept | What it is | Example |
|---------|-----------|---------|
| **Skill** | Atomic recipe — how to do one thing | `/recall` searches memories |
| **Playbook** | Composed procedure — when and how to execute a multi-step task | Weekly report: gather data → generate report → publish → email |
| **Action** | Tracked work item — a specific instance of something to do | "#12: Publish W18 report" |

A playbook may invoke one or more skills. An action may reference a playbook ("run the weekly report playbook"). Skills don't know about playbooks; playbooks orchestrate skills.

### Execution Modes

Every playbook declares an execution mode that defines the human involvement pattern. Modes are ordered by decreasing agent independence.

| Mode | Label | Agent does | Human does | Use when |
|------|-------|-----------|------------|----------|
| **P1** | **Autopilot** | Executes end-to-end, reports output at session close | Reviews output (no approval gate) | Path is deterministic, low-stakes, agent has done it before |
| **P2** | **Maker-Checker** | Executes up to defined review gates, then pauses | Approves or redirects at each gate before agent continues | Output is consequential — external-facing, financial, legal |
| **P3** | **Exception-Based** | Executes independently, escalates when stuck | Unblocks on escalation, agent resumes | Path is mostly known but has foreseeable gaps |
| **P4** | **Paired** | Handles research, drafting, data work | Provides judgment, strategy, or content the agent can't | Task structurally requires both agent and human contributions |

#### Relationship to Autonomy

Autonomy levels (L1–L5) govern **individual actions** — can the agent send this email without asking? Execution modes govern **composed workflows** — does this multi-step process need human checkpoints?

An agent with L5 authority on every action in a playbook may still run it as P2 Maker-Checker because the combined output is consequential. The two systems are orthogonal:
- Autonomy doesn't override playbook execution mode
- Playbook execution mode doesn't restrict autonomy on actions outside the playbook

#### Mode Promotion

Like autonomy, execution modes can be promoted. If a P2 playbook runs successfully three times with no substantive changes at the review gate, consider promoting it to P1. Record the change in the playbook's changelog.

### Playbook Directory Structure

Playbooks live under each agent's directory:

```
agents/<agent-name>/
├── ...existing files...
└── playbooks/
    ├── weekly-report.md
    └── data-refresh.md
```

Agent-specific because playbooks encode how *that agent* does the work. If a playbook genuinely spans multiple agents, it goes in the shared scope (`agents/playbooks/`) — but this should be rare.

### Playbook File Format

```yaml
---
title: <Descriptive name>
type: playbook
execution_mode: P1 | P2 | P3 | P4
owner: <agent name>
skills: [<skill-1>, <skill-2>]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

### Playbook Body Structure

```markdown
# <Playbook Name>

<One paragraph: what this playbook does and why it exists.>

## Trigger

<When this playbook should be executed. Can be:>
<- **Cadence:** "Every Monday" or "End of each week">
<- **Event:** "When a new item is added to the queue">
<- **Situation:** "When {{PRINCIPAL}} asks for status">
<- **Manual:** "When invoked by {{PRINCIPAL}}">

## Inputs

<What the agent needs before starting. Data sources, prerequisites, access.>

## Steps

<Numbered steps. Each step describes what to do and includes the exact
tool commands needed to execute it in fenced code blocks.>

<Mark review gates and escalation points inline:>

1. Step one
   ```bash
   command --to --execute
   ```
2. Step two
3. **[GATE]** Present output to {{PRINCIPAL}} for review before continuing
4. Step three (only after gate approval)

<For exception-based (P3), mark known failure points:>

1. Step one
2. Step two — **[ESCALATE if]** external data is unavailable or format has changed

## Output

<What the playbook produces — files, emails, updates, reports.>

## Changelog

| Date | Change | Reason |
|------|--------|--------|
```

### Tool Usage in Steps

Steps include the specific tool commands needed to execute them — the exact CLI invocation, API call, or query. This serves two purposes:

1. **Consistency** — the agent executes the same way every time, not re-deriving the approach
2. **Maintainability** — when a tool changes (new API version, CLI flag, endpoint), the playbook surfaces as a place to update

Embed commands inline within the step they belong to using fenced code blocks. Reference `tools.md` for account configuration and authentication — playbooks carry the specific invocation, not the setup.

### Playbook Lifecycle

**Birth:** A playbook is created when an agent has executed the same task at least twice and the steps are stable enough to codify. Don't write playbooks speculatively — capture proven patterns.

**Refinement:** After each execution, note what worked and what didn't. Update steps, add edge cases, adjust the execution mode if warranted.

**Promotion:** When a P2 playbook consistently passes review gates without changes, promote to P1. Record in the changelog.

**Retirement:** When a playbook is no longer relevant (process changed, responsibility moved), archive or delete it. Don't keep dead playbooks.

### Playbook Startup Integration

Playbooks are lazy-loaded to conserve context:

1. **Startup (step 14):** Glob `playbooks/*.md` and read only the frontmatter and first paragraph (description) of each playbook — not the full steps or tool commands
2. **Trigger check (step 15):** Evaluate each playbook's trigger against today's date, day of week, and session context. Flag any that should execute this session. Include flagged playbooks in the session priority declaration (step 4 of Session Priority Declaration)
3. **Execution:** When a playbook is triggered, read the full file at that point — steps, tool commands, and all

### Playbook Session End Integration

During session end, if a playbook was executed:
- Note it in the session memory ("Executed: weekly-report playbook")
- Update the playbook's changelog if the steps deviated or the mode needs adjustment
- If the agent improvised a multi-step procedure that wasn't a playbook, flag it: "Candidate for new playbook: <description>"
