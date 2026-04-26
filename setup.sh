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

# Conventions
if [ -f "$TARGET_REPO/Agents/CONVENTIONS.md" ]; then
    echo -e "   ${YELLOW}Agents/CONVENTIONS.md already exists in target repo.${RESET}"
    read -p "   Overwrite? [y/N]: " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo "   Keeping existing CONVENTIONS.md."
        SKIP_CONVENTIONS=true
    fi
fi

if [ "$SKIP_CONVENTIONS" != "true" ]; then
    mkdir -p "$TARGET_REPO/Agents"
    cp "$SCRIPT_DIR/template/CONVENTIONS.md" "$TARGET_REPO/Agents/CONVENTIONS.md"

    # Replace template markers
    sedi "s|{{PRINCIPAL}}|${PRINCIPAL}|g" "$TARGET_REPO/Agents/CONVENTIONS.md"
    sedi "s|{{NAMING_TRADITION}}|${NAMING_TRADITION}|g" "$TARGET_REPO/Agents/CONVENTIONS.md"
    sedi "s|{{NAMING_DESCRIPTION}}|${NAMING_DESCRIPTION}|g" "$TARGET_REPO/Agents/CONVENTIONS.md"
    sedi "s|{{NAMING_EXAMPLES}}|${NAMING_EXAMPLES}|g" "$TARGET_REPO/Agents/CONVENTIONS.md"

    echo -e "   ${GREEN}Created $TARGET_REPO/Agents/CONVENTIONS.md${RESET}"
fi
echo ""

# ─── 5. Install skills ───────────────────────────────────────────────────────
echo -e "${CYAN}5. Skills installation${RESET}"
echo -e "${DIM}   Two Claude Code skills power the agent system:${RESET}"
echo -e "${DIM}     /agent        — router that activates agents${RESET}"
echo -e "${DIM}     /create-agent — interactive agent builder${RESET}"
echo ""

SKILLS_DIR="$HOME/.claude/skills"

# Check for existing skills
EXISTING_SKILLS=false
if [ -f "$SKILLS_DIR/agent/SKILL.md" ] || [ -f "$SKILLS_DIR/create-agent/SKILL.md" ]; then
    EXISTING_SKILLS=true
    echo -e "   ${YELLOW}Existing agent skills detected in ~/.claude/skills/.${RESET}"
    read -p "   Overwrite? [y/N]: " OVERWRITE_SKILLS
    if [[ ! "$OVERWRITE_SKILLS" =~ ^[Yy]$ ]]; then
        echo "   Skipping skill installation."
        SKIP_SKILLS=true
    fi
fi

if [ "$SKIP_SKILLS" != "true" ]; then
    read -p "   Install skills to ~/.claude/skills/? [Y/n]: " INSTALL_SKILLS
    INSTALL_SKILLS="${INSTALL_SKILLS:-Y}"

    if [[ "$INSTALL_SKILLS" =~ ^[Yy]$ ]]; then
        mkdir -p "$SKILLS_DIR/agent"
        mkdir -p "$SKILLS_DIR/create-agent"

        cp "$SCRIPT_DIR/skills/agent/SKILL.md" "$SKILLS_DIR/agent/SKILL.md"
        cp "$SCRIPT_DIR/skills/create-agent/SKILL.md" "$SKILLS_DIR/create-agent/SKILL.md"

        # Replace principal name in skills
        sedi "s|{{PRINCIPAL}}|${PRINCIPAL}|g" "$SKILLS_DIR/agent/SKILL.md"
        sedi "s|{{PRINCIPAL}}|${PRINCIPAL}|g" "$SKILLS_DIR/create-agent/SKILL.md"

        echo -e "   ${GREEN}Installed /agent to ~/.claude/skills/agent/SKILL.md${RESET}"
        echo -e "   ${GREEN}Installed /create-agent to ~/.claude/skills/create-agent/SKILL.md${RESET}"
    else
        echo "   Skipping skill installation."
        echo -e "   ${DIM}You can install them later by copying from skills/ to ~/.claude/skills/.${RESET}"
    fi
fi
echo ""

# ─── 6. CLAUDE.md integration (optional) ─────────────────────────────────────
if [ -f "$TARGET_REPO/CLAUDE.md" ]; then
    echo -e "${CYAN}6. CLAUDE.md integration${RESET}"
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

Persistent AI collaborators with calibrated autonomy. See `PHILOSOPHY.md` for principles, `Agents/CONVENTIONS.md` for mechanics.

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
    echo -e "${CYAN}6. CLAUDE.md${RESET}"
    echo -e "${DIM}   No CLAUDE.md found. Consider creating one — Claude Code reads it on startup${RESET}"
    echo -e "${DIM}   and it's the best place to document your agents.${RESET}"
    echo ""
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
echo -e "${BOLD}${GREEN}Setup complete.${RESET}"
echo ""
echo "   Target repo:     $TARGET_REPO"
echo "   Principal:       $PRINCIPAL"
echo "   Naming pool:     $NAMING_TRADITION"
echo ""
echo -e "${BOLD}Next steps:${RESET}"
echo ""
echo "   1. cd $TARGET_REPO"
echo "   2. Run /create-agent to build your first agent"
echo "   3. Run /agent <name> to activate it"
echo ""
echo -e "${DIM}Start with PHILOSOPHY.md for the principles, then Agents/CONVENTIONS.md${RESET}"
echo -e "${DIM}for the mechanics — autonomy model, session focus, and memory system.${RESET}"
echo ""
