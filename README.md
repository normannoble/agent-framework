# Agent Framework

A convention-based system for building persistent AI collaboration partners in [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Agents that challenge your thinking, drive the agenda, and hold you accountable — not task runners that wait for instructions.

## Why This Approach

Most AI agent setups build obedient assistants. You tell them what to do, they do it, they report back. That works for repeatable tasks with clear playbooks. It fails for the work that actually needs a collaborator — strategy, prioritisation, synthesis, judgment under ambiguity.

This framework takes the opposite position. Agents are **drivers, not passengers.** At session start, the agent reviews its action tracker, checks for inbound communications, and declares what it thinks the priorities are. You agree, redirect, or override — but the agent sets the agenda. When conversation drifts from declared priorities, the agent notices and names it. Not rigidly, but consciously. Drift becomes a decision, not an accident.

The autonomy model isn't about delegation. It's about **calibrating collaboration.** An agent at L3 (Intend) doesn't just do more stuff unsupervised — it exercises more judgment independently. You do different work as autonomy rises: steering instead of deciding, correcting instead of approving. The collaboration gets richer, not thinner.

See [PHILOSOPHY.md](PHILOSOPHY.md) for the full position.

## Quick Start

### Install as a plugin (recommended)

Inside Claude Code:

```
/plugin marketplace add normannoble/agent-framework
/plugin install agents@normannoble
```

Or from the shell:

```bash
claude plugin marketplace add normannoble/agent-framework
claude plugin install agents@normannoble
```

This gives every project these skills:

| Skill | What it does |
|-------|--------------|
| `/agents:help` | The guide: commands, the flow, what an agent is, common fixes |
| `/agents:init` | Set up the current repo as a workspace (run once) |
| `/agents:new` | Design and create an agent |
| `/agents:start <name>` | Run an agent (`<name> <topic>` to work on something, `<name> close` to end) |
| `/agents:list` | List agents (`<scope>` to filter, `all` to include retired) |
| `/agents:status` | Live org status board |
| `/agents:next` | The single next best action across the org |
| `/agents:doctor` | Health review: startup cost, tracker and memory hygiene, staleness. Read-only, recommends the next commands |

Then, in the repo where you want agents:

```
/agents:init
/agents:new
/agents:start <name>
```

`/agents:init` asks for your name and a naming tradition, then writes a short `agents/CONVENTIONS.md` that `extends: plugin`. The full conventions ship inside the plugin; the workspace file holds only your overrides and wins on conflict. Update the plugin later with:

```bash
claude plugin marketplace update normannoble && claude plugin update agents@normannoble
```

### Install by copying (the installer)

If you would rather have every file inside your repo, with the same `/agents:*` commands:

```bash
curl -fsSL https://agent-framework.sh/install.sh | sh
```

The installer downloads the release asset for your operating system and architecture, verifies its SHA-256 checksum, and opens an interactive terminal wizard. It collects the target repository, principal, naming tradition, and optional components, then shows the complete installation plan before writing anything. No Python or Go installation is required.

### Run from a source checkout

Developing the installer requires Go 1.25.8 or newer:

```bash
git clone https://github.com/normannoble/agent-framework.git
cd agent-framework
./setup.sh
```

`setup.sh` builds a temporary native binary from the checkout and runs the same wizard. It does not install anything globally.

The CLI is written in Go and uses Charm's [Huh](https://github.com/charmbracelet/huh) forms with a project-owned Lip Gloss theme. Framework templates and skills are embedded in the release binary.

### Public installer

`install.sh` is the release bootstrap served by the project domain:

```bash
curl -fsSL https://agent-framework.sh/install.sh | sh
```

The bootstrap detects macOS or Linux and ARM64 or AMD64, downloads the pinned binary from GitHub Releases, verifies the adjacent `.sha256` file, and runs `agent-framework init`. The temporary binary is removed when setup exits.

To test that exact release path locally from Nushell before publishing:

```nu
with-env {GO111MODULE: on} {
  go build -o dist/agent-framework ./cmd/agent-framework
}
let target = (mktemp -d)
git -C $target init -q
$env.AGENT_FRAMEWORK_BINARY = (pwd | path join dist agent-framework)
./install.sh $target
hide-env AGENT_FRAMEWORK_BINARY
```

### Releasing the CLI

A merge does not update the CLI downloaded by `install.sh`. Publish a new release when the Go CLI, embedded framework templates, or embedded skills change. Documentation-only and website-only changes do not require a CLI release.

First, choose the next version and update the fallback `VERSION` near the top of `install.sh`. The release tag must match it exactly; for example, `VERSION=${AGENT_FRAMEWORK_VERSION:-0.1.1}` requires the tag `v0.1.1`. Commit that version bump and get it merged into `main` before tagging.

From an up-to-date `main` checkout, create and push the matching tag:

```nu
git switch main
git pull --ff-only
git tag v0.1.1
git push origin v0.1.1
```

Pushing the tag starts `.github/workflows/release.yml`. The workflow verifies the version, runs the tests and shell checks, builds checksummed binaries for macOS and Linux on ARM64 and AMD64, smoke-tests the bootstrap, and publishes the GitHub Release.

Watch the run and verify the published release with GitHub CLI:

```nu
let run_id = (gh run list --workflow release.yml --limit 1 --json databaseId --jq '.[0].databaseId')
gh run watch $run_id
gh release view v0.1.1
```

Always increment the version for a new release. Do not move or reuse an existing release tag.

### Automation and CI

The same installer has a fully non-interactive interface:

```bash
curl -fsSL https://agent-framework.sh/install.sh | sh -s -- ./my-repo \
  --principal Fauzaan \
  --naming roman \
  --skills \
  --workspace \
  --no-claude \
  --conflict fail \
  --yes
```

Use `--dry-run` to preview without writing and add `--json` for machine-readable output. An unresolved inspection is returned with `plan.ready: false`; automation should check that field. `--yes` approves the final plan but never implies that customized files may be overwritten.

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

- **`skills/start/SKILL.md`** — Router skill that activates agents (`/agents:start <name>`)
- **`skills/list/SKILL.md`**, **`skills/status/SKILL.md`**, **`skills/next/SKILL.md`** — Org views (`/agents:list`, `/agents:status`, `/agents:next`)
- **`skills/help/SKILL.md`** — In-product guide (`/agents:help`)
- **`skills/doctor/SKILL.md`** — Health review (`/agents:doctor`); thresholds mirror the master conventions
- **`skills/new/SKILL.md`** — Builder skill for interactive agent creation (`/agents:new`)
- **`skills/init/SKILL.md`** — Workspace setup (`/agents:init`; marketplace plugin only — the installer does this job in copied mode)

In plugin mode the skills come from the plugin and are namespaced (`/agents:help`, `/agents:start`, `/agents:list`, `/agents:status`, `/agents:next`, `/agents:doctor`, `/agents:new`, `/agents:init`). In copied mode the installer writes a small in-repo plugin at `.claude/skills/agents/` (manifest plus the `help`, `start`, `list`, `status`, `next`, `doctor`, and `new` skills). Claude Code loads it as `agents@skills-dir` once the folder is trusted, so the commands are the same. Browsing copies are synced to `agents/skills/`. Do not also install the marketplace plugin in that repo, or both will answer to the same names.

The master conventions load a lean core at every agent start. Long procedures (session end, memory consolidation, tooling admin, playbook format, and so on) live in `template/agents/reference/` and are read only when needed.

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
    └── skills/
        └── agents/         # Copied mode only: an in-repo plugin (agents@skills-dir)
            ├── .claude-plugin/plugin.json
            └── skills/
                ├── help/SKILL.md
                ├── start/SKILL.md
                ├── list/SKILL.md
                ├── status/SKILL.md
                ├── next/SKILL.md
                ├── doctor/SKILL.md
                └── new/SKILL.md
```

Lifecycle flows connect the areas: thinking → work (when ideas become active), thinking → knowledge (when notes crystallize), work → knowledge (when insights emerge), work → outputs (when artifacts are produced).

## Setup Details

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- A git repository where you want agents — personal wiki, knowledgebase, codebase, anything

### What the Setup Script Does

1. **Collects setup choices interactively** — arrow-key menus for the target, principal, naming convention, skills, workspace directories, and `CLAUDE.md` integration
2. **Preflights the complete change set** — identifies additions, managed updates, unchanged files, and customized conflicts without writing anything
3. **Reviews conflicts safely** — keep, replace, or inspect a diff; existing files are kept by default
4. **Shows the final plan** — every file and directory is listed before confirmation
5. **Applies safely** — uses atomic per-file replacements and rolls back caught failures while installing philosophy, conventions, shared tools, skills, workspace directories, and the optional managed `CLAUDE.md` block
6. **Records managed state** — `.agent-framework/install.json` makes identical reruns true no-ops and enables safe future updates

### Creating Your First Agent

In your target repository:

```
/agents:new
```

This walks you through 7 phases: scope, role definition, autonomy levels, soul/personality, naming, file creation, and verification. No files are created until phase 6 — the first five phases are pure design conversation.

## Releasing the plugin

Plugin users get a new version only when `version` in `.claude-plugin/plugin.json` changes. From a clean checkout:

```bash
./release.sh          # patch bump, validate, commit, push, update your local install
./release.sh minor    # or major, or an exact version like 1.4.0
```

Then restart Claude Code. The Go installer has its own release flow (below); a plugin release does not publish a binary.

## Developing the framework without the plugin (symlinks)

To see edits instantly without a release, symlink the checkout itself into your user skills folder. The repo root already has the plugin layout, so it loads as `agents@skills-dir` with the same `/agents:*` commands:

```bash
ln -s /path/to/agent-framework ~/.claude/skills/agents
```

Uninstall the marketplace copy first (`claude plugin uninstall agents@normannoble`), or both will answer to the same names.

In each workspace, set `extends:` in `agents/CONVENTIONS.md` to the absolute path of `template/agents/CONVENTIONS.md` instead of `plugin`.

## Customisation

### Tool Permissions

The `/agents:start` skill includes tool permissions in its frontmatter:

```yaml
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date), Bash(ls), AskUserQuestion
```

Edit `skills/start/SKILL.md` (or the copied `.claude/skills/agents/skills/start/SKILL.md`) to match your toolchain. If your agents need database access, API calls, or CLI tools, add the relevant permissions here.

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
