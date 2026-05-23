# Tools

Shared tool configuration for all agents. Per-tool reference files are in this directory. Agent-specific overrides live in each agent's `tools.md`.

## Available Tools

| Tool | Credential | Status | Reference | Description |
|------|-----------|--------|-----------|-------------|

**Credential types:**
- **Agent** — uses a shared agent service account. Agents identify themselves via aliases/labels.
- **User** — uses {{PRINCIPAL}}'s host machine credentials directly. No separate agent account.
- **MCP** — configured via MCP server. No CLI needed.
