#!/bin/bash
set -e

# ─── Colors ───────────────────────────────────────────────────────────────────
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ─── Cross-platform sed in-place ──────────────────────────────────────────────
sedi() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

# ─── Header ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Agent Framework Setup${RESET}"
echo -e "${DIM}Build senior AI collaborators with calibrated autonomy in Claude Code.${RESET}"
echo -e "${DIM}Agents that challenge, drive, and hold you accountable — not task runners.${RESET}"
echo ""

# ─── 1. Target repository ────────────────────────────────────────────────────
echo -e "${CYAN}1. Target repository${RESET}"
echo -e "${DIM}   Any git repo — personal wiki, knowledgebase, codebase, or workspace.${RESET}"
read -p "   Path [.]: " TARGET_REPO
TARGET_REPO="${TARGET_REPO:-.}"
TARGET_REPO="$(cd "$TARGET_REPO" 2>/dev/null && pwd)" || {
    echo "   Error: directory not found: $TARGET_REPO"
    exit 1
}

if [ ! -d "$TARGET_REPO/.git" ]; then
    echo -e "   ${YELLOW}Warning: $TARGET_REPO is not a git repository.${RESET}"
    read -p "   Continue anyway? [y/N]: " CONTINUE
    [[ "$CONTINUE" =~ ^[Yy]$ ]] || exit 0
fi
echo ""

# ─── 2. Principal name ───────────────────────────────────────────────────────
echo -e "${CYAN}2. Principal name${RESET}"
echo -e "${DIM}   The person who directs the agents — usually you.${RESET}"
echo -e "${DIM}   Used in conventions and skill files (e.g., \"Surface for <name> to decide\").${RESET}"
read -p "   Name [the principal]: " PRINCIPAL
PRINCIPAL="${PRINCIPAL:-the principal}"
echo ""

# ─── 3. Naming convention ────────────────────────────────────────────────────
echo -e "${CYAN}3. Naming convention${RESET}"
echo -e "${DIM}   Agents get names that outlive their current assignment — neutral, dignified,${RESET}"
echo -e "${DIM}   and drawn from a deep cultural pool. Each carries an archetype.${RESET}"
echo ""
echo "   1) Roman cognomina (default)"
echo -e "      ${DIM}Cato, Varro, Seneca, Corvus, Regulus, Cassia, Livia, Marius...${RESET}"
echo ""
echo "   2) Norse sagas"
echo -e "      ${DIM}Sigrid, Bjorn, Freya, Leif, Astrid, Gunnar, Ingrid, Ragna...${RESET}"
echo ""
echo "   3) Hellenic sages"
echo -e "      ${DIM}Solon, Thales, Hypatia, Aspasia, Pericles, Zeno, Lycurgus, Diotima...${RESET}"
echo ""
read -p "   Choose [1]: " NAMING_CHOICE
NAMING_CHOICE="${NAMING_CHOICE:-1}"

case "$NAMING_CHOICE" in
    1)
        NAMING_TRADITION="Roman cognomina"
        NAMING_DESCRIPTION="historical Roman names that are dignified, neutral, and large enough as a pool to scale"
        NAMING_EXAMPLES="Cato, Varro, Seneca, Corvus, Regulus, Cassia, Livia, Marius, Titus, Praxis, Lucian, Nerva, Flavia, Sabina, Quintus, Aulus, Gaius, Tertia, Decima, Balbus"
        ;;
    2)
        NAMING_TRADITION="Norse saga names"
        NAMING_DESCRIPTION="names from Norse mythology and saga literature — strong, evocative, and drawn from a deep cultural well"
        NAMING_EXAMPLES="Sigrid, Bjorn, Freya, Leif, Astrid, Gunnar, Ingrid, Ragna, Eirik, Sif, Tyr, Vidar, Brynhild, Ivar, Solveig, Arne, Dagny, Halvard, Rune, Thyra"
        ;;
    3)
        NAMING_TRADITION="Hellenic names"
        NAMING_DESCRIPTION="names from ancient Greek history and philosophy — associated with wisdom, governance, and systematic thought"
        NAMING_EXAMPLES="Solon, Thales, Hypatia, Aspasia, Pericles, Zeno, Lycurgus, Diotima, Arete, Philo, Cleisthenes, Myia, Timaeus, Aristos, Charis, Hector, Melos, Doris, Xanthippe, Archon"
        ;;
    *)
        echo "   Invalid choice. Using Roman cognomina."
        NAMING_TRADITION="Roman cognomina"
        NAMING_DESCRIPTION="historical Roman names that are dignified, neutral, and large enough as a pool to scale"
        NAMING_EXAMPLES="Cato, Varro, Seneca, Corvus, Regulus, Cassia, Livia, Marius, Titus, Praxis, Lucian, Nerva, Flavia, Sabina, Quintus, Aulus, Gaius, Tertia, Decima, Balbus"
        ;;
esac
echo ""

# ─── 4. Install philosophy and conventions ───────────────────────────────────
echo -e "${CYAN}4. Installing framework${RESET}"

# Philosophy
if [ -f "$TARGET_REPO/PHILOSOPHY.md" ]; then
    echo -e "   ${YELLOW}PHILOSOPHY.md already exists in target repo.${RESET}"
    read -p "   Overwrite? [y/N]: " OVERWRITE_PHIL
    if [[ ! "$OVERWRITE_PHIL" =~ ^[Yy]$ ]]; then
        echo "   Keeping existing PHILOSOPHY.md."
    else
        cp "$SCRIPT_DIR/PHILOSOPHY.md" "$TARGET_REPO/PHILOSOPHY.md"
        echo -e "   ${GREEN}Updated $TARGET_REPO/PHILOSOPHY.md${RESET}"
    fi
else
    cp "$SCRIPT_DIR/PHILOSOPHY.md" "$TARGET_REPO/PHILOSOPHY.md"
    echo -e "   ${GREEN}Created $TARGET_REPO/PHILOSOPHY.md${RESET}"
fi

# Workspace Conventions
if [ -f "$TARGET_REPO/CONVENTIONS.md" ]; then
    echo -e "   ${YELLOW}CONVENTIONS.md already exists in target repo.${RESET}"
    read -p "   Overwrite? [y/N]: " OVERWRITE_WC
    if [[ ! "$OVERWRITE_WC" =~ ^[Yy]$ ]]; then
        echo "   Keeping existing CONVENTIONS.md."
        SKIP_WORKSPACE_CONVENTIONS=true
    fi
fi

if [ "$SKIP_WORKSPACE_CONVENTIONS" != "true" ]; then
    cp "$SCRIPT_DIR/template/CONVENTIONS.md" "$TARGET_REPO/CONVENTIONS.md"
    echo -e "   ${GREEN}Created $TARGET_REPO/CONVENTIONS.md${RESET}"
fi

# Agent Conventions
if [ -f "$TARGET_REPO/agents/CONVENTIONS.md" ]; then
    echo -e "   ${YELLOW}agents/CONVENTIONS.md already exists in target repo.${RESET}"
    read -p "   Overwrite? [y/N]: " OVERWRITE_AC
    if [[ ! "$OVERWRITE_AC" =~ ^[Yy]$ ]]; then
        echo "   Keeping existing agents/CONVENTIONS.md."
        SKIP_AGENT_CONVENTIONS=true
    fi
fi

if [ "$SKIP_AGENT_CONVENTIONS" != "true" ]; then
    mkdir -p "$TARGET_REPO/agents"
    cp "$SCRIPT_DIR/template/agents/CONVENTIONS.md" "$TARGET_REPO/agents/CONVENTIONS.md"

    # Replace template markers in agent conventions
    sedi "s|{{PRINCIPAL}}|${PRINCIPAL}|g" "$TARGET_REPO/agents/CONVENTIONS.md"
    sedi "s|{{NAMING_TRADITION}}|${NAMING_TRADITION}|g" "$TARGET_REPO/agents/CONVENTIONS.md"
    sedi "s|{{NAMING_DESCRIPTION}}|${NAMING_DESCRIPTION}|g" "$TARGET_REPO/agents/CONVENTIONS.md"
    sedi "s|{{NAMING_EXAMPLES}}|${NAMING_EXAMPLES}|g" "$TARGET_REPO/agents/CONVENTIONS.md"

    echo -e "   ${GREEN}Created $TARGET_REPO/agents/CONVENTIONS.md${RESET}"
fi

# Shared tools index
mkdir -p "$TARGET_REPO/agents/tools"
if [ ! -f "$TARGET_REPO/agents/tools/INDEX.md" ]; then
    cp "$SCRIPT_DIR/template/agents/tools/INDEX.md" "$TARGET_REPO/agents/tools/INDEX.md"
    sedi "s|{{PRINCIPAL}}|${PRINCIPAL}|g" "$TARGET_REPO/agents/tools/INDEX.md"
    echo -e "   ${GREEN}Created $TARGET_REPO/agents/tools/INDEX.md${RESET}"
else
    echo -e "   ${DIM}agents/tools/INDEX.md already exists — skipping.${RESET}"
fi

# Agents skills sync directory
mkdir -p "$TARGET_REPO/agents/skills"
echo ""

# ─── 5. Install skills (project-scoped) ─────────────────────────────────────
echo -e "${CYAN}5. Skills installation${RESET}"
echo -e "${DIM}   Two Claude Code skills power the agent system:${RESET}"
echo -e "${DIM}     /agent        — router that activates agents${RESET}"
echo -e "${DIM}     /create-agent — interactive agent builder${RESET}"
echo -e "${DIM}   Skills are installed to .claude/skills/ (project-scoped).${RESET}"
echo ""

SKILLS_DIR="$TARGET_REPO/.claude/skills"

# Check for existing skills
EXISTING_SKILLS=false
if [ -f "$SKILLS_DIR/agent/SKILL.md" ] || [ -f "$SKILLS_DIR/create-agent/SKILL.md" ]; then
    EXISTING_SKILLS=true
    echo -e "   ${YELLOW}Existing agent skills detected in .claude/skills/.${RESET}"
    read -p "   Overwrite? [y/N]: " OVERWRITE_SKILLS
    if [[ ! "$OVERWRITE_SKILLS" =~ ^[Yy]$ ]]; then
        echo "   Skipping skill installation."
        SKIP_SKILLS=true
    fi
fi

if [ "$SKIP_SKILLS" != "true" ]; then
    read -p "   Install skills to .claude/skills/? [Y/n]: " INSTALL_SKILLS
    INSTALL_SKILLS="${INSTALL_SKILLS:-Y}"

    if [[ "$INSTALL_SKILLS" =~ ^[Yy]$ ]]; then
        mkdir -p "$SKILLS_DIR/agent"
        mkdir -p "$SKILLS_DIR/create-agent"

        cp "$SCRIPT_DIR/skills/agent/SKILL.md" "$SKILLS_DIR/agent/SKILL.md"
        cp "$SCRIPT_DIR/skills/create-agent/SKILL.md" "$SKILLS_DIR/create-agent/SKILL.md"

        # Replace principal name in skills
        sedi "s|{{PRINCIPAL}}|${PRINCIPAL}|g" "$SKILLS_DIR/agent/SKILL.md"
        sedi "s|{{PRINCIPAL}}|${PRINCIPAL}|g" "$SKILLS_DIR/create-agent/SKILL.md"

        echo -e "   ${GREEN}Installed /agent to .claude/skills/agent/SKILL.md${RESET}"
        echo -e "   ${GREEN}Installed /create-agent to .claude/skills/create-agent/SKILL.md${RESET}"

        # Sync copies to agents/skills/ for browsing
        mkdir -p "$TARGET_REPO/agents/skills/agent"
        mkdir -p "$TARGET_REPO/agents/skills/create-agent"
        cp "$SKILLS_DIR/agent/SKILL.md" "$TARGET_REPO/agents/skills/agent/SKILL.md"
        cp "$SKILLS_DIR/create-agent/SKILL.md" "$TARGET_REPO/agents/skills/create-agent/SKILL.md"
        echo -e "   ${DIM}Synced copies to agents/skills/ for browsing.${RESET}"
    else
        echo "   Skipping skill installation."
        echo -e "   ${DIM}You can install them later by copying from skills/ to .claude/skills/.${RESET}"
    fi
fi
echo ""

# ─── 6. Workspace directories ───────────────────────────────────────────────
echo -e "${CYAN}6. Workspace directories${RESET}"
echo -e "${DIM}   Create the standard workspace folder structure?${RESET}"
echo -e "${DIM}   (thinking, work, knowledge, outputs — see CONVENTIONS.md)${RESET}"
read -p "   Create workspace directories? [Y/n]: " CREATE_DIRS
CREATE_DIRS="${CREATE_DIRS:-Y}"

if [[ "$CREATE_DIRS" =~ ^[Yy]$ ]]; then
    for DIR in thinking work work/projects work/operations knowledge knowledge/systems knowledge/people knowledge/processes knowledge/company outputs; do
        mkdir -p "$TARGET_REPO/$DIR"
    done

    # Create INDEX.md files for top-level folders if they don't exist
    for DIR_NAME in thinking work knowledge outputs; do
        if [ ! -f "$TARGET_REPO/$DIR_NAME/INDEX.md" ]; then
            case "$DIR_NAME" in
                thinking)
                    cat > "$TARGET_REPO/$DIR_NAME/INDEX.md" << 'EOF'
---
title: Thinking
type: index
scope: area
---

# Thinking

Unstructured capture — ideas, conversations, notes, and backlog items. Low friction, minimal structure.
EOF
                    ;;
                work)
                    cat > "$TARGET_REPO/$DIR_NAME/INDEX.md" << 'EOF'
---
title: Work
type: index
scope: area
---

# Work

Structured work — initiatives and ongoing responsibilities.

## Lanes

- [[work/projects/INDEX|Projects]] — Finite initiatives with clear deliverables and timelines
- [[work/operations/INDEX|Operations]] — Ongoing responsibilities (no fixed end date)
EOF
                    ;;
                knowledge)
                    cat > "$TARGET_REPO/$DIR_NAME/INDEX.md" << 'EOF'
---
title: Knowledge
type: index
scope: area
---

# Knowledge

Distilled reference material. Items here are maintained over time — they represent settled understanding, not in-progress thinking.

## Categories

- **systems/** — Platform architecture, integrations, and technical concepts
- **people/** — Context about people you work with
- **processes/** — Operational processes, standards, and principles
- **company/** — Org structure, strategy, and business context
EOF
                    ;;
                outputs)
                    cat > "$TARGET_REPO/$DIR_NAME/INDEX.md" << 'EOF'
---
title: Outputs
type: index
scope: workspace
---

# Outputs

Artifacts produced for specific audiences — decks, reports, emails, briefings.
EOF
                    ;;
            esac
            echo -e "   ${GREEN}Created $DIR_NAME/INDEX.md${RESET}"
        fi
    done

    # Create knowledge MOC if it doesn't exist
    if [ ! -f "$TARGET_REPO/knowledge/MOC.md" ]; then
        cat > "$TARGET_REPO/knowledge/MOC.md" << 'EOF'
---
title: Knowledge Map
type: moc
scope: workspace
---

# Knowledge Map

Conceptual map of knowledge, organized by domain. Each category has its own folder for browsing.
EOF
        echo -e "   ${GREEN}Created knowledge/MOC.md${RESET}"
    fi

    echo -e "   ${GREEN}Workspace directories created.${RESET}"
else
    echo "   Skipping workspace directory creation."
fi
echo ""

# ─── 7. CLAUDE.md integration (optional) ─────────────────────────────────────
if [ -f "$TARGET_REPO/CLAUDE.md" ]; then
    echo -e "${CYAN}7. CLAUDE.md integration${RESET}"
    echo -e "${DIM}   Add an agents section to your existing CLAUDE.md?${RESET}"
    read -p "   Add agents section? [Y/n]: " UPDATE_CLAUDE
    UPDATE_CLAUDE="${UPDATE_CLAUDE:-Y}"

    if [[ "$UPDATE_CLAUDE" =~ ^[Yy]$ ]]; then
        # Check if agents section already exists
        if grep -q "## Agents" "$TARGET_REPO/CLAUDE.md" 2>/dev/null; then
            echo -e "   ${YELLOW}Agents section already exists in CLAUDE.md. Skipping.${RESET}"
        else
            cat >> "$TARGET_REPO/CLAUDE.md" << 'CLAUDEBLOCK'

## Agents

Persistent AI collaborators with calibrated autonomy. See `PHILOSOPHY.md` for principles, `agents/CONVENTIONS.md` for mechanics.

| Name | Role |
|------|------|
| *(use `/create-agent` to add your first agent)* | |

Invoke with `/agent <name>`. List with `/agent list`.
CLAUDEBLOCK
            echo -e "   ${GREEN}Added agents section to CLAUDE.md${RESET}"
        fi
    fi
    echo ""
else
    echo -e "${CYAN}7. CLAUDE.md${RESET}"
    echo -e "${DIM}   No CLAUDE.md found. Consider creating one — Claude Code reads it on startup${RESET}"
    echo -e "${DIM}   and it's the best place to document your workspace.${RESET}"
    echo ""
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
echo -e "${BOLD}${GREEN}Setup complete.${RESET}"
echo ""
echo "   Target repo:     $TARGET_REPO"
echo "   Principal:       $PRINCIPAL"
echo "   Naming pool:     $NAMING_TRADITION"
echo ""
echo -e "${BOLD}Installed:${RESET}"
echo ""
echo "   CONVENTIONS.md              — workspace structure conventions"
echo "   agents/CONVENTIONS.md       — agent framework conventions"
echo "   agents/tools/INDEX.md       — shared tool index"
echo "   .claude/skills/agent/       — /agent router skill"
echo "   .claude/skills/create-agent — /create-agent builder skill"
echo "   PHILOSOPHY.md               — framework principles"
echo ""
echo -e "${BOLD}Next steps:${RESET}"
echo ""
echo "   1. cd $TARGET_REPO"
echo "   2. Run /create-agent to build your first agent"
echo "   3. Run /agent <name> to activate it"
echo ""
echo -e "${DIM}Start with PHILOSOPHY.md for the principles, then agents/CONVENTIONS.md${RESET}"
echo -e "${DIM}for the mechanics — autonomy model, session focus, and memory system.${RESET}"
echo ""
