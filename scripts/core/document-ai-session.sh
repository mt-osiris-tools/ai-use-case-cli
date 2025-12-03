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

# Get script directory early for version checking
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get CLI version from version.sh (single source of truth)
get_cli_version() {
    local version_file="$SCRIPT_DIR/../utils/version.sh"
    if [ -f "$version_file" ]; then
        (source "$version_file" && echo "$CLI_VERSION")
    else
        echo "unknown"
    fi
}

# Check for CLI updates
check_cli_version() {
    local current_version=$(get_cli_version)
    local remote_version=""

    # Version check cache (matches ai-use-case main script)
    local VERSION_CHECK_FILE="${HOME}/.cache/ai-use-case-version-check"
    local CACHE_MAX_AGE=86400  # 24 hours in seconds
    local now
    now=$(date +%s)

    # Ensure cache directory exists
    mkdir -p "$(dirname "$VERSION_CHECK_FILE")"

    # Try to use cached remote version if cache is fresh
    if [ -f "$VERSION_CHECK_FILE" ]; then
        local cache_time
        cache_time=$(head -1 "$VERSION_CHECK_FILE" 2>/dev/null)
        if [ -n "$cache_time" ] && [ $((now - cache_time)) -lt $CACHE_MAX_AGE ]; then
            remote_version=$(sed -n '2p' "$VERSION_CHECK_FILE" 2>/dev/null)
        fi
    fi

    # If no fresh cache, fetch remote version and update cache
    if [ -z "$remote_version" ]; then
        echo -e "${BLUE}Checking CLI version...${NC}"
        if command -v curl &> /dev/null; then
            remote_version=$(curl -s -m 3 https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/scripts/utils/version.sh 2>/dev/null | grep '^export CLI_VERSION=' | head -1 | cut -d'"' -f2)
        elif command -v wget &> /dev/null; then
            remote_version=$(wget -qO- -T 3 https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/scripts/utils/version.sh 2>/dev/null | grep '^export CLI_VERSION=' | head -1 | cut -d'"' -f2)
        fi
        # Update cache (even if empty, to avoid repeated attempts)
        {
            echo "$now"
            echo "$remote_version"
        } > "$VERSION_CHECK_FILE"
    fi
    # If we couldn't fetch remote version, continue silently
    if [ -z "$remote_version" ]; then
        echo -e "${YELLOW}⚠${NC} Could not check for updates (network issue)"
        echo -e "${BLUE}Current version: ${NC}v$current_version"
        echo ""
        return 0
    fi

    # Compare versions
    if [ "$current_version" != "$remote_version" ]; then
        echo ""
        # Dynamically determine box width based on version string lengths
        local box_inner_width=52  # default inner width (matches original box)
        local cv_line="Current version: v$current_version"
        local lv_line="Latest version:  v$remote_version"
        local max_line_len=${#cv_line}
        if [ ${#lv_line} -gt $max_line_len ]; then
            max_line_len=${#lv_line}
        fi
        # Also consider the recommendation line length
        local rec_line="It's recommended to update before documenting"
        if [ ${#rec_line} -gt $max_line_len ]; then
            max_line_len=${#rec_line}
        fi
        # Add color codes length fudge factor (since they don't print, but are in the string)
        # We'll ignore color codes for width, as printf will pad the visible chars
        if [ $max_line_len -gt $box_inner_width ]; then
            box_inner_width=$((max_line_len + 4)) # add some padding
        fi
        local box_width=$((box_inner_width + 2)) # account for borders
        local h_border=$(printf '─%.0s' $(seq 1 $box_inner_width))
        # Print top border
        echo -e "${YELLOW}╭${h_border}╮${NC}"
        # Print title
        printf "${YELLOW}│${NC} ${RED}⚠${NC} CLI Update Available"
        printf "%*s${YELLOW}│${NC}\n" $((box_inner_width - 25)) ""
        # Empty line
        printf "${YELLOW}│%*s│${NC}\n" "-$box_inner_width" ""
        # Current version line
        printf "${YELLOW}│${NC} Current version: ${RED}v$current_version${NC}"
        printf "%*s${YELLOW}│${NC}\n" $((box_inner_width - ${#cv_line})) ""
        # Latest version line
        printf "${YELLOW}│${NC} Latest version:  ${GREEN}v$remote_version${NC}"
        printf "%*s${YELLOW}│${NC}\n" $((box_inner_width - ${#lv_line})) ""
        # Empty line
        printf "${YELLOW}│%*s│${NC}\n" "-$box_inner_width" ""
        # Recommendation line
        printf "${YELLOW}│${NC} ${CYAN}It's recommended to update before documenting${NC}"
        printf "%*s${YELLOW}│${NC}\n" $((box_inner_width - 44)) ""
        # Next line
        printf "${YELLOW}│${NC} to ensure you have the latest features."
        printf "%*s${YELLOW}│${NC}\n" $((box_inner_width - 44)) ""
        # Bottom border
        echo -e "${YELLOW}╰${h_border}╯${NC}"
        echo ""
        echo -e "${YELLOW}To update:${NC}"
        echo -e "  ${BLUE}cd ~/.local/share/ai-use-case-cli && git pull${NC}"
        echo ""

        # Check if running in interactive terminal
        if [ -t 0 ]; then
            # Interactive mode: Ask user if they want to continue
            read -p "Continue with current version? (y/N): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${BLUE}Please update and re-run the command.${NC}"
                exit 0
            fi
            echo ""
        else
            # Non-interactive mode: Continue automatically with warning
            echo -e "${YELLOW}⚠${NC} Running in non-interactive mode - continuing with current version"
            echo -e "${CYAN}Note:${NC} Update recommended before next session"
            echo ""
        fi
    else
        echo -e "${GREEN}✓${NC} CLI is up-to-date (v$current_version)"
        echo ""
    fi
}

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

# Configuration - Auto-detect locations
# SCRIPT_DIR = CLI installation directory (for scripts and templates) - defined above for version checking
# CENTRAL_DIR = Documentation hub directory (for storage only, no longer stores templates)
# TEMPLATE_FILE = Will be set dynamically based on session type selection
CENTRAL_DIR=$(ensure_hub_exists)
SYNC_SCRIPT="$SCRIPT_DIR/sync-ai-use-cases.sh"

# Check for flags
SKIP_VERSION_CHECK=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --skip-version-check)
            SKIP_VERSION_CHECK=true
            shift
            ;;
        --help|-h)
            break
            ;;
        *)
            break
            ;;
    esac
done

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
    echo "  -h, --help              Show this help message"
    echo "  --skip-version-check    Skip CLI version check (useful for automation)"
    exit 0
fi

# Get project path
PROJECT_PATH="${1:-$(pwd)}"

if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Directory $PROJECT_PATH does not exist${NC}"
    exit 1
fi

cd "$PROJECT_PATH"

# Check CLI version before starting (unless skipped)
if [ "$SKIP_VERSION_CHECK" = false ]; then
    check_cli_version
fi

# Check if it's a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not a git repository${NC}"
    exit 1
fi

PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
AI_USECASES_DIR="$PROJECT_PATH/.usecase/cases"

echo -e "${BLUE}=== AI Session Documentor ===${NC}"
echo "Project: $PROJECT_NAME"
echo "Path: $PROJECT_PATH"
echo ""

# Check if project is set up (also check old location for migration)
OLD_USECASES_DIR="$PROJECT_PATH/docs/ai-use-cases"
if [ ! -d "$AI_USECASES_DIR" ] && [ ! -d "$OLD_USECASES_DIR" ]; then
    echo -e "${YELLOW}⚠ This project is not set up for use case documentation${NC}"
    echo -e "Run: ${CYAN}ai-use-case --init${NC}"
    exit 1
elif [ ! -d "$AI_USECASES_DIR" ] && [ -d "$OLD_USECASES_DIR" ]; then
    echo -e "${YELLOW}⚠ Old structure detected. Please re-run setup:${NC}"
    echo -e "Run: ${CYAN}ai-use-case --init${NC}"
    echo -e "This will automatically migrate your use cases to the new structure."
    exit 1
fi

# Prompt for session type (implementation or research)
echo -e "${CYAN}Select session type:${NC}"
echo "  1) Implementation (code changes, commits)"
echo "  2) Research (exploration, no code changes)"
echo ""
read -p "Enter choice [1-2] (default: 1): " SESSION_TYPE_CHOICE

case "$SESSION_TYPE_CHOICE" in
    2)
        SESSION_TYPE="research"
        TEMPLATE_FILE="$SCRIPT_DIR/../../docs/TEMPLATE-RESEARCH.md"
        echo -e "${GREEN}✓${NC} Using research session template"
        ;;
    *)
        SESSION_TYPE="implementation"
        TEMPLATE_FILE="$SCRIPT_DIR/../../docs/TEMPLATE.md"
        echo -e "${GREEN}✓${NC} Using implementation session template"
        ;;
esac
echo ""

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

# Session type
echo "Session Type:"
echo "1) Implementation (code changes, commits, file modifications)"
echo "2) Research (exploratory, architecture discussions, no commits)"
read -p "Select (1-2) [1]: " SESSION_TYPE_CHOICE
SESSION_TYPE_CHOICE=${SESSION_TYPE_CHOICE:-1}

case $SESSION_TYPE_CHOICE in
    1)
        SESSION_TYPE="implementation"
        TEMPLATE_FILE="$SCRIPT_DIR/../../docs/TEMPLATE.md"
        ;;
    2)
        SESSION_TYPE="research"
        TEMPLATE_FILE="$SCRIPT_DIR/../../docs/TEMPLATE-RESEARCH.md"
        ;;
    *)
        SESSION_TYPE="implementation"
        TEMPLATE_FILE="$SCRIPT_DIR/../../docs/TEMPLATE.md"
        ;;
esac

echo ""

# Date (with week number in ISO 8601 format: YYYY-Www-MM-DD)
read -p "Date (YYYY-MM-DD) [$(date +%Y-%m-%d)]: " USER_DATE
USER_DATE=${USER_DATE:-$(date +%Y-%m-%d)}

# Calculate week number for the given date
WEEK_NUM=$(date -d "$USER_DATE" +%V 2>/dev/null || date -j -f "%Y-%m-%d" "$USER_DATE" +%V 2>/dev/null)

# Format as YYYY-Www-MM-DD
YEAR=$(echo "$USER_DATE" | cut -d'-' -f1)
MONTH=$(echo "$USER_DATE" | cut -d'-' -f2)
DAY=$(echo "$USER_DATE" | cut -d'-' -f3)
SESSION_DATE="${YEAR}-W${WEEK_NUM}-${MONTH}-${DAY}"

# Helper function to find next available research ticket (handles race conditions)
find_next_research_ticket() {
    local max_attempts=100
    local attempt=0
    local research_num=1

    # Find the highest existing RESEARCH number (if any exist)
    # Check if any research files exist first to avoid empty pipeline issues
    if compgen -G "$AI_USECASES_DIR"/*_RESEARCH-*.md > /dev/null; then
        local highest_num=$(ls "$AI_USECASES_DIR"/*_RESEARCH-*.md 2>/dev/null | \
            grep -oE 'RESEARCH-[0-9]+' | \
            sed 's/RESEARCH-//' | \
            sort -n | \
            tail -1)

        # Validate that we got a numeric result
        if [[ "$highest_num" =~ ^[0-9]+$ ]]; then
            research_num=$((highest_num + 1))
        else
            # Fallback to 1 if parsing failed
            research_num=1
        fi
    else
        # No research files exist yet, start at 1
        research_num=1
    fi

    # Try to find an unused number (handles concurrent creation)
    while [ $attempt -lt $max_attempts ]; do
        local candidate="RESEARCH-$(printf "%03d" $research_num)"

        # Check if any file with this ticket already exists in the directory
        if ! compgen -G "$AI_USECASES_DIR"/*_${candidate}_*.md > /dev/null; then
            echo "$candidate"
            return 0
        fi

        # Collision detected, try next number
        research_num=$((research_num + 1))
        attempt=$((attempt + 1))
    done

    # Fallback: use timestamp-based ticket if all sequential numbers exhausted
    echo "RESEARCH-$(date +%Y%m%d%H%M%S)"
}

# Ticket number (optional for research sessions)
if [ "$SESSION_TYPE" = "research" ]; then
    read -p "Ticket/Issue (e.g., RESEARCH-001, or leave blank): " TICKET
    if [ -z "$TICKET" ]; then
        # Auto-generate research ticket number with race condition protection
        TICKET=$(find_next_research_ticket)
        echo -e "${BLUE}Auto-generated: $TICKET${NC}"
    fi
else
    read -p "Ticket/Issue (e.g., PROJ-1234): " TICKET
    if [ -z "$TICKET" ]; then
        echo -e "${RED}Error: Ticket number is required for implementation sessions${NC}"
        exit 1
    fi
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

# AI Interaction Metrics
echo ""
echo -e "${CYAN}AI Interaction Metrics:${NC}"
read -p "Total interactions (back-and-forth exchanges): " TOTAL_INTERACTIONS
TOTAL_INTERACTIONS=${TOTAL_INTERACTIONS:-10}
read -p "User prompts/messages sent: " USER_PROMPTS
USER_PROMPTS=${USER_PROMPTS:-${TOTAL_INTERACTIONS}}
read -p "Total tokens used (if known, or leave blank): " TOTAL_TOKENS
TOTAL_TOKENS=${TOTAL_TOKENS:-""}
read -p "Input tokens (if known, or leave blank): " INPUT_TOKENS
INPUT_TOKENS=${INPUT_TOKENS:-""}
read -p "Output tokens (if known, or leave blank): " OUTPUT_TOKENS
OUTPUT_TOKENS=${OUTPUT_TOKENS:-""}
read -p "Estimated cost in USD (e.g., 0.25 or leave blank): " ESTIMATED_COST
ESTIMATED_COST=${ESTIMATED_COST:-""}

# Claude Agents Usage (new section)
echo ""
echo -e "${CYAN}Claude Agents Usage:${NC}"
read -p "Were any Claude agents used during this session? (y/N): " AGENTS_USED
AGENTS_USED=${AGENTS_USED:-n}

if [[ "$AGENTS_USED" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Which agents were used? (comma-separated)"
    echo "  Options: Explore, Plan, general-purpose, code-reviewer, other"
    read -p "  Agents: " AGENTS_LIST

    # Validate that agent list is not empty
    if [ -z "$AGENTS_LIST" ]; then
        echo "  No agents specified, skipping agent documentation"
        AGENTS_USED=n
    fi
fi

# Only collect agent details if agents were specified
if [[ "$AGENTS_USED" =~ ^[Yy]$ ]]; then
    # Initialize arrays for storing agent data
    declare -a AGENT_NAMES
    declare -a AGENT_COUNTS
    declare -a AGENT_PURPOSES
    declare -a AGENT_VALUES

    # Parse comma-separated list
    IFS=',' read -ra AGENT_ARRAY <<< "$AGENTS_LIST"

    # Collect details for each agent
    local agent_index=0
    for i in "${!AGENT_ARRAY[@]}"; do
        agent=$(echo "${AGENT_ARRAY[$i]}" | xargs) # trim whitespace

        # Skip empty agent names
        [ -z "$agent" ] && continue

        # Capitalize each word and hyphen-separated segment for consistency
        # This handles "general-purpose" -> "General-Purpose"
        agent="$(echo "$agent" | awk -F'-' '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) tolower(substr($i,2)) } print $0 }' OFS='-')"

        echo ""
        echo -e "${BLUE}Details for: $agent${NC}"

        read -p "  Number of invocations: " agent_count
        agent_count=${agent_count:-1}

        # Validate numeric input
        if ! [[ "$agent_count" =~ ^[0-9]+$ ]]; then
            echo -e "  ${YELLOW}Warning: Invalid number, using default of 1${NC}"
            agent_count=1
        fi

        read -p "  Purpose (what was it used for?): " agent_purpose
        read -p "  Key outcome or value: " agent_value

        # Store in arrays using sequential index
        AGENT_NAMES[$agent_index]="$agent"
        AGENT_COUNTS[$agent_index]="$agent_count"
        AGENT_PURPOSES[$agent_index]="$agent_purpose"
        AGENT_VALUES[$agent_index]="$agent_value"
        agent_index=$((agent_index + 1))
    done
fi

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

# Research-specific questions
if [ "$SESSION_TYPE" = "research" ]; then
    echo ""
    echo -e "${CYAN}Research Details:${NC}"
    read -p "Initial question/query: " INITIAL_QUERY
    read -p "How many iterations to refine the query?: " QUERY_ITERATIONS
    QUERY_ITERATIONS=${QUERY_ITERATIONS:-3}
    read -p "Key insights gained (comma-separated): " KEY_INSIGHTS
    read -p "Approaches evaluated (comma-separated): " APPROACHES_EVALUATED
    read -p "Final decision/recommendation: " FINAL_DECISION
fi

# Generate filename
FILENAME="${SESSION_DATE}_${TICKET}_${SLUG}.md"
OUTPUT_FILE="$AI_USECASES_DIR/$FILENAME"

# Final collision check (race condition protection)
if [ -f "$OUTPUT_FILE" ]; then
    echo -e "${RED}Error: File already exists: $OUTPUT_FILE${NC}"
    echo -e "${YELLOW}This may be due to concurrent session documentation.${NC}"
    if [ "$SESSION_TYPE" = "research" ]; then
        # For auto-generated research tickets, try to find next available
        echo -e "${BLUE}Attempting to find next available ticket number...${NC}"
        TICKET=$(find_next_research_ticket)
        FILENAME="${SESSION_DATE}_${TICKET}_${SLUG}.md"
        OUTPUT_FILE="$AI_USECASES_DIR/$FILENAME"
        echo -e "${GREEN}Using alternative ticket: $TICKET${NC}"
    else
        echo "Please try again with a different ticket number or description."
        exit 1
    fi
fi

echo ""
echo -e "${YELLOW}Generating documentation...${NC}"

# Get git diff for recent changes
if [ "$UNCOMMITTED_CHANGES" -gt 0 ]; then
    GIT_DIFF=$(git diff --stat 2>/dev/null || echo "No diff available")
else
    GIT_DIFF=$(git show --stat HEAD 2>/dev/null || echo "No diff available")
fi

# Helper function to escape special characters for sed
escape_for_sed() {
    echo "$1" | sed -e 's/[\/&]/\\&/g' -e 's/$/\\/' | tr -d '\n' | sed 's/\\$//'
}

# Helper function to generate Claude Agents section content
generate_agents_content() {
    local output=""
    
    # Only generate section if agents were used
    if [[ "$AGENTS_USED" =~ ^[Yy]$ ]] && [ ${#AGENT_NAMES[@]} -gt 0 ]; then
        # Generate entry for each agent
        for i in "${!AGENT_NAMES[@]}"; do
            local agent_name="${AGENT_NAMES[$i]}"
            local count="${AGENT_COUNTS[$i]}"
            local purpose="${AGENT_PURPOSES[$i]}"
            local value="${AGENT_VALUES[$i]}"

            # Handle singular/plural
            local invocations="invocation"
            [ "$count" -gt 1 ] && invocations="invocations"

            output+="
- **${agent_name} Agent:** ${count} ${invocations}
  - **Purpose:** ${purpose}
  - **Value:** ${value}
"
        done

        # Generate summary
        local total_invocations=0
        local max_count=0
        local most_valuable_agent=""

        for i in "${!AGENT_COUNTS[@]}"; do
            local count="${AGENT_COUNTS[$i]}"

            # Validate numeric before adding
            if [[ "$count" =~ ^[0-9]+$ ]]; then
                total_invocations=$((total_invocations + count))

                # Track agent with highest invocation count
                if [ "$count" -gt "$max_count" ]; then
                    max_count=$count
                    most_valuable_agent="${AGENT_NAMES[$i]}"
                fi
            fi
        done

        # Determine most valuable agent description
        local valuable_description=""
        if [ -n "$most_valuable_agent" ]; then
            valuable_description="$most_valuable_agent - most frequently used ($max_count invocations)"
        elif [ ${#AGENT_NAMES[@]} -eq 1 ]; then
            valuable_description="${AGENT_NAMES[0]} - only agent used"
        else
            valuable_description="Multiple agents used equally"
        fi

        output+="
**Agent Effectiveness Summary:**
- Total agent invocations: ${total_invocations}
- Most valuable agent: ${valuable_description}"
    else
        # Placeholder content when no agents used
        output="
- **Explore Agent:** X invocations
  - **Purpose:** Codebase exploration, finding patterns, understanding architecture
  - **Key Findings:** [What the agent discovered or helped with]
  - **Value:** [Impact on session - saved time, provided insights, etc.]

**Agent Effectiveness Summary:**
- Total agent invocations: X
- Most valuable agent: [Agent name and why]"
    fi
    
    echo "$output"
}

# Generate documentation based on session type by reading and populating templates
if [ "$SESSION_TYPE" = "research" ]; then
    # Read the research template
    if [ ! -f "$TEMPLATE_FILE" ]; then
        echo -e "${RED}Error: Template file not found: $TEMPLATE_FILE${NC}"
        exit 1
    fi
    
    TEMPLATE_CONTENT=$(cat "$TEMPLATE_FILE")
    
    # Prepare agent content
    AGENTS_CONTENT=$(generate_agents_content)
    
    # Replace placeholders with actual values
    # Use temporary file for safer multi-line replacements
    echo "$TEMPLATE_CONTENT" | \
    # Header section
    sed "s/# 🔬 Claude Code: \[Research Topic\/Question\]/# 🔬 ${AI_TOOL}: ${BRIEF_DESC}/" | \
    sed "s/\*\*Date:\*\* YYYY-MM-DD (Week XX of YYYY)/**Date:** ${SESSION_DATE}/" | \
    sed "s/\*\*Repository\/Project:\*\* project-name/**Repository\/Project:** ${PROJECT_NAME}/" | \
    sed "s/\[RESEARCH-XXX\](https:\/\/your-jira-or-github\/browse\/RESEARCH-XXX)/[${TICKET}](https:\/\/your-jira-or-github\/browse\/${TICKET})/" | \
    sed "s/\*\*Agent Used:\*\* Claude Code (Sonnet 4.5) \/ GitHub Copilot \/ Other/**Agent Used:** ${AI_TOOL}/" | \
    sed "s/\*\*Complexity:\*\* Low \/ Medium \/ High/**Complexity:** ${COMPLEXITY}/" | \
    sed "s/\*\*Time Saved:\*\* ~X hours vs manual research/**Time Saved:** ~${TIME_SAVED} hours vs manual research/" | \
    sed "s/\*\*Session Duration:\*\* X hours YY minutes/**Session Duration:** ${TIME_SPENT}/" | \
    sed "s/\*\*Query Iterations:\*\* X iterations to optimal solution/**Query Iterations:** ${QUERY_ITERATIONS} iterations to optimal solution/" | \
    # TL;DR section
    sed "s/\*\*What:\*\* \[1-2 sentences: What research question or problem were you exploring?\]/**What:** ${TLDR_WHAT}/" | \
    sed "s/\*\*Result:\*\* \[1-2 sentences: What insights, decisions, or recommendations emerged?\]/**Result:** ${TLDR_RESULT}/" | \
    sed "s/\*\*Time:\*\* \[X minutes (AI-assisted research) vs Y hours manual research\]/**Time:** ${TIME_SPENT} (AI-assisted) vs ${TIME_SAVED} hours manual research/" | \
    # AI Metrics section
    sed "s/- \*\*Total Interactions:\*\* X back-and-forth exchanges between user and AI/- **Total Interactions:** ${TOTAL_INTERACTIONS} back-and-forth exchanges between user and AI/" | \
    sed "s/- \*\*User Prompts:\*\* X total queries\/questions from user/- **User Prompts:** ${USER_PROMPTS} total queries\/questions from user/" | \
    sed "s/- \*\*AI Responses:\*\* X total responses from AI/- **AI Responses:** ~${USER_PROMPTS} total responses from AI/" | \
    sed "s/- \*\*Total Tokens Used:\*\* X,XXX tokens/- **Total Tokens Used:** ${TOTAL_TOKENS:-[Track in your AI tool]} tokens/" | \
    sed "s/- \*\*Estimated Cost:\*\* ~\$X.XX (based on model pricing)/- **Estimated Cost:** ~\$${ESTIMATED_COST:-[Calculate based on tokens]} (based on model pricing)/" | \
    sed "s/- \*\*Model Used:\*\* Claude Sonnet 4.5 \/ GPT-4 \/ Other/- **Model Used:** ${AI_TOOL}/" | \
    sed "s/- \*\*Questions Resolved:\*\* \[Number\] through iterative refinement/- **Questions Resolved:** ${QUERY_ITERATIONS}+ through iterative refinement/" | \
    # Research Context section  
    sed "s/\*\*Initial Query:\*\* \[Your original question or problem statement\]/**Initial Query:** ${INITIAL_QUERY}/" | \
    sed "s/\*\*Objective:\*\* \[What were you trying to understand or decide?\]/**Objective:** ${OBJECTIVE}/" | \
    sed "s/\*\*Background:\*\* \[Why was this research needed? What triggered it?\]/**Background:** ${BACKGROUND}/" | \
    sed "s/\*\*Query Refinement:\*\* \[Number\] iterations to reach optimal clarity/**Query Refinement:** ${QUERY_ITERATIONS} iterations to reach optimal clarity/" | \
    # Query Evolution section - first iteration
    sed "0,/- \*\*Query:\*\* \[Your first question to the AI\]/s//- **Query:** ${INITIAL_QUERY}/" | \
    # Key Insights section
    sed "0,/\[Comma-separated list of main insights for quick reference\]/s//${KEY_INSIGHTS}/" | \
    # Approaches Evaluated section
    sed "0,/\[Comma-separated list of approaches considered\]/s//${APPROACHES_EVALUATED}/" | \
    # Final Decision section
    sed "s/\*\*Decision:\*\* \[Chosen approach or answer to your research question\]/**Decision:** ${FINAL_DECISION}/" | \
    # Research Impact section
    sed "s/- \*\*Time Efficiency:\*\* \[X\]x faster than manual research (\[Y\] hours saved)/- **Time Efficiency:** ${TIME_SAVED}x faster than manual research (${TIME_SAVED} hours saved)/" | \
    sed "s/- ✅ \*\*Accelerated Planning:\*\* \[X\] hours saved in research phase/- ✅ **Accelerated Planning:** ${TIME_SAVED} hours saved in research phase/" | \
    # Resources section
    sed "s/\*\*AI Tool Used:\*\* \[Specific AI tool and model\]/**AI Tool Used:** ${AI_TOOL}/" | \
    # Footer section
    sed "s/\*\*Created:\*\* YYYY-MM-DD/**Created:** ${SESSION_DATE}/" | \
    sed "s/\*\*Last Updated:\*\* YYYY-MM-DD/**Last Updated:** ${SESSION_DATE}/" \
    > "$OUTPUT_FILE"
    
    # Now replace the Claude Agents section if agents were used
    if [[ "$AGENTS_USED" =~ ^[Yy]$ ]] && [ ${#AGENT_NAMES[@]} -gt 0 ]; then
        # Create a temporary file with the agents content
        TEMP_AGENTS_FILE=$(mktemp)
        echo "$AGENTS_CONTENT" > "$TEMP_AGENTS_FILE"
        
        # Use awk to replace the entire Claude Agents section
        awk '
        /^### Claude Agents Used$/ {
            print
            # Skip until we find the Agent Effectiveness Summary end
            while (getline > 0) {
                if (/^- \*\*Time saved by agents:/ || /^---$/) {
                    print
                    break
                }
            }
            # Insert our custom agents content
            while ((getline line < "'"$TEMP_AGENTS_FILE"'") > 0) {
                print line
            }
            next
        }
        { print }
        ' "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp" && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
        
        rm -f "$TEMP_AGENTS_FILE"
    fi

else
    # Read the implementation template
    if [ ! -f "$TEMPLATE_FILE" ]; then
        echo -e "${RED}Error: Template file not found: $TEMPLATE_FILE${NC}"
        exit 1
    fi
    
    TEMPLATE_CONTENT=$(cat "$TEMPLATE_FILE")
    
    # Prepare agent content
    AGENTS_CONTENT=$(generate_agents_content)
    
    # Replace placeholders with actual values
    echo "$TEMPLATE_CONTENT" | \
    # Header section
    sed "s/# 🎯 Claude Code: \[Brief Descriptive Title\]/# 🎯 ${AI_TOOL}: ${BRIEF_DESC}/" | \
    sed "s/\*\*Date:\*\* YYYY-MM-DD (Week XX of YYYY)/**Date:** ${SESSION_DATE}/" | \
    sed "s/\*\*Repository\/Project:\*\* project-name/**Repository\/Project:** ${PROJECT_NAME}/" | \
    sed "s/\[TICKET-XXXXX\](https:\/\/your-jira-or-github\/browse\/TICKET-XXXXX)/[${TICKET}](https:\/\/your-jira-or-github\/browse\/${TICKET})/" | \
    sed "s/\*\*Agent Used:\*\* Claude Code (Sonnet 4.5) \/ GitHub Copilot \/ Other/**Agent Used:** ${AI_TOOL}/" | \
    sed "s/\*\*Complexity:\*\* Low \/ Medium \/ High/**Complexity:** ${COMPLEXITY}/" | \
    sed "s/\*\*Time Saved:\*\* ~X hours vs manual approach/**Time Saved:** ~${TIME_SAVED} hours vs manual approach/" | \
    sed "s/\*\*Session Duration:\*\* X hours YY minutes/**Session Duration:** ${TIME_SPENT}/" | \
    # TL;DR section
    sed "s/\*\*What:\*\* \[1-2 sentences: What did the AI help you accomplish?\]/**What:** ${TLDR_WHAT}/" | \
    sed "s/\*\*Result:\*\* \[1-2 sentences: What was the outcome? Files changed, features added, etc.\]/**Result:** ${TLDR_RESULT}/" | \
    sed "s/\*\*Time:\*\* \[X minutes (AI-assisted) vs Y hours manual approach\]/**Time:** ${TIME_SPENT} (AI-assisted) vs ${TIME_SAVED} hours manual approach/" | \
    # AI Metrics section
    sed "s/- \*\*Total Interactions:\*\* X back-and-forth exchanges between user and AI/- **Total Interactions:** ${TOTAL_INTERACTIONS} back-and-forth exchanges between user and AI/" | \
    sed "s/- \*\*User Prompts:\*\* X total prompts\/messages from user/- **User Prompts:** ${USER_PROMPTS} total prompts\/messages from user/" | \
    sed "s/- \*\*AI Responses:\*\* X total responses from AI/- **AI Responses:** ~${USER_PROMPTS} total responses from AI/" | \
    sed "s/- \*\*Total Tokens Used:\*\* X,XXX tokens/- **Total Tokens Used:** ${TOTAL_TOKENS:-[Track in your AI tool]} tokens/" | \
    sed "s/- \*\*Estimated Cost:\*\* ~\$X.XX (based on model pricing)/- **Estimated Cost:** ~\$${ESTIMATED_COST:-[Calculate based on tokens]} (based on model pricing)/" | \
    sed "s/- \*\*Model Used:\*\* Claude Sonnet 4.5 \/ GPT-4 \/ Other/- **Model Used:** ${AI_TOOL}/" | \
    # Business Context section
    sed "s/\*\*Objective:\*\* \[What business problem were you solving?\]/**Objective:** ${OBJECTIVE}/" | \
    sed "s/\*\*Background:\*\* \[Why was this work needed? What problem exists without it?\]/**Background:** ${BACKGROUND}/" | \
    # Technical Details section
    sed "s/- \*\*Primary AI Tool:\*\* \[Claude Code \/ Copilot \/ etc.\]/- **Primary AI Tool:** ${AI_TOOL}/" | \
    sed "s/- \*\*Branch:\*\* \`branch-name\`/- **Branch:** \`${BRANCH}\`/" | \
    # Results section
    sed "s/- \*\*Files Modified:\*\* X files/- **Files Modified:** ${FILES_COUNT} files/" | \
    sed "s/- \*\*Commits Created:\*\* Z/- **Commits Created:** ${RECENT_COMMITS}/" | \
    # Success Metrics table
    sed "s/| Time to complete | <X hours | Y minutes | ✅ Met \/ ❌ Missed |/| Time to complete | <${TIME_SAVED} hours | ${TIME_SPENT} | ✅ Met |/" | \
    # Related Resources section - first occurrence
    sed "0,/- \*\*Repository:\*\* \[Repo name\]/s//- **Repository:** ${PROJECT_NAME}/" | \
    sed "0,/- \*\*Branch:\*\* \`branch-name\`/s//- **Branch:** \`${BRANCH}\`/" | \
    # Footer section
    sed "s/\*\*Created:\*\* YYYY-MM-DD/**Created:** ${SESSION_DATE}/" | \
    sed "s/\*\*Last Updated:\*\* YYYY-MM-DD/**Last Updated:** ${SESSION_DATE}/" \
    > "$OUTPUT_FILE"
    
    # Now add files changed and git diff sections using awk
    awk -v files_count="$FILES_COUNT" -v changed_files="$CHANGED_FILES" -v git_diff="$GIT_DIFF" '
    /^\*\*Files Changed \([0-9X]+\):\*\*$/ {
        print "**Files Changed (" files_count "):**"
        if (changed_files != "") {
            print ""
            print changed_files
        }
        next
    }
    /^```$/ && prev_line ~ /^\*\*Git Changes:\*\*$/ {
        print
        if (git_diff != "") {
            print git_diff
        }
        next
    }
    { prev_line = $0; print }
    ' "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp" && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
    
    # Replace the Claude Agents section if agents were used
    if [[ "$AGENTS_USED" =~ ^[Yy]$ ]] && [ ${#AGENT_NAMES[@]} -gt 0 ]; then
        # Create a temporary file with the agents content
        TEMP_AGENTS_FILE=$(mktemp)
        echo "$AGENTS_CONTENT" > "$TEMP_AGENTS_FILE"
        
        # Use awk to replace the entire Claude Agents section
        awk '
        /^### Claude Agents Used$/ {
            print
            # Skip until we find the Agent Effectiveness Summary end
            while (getline > 0) {
                if (/^- \*\*Time saved by agents:/ || /^---$/) {
                    print
                    break
                }
            }
            # Insert our custom agents content
            while ((getline line < "'"$TEMP_AGENTS_FILE"'") > 0) {
                print line
            }
            next
        }
        { print }
        ' "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp" && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
        
        rm -f "$TEMP_AGENTS_FILE"
    fi
fi

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
