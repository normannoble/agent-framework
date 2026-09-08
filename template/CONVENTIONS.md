# Workspace Conventions

This is an agent workspace. All work flows through named AI agents invoked via the `/agents:start` router. Agents discover context through their startup sequence and INDEX.md files.

## Naming

**System files are UPPERCASE, content files are lowercase.** Files that serve the workspace system — `CONVENTIONS.md`, `INDEX.md`, `MEMORY.md` — use uppercase names to visually distinguish them from content files like notes, deliverables, and reports.

## System Files

**INDEX.md** is the primary context file at every scope. It serves both humans (navigation) and agents (startup context). Contains: description, goals/KRs, current status, relevant agents, and activity log.

**CONVENTIONS.md** exists at root (workspace-level) and under `agents/` (agent framework). Only create additional CONVENTIONS.md files when a scope has genuinely distinct rules — don't create empty stubs.

## Structure

### Top-level folders

- **`agents/`** — AI agent persona files and workspace infrastructure. Each agent defines a persona for a specific business function. Shared `tools/` and `skills/` directories live here.
- **`work/`** — All active business work, containing two sub-concerns:
  - **`work/operations/`** — Ongoing business functions (no fixed end date). Each area has its own INDEX.md.
  - **`work/projects/`** — Time-bounded efforts with a clear start and end.
- **`knowledge/`** — Distilled reference knowledge, organized by category:
  - `company/` — business model, organization, strategic plan
  - `people/` — key team members and stakeholders
  - `processes/` — operational playbooks and templates
  - `systems/` — platform architecture, technical concepts
- **`thinking/`** — Working space for analysis, drafts, and exploration. Low structure by design.
- **`outputs/`** — Final deliverables, reports, and externally-shared artifacts.
- **`code/`** — External code repositories (optional).

### System-level folders

Workspace infrastructure:

- **`.claude/skills/`** — Agent framework skills (project-level). Claude Code discovers these as slash commands.
- **`agents/skills/`** — Synced copies of skills for browsing in the vault.
- **`agents/tools/`** — Shared tool reference files with per-tool configuration and autonomy defaults.

### Lifecycle flows

- **Thinking → Work:** Ideas get triaged into `work/projects/` or `work/operations/` when they become active
- **Thinking → Knowledge:** Notes get distilled into `knowledge/` when they crystallize into durable reference
- **Work → Knowledge:** Insights from project work get extracted into `knowledge/` entries
- **Work → Outputs:** Projects and operations produce artifacts for audiences

## Cascading

CONVENTIONS.md files cascade from parent directories automatically. A project inside `work/projects/some-project/` inherits rules from the root CONVENTIONS.md. Do not repeat inherited conventions in child files.

INDEX.md files are self-contained — each one carries the full context for its scope. They do not cascade.

## New Project Setup

When creating a new project directory:

1. Create the project inside `work/projects/`
2. Create `INDEX.md` with: project description, goals/KRs, context, relevant agents, and log section
3. Create `CONVENTIONS.md` only if the project has genuinely distinct rules

## Index Files

Landing pages for folders that serve both humans (navigation) and agents (startup context).

### Where they exist

- Operations areas (inside `work/operations/<area>/`)
- Project roots (inside `work/projects/<project>/`)
- Project subfolders (`notes/`, `deliverables/`, `reports/`)
- Knowledge categories (inside `knowledge/<category>/`)

### Exclusions

Do not create `INDEX.md` in:
- System folders (`.claude/`, `agents/tools/`, `agents/skills/`)
- Intermediary folders unless the grouping has its own conventions worth documenting

### Frontmatter

```yaml
---
title: <Human-readable folder name>
type: index
scope: <workspace | area | project | subfolder>
---
```

`type: index` is required — queries use it to exclude index files from content listings.

### Content patterns by scope

- **Operations area**: What this area does, owner, KRs, current status, milestones, relevant agents, activity log.
- **Project root**: Why the project exists, goals/KRs, current status, directory map of key files, deliverables/reports, stakeholders.
- **Knowledge category**: Brief description, auto-listing of entries.
- **Subfolders** (notes, deliverables, reports): Brief description of what belongs here, contents listing.

## Notes, Deliverables, and Reports

Projects and areas may contain three types of knowledge artifacts:

- **`notes/`** — Reference knowledge, insights, and data gathered during work. Not project outputs.
- **`deliverables/`** — Artifacts that must be produced to complete the project. Linked from milestones in project `INDEX.md`.
- **`reports/`** — Externally-shareable communication artifacts. Lenses on base information shaped for a specific audience.

### Deliverable vs. report

- **Deliverables** answer "what did we produce?" — they exist because the project requires them. Remove the audience and the artifact still needs to exist.
- **Reports** answer "what does audience X need to know?" — they exist because someone outside the project needs a shaped view. Remove the audience and there's no reason to write it.

### Reports

- **Recurring reports** use named series subfolders with dated files: `reports/exec-updates/2026-02-12.md`
- **One-off reports** live directly in `reports/`

### Conventions

- Deliverables use front-matter `references:` to link to notes they draw from
- Milestones in project `INDEX.md` link to deliverables
- Reports are linked from milestones or listed in the project `INDEX.md` Reports section
- When work on a deliverable produces reusable reference insights, extract them to `notes/` and add a `references:` link

## Knowledge

### Entry format

Each knowledge entry is a standalone markdown file with YAML frontmatter:

```yaml
---
title: <Name>
type: knowledge
category: <systems | people | processes | company>
tags: [<1-3 tags>]
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources:
  - <workspace-relative path to source file>
---
```

- **One concept per file.** Split only when an entry gets unwieldy.
- **Wiki-style.** Use wikilinks (`[[entry-name]]`) to connect related entries.
- **Sources field.** When extracted from project work or thinking notes, list the source files as provenance.
- **Naming.** Lowercase hyphenated slugs (`platform-overview.md`, `okr-system.md`).

### Categories

| Category | Directory | What belongs |
|----------|-----------|-------------|
| `systems` | `knowledge/systems/` | Platform architecture, integrations, technical concepts |
| `people` | `knowledge/people/` | Context about people you work with |
| `processes` | `knowledge/processes/` | How things work operationally — rituals, standards, templates |
| `company` | `knowledge/company/` | Org structure, strategy, business context |

Add categories as needed for your workspace (e.g., `vendors/`, `strategy/`, `marketing/`).

### People

Each person is a standalone markdown file in `knowledge/people/`:

```yaml
---
title: Full Name
type: person
relationship: colleague | acquaintance
tags: [<1-3 tags>]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

Body sections (all optional, grow incrementally): **Context** (who they are), **Key Facts** (structured bullets), **Notes** (freeform observations).

- **Create** when a concrete fact about someone is worth persisting.
- **Update** when new facts emerge. **Don't create** for one-off mentions.
- **Naming:** full name as lowercase hyphenated slug (`jane-smith.md`).

### Map of Content (MOC)

`knowledge/MOC.md` is the knowledge landing page — entries organized by domain and their relationships. Unlike INDEX.md (structural view), a MOC organizes by meaning and relationships.

When adding a knowledge entry, place it in the MOC under the domain it belongs to.

### Knowledge Lifecycle

- **Creation.** Extracted from project work (`work/`), distilled from thinking notes (`thinking/`), or captured directly. Always include `sources` when extracting.
- **Updates.** Update entries in place. Bump the `updated` date.
- **Retirement.** When knowledge becomes obsolete, delete the entry and remove it from the MOC.

## Task Management

Work items are tracked in your issue tracker. The vault retains milestones (in project INDEX.md files) and project context. The tracker holds all actionable tasks.

### Vault integration

- **Milestones** live in project INDEX.md files
- **Vault frontmatter:** Artifacts with a driving ticket include the tracker ID in frontmatter
- **Typed artifact links** in issue descriptions connect the tracker to vault content

### Workflow states

Adapt to your tracker. A recommended flow:

Backlog → Validate → ToDo → Doing → (Blocked) → Done → Archive
