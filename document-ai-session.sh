#!/bin/bash
# AI Session Documentor - INTERACTIVE MODE
# Captures AI-assisted coding session details and generates documentation
#
# IMPORTANT: This script is for MANUAL/INTERACTIVE mode only!
# When using Claude Code, documentation is generated AUTOMATICALLY
# via the /document-session command without running this script.
#
# Usage:
#   ./document-ai-session.sh [project_path]
#   ai-use-case document [project_path]
#
# Mode Selection:
#   - AUTOMATIC (Claude Code): Run /document-session command
#     * No prompts required
#     * Auto-extracts info from git + conversation
#     * Generates complete documentation instantly
#
#   - INTERACTIVE (Manual/Shell): Run this script directly
#     * Prompts for all details
#     * Manual input required
#     * Use when no AI context exists

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to ensure hub repository exists
ensure_hub_exists() {
    local hub_dir
    local default_hub="$HOME/Documents/ai-use-case-hub"

    # Check if AI_USECASES_DIR is set
    if [ -n "$AI_USECASES_DIR" ]; then
        hub_dir="$AI_USECASES_DIR"
    else
        hub_dir="$default_hub"
    fi

    # Check if hub exists
    if [ ! -d "$hub_dir" ]; then
        echo -e "${YELLOW}Hub repository not found at: $hub_dir${NC}" >&2
        echo -e "${BLUE}Cloning ai-use-case-hub repository...${NC}" >&2

        # Create parent directory if needed
        mkdir -p "$(dirname "$hub_dir")"

        # Clone the repository
        if git clone https://github.com/mt-osiris-tools/ai-use-case-hub.git "$hub_dir" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Hub repository cloned successfully" >&2
        else
            echo -e "${RED}Error: Failed to clone hub repository${NC}" >&2
            echo "Please clone manually:" >&2
            echo "  git clone https://github.com/mt-osiris-tools/ai-use-case-hub.git $hub_dir" >&2
            exit 1
        fi
    fi

    # Verify hub structure
    if [ ! -d "$hub_dir/by-project" ]; then
        mkdir -p "$hub_dir/by-project" "$hub_dir/by-date" "$hub_dir/by-topic"
    fi

    echo "$hub_dir"
}

# Configuration - Auto-detect hub location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CENTRAL_DIR=$(ensure_hub_exists)
TEMPLATE_FILE="$CENTRAL_DIR/TEMPLATE.md"
SYNC_SCRIPT="$CENTRAL_DIR/sync-ai-use-cases.sh"

# Show help
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "AI Session Documentor - INTERACTIVE MODE"
    echo ""
    echo "Usage:"
    echo "  $0 [project_path]"
    echo "  ai-use-case document [project_path]"
    echo ""
    echo "Description:"
    echo "  Interactive tool to document AI-assisted coding sessions."
    echo "  Captures git changes, guides you through prompts, and"
    echo "  generates documentation using the template."
    echo ""
    echo "IMPORTANT: Mode Selection"
    echo "  AUTOMATIC MODE (Recommended when using Claude Code):"
    echo "    - Use /document-session command in Claude Code"
    echo "    - No prompts, fully automatic generation"
    echo "    - Extracts info from git history + AI conversation"
    echo ""
    echo "  INTERACTIVE MODE (This script):"
    echo "    - Run this script directly in terminal"
    echo "    - Manual prompts for all details"
    echo "    - Use when no AI context exists"
    echo ""
    echo "Arguments:"
    echo "  project_path    Path to project directory (default: current directory)"
    echo ""
    echo "Examples:"
    echo "  $0                        # Document session in current directory"
    echo "  $0 /path/to/project       # Document session in specific project"
    echo "  ai-use-case document      # Same, using CLI wrapper"
    echo ""
    echo "Workflow:"
    echo "  1. Analyzes git changes and statistics"
    echo "  2. Prompts for session details (ticket, description, AI tool used)"
    echo "  3. Generates markdown documentation"
    echo "  4. Optionally commits and syncs to central repository"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    exit 0
fi

# Get project path
PROJECT_PATH="${1:-$(pwd)}"

if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Directory $PROJECT_PATH does not exist${NC}"
    exit 1
fi

cd "$PROJECT_PATH"

# Check if it's a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not a git repository${NC}"
    exit 1
fi

PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
AI_USECASES_DIR="$PROJECT_PATH/docs/ai-use-cases"

echo -e "${BLUE}=== AI Session Documentor ===${NC}"
echo "Project: $PROJECT_NAME"
echo "Path: $PROJECT_PATH"
echo ""

# Check if project is set up
if [ ! -d "$AI_USECASES_DIR" ]; then
    echo -e "${YELLOW}⚠ This project is not set up for AI use cases${NC}"
    echo -e "Run: ${CYAN}$CENTRAL_DIR/setup-project.sh${NC}"
    exit 1
fi

# Collect session data
echo -e "${CYAN}Collecting session data...${NC}"
echo ""

# Get git status
UNCOMMITTED_CHANGES=$(git status --porcelain | wc -l)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Get recent commits (last 24 hours)
RECENT_COMMITS=$(git log --since="24 hours ago" --oneline | wc -l)

# Get changed files in last commit or staged
if [ "$UNCOMMITTED_CHANGES" -gt 0 ]; then
    CHANGED_FILES=$(git status --porcelain | awk '{print $2}')
    FILES_COUNT=$(echo "$CHANGED_FILES" | wc -l)
else
    CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null || echo "")
    FILES_COUNT=$(echo "$CHANGED_FILES" | grep -c . || echo "0")
fi

# Display session summary
echo -e "${GREEN}Session Summary:${NC}"
echo "  Branch: $BRANCH"
echo "  Files changed: $FILES_COUNT"
echo "  Recent commits (24h): $RECENT_COMMITS"
echo "  Uncommitted changes: $UNCOMMITTED_CHANGES"
echo ""

# Interactive prompts
echo -e "${CYAN}Please provide session details:${NC}"
echo ""

# Date
read -p "Date (YYYY-MM-DD) [$(date +%Y-%m-%d)]: " SESSION_DATE
SESSION_DATE=${SESSION_DATE:-$(date +%Y-%m-%d)}

# Ticket number
read -p "Ticket/Issue (e.g., PROJ-1234): " TICKET
if [ -z "$TICKET" ]; then
    echo -e "${RED}Error: Ticket number is required${NC}"
    exit 1
fi

# Brief description
read -p "Brief description (for filename): " BRIEF_DESC
if [ -z "$BRIEF_DESC" ]; then
    echo -e "${RED}Error: Description is required${NC}"
    exit 1
fi

# Convert description to slug
SLUG=$(echo "$BRIEF_DESC" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

# AI tool used
echo ""
echo "AI Tool Used:"
echo "1) Claude Code (Sonnet 4.5)"
echo "2) GitHub Copilot"
echo "3) Claude Code + GitHub Copilot"
echo "4) Other"
read -p "Select (1-4) [1]: " AI_TOOL_CHOICE
AI_TOOL_CHOICE=${AI_TOOL_CHOICE:-1}

case $AI_TOOL_CHOICE in
    1) AI_TOOL="Claude Code (Sonnet 4.5)" ;;
    2) AI_TOOL="GitHub Copilot" ;;
    3) AI_TOOL="Claude Code (Sonnet 4.5) + GitHub Copilot" ;;
    4)
        read -p "Specify AI tool: " AI_TOOL
        ;;
    *) AI_TOOL="Claude Code (Sonnet 4.5)" ;;
esac

# Complexity
echo ""
echo "Complexity:"
echo "1) Low"
echo "2) Medium"
echo "3) High"
read -p "Select (1-3) [2]: " COMPLEXITY_CHOICE
COMPLEXITY_CHOICE=${COMPLEXITY_CHOICE:-2}

case $COMPLEXITY_CHOICE in
    1) COMPLEXITY="Low" ;;
    2) COMPLEXITY="Medium" ;;
    3) COMPLEXITY="High" ;;
    *) COMPLEXITY="Medium" ;;
esac

# Time saved
read -p "Time saved vs manual approach (hours): " TIME_SAVED
TIME_SAVED=${TIME_SAVED:-2}

# TL;DR
echo ""
echo -e "${CYAN}TL;DR Section:${NC}"
read -p "What did AI help accomplish? (1-2 sentences): " TLDR_WHAT
read -p "What was the result? (1-2 sentences): " TLDR_RESULT
read -p "Time spent on this task (e.g., '45 minutes'): " TIME_SPENT
TIME_SPENT=${TIME_SPENT:-"1 hour"}

# Business Context
echo ""
echo -e "${CYAN}Business Context:${NC}"
read -p "Objective (what problem were you solving?): " OBJECTIVE
read -p "Why was this work needed?: " BACKGROUND

# Generate filename
FILENAME="${SESSION_DATE}_${TICKET}_${SLUG}.md"
OUTPUT_FILE="$AI_USECASES_DIR/$FILENAME"

echo ""
echo -e "${YELLOW}Generating documentation...${NC}"

# Get git diff for recent changes
if [ "$UNCOMMITTED_CHANGES" -gt 0 ]; then
    GIT_DIFF=$(git diff --stat 2>/dev/null || echo "No diff available")
else
    GIT_DIFF=$(git show --stat HEAD 2>/dev/null || echo "No diff available")
fi

# Generate documentation
# TODO: Refactor to use TEMPLATE.md file with variable substitution instead of inline template
cat > "$OUTPUT_FILE" <<EOF
# 🎯 ${AI_TOOL}: ${BRIEF_DESC}

**Date:** ${SESSION_DATE}
**Repository/Project:** ${PROJECT_NAME}
**Ticket:** [${TICKET}](https://your-jira-or-github/browse/${TICKET})
**Agent Used:** ${AI_TOOL}
**Complexity:** ${COMPLEXITY}
**Time Saved:** ~${TIME_SAVED} hours vs manual approach

---

## 📄 TL;DR

**What:** ${TLDR_WHAT}

**Result:** ${TLDR_RESULT}

**Time:** ${TIME_SPENT} (AI-assisted) vs ${TIME_SAVED} hours manual approach

**Cost:** ~[tokens/cost] for complete workflow

**Key Success:** [What made this particularly successful?]

---

## 🏢 Business Context

**Objective:** ${OBJECTIVE}

**Domain:** [Technical area: Frontend, Backend, Infrastructure, Testing, etc.]

**Requestor:** [Who requested this? Team, stakeholder, technical debt initiative]

**Background:** ${BACKGROUND}

**Expected Benefits:**
- [Benefit 1]
- [Benefit 2]
- [Benefit 3]

---

## 🔄 Workflow Steps

### 1. **[Step Name]**
- [What you did]
- [Tools/commands used]
- **Time:** X minutes

### 2. **[Step Name]**
- [What you did]
- [Tools/commands used]
- **Time:** X minutes

[Continue for all major steps...]

---

## 🛠️ Technical Details

### Tools & Technologies Used
- **Primary AI Tool:** ${AI_TOOL}
- **Version Control:** Git
- **Branch:** ${BRANCH}
- **Other Tools:** [Any other relevant tools]

### Session Statistics

**Files Changed (${FILES_COUNT}):**
${CHANGED_FILES}

**Git Changes:**
\`\`\`
${GIT_DIFF}
\`\`\`

### Code Patterns Used

\`\`\`[language]
// Example of key pattern or approach used
[code snippet]
\`\`\`

### Key Technical Insights

1. **[Insight 1]:** [What you learned]

2. **[Insight 2]:** [What worked well]

3. **[Insight 3]:** [What to watch out for]

---

## 📊 Results & Impact

### Quantitative Results
- **${FILES_COUNT} files** modified
- **${RECENT_COMMITS} commits** in last 24 hours
- **[Y tests]** passing
- **0 regressions** introduced

### Business Impact
- ✅ **[Impact 1]:** [Description]
- ✅ **[Impact 2]:** [Description]
- ✅ **[Impact 3]:** [Description]

---

## 📈 Success Metrics

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Time to complete | <X hours | ${TIME_SPENT} | ✅ Met / ❌ Missed |
| Test coverage | X% | Y% | ✅ Met / ❌ Missed |
| Code quality | 0 issues | Y issues | ✅ Met / ❌ Missed |
| Documentation | Complete | Complete | ✅ Met / ❌ Missed |

---

## 💡 Key Learnings

### ✅ What Worked Well

- **[Success 1]:** [Why it worked]

- **[Success 2]:** [Why it worked]

- **[Success 3]:** [Why it worked]

### ⚠️ Areas for Improvement

- **[Area 1]:** [What could be better]

- **[Area 2]:** [What could be better]

### 🔄 Process Refinements

1. **[Refinement 1]:** [How to improve next time]

2. **[Refinement 2]:** [How to improve next time]

---

## 🎯 Best Practices Identified

1. **[Practice 1]:** [Description and rationale]

2. **[Practice 2]:** [Description and rationale]

3. **[Practice 3]:** [Description and rationale]

---

## 🔄 Replicability Framework

### This workflow is directly replicable for

- ✅ [Use case 1]
- ✅ [Use case 2]
- ✅ [Use case 3]
- ❌ Not suitable for [Use case that won't work]

### Prerequisites for Replication

- **Technology:** [Tools needed]
- **Permissions:** [Access required]
- **Knowledge:** [Skills/understanding needed]
- **Documentation:** [Docs that must exist]

### Expected Timeframe & Cost

- **Simple version:** X minutes, ~Y tokens (~\$Z)
- **Medium complexity:** X minutes, ~Y tokens (~\$Z)
- **Complex version:** X hours, ~Y tokens (~\$Z)

---

## 📝 Implementation Summary

### Files Modified (${FILES_COUNT} total)

${CHANGED_FILES}

### Quality Verification Results

\`\`\`bash
# Tests
✅ X/X tests passing
✅ Y assertions successful

# Code quality
✅ 0 linting issues
✅ 0 type errors
\`\`\`

---

## 🔗 Related Resources

- **Pull Request:** [Link to PR]
- **Issue/Ticket:** [Link to Jira/GitHub issue]
- **Repository:** ${PROJECT_NAME}
- **Branch:** ${BRANCH}
- **Documentation:** [Links to relevant docs]

---

**Created:** ${SESSION_DATE}
**Last Updated:** ${SESSION_DATE}
**Author:** [Your name]
**Review Status:** Draft

<!-- TODO: Fill in bracketed sections above -->
EOF

echo -e "${GREEN}✓ Documentation created!${NC}"
echo "  Location: $OUTPUT_FILE"
echo ""

# Ask if user wants to edit
read -p "Open in editor? (y/N): " OPEN_EDITOR
if [[ "$OPEN_EDITOR" =~ ^[Yy]$ ]]; then
    ${EDITOR:-nano} "$OUTPUT_FILE"
fi

# Ask if user wants to commit
echo ""
read -p "Commit this documentation? (Y/n): " COMMIT_DOC
COMMIT_DOC=${COMMIT_DOC:-y}

if [[ "$COMMIT_DOC" =~ ^[Yy]$ ]]; then
    git add "$OUTPUT_FILE"
    git commit -m "docs: AI session ${SESSION_DATE} - ${TICKET} - ${AI_TOOL}"
    echo -e "${GREEN}✓ Documentation committed${NC}"

    # Auto-sync will be triggered by post-commit hook
    echo -e "${BLUE}📤 Post-commit hook will sync to central repository${NC}"
else
    echo -e "${YELLOW}Documentation saved but not committed${NC}"
    echo "To commit later: git add $OUTPUT_FILE && git commit -m 'docs: AI session'"
fi

echo ""
echo -e "${GREEN}=== Session Documentation Complete! ===${NC}"
echo ""
echo "Next steps:"
echo "1. Fill in TODO sections in the document"
echo "2. Add code snippets and detailed technical insights"
echo "3. Update metrics and results"
echo ""
echo "View: $OUTPUT_FILE"
echo "Central repo: $CENTRAL_DIR/by-project/$PROJECT_NAME/"
