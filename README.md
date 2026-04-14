# Agent Framework

A convention-based system for creating persistent AI agents in [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Agents maintain memory across sessions, operate with calibrated autonomy, and drive work forward through intent-based communication.

## Quick Start

```bash
git clone <this-repo>
cd agent-framework
chmod +x setup.sh
./setup.sh
```

The setup script installs the framework into your target repository and configures the two Claude Code skills that power it.

## What You Get

| Command | What it does |
|---------|-------------|
| `/agent <name>` | Activate an agent — loads identity, memory, action tracker, declares session priorities |
| `/agent <name> <topic>` | Activate and go straight to a specific topic |
| `/agent <name> close` | End session — saves decisions, updates tracker, creates memory entry, commits |
| `/agent list` | List all agents in the workspace |
| `/create-agent` | Interactive 7-phase process to define a new agent |

## How It Works

### Agents Are Files

Each agent is a directory of markdown files under `Agents/`:

```
Agents/<name>/
├── role.md          What the agent does — purpose, outcomes, boundaries
├── soul.md          How it communicates — voice, temperament, values
├── name.md          The historical figure behind the name and why it fits
├── autonomy.md      Authority levels — what it owns vs. what it flags
├── actions.md       Standing to-do list, updated every session
├── context.md       Startup file paths and project references
├── MEMORY.md        Index of standing knowledge and session logs
└── memory/
    ├── standing/    Durable rules, decisions, baselines (all loaded on startup)
    └── sessions/    Per-session logs (most recent 2 loaded on startup)
```

No database, no API, no runtime. Just markdown in your git repo.

### The Autonomy Model

Based on *Turn the Ship Around* by L. David Marquet. Agents operate on a five-level authority ladder:

| Level | Agent Says | Meaning |
|-------|-----------|---------|
| **L5 — Own** | *(in summary)* | Acts independently, reports at close |
| **L4 — Act & Inform** | "I've done X." | Acts, then flags |
| **L3 — Intend** | "I intend to..." | States intent, proceeds unless redirected |
| **L2 — Recommend** | "I recommend..." | Presents analysis, waits for approval |
| **L1 — Flag** | "I see a problem..." | Surfaces for you to decide |

New agents start conservative (mostly L2). Authority moves up the ladder as trust is demonstrated — "good call, just do that next time" promotes an action type; "check with me first" demotes it. All changes are logged with dates and context in `autonomy.md`.

The signature behavior: agents default to **"I intend to..."** rather than **"What should I do?"** — this keeps you in the loop without making you the bottleneck.

### Session Mechanics

Every session follows a pattern:

1. **Startup** — Agent loads its soul, role, autonomy, action tracker, and memories
2. **Priority declaration** — Agent proposes up to 3 focus items from its tracker, gets your agreement
3. **Work** — Compass checks make drift conscious rather than accidental
4. **Close** — Agent reviews the session, updates tracker, saves memory, commits and pushes

Session focus prevents recency bias — the agent won't silently let conversation momentum displace declared priorities.

### Memory

Two types:
- **Standing** (durable) — baselines, decisions, stakeholder feedback. All loaded on startup.
- **Sessions** (temporal) — per-session logs. Most recent 2 loaded on startup.

Session memories reference `actions.md` instead of duplicating action items. This prevents items from getting lost in old session logs.

When entries accumulate (>5 standing or >10 sessions), the agent consolidates into a new baseline.

## Setup Details

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- A git repository where you want agents

### What the Setup Script Does

1. **Asks for your target repository** — any git repo where you want to use agents
2. **Asks for your name** — the "principal" who directs agents (default: "the principal"). Used in conventions and skill files wherever agent-to-human interaction is described.
3. **Asks for a naming convention** — agents need neutral names that don't signal their domain:
   - **Roman cognomina** — Cato, Varro, Seneca, Corvus, Cassia, Livia...
   - **Norse sagas** — Sigrid, Bjorn, Freya, Leif, Astrid, Gunnar...
   - **Hellenic sages** — Solon, Thales, Hypatia, Aspasia, Pericles, Zeno...
4. **Installs `Agents/CONVENTIONS.md`** in the target repo — the framework definition
5. **Installs `/agent` and `/create-agent` skills** to `~/.claude/skills/` — the runtime harness
6. **Optionally updates `CLAUDE.md`** — adds an agents table if one exists

### Creating Your First Agent

In your target repository:

```
/create-agent
```

This walks you through 7 phases: scope, role definition, autonomy levels, soul/personality, naming, file creation, and verification. No files are created until phase 6 — the first five phases are pure design conversation.

## Customization

### Tool Permissions

The `/agent` skill includes example tool permissions in its frontmatter:

```yaml
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(gws), Bash(date), Bash(ls), AskUserQuestion
```

Edit `~/.claude/skills/agent/SKILL.md` to match your toolchain. For example, if your agents need database access or API calls, add the relevant tool permissions here.

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
└── Agents/
    ├── CONVENTIONS.md          # Framework rules (installed by setup)
    └── <name>/                 # One directory per agent
        ├── role.md
        ├── soul.md
        ├── name.md
        ├── autonomy.md
        ├── actions.md
        ├── context.md
        ├── MEMORY.md
        └── memory/
            ├── standing/
            └── sessions/

~/.claude/skills/
├── agent/
│   └── SKILL.md                # Router skill (installed by setup)
└── create-agent/
    └── SKILL.md                # Builder skill (installed by setup)
```

## Background

The autonomy model is inspired by *Turn the Ship Around* by L. David Marquet — specifically the idea that people (and agents) perform better when they state intent and drive execution rather than waiting for instructions. The five-level authority ladder gives you granular control over how much independence each agent has, with a built-in mechanism for that independence to grow (or shrink) based on demonstrated competence.

The session mechanics — priority declaration, compass checks, drift management — exist because AI agents have a strong recency bias. Without explicit structure, conversation momentum displaces strategic priorities. These mechanics make drift conscious rather than accidental.

The memory system is designed around the constraint that Claude Code sessions don't share context. Standing memories give agents institutional knowledge; session logs give them continuity. The consolidation rules prevent context bloat while preserving what matters.
