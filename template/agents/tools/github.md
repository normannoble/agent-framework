# GitHub

Agents interact with GitHub using the `gh` CLI.

## Account Isolation (required for any agent that uses `gh`)

`gh` stores one **active account per machine** in `~/.config/gh/hosts.yml`. When several agents share a host, one agent's `gh auth switch` silently changes the identity that every other agent's `gh` — and git-over-`gh` — commands run as. This has already caused a session in one workspace to act as another workspace's GitHub account and cross the workspace boundary.

**Fix:** give each agent its own isolated `gh` state via the `GH_CONFIG_DIR` environment variable, so the agent never touches shared global state and parallel sessions never clobber each other. This mirrors the Google Workspace pattern (`GOOGLE_WORKSPACE_CLI_CONFIG_DIR=$HOME/.config/gws-accounts/<account>`), keeping credential handling consistent across tools.

```bash
export GH_CONFIG_DIR="$HOME/.config/gh-accounts/<agent>"
```

Set it once at session start (or prefix each command with it). Because the isolated dir also drives git-over-`gh`: when git uses `gh` as its credential helper (`gh auth setup-git`), run `git push` / `git fetch` with the same `GH_CONFIG_DIR` in the environment — the helper resolves the account from it. Exporting the variable for the session covers both `gh` and `git`.

**Opt-in.** Only agents that use GitHub need this.
- An agent that never runs `gh` needs no config dir — ignore this section.
- An agent that **does** use `gh` **must** set `GH_CONFIG_DIR` on every `gh`/`git` command, and record its dir in its own `tools.md`, so it never falls back to shared global state.

**One-time setup** (per agent, per host — needs the agent's own GitHub account or scoped token; see Provisioning):

```bash
export GH_CONFIG_DIR="$HOME/.config/gh-accounts/<agent>"
gh auth login                 # log in once into this agent's private config dir
gh auth setup-git             # only if the agent pushes/fetches over https
```

After the one-time login, no `gh auth switch` is ever needed — each agent stays logged in to its own account in its own dir.

### Provisioning (the one decision this doc does not settle)

Each agent that uses GitHub needs its own GitHub identity — a separate GitHub account, or a scoped token — granted the repo permissions its work requires. Isolation (above) stops the clobbering the moment each agent has its own dir; distinct **identity** in commits and PR authorship requires that separate account/token. Provision it before the agent's first `gh auth login`.

## Commands

**List PRs:**
```bash
gh pr list
gh pr list --author <user>
```

**View a PR:**
```bash
gh pr view <PR_NUMBER>
```

**Create a PR:**
```bash
gh pr create --title '...' --body '...'
```

**Review a PR:**
```bash
gh pr review <PR_NUMBER> --approve
gh pr review <PR_NUMBER> --comment --body '...'
gh pr review <PR_NUMBER> --request-changes --body '...'
```

**Merge a PR:**
```bash
gh pr merge <PR_NUMBER> --squash
```

**View issues:**
```bash
gh issue view <ISSUE_NUMBER>
```

**View checks/CI status:**
```bash
gh pr checks <PR_NUMBER>
```

## Autonomy Defaults

| Action | Default Level |
|--------|--------------|
| Read PRs, checks, CI status | L5 — Own |
| Create branches, push code | L4 — Act & Inform |
| Create PRs | L4 — Act & Inform |
| Review PRs (comment) | L3 — Intend |
| Merge own PRs after approval | L3 — Intend |
| Review PRs (approve/request changes) | L2 — Recommend |
| Merge others' PRs | L2 — Recommend |
| Close or reject PRs | L2 — Recommend |
