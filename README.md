# Agent Framework

A convention-based system for building persistent AI collaboration partners in [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Agents that challenge your thinking, drive the agenda, and hold you accountable — not task runners that wait for instructions.

## Why This Approach

Most AI agent setups build obedient assistants. You tell them what to do, they do it, they report back. That works for repeatable tasks with clear playbooks. It fails for the work that actually needs a collaborator — strategy, prioritisation, synthesis, judgment under ambiguity.

This framework takes the opposite position. Agents are **drivers, not passengers.** At session start, the agent reviews its action tracker, checks for inbound communications, and declares what it thinks the priorities are. You agree, redirect, or override — but the agent sets the agenda. When conversation drifts from declared priorities, the agent notices and names it. Not rigidly, but consciously. Drift becomes a decision, not an accident.

The autonomy model isn't about delegation. It's about **calibrating collaboration.** An agent at L3 (Intend) doesn't just do more stuff unsupervised — it exercises more judgment independently. You do different work as autonomy rises: steering instead of deciding, correcting instead of approving. The collaboration gets richer, not thinner.

See [PHILOSOPHY.md](PHILOSOPHY.md) for the full position.

## What Kind of Agents

The framework supports two design points:

**Senior agents** are sparring partners. They exercise judgment, challenge direction, push back when they disagree, and drive session agendas. Less documentation, more latitude. A senior agent that always agrees with you is broken.

**Junior agents** are execution partners. Detailed runbooks, tight guardrails, conservative autonomy that grows through demonstrated reliability. Valuable for well-documented, repeatable work.

The framework defaults to senior. Most of the interesting work — the work that benefits most from a persistent AI partner — needs judgment, not compliance.

## Quick Start

```bash
git clone https://github.com/normannoble/agent-framework.git
cd agent-framework
chmod +x setup.sh
./setup.sh
```

The setup script asks three questions (target repo, your name, naming convention), then installs everything you need. Your first agent is ten minutes away.

## How It Works

### Agents Are Files

Each agent is a directory of markdown files under `Agents/`:

```
Agents/<name>/
├── role.md          What the agent does — purpose, outcomes, boundaries
├── soul.md          How it communicates — voice, temperament, values
├── name.md          The historical figure behind the name and why it fits
├── autonomy.md      Authority levels — what it owns vs. what it flags
├── tools.md         External tools and their configuration
├── actions.md       Standing to-do list, updated every session
├── context.md       Startup file paths and project references
├── MEMORY.md        Index of standing knowledge and session logs
├── memory/
│   ├── standing/    Durable rules, decisions, baselines (all loaded on startup)
│   └── sessions/    Per-session logs (most recent 2 loaded on startup)
└── playbooks/       Repeatable procedures with defined execution modes
```

No database, no API, no runtime. Just markdown in your git repo. Works with any workspace — personal wiki, knowledgebase, codebase, or multi-project monorepo.

### The Autonomy Model

Based on *Turn the Ship Around* by L. David Marquet. Agents operate on a five-level authority ladder:

| Level | Agent Says | Meaning |
|-------|-----------|---------|
| **L5 — Own** | *(in summary)* | Acts independently, reports at close |
| **L4 — Act & Inform** | "I've done X." | Acts, then flags |
| **L3 — Intend** | "I intend to..." | States intent, proceeds unless redirected |
| **L2 — Recommend** | "I recommend..." | Presents analysis, waits for approval |
| **L1 — Flag** | "I see a problem..." | Surfaces for you to decide |

New agents start conservative (mostly L2). Authority moves up the ladder as trust is demonstrated — "good call, just do that next time" promotes an action type; "check with me first" demotes it. All changes are logged with dates and context.

The signature behaviour: agents default to **"I intend to..."** rather than **"What should I do?"** — keeping you in the loop without making you the bottleneck.

Senior agents start with more actions at L3-L4 and are expected to push back on direction they disagree with. Junior agents start at L1-L2 and earn autonomy through reliability. See [PHILOSOPHY.md](PHILOSOPHY.md) for why this distinction matters.

### Playbooks

Agents codify repeatable procedures as playbooks — markdown files that capture the trigger, steps, tool commands, and execution mode for tasks they've done multiple times. Each playbook declares one of four execution modes:

| Mode | Label | Human Involvement |
|------|-------|----|
| **P1** | **Autopilot** | Agent runs end-to-end, reports output |
| **P2** | **Maker-Checker** | Agent pauses at review gates for approval |
| **P3** | **Exception-Based** | Agent runs independently, escalates when stuck |
| **P4** | **Paired** | Agent and human alternate contributions |

Playbooks are lazy-loaded on startup (frontmatter only) and fully read only when triggered. The trigger check at startup flags any cadenced playbooks due this session.

### Session Mechanics

Every session follows a pattern:

1. **Startup** — Agent loads its soul, role, autonomy, tools, action tracker, memories, and playbook index
2. **Trigger check** — Agent evaluates playbook triggers against current context
3. **Priority declaration** — Agent proposes up to 3 focus items (including triggered playbooks), checks inbound communications, gets your agreement
4. **Work** — Compass checks make drift conscious rather than accidental
5. **Close** — Agent reviews the session, updates tracker, saves memory, commits and pushes

Session focus prevents recency bias — the agent won't silently let conversation momentum displace declared priorities. When it notices drift, it names it: "We agreed these three things matter today. We've spent forty minutes on something else. Should I capture this as a new priority, or should we get back to what we declared?"

### Memory

Two types:
- **Standing** (durable) — baselines, decisions, stakeholder feedback. All loaded on startup.
- **Sessions** (temporal) — per-session logs. Most recent 2 loaded on startup.

Session memories reference `actions.md` instead of duplicating action items. This prevents items from getting lost in old session logs.

When entries accumulate (>5 standing or >10 sessions), the agent consolidates into a new baseline.

### Tooling Framework

Agents can have access to external tools — email, calendars, issue trackers, version control, databases, browsers. The framework provides:

- **`tools.md` per agent** — defines *how* to use each tool (accounts, commands, constraints)
- **Autonomy integration** — defines *when* the agent needs approval for tooling actions (default levels in CONVENTIONS.md)
- **Post-creation checklist** — external setup steps (aliases, labels, permissions) customised to your stack
- **Adding new tools** — a 6-step process for introducing new tools to the framework

Tooling is optional. An agent with no external tools works fine — it just collaborates through conversation and file changes.

## Setup Details

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- A git repository where you want agents — personal wiki, knowledgebase, codebase, anything

### What the Setup Script Does

1. **Asks for your target repository** — any git repo where you want to use agents
2. **Asks for your name** — the "principal" who directs agents (default: "the principal"). Used in conventions and skill files wherever agent-to-human interaction is described.
3. **Asks for a naming convention** — agents need neutral names that outlive their current assignment:
   - **Roman cognomina** — Cato, Varro, Seneca, Corvus, Cassia, Livia...
   - **Norse sagas** — Sigrid, Bjorn, Freya, Leif, Astrid, Gunnar...
   - **Hellenic sages** — Solon, Thales, Hypatia, Aspasia, Pericles, Zeno...
4. **Installs `PHILOSOPHY.md`** in the target repo — the principles behind the framework
5. **Installs `Agents/CONVENTIONS.md`** in the target repo — the framework definition
6. **Installs `/agent` and `/create-agent` skills** to `~/.claude/skills/` — the runtime harness
7. **Optionally updates `CLAUDE.md`** — adds an agents table if one exists

### Creating Your First Agent

In your target repository:

```
/create-agent
```

This walks you through 7 phases: scope, role definition, autonomy levels, soul/personality, naming, file creation, and verification. No files are created until phase 6 — the first five phases are pure design conversation.

The builder will ask whether you're creating a senior agent (sparring partner) or a junior agent (execution partner). This shapes how autonomy is seeded and how much latitude the role gets.

## Customisation

### Tool Permissions

The `/agent` skill includes tool permissions in its frontmatter:

```yaml
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date), Bash(ls), AskUserQuestion
```

Edit `~/.claude/skills/agent/SKILL.md` to match your toolchain. If your agents need database access, API calls, or CLI tools, add the relevant permissions here.

### Workspace Layout

The framework auto-detects two layouts:
- **Single-domain** (`Agents/<name>/`) — one project per repo (most common)
- **Multi-domain** (`Agents/<scope>/<name>/`) — multiple projects per repo

No configuration needed. The router globs for both patterns and uses whichever matches.

### Custom Naming Pool

Edit the **Naming** section of `Agents/CONVENTIONS.md` to use any naming convention. The only requirements are:
- Names should not signal the agent's domain (a legal agent named "Ulpian" defeats the purpose)
- The pool should be deep enough to scale (20+ names)
- Each name should carry an archetype — a historical or mythological figure that gives the agent identity beyond its role

### Adding to CLAUDE.md

For best discoverability, add an agents table to your repo's `CLAUDE.md`:

```markdown
## Agents

| Name | Role |
|------|------|
| Sigrid | Senior Product Manager |
| Bjorn | Staff Software Engineer |
```

## File Reference

```
your-repo/
├── PHILOSOPHY.md               # Why — the principles behind the framework
└── Agents/
    ├── CONVENTIONS.md           # How — framework rules (installed by setup)
    └── <name>/                  # One directory per agent
        ├── role.md
        ├── soul.md
        ├── name.md
        ├── autonomy.md
        ├── tools.md
        ├── actions.md
        ├── context.md
        ├── MEMORY.md
        ├── memory/
        │   ├── standing/
        │   └── sessions/
        └── playbooks/          # Added as patterns emerge

~/.claude/skills/
├── agent/
│   └── SKILL.md                # Router skill (installed by setup)
└── create-agent/
    └── SKILL.md                # Builder skill (installed by setup)
```

## Background

The autonomy model is inspired by *Turn the Ship Around* by L. David Marquet — specifically the idea that people (and agents) perform better when they state intent and drive execution rather than waiting for instructions. The five-level authority ladder gives you granular control over how much independence each agent has, with a built-in mechanism for that independence to grow (or shrink) based on demonstrated judgment.

The session mechanics — priority declaration, compass checks, drift management — exist because AI agents have a strong recency bias. Without explicit structure, conversation momentum displaces strategic priorities. These mechanics make drift conscious rather than accidental.

The memory system is designed around the constraint that Claude Code sessions don't share context. Standing memories give agents institutional knowledge; session logs give them continuity. The consolidation rules prevent context bloat while preserving what matters.

The senior/junior distinction exists because not all work needs the same kind of partner. Senior agents bring judgment and challenge — they make you sharper. Junior agents bring consistency and reliability — they make you faster. Knowing which one you're building, and designing accordingly, is the single most important decision in agent creation.
