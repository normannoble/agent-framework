# INDEX.md Maintenance

Reference for `agents/CONVENTIONS.md` (the master). Loaded on demand, not at startup.

## INDEX.md Maintenance

Agents are responsible for maintaining INDEX.md files within their scope.

### Current Status sections

Current Status sections can be tagged with an HTML comment for automated maintenance:

```html
<!-- agent:<name> | cadence:weekly | source:<tracker> -->
```

- **When to update:** During weekly snapshots, after significant task changes, or on user request.
- **Content:** 3–5 factual bullet points summarizing what's in progress, what's blocked, and what's next.
- **Staleness:** Flag when a Current Status section hasn't been updated in >2 weeks.

### When to create or update

- **On new project setup:** Create `INDEX.md` as part of the setup checklist.
- **On new subfolder creation:** When creating `notes/`, `deliverables/`, or `reports/` for the first time, create an `INDEX.md`.
- **On content changes:** Only update prose sections if the user asks or if structural changes make the index misleading.
