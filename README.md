# Agent Framework

A convention-based system for building persistent AI collaboration partners in [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Agents that challenge your thinking, drive the agenda, and hold you accountable — not task runners that wait for instructions.

## Why This Approach

Most AI agent setups build obedient assistants. You tell them what to do, they do it, they report back. That works for repeatable tasks with clear playbooks. It fails for the work that actually needs a collaborator — strategy, prioritisation, synthesis, judgment under ambiguity.

This framework takes the opposite position. Agents are **drivers, not passengers.** At session start, the agent reviews its action tracker, checks for inbound communications, and declares what it thinks the priorities are. You agree, redirect, or override — but the agent sets the agenda. When conversation drifts from declared priorities, the agent notices and names it. Not rigidly, but consciously. Drift becomes a decision, not an accident.

The autonomy model isn't about delegation. It's about **calibrating collaboration.** An agent at L3 (Intend) doesn't just do more stuff unsupervised — it exercises more judgment independently. You do different work as autonomy rises: steering instead of deciding, correcting instead of approving. The collaboration gets richer, not thinner.

See [PHILOSOPHY.md](PHILOSOPHY.md) for the full position.

## Quick Start

```bash
git clone https://github.com/normannoble/agent-framework.git
cd agent-framework
chmod +x setup.sh
./setup.sh
```

The setup script asks three questions (target repo, your name, naming convention), then installs everything you need. Your first agent is ten minutes away.

## What Gets Installed

The framework installs two layers of conventions and the runtime skills:

### Workspace Layer

- **`CONVENTIONS.md`** — Workspace structure: folder layout (thinking, work, knowledge, outputs, agents), INDEX.md patterns, knowledge system, deliverables vs. reports, lifecycle flows
- **`PHILOSOPHY.md`** — The principles behind the framework
- **Standard directories** — `thinking/`, `work/projects/`, `work/operations/`, `knowledge/` (with categories), `outputs/`, `agents/`

### Agent Layer

- **`agents/CONVENTIONS.md`** — The agent framework: structure, autonomy model, session lifecycle, tooling, playbooks. Organized into 4 parts:
  1. **Agent Structure** — file reference, naming, directory layout
  2. **Autonomy** — L1-L5 authority ladder, promotion/demotion, intent-based communication
  3. **Session Lifecycle** — startup sequence, priority declaration, compass check, drift management, session end protocol
  4. **Supporting Systems** — memory, skills, tooling (3-level architecture), INDEX.md maintenance, playbooks
- **`agents/tools/INDEX.md`** — Shared tool index (credential types, status, references)

### Runtime Skills

- **`.claude/skills/agent/SKILL.md`** — Router skill that activates agents (`/agent <name>`)
- **`.claude/skills/create-agent/SKILL.md`** — Builder skill for interactive agent creation (`/create-agent`)

Skills are installed **project-scoped** (`.claude/skills/`), with browsing copies synced to `agents/skills/`.

## How It Works

### Agents Are Files

Each agent is a directory of markdown files under `agents/`:

```
agents/<name>/
├── role.md          What the agent does — purpose, outcomes, boundaries
├── soul.md          How it communicates — voice, temperament, values
├── name.md          The historical figure behind the name and why it fits
├── autonomy.md      Authority levels — what it owns vs. what it flags
├── tools.md         Agent-specific tool overrides (references agents/tools/)
├── actions.md       Standing to-do list, updated every session
├── actions-archive.md  Completed actions older than 30 days
├── context.md       Startup file paths and project references
├── MEMORY.md        Index of standing knowledge and session logs
├── memory/
│   ├── standing/    Durable rules, decisions, baselines (all loaded on startup)
│   └── sessions/    Per-session logs (most recent 2 loaded on startup)
└── playbooks/       Repeatable procedures with defined execution modes
```

No database, no API, no runtime. Just markdown in your git repo. Works with any workspace — personal wiki, knowledgebase, codebase, or multi-project monorepo. Compatible with Obsidian for browsing, linking, and tagging.

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

### Three-Level Tooling

Tool configuration is split to avoid duplication and support multiple agents:

1. **`agents/tools/INDEX.md`** — shared index of all available tools (credential type, status, reference)
2. **`agents/tools/<tool>.md`** — per-tool reference files (setup, commands, scope constraints, autonomy defaults)
3. **`<agent>/tools.md`** — agent-specific overrides (identity, scoped commands)

Per-tool reference files are loaded on demand, not at startup. Agents read the shared index and their own overrides at startup; they consult the per-tool files when they need to use a specific tool.

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

1. **Startup** — Agent loads conventions, soul, role, autonomy, shared tools, agent tools, action tracker, memories, and playbook index
2. **Trigger check** — Agent evaluates playbook triggers against current context
3. **Priority declaration** — Agent proposes up to 3 focus items (including triggered playbooks), checks inbound communications, gets your agreement
4. **Work** — Compass checks make drift conscious rather than accidental
5. **Close** — Agent reviews the session, updates tracker, saves memory, commits and pushes

Session focus prevents recency bias — the agent won't silently let conversation momentum displace declared priorities.

### Memory

Two types:
- **Standing** (durable) — baselines, decisions, stakeholder feedback. All loaded on startup.
- **Sessions** (temporal) — per-session logs. Most recent 2 loaded on startup.

Session memories reference `actions.md` instead of duplicating action items. When entries accumulate (>5 standing or >10 sessions), the agent consolidates into a new baseline.

### Workspace Structure

The framework installs a standard workspace layout:

```
your-repo/
├── CONVENTIONS.md          # Workspace structure conventions
├── PHILOSOPHY.md           # Framework principles
├── thinking/               # Unstructured capture — ideas, notes, backlog
├── work/
│   ├── projects/           # Time-bounded initiatives
│   └── operations/         # Ongoing responsibilities
├── knowledge/
│   ├── systems/            # Platform architecture, technical concepts
│   ├── people/             # People you work with
│   ├── processes/          # Operational processes and standards
│   ├── company/            # Org structure, strategy, context
│   └── MOC.md              # Map of Content — conceptual relationships
├── outputs/                # Audience-facing artifacts
├── agents/
│   ├── CONVENTIONS.md      # Agent framework conventions
│   ├── tools/              # Shared tool configuration
│   │   ├── INDEX.md        # Tool index (credential types, status)
│   │   └── <tool>.md       # Per-tool reference files
│   ├── skills/             # Browsing copies of .claude/skills/
│   └── <name>/             # One directory per agent
│       ├── role.md
│       ├── soul.md
│       ├── name.md
│       ├── autonomy.md
│       ├── tools.md
│       ├── actions.md
│       ├── actions-archive.md
│       ├── context.md
│       ├── MEMORY.md
│       ├── memory/
│       │   ├── standing/
│       │   └── sessions/
│       └── playbooks/
└── .claude/
    └── skills/             # Project-scoped skills (source of truth)
        ├── agent/
        │   └── SKILL.md
        └── create-agent/
            └── SKILL.md
```

Lifecycle flows connect the areas: thinking → work (when ideas become active), thinking → knowledge (when notes crystallize), work → knowledge (when insights emerge), work → outputs (when artifacts are produced).

## Setup Details

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- A git repository where you want agents — personal wiki, knowledgebase, codebase, anything

### What the Setup Script Does

1. **Asks for your target repository** — any git repo where you want to use agents
2. **Asks for your name** — the "principal" who directs agents (default: "the principal")
3. **Asks for a naming convention** — Roman cognomina, Norse sagas, or Hellenic sages
4. **Installs `PHILOSOPHY.md`** — the principles behind the framework
5. **Installs `CONVENTIONS.md`** — workspace structure conventions
6. **Installs `agents/CONVENTIONS.md`** — agent framework conventions
7. **Installs `agents/tools/INDEX.md`** — shared tool index
8. **Installs `/agent` and `/create-agent` skills** to `.claude/skills/` (project-scoped)
9. **Creates workspace directories** — thinking, work, knowledge, outputs (optional)
10. **Optionally updates `CLAUDE.md`** — adds an agents table if one exists

### Creating Your First Agent

In your target repository:

```
/create-agent
```

This walks you through 7 phases: scope, role definition, autonomy levels, soul/personality, naming, file creation, and verification. No files are created until phase 6 — the first five phases are pure design conversation.

## Customisation

### Tool Permissions

The `/agent` skill includes tool permissions in its frontmatter:

```yaml
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date), Bash(ls), AskUserQuestion
```

Edit `.claude/skills/agent/SKILL.md` to match your toolchain. If your agents need database access, API calls, or CLI tools, add the relevant permissions here.

### Adding Tools

The three-level tooling architecture makes it easy to add new tools:

1. Create `agents/tools/<tool>.md` with setup, commands, and autonomy defaults
2. Add a row to `agents/tools/INDEX.md`
3. Add the tool to each agent's `tools.md` with agent-specific config
4. Update each agent's `autonomy.md` with the tooling actions

### Workspace Layout

The framework auto-detects two layouts:
- **Single-domain** (`agents/<name>/`) — one project per repo (most common)
- **Multi-domain** (`agents/<scope>/<name>/`) — multiple projects per repo

No configuration needed. The router globs for both patterns and uses whichever matches.

### Custom Naming Pool

Edit the **Naming** section of `agents/CONVENTIONS.md` to use any naming convention. The only requirements are:
- Names should not signal the agent's domain
- The pool should be deep enough to scale (20+ names)
- Each name should carry an archetype — a historical or mythological figure that gives the agent identity beyond its role

### Obsidian Integration

The workspace is fully compatible with Obsidian:
- System files use UPPERCASE names for visual distinction
- INDEX.md files use `type: index` frontmatter for Dataview exclusion
- Wiki-links (`[[entry-name]]`) connect knowledge entries
- Skills are synced to `agents/skills/` for vault browsing
- MOC.md provides a conceptual relationship map

## Background

The autonomy model is inspired by *Turn the Ship Around* by L. David Marquet — specifically the idea that people (and agents) perform better when they state intent and drive execution rather than waiting for instructions. The five-level authority ladder gives you granular control over how much independence each agent has, with a built-in mechanism for that independence to grow (or shrink) based on demonstrated judgment.

The session mechanics — priority declaration, compass checks, drift management — exist because AI agents have a strong recency bias. Without explicit structure, conversation momentum displaces strategic priorities. These mechanics make drift conscious rather than accidental.

The memory system is designed around the constraint that Claude Code sessions don't share context. Standing memories give agents institutional knowledge; session logs give them continuity. The consolidation rules prevent context bloat while preserving what matters.

The two-tier conventions — workspace structure and agent framework — separate concerns cleanly. Workspace conventions govern how the workspace is organized; agent conventions govern how agents behave. Both evolve independently.
