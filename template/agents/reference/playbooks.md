# Playbooks: Structure, Format, Lifecycle

Reference for `agents/CONVENTIONS.md` (the master). Loaded on demand, not at startup.

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
