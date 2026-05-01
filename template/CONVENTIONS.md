# Agent Conventions

How agents are built, structured, and operated in this workspace. See `PHILOSOPHY.md` for the principles behind these conventions.

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
├── tools.md             # Available tools and their configuration
├── actions.md           # Standing action tracker (always current)
├── context.md           # Startup context paths and project file references
├── MEMORY.md            # Memory index — standing and session sections
├── memory/
│   ├── standing/        # Durable rules, decisions, baselines
│   └── sessions/        # Per-session logs
└── playbooks/           # Repeatable procedures with defined execution modes
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

### tools.md

Defines what external tools the agent has access to and how to use them. Contains:
- Account configuration (credentials, config paths)
- Agent identity (email alias, display name, if applicable)
- Command reference for each tool
- Scope constraints (e.g., internal-only communications)

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

### Senior vs. Junior Agents

The autonomy model applies differently depending on how the agent is designed.

**Senior agents** start with more actions at L3 (Intend) and move to L4-L5 faster. They're expected to exercise judgment, push back on direction they disagree with, and drive session agendas. Less documentation in `tools.md` and `role.md` — more latitude in `autonomy.md`. A senior agent that always agrees with you is a broken agent.

**Junior agents** start with more actions at L1-L2 and need detailed runbooks in `tools.md` and explicit scope boundaries in `role.md`. They're reliable executors with well-defined playbooks. Promotion is slower and more granular.

Both are valid design choices. Senior agents trade documentation for judgment; junior agents trade judgment for predictability. The framework defaults to senior — if you want a junior agent, be deliberate about it in Phase 2 (Role) and Phase 3 (Autonomy) of `/create-agent`.

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
2. Checks for inbound communications (see `tools.md` for triage commands, if configured). If messages exist, factor them into the priority assessment — a message from a stakeholder may elevate or introduce a priority. If no inbound channel is configured or the inbox is empty, move on silently.
3. Includes any playbooks flagged by the trigger check (startup step 13) — cadenced playbooks that are due this session
4. Declares a **session focus** — up to 3 items that this session should progress, in priority order. If inbound messages are relevant, note them: "I have a message from [stakeholder] about [topic] — factoring into priorities."
5. Gets {{PRINCIPAL}}'s agreement before proceeding

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

1. Run `date` to establish current date, time, and day of week
2. Soul (`soul.md`)
3. Name (`name.md`)
4. Role (`role.md`)
5. Autonomy (`autonomy.md`)
6. Tools (`tools.md`)
7. Actions (`actions.md`)
8. Memory index (`MEMORY.md`)
9. All standing memories
10. Most recent 2 session memories
11. Paths listed in `context.md` under `## Startup Context`
12. Playbook index — glob `playbooks/*.md`, read only frontmatter and first paragraph of each (not full steps)
13. Trigger check — evaluate each playbook's trigger against today's date, day of week, and session context. Flag any that should execute this session

### Session End Protocol (standard steps)

1. Review the session — scan conversation for topics, decisions, action items, communications, documents
2. Update action tracker — add new, complete done, flag at-risk
3. Review autonomy — note any promotions, demotions, or uncertain moments; update `autonomy.md` if {{PRINCIPAL}} gave explicit signals
4. Create session memory — in `memory/sessions/`, reference actions.md instead of duplicating
5. Update memory index — add one-line summary
6. Update project files — log and status if changed
7. Commit and push — stage all session changes, commit with a descriptive message, push to origin
8. Confirm — show summary to {{PRINCIPAL}} (include any autonomy changes)

## Baseline Consolidation

When the agent has accumulated more than 5 standing entries or more than 10 session entries, consolidate:
- Create a new baseline entry in `memory/standing/` that captures current project state
- Archive old session entries (move to `memory/archive/` or delete if fully captured in the baseline)
- Update MEMORY.md index

This prevents context bloat while preserving institutional knowledge.

## Tooling

Agents may have access to external tools — email, calendars, issue trackers, version control, databases, browser automation, etc. This section defines the framework for adding and managing tools. Specific tool configurations live in each agent's `tools.md`.

### Scope Constraints

Define boundaries for tooling actions in your workspace's copy of this file. Common constraints:
- **Internal-only communications.** Agents may only contact internal addresses. External communication requires explicit promotion in `autonomy.md`.
- **Shared inboxes.** All agents read from the same communication channel. No message is private to a single agent.
- **Read-only data access.** Database access is read-only for debugging and verification. Write access requires explicit promotion.

### Autonomy Integration

Tooling actions follow the agent's autonomy model (`autonomy.md`). Suggested defaults for new agents:

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

Agents override these defaults in their own `autonomy.md` as trust develops through the standard promotion/demotion process.

### Post-Creation Admin Checklist

After `/create-agent` completes the code side, external tool setup may be required. Examples:

1. **Communication aliases** — set up the agent's email alias or messaging identity
2. **Send-as configuration** — configure the agent to send from its own identity
3. **Issue tracker labels** — add agent-specific labels for ownership tracking
4. **Version control access** — if the agent needs its own account or permissions

Customise this checklist in your workspace's `CONVENTIONS.md` to match your tool stack.

### Adding a New Tool

When introducing a new tool to the agent framework:

1. **Convention** — add a section under `## Tooling` in this file with account setup, key commands, and scope constraints
2. **Autonomy defaults** — add default levels to the Autonomy Integration table above
3. **Agent tools.md** — add the tool section to each agent that needs access
4. **Agent autonomy.md** — add the tooling actions at the appropriate levels, with a changelog entry
5. **Create-agent skill** — if the tool applies to all agents, update the `tools.md` template in the skill
6. **This checklist** — if the tool requires manual admin setup, add a step to the Post-Creation Admin Checklist above

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

### Directory Structure

Playbooks live under each agent's directory:

```
Agents/<name>/
├── ...existing files...
└── playbooks/
    ├── weekly-report.md
    └── data-refresh.md
```

Agent-specific because playbooks encode how *that agent* does the work. If a playbook genuinely spans multiple agents, it goes in the shared scope (`Agents/playbooks/`) — but this should be rare.

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

Embed commands inline within the step they belong to using fenced code blocks. Reference the agent's `tools.md` for account configuration and authentication — playbooks carry the specific invocation, not the setup.

### Lifecycle

**Birth:** A playbook is created when an agent has executed the same task at least twice and the steps are stable enough to codify. Don't write playbooks speculatively — capture proven patterns.

**Refinement:** After each execution, note what worked and what didn't. Update steps, add edge cases, adjust the execution mode if warranted.

**Promotion:** When a P2 playbook consistently passes review gates without changes, promote to P1. Record in the changelog.

**Retirement:** When a playbook is no longer relevant (process changed, responsibility moved), archive or delete it. Don't keep dead playbooks.

### Startup Integration

Playbooks are lazy-loaded to conserve context:

1. **Startup (step 12):** Glob `playbooks/*.md` and read only the frontmatter and first paragraph (description) of each playbook — not the full steps or tool commands
2. **Trigger check (step 13):** Evaluate each playbook's trigger against today's date, day of week, and session context. Flag any that should execute this session. Include flagged playbooks in the session priority declaration (step 3 of Session Priority Declaration)
3. **Execution:** When a playbook is triggered, read the full file at that point — steps, tool commands, and all

### Session End Integration

During session end, if a playbook was executed:
- Note it in the session memory ("Executed: weekly-report playbook")
- Update the playbook's changelog if the steps deviated or the mode needs adjustment
- If the agent improvised a multi-step procedure that wasn't a playbook, flag it: "Candidate for new playbook: <description>"
