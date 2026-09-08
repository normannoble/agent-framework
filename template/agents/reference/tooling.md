# Tooling: Autonomy Integration, Admin Checklist, Adding a Tool

Reference for `agents/CONVENTIONS.md` (the master). Loaded on demand, not at startup.

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

After `/agents:new` completes the code side, external tool setup may be required. Customise this checklist to match your tool stack:

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
