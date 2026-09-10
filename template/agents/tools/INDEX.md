# Tools

Shared tool configuration for all agents. Per-tool reference files are in this directory. Agent-specific overrides live in each agent's `tools.md`.

## Available Tools

| Tool | Credential | Status | Reference | Description |
|------|-----------|--------|-----------|-------------|
| GitHub | Agent | Active | `github.md` | PRs, issues, CI via the `gh` CLI. Each agent that uses `gh` sets its own `GH_CONFIG_DIR` (`$HOME/.config/gh-accounts/<agent>`) so parallel sessions never clobber the shared active account. Opt-in — agents that never use `gh` skip it. |

**Credential types:**
- **Agent** — uses a shared agent service account. Agents identify themselves via aliases/labels.
- **User** — uses {{PRINCIPAL}}'s host machine credentials directly. No separate agent account.
- **MCP** — configured via MCP server. No CLI needed.
