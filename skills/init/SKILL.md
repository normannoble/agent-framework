---
description: Set up the current repository as an agent workspace — creates agents/CONVENTIONS.md (extends the plugin master), the shared tools index, and optional workspace folders. Run once per repo, before /agents:new.
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Bash(ls), Bash(mkdir), Bash(cat), Bash(git), AskUserQuestion
argument-hint: [--principal <name>] [--naming roman|norse|hellenic] [--no-workspace]
---

# /agents:init — Workspace Setup

You set up the current working directory as an agent workspace for the `agents` plugin. You create only what is missing. You never overwrite a file that exists.

## 1. Look before writing

Run `ls -a` and glob for these. Note which already exist:

- `agents/CONVENTIONS.md`
- `agents/tools/INDEX.md`
- `CONVENTIONS.md`, `PHILOSOPHY.md`, `CLAUDE.md`
- `thinking/`, `work/projects/`, `work/operations/`, `knowledge/`, `outputs/`

If `agents/CONVENTIONS.md` already exists and has `extends:` in its frontmatter, say the workspace is already set up, show what it contains, and stop.

Resolve the plugin's template folder: `ls "${CLAUDE_PLUGIN_ROOT}/template"`. If the variable is empty, glob `~/.claude/plugins/cache/*/agents/*/template` and take the highest version. Call this `TEMPLATE`.

## 2. Ask three things (skip any given as arguments)

Use one AskUserQuestion call with up to three questions:

1. **Principal** — the person who directs the agents. Default: `git config user.name`, else "the principal".
2. **Naming tradition** — one of:
   - **Roman cognomina** (default): historical Roman names that are dignified, neutral, and large enough as a pool to scale. Pool: Cato, Varro, Seneca, Corvus, Regulus, Cassia, Livia, Marius, Titus, Praxis, Lucian, Nerva, Flavia, Sabina, Quintus, Aulus, Gaius, Tertia, Decima, Balbus
   - **Norse saga names**: names from Norse mythology and saga literature — strong, evocative, and drawn from a deep cultural well. Pool: Sigrid, Bjorn, Freya, Leif, Astrid, Gunnar, Ingrid, Ragna, Eirik, Sif, Tyr, Vidar, Brynhild, Ivar, Solveig, Arne, Dagny, Halvard, Rune, Thyra
   - **Hellenic names**: names from ancient Greek history and philosophy — associated with wisdom, governance, and systematic thought. Pool: Solon, Thales, Hypatia, Aspasia, Pericles, Zeno, Lycurgus, Diotima, Arete, Philo, Cleisthenes, Myia, Timaeus, Aristos, Charis, Hector, Melos, Doris, Xanthippe, Archon
3. **Workspace folders** — create the standard layout (`thinking/`, `work/projects/`, `work/operations/`, `knowledge/`, `outputs/`) plus root `CONVENTIONS.md` and `PHILOSOPHY.md`? Default yes. Skip if `--no-workspace`.

## 3. Create the files

**`agents/CONVENTIONS.md`** (always, if missing):

```markdown
---
extends: plugin
principal: <principal>
naming: <tradition name>
naming-description: <description from the chosen tradition>
naming-examples: <pool>
reserved: []
---

# Agent Conventions — <repo folder name>

This file extends the master that ships with the `agents` plugin. Only differences from the master live here. On conflict, this file wins.

No workspace-specific overrides yet. The master applies in full.
```

**`agents/tools/INDEX.md`** (if missing): copy `TEMPLATE/agents/tools/INDEX.md`, replacing `{{PRINCIPAL}}` with the principal.

**Workspace layout** (if chosen): `mkdir -p thinking work/projects work/operations knowledge/systems knowledge/people knowledge/processes knowledge/company outputs`. Copy `TEMPLATE/CONVENTIONS.md` to `CONVENTIONS.md` and `TEMPLATE/../PHILOSOPHY.md` to `PHILOSOPHY.md` only if each is missing. Put an empty `.gitkeep` in each new empty folder.

**`CLAUDE.md`**: if it exists and has no `## Agents` heading, append this block. If it does not exist, create it with just this block.

```markdown
## Agents

Persistent AI collaborators with calibrated autonomy. See `agents/CONVENTIONS.md` (extends the `agents` plugin master).

| Name | Role |
|------|------|
| *(run `/agents:new` to add the first one)* | |

Start one with `/agents:start <name>`. List with `/agents:start list`.
```

## 4. Confirm

Show a short table of what was created and what was skipped because it existed. Then say:

```
Next: /agents:new   — design and create your first agent
Then: /agents:start <name>
```

Do not create any agent here. Do not commit.
