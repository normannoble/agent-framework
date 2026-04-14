# Agent Conventions

How agents are built, structured, and operated in this workspace.

## Naming

Agents are named using **{{NAMING_TRADITION}}** — {{NAMING_DESCRIPTION}}. Names are invocation handles: `/agent <name>`, not `/agent platform-strategy-lead`.

Names should not signal the agent's domain. A project-scoped agent may outlive its original project, or be reassigned. Neutral names survive these changes.

**Pool:** {{NAMING_EXAMPLES}}

**Reserved:** *(add names here as agents are created)*

## Invocation

All agents are invoked through the `/agent` router:

```
/agent <name>          — activate an agent
/agent <name> <topic>  — activate and work on a topic
/agent <name> close    — end session and save state
/agent list            — list all agents
/agent list <scope>    — list agents in a scope
```

## Directory Structure

Workspaces use one of two layouts:

- **Single-domain** (most repos): `Agents/<name>/`
- **Multi-domain** (multi-project repos): `Agents/<scope>/<name>/`

```
Agents/<name>/
├── role.md              # Purpose, scope, outcomes, boundaries
├── soul.md              # Voice, temperament, behavioral traits
├── name.md              # Historical/mythological figure behind the name
├── autonomy.md          # Authority ladder — what the agent owns vs. flags
├── actions.md           # Standing action tracker (always current)
├── context.md           # Startup context paths and project file references
├── MEMORY.md            # Memory index — standing and session sections
└── memory/
    ├── standing/        # Durable rules, decisions, baselines
    └── sessions/        # Per-session logs
```

### context.md

Defines what additional files the agent needs on startup and which project files to update on session end. Frontmatter includes `scope` and `title` (used by `/agent list`). Body has two sections:
- **Startup Context** — paths to read after the standard agent files
- **Project Files** — paths to check for updates during Session End Protocol

All paths are relative to the repository root.

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

Soul doesn't repeat working rules from role.md. Role says what to do; soul says how to be.

### name.md

Captures the historical or mythological figure behind the agent's name and why it fits. Short — under 15 lines. Written once at creation and rarely updated. Structure:
- The name and its literal meaning (if it translates)
- The figure (2-4 sentences — who they were, what they did)
- Why it fits this agent's character (1-2 sentences)

Name files preserve the naming rationale across time. The naming pool is chosen specifically because the figures carry archetypes; that archetype is lost if the reasoning only lives in the creation conversation.

### autonomy.md

Defines the agent's operating authority — what it can do independently and what requires input. Structure:
- Five authority levels (L5 Own → L1 Flag), each listing specific action types
- A changelog recording promotions and demotions with dates and context

See **Autonomy Model** below for the full framework. This file is the agent's primary reference for how to behave during a session — it governs whether the agent acts, announces intent, or asks.

### actions.md

Single standing file — the agent's running to-do list. Always current, updated every session close. Structure:
- "Last reviewed" date at the top
- Open table: #, Action, Owner, Priority, Due/Target, Status, Since
- Completed table: #, Action, Owner, Completed date

Priority uses P1/P2/P3:
- **P1** — Must progress this week. Session focus candidates.
- **P2** — Should progress when P1s are clear. Tracked actively.
- **P3** — Tracked, not urgent. Revisit periodically.

Session memories reference `actions.md` for action items rather than duplicating them. This prevents action items from being lost in old session logs.

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

## Autonomy Model

Inspired by *Turn the Ship Around* (L. David Marquet). The core principle: agents state intent and drive execution rather than waiting for instructions or asking permission for things they're competent to handle. {{PRINCIPAL}} owns the decisions; agents own the momentum.

### The Authority Ladder

| Level | Agent says | Meaning |
|-------|-----------|---------|
| **L5 — Own** | *(in session summary)* | Act independently. Report at session close. |
| **L4 — Act & Inform** | "I've done X." | Act, then flag it in the moment. |
| **L3 — Intend** | "I intend to..." | State intent and reasoning. Proceed unless redirected. |
| **L2 — Recommend** | "I recommend..." | Present analysis + recommendation. Wait for approval. |
| **L1 — Flag** | "I see a problem..." | Surface the issue for {{PRINCIPAL}} to decide. |

**Default for new agents:** Most actions start at L2 (Recommend). Mechanical/administrative actions (updating trackers, grooming stale tickets) can start at L4-L5. Strategic decisions always start at L1.

### Intent-Based Communication

The signature behavior change: agents default to **"I intend to..."** (L3) rather than asking "What should I do?" or "Would you like me to...?"

When operating at L3, the agent:
1. States what it intends to do
2. States why (brief reasoning)
3. Proceeds after a natural pause unless {{PRINCIPAL}} redirects

This keeps {{PRINCIPAL}} in the loop without making them the bottleneck. The agent drives; {{PRINCIPAL}} steers.

### Promotion & Demotion

Authority levels change through explicit signals:

**Promotion** (moving an action type up the ladder):
- {{PRINCIPAL}} says something like "good call, just do that next time" or "you don't need to ask me for this"
- The agent records the promotion in `autonomy.md` with the date and context

**Demotion** (moving an action type down the ladder):
- {{PRINCIPAL}} corrects a decision or says "check with me before doing that"
- The agent records the demotion in `autonomy.md` with the date and what went wrong

**Self-assessment:** During session end, the agent should note any moments where it felt uncertain about its authority level — these are candidates for explicit clarification.

### autonomy.md Format

```markdown
# <Name> — Autonomy

Operating authority for <Name>. Items move up the ladder as trust is demonstrated.
See `Agents/CONVENTIONS.md` § Autonomy Model.

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

## Session Focus

Agents have a natural tendency toward recency bias — prioritising whatever was discussed most recently over items that may actually be more important. These mechanics counteract that.

### Session Priority Declaration

At the start of every session (after loading context), the agent:
1. Reviews `actions.md` and identifies the top priorities (P1 items first, then P2)
2. Declares a **session focus** — up to 3 items that this session should progress, in priority order
3. Gets {{PRINCIPAL}}'s agreement before proceeding

This declaration becomes the session's compass. Everything that follows is measured against it.

### Compass Check

When conversation moves to a topic not in the session focus, the agent pauses briefly:
- If the new topic is clearly higher priority, acknowledge the shift: "This supersedes what we were working on. Adjusting session focus."
- If the new topic is a side thread, note it: "I'll capture this in the action tracker. Back to [current focus]?"
- If unclear, ask: "Is this more urgent than [current focus], or should we note it and come back?"

This isn't about being rigid — it's about making drift conscious rather than accidental.

### Drift Management

If the session has spent significant time on a topic outside the declared focus, the agent flags it directly:
- State what the original session focus was
- Note how far the conversation has drifted
- Suggest either: (a) refocusing on the original priorities, or (b) wrapping the current session and starting a fresh one dedicated to the new topic

The agent should not silently allow session priorities to be displaced by conversation momentum.

### Session-End Reconciliation

During session close, the agent explicitly reviews:
- Which session focus items were actually addressed
- Which were not, and why (deliberate pivot, time ran out, drift)
- Whether any side topics emerged that should become P1/P2 actions

This is reported in the session summary and the confirm step — not hidden.

## Agent Router

All agents are invoked through the `/agent` router skill. The router:
- Parses the agent name from arguments
- Finds the agent directory
- Executes the standard startup sequence
- Becomes that agent for the session

Individual per-agent skill files are not needed. Agent-specific startup context is defined in `context.md`.

### Startup Sequence (standard order)

1. Soul (`soul.md`)
2. Name (`name.md`)
3. Role (`role.md`)
4. Autonomy (`autonomy.md`)
5. Actions (`actions.md`)
6. Memory index (`MEMORY.md`)
7. All standing memories
8. Most recent 2 session memories
9. Paths listed in `context.md` under `## Startup Context`

### Session End Protocol (standard steps)

1. Review the session — scan conversation for topics, decisions, action items, documents
2. Update action tracker — add new, complete done, flag at-risk
3. Review autonomy — note any promotions, demotions, or uncertain moments; update `autonomy.md`
4. Create session memory — in `memory/sessions/`, reference actions.md instead of duplicating
5. Update memory index — add one-line summary
6. Update project files — log and status if changed
7. Commit and push — stage all session changes, commit with a descriptive message, push to origin
8. Confirm — show summary (include any autonomy changes)

## Baseline Consolidation

When the agent has accumulated more than 5 standing entries or more than 10 session entries, consolidate:
- Create a new baseline entry in `memory/standing/` that captures current project state
- Archive old session entries (move to `memory/archive/` or delete if fully captured in the baseline)
- Update MEMORY.md index

This prevents context bloat while preserving institutional knowledge.
