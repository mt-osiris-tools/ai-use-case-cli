#!/bin/bash
# AI Use Case CLI - Session Data Extraction
# Extracts AI interaction session data from git history and file system
# to support automated use case documentation and reporting

set -euo pipefail

# Colors
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source version
if [ -f "$CLI_ROOT/scripts/utils/version.sh" ]; then
    source "$CLI_ROOT/scripts/utils/version.sh"
fi

VERSION="${CLI_VERSION:-unknown}"

# Default values
PROJECT_DIR="."
TIME_WINDOW="24" # Default: last 24 hours
OUTPUT_FORMAT="json" # json or markdown
OUTPUT_FILE=""

# Token and context usage (optional, can be provided via environment or parameters)
TOKEN_INPUT="${TOKEN_INPUT:-0}"
TOKEN_OUTPUT="${TOKEN_OUTPUT:-0}"
TOKEN_CACHED="${TOKEN_CACHED:-0}"
CONTEXT_TOTAL="${CONTEXT_TOTAL:-0}"
CACHE_HITS="${CACHE_HITS:-0}"
ESTIMATED_COST="${ESTIMATED_COST:-0.00}"

# Positional args
POSITIONAL_ARGS=()

# Usage information
usage() {
    cat << EOF
${BLUE}AI Use Case CLI - Session Data Extraction${NC} v${VERSION}

Extract AI interaction session data from git history and file system.

${YELLOW}USAGE${NC}
  $(basename "$0") [PROJECT_DIR] [TIME_WINDOW] [FORMAT] [OPTIONS]

${YELLOW}ARGUMENTS${NC}
  PROJECT_DIR    Project directory (default: current directory)
  TIME_WINDOW    Hours to look back (default: 24)
  FORMAT         Output format: json or markdown (default: json)

${YELLOW}OPTIONS${NC}
  -o, --output FILE       Save to file instead of stdout
  --token-input N         Input tokens used (for cost tracking)
  --token-output N        Output tokens used (for cost tracking)
  --token-cached N        Cached tokens used (for efficiency tracking)
  --context-total N       Total context tokens
  --cache-hits N          Number of cache hits
  --cost N                Estimated cost in USD
  -h, --help              Show this help message

${YELLOW}EXAMPLES${NC}
  # Extract data from current session (last 24 hours)
  $(basename "$0")

  # Extract data from last 8 hours
  $(basename "$0") . 8

  # Extract and save to file
  $(basename "$0") . 24 json -o session-data.json

  # Extract as markdown
  $(basename "$0") . 24 markdown

  # Extract with token usage data
  $(basename "$0") . 8 json --token-input 50000 --token-output 15000 --cost 0.85

${YELLOW}OUTPUT${NC}
  Generates structured data including:
  - Session metadata (project, branch, duration, AI tool)
  - Git history (commits, file changes, line counts)
  - File changes (modified, created, deleted)
  - Token usage (input, output, cached, context, cost)
  - Calculated metrics (interactions, duration, averages)
  - Placeholder for conversation data (manual input)

${CYAN}More info: https://github.com/mt-osiris-tools/ai-use-case-cli${NC}
EOF
    exit 0
}

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --token-input)
            TOKEN_INPUT="$2"
            shift 2
            ;;
        --token-output)
            TOKEN_OUTPUT="$2"
            shift 2
            ;;
        --token-cached)
            TOKEN_CACHED="$2"
            shift 2
            ;;
        --context-total)
            CONTEXT_TOTAL="$2"
            shift 2
            ;;
        --cache-hits)
            CACHE_HITS="$2"
            shift 2
            ;;
        --cost)
            ESTIMATED_COST="$2"
            shift 2
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# Process positional arguments
if [ "${#POSITIONAL_ARGS[@]}" -gt 0 ]; then
    PROJECT_DIR="${POSITIONAL_ARGS[0]}"
fi
if [ "${#POSITIONAL_ARGS[@]}" -gt 1 ]; then
    TIME_WINDOW="${POSITIONAL_ARGS[1]}"
fi
if [ "${#POSITIONAL_ARGS[@]}" -gt 2 ]; then
    OUTPUT_FORMAT="${POSITIONAL_ARGS[2]}"
fi

# Change to project directory
cd "$PROJECT_DIR"
PROJECT_DIR="$(pwd)"

# Verify it's a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not a git repository${NC}" >&2
    exit 1
fi

# Validate TIME_WINDOW is a positive number
if ! [[ "$TIME_WINDOW" =~ ^[0-9]+$ ]] || [ "$TIME_WINDOW" -le 0 ]; then
    echo -e "${RED}Error: TIME_WINDOW must be a positive integer (got: ${TIME_WINDOW})${NC}" >&2
    exit 1
fi

# Extract project name
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Extract git history data
echo -e "${BLUE}Extracting session data from ${PROJECT_NAME}...${NC}" >&2
echo -e "${CYAN}Time window: Last ${TIME_WINDOW} hours${NC}" >&2
echo "" >&2

# Get commits since time window
SINCE_DATE=$(date -d "${TIME_WINDOW} hours ago" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -v-${TIME_WINDOW}H '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "${TIME_WINDOW}.hours.ago")

# Count commits
TOTAL_COMMITS=$(git log --since="${SINCE_DATE}" --oneline | wc -l)

# Extract commit data as JSON array
COMMITS_JSON="[]"
if [ "$TOTAL_COMMITS" -gt 0 ]; then
    COMMITS_JSON=$(git log --since="${SINCE_DATE}" --pretty=format:'{"hash":"%h","fullHash":"%H","message":"%s","author":"%an","email":"%ae","timestamp":"%ai","relative":"%ar"}' | jq -s '.')
fi

# Get detailed stats for each commit
TOTAL_FILES=0
TOTAL_INSERTIONS=0
TOTAL_DELETIONS=0

if [ "$TOTAL_COMMITS" -gt 0 ]; then
    # Get stats from all commits in time window
    STATS=$(git log --since="${SINCE_DATE}" --shortstat --pretty=format:'' | \
        awk '/file.*changed/ {
            files+=$1;
            for(i=1;i<=NF;i++) {
                if($i=="insertions(+)") ins+=$(i-1);
                if($i=="deletions(-)") del+=$(i-1);
            }
        }
        END {print files, ins, del}')

    read TOTAL_FILES TOTAL_INSERTIONS TOTAL_DELETIONS <<< "$STATS"

    # Set defaults if empty
    TOTAL_FILES=${TOTAL_FILES:-0}
    TOTAL_INSERTIONS=${TOTAL_INSERTIONS:-0}
    TOTAL_DELETIONS=${TOTAL_DELETIONS:-0}
fi

# Get list of modified files
if [ "$TOTAL_COMMITS" -gt 0 ]; then
    MODIFIED_FILES=$(git diff --name-only HEAD~${TOTAL_COMMITS}..HEAD 2>/dev/null | jq -R . | jq -s . || echo "[]")
else
    MODIFIED_FILES="[]"
fi

# Get uncommitted changes
UNCOMMITTED_MODIFIED=$(git status --short | grep '^ M' | awk '{print $2}' | jq -R . | jq -s . || echo "[]")
UNCOMMITTED_NEW=$(git status --short | grep '^??' | awk '{print $2}' | jq -R . | jq -s . || echo "[]")
UNCOMMITTED_DELETED=$(git status --short | grep '^ D' | awk '{print $2}' | jq -R . | jq -s . || echo "[]")

# Calculate session duration
if [ "$TOTAL_COMMITS" -gt 0 ]; then
    FIRST_COMMIT_TIME=$(git log --since="${SINCE_DATE}" --reverse --pretty=format:'%at' | head -1)
    LAST_COMMIT_TIME=$(git log --since="${SINCE_DATE}" --pretty=format:'%at' | head -1)
    DURATION_SECONDS=$((LAST_COMMIT_TIME - FIRST_COMMIT_TIME))
    # Use shell arithmetic for hours and minutes (no external dependencies)
    DURATION_HOURS=$((DURATION_SECONDS / 3600))
    DURATION_MINUTES=$(((DURATION_SECONDS % 3600) / 60))
    DURATION_HUMAN="${DURATION_HOURS}h ${DURATION_MINUTES}m"
else
    DURATION_SECONDS=0
    DURATION_HOURS=0
    DURATION_HUMAN="N/A"
fi

# Calculate metrics
# Note: Using bc for decimal precision in averages (required dependency)
# bc is a standard Unix utility available on Linux, macOS, and most Unix systems
if [ "$TOTAL_COMMITS" -gt 0 ]; then
    AVG_FILES_PER_COMMIT=$(echo "scale=2; $TOTAL_FILES / $TOTAL_COMMITS" | bc)
    AVG_LINES_PER_COMMIT=$(echo "scale=2; ($TOTAL_INSERTIONS + $TOTAL_DELETIONS) / $TOTAL_COMMITS" | bc)
    NET_LINES=$((TOTAL_INSERTIONS - TOTAL_DELETIONS))
else
    AVG_FILES_PER_COMMIT=0
    AVG_LINES_PER_COMMIT=0
    NET_LINES=0
fi

# Estimate interactions (rough heuristic: commits + (files/3) + (major tool uses))
# Heuristic explanation:
#   - TOTAL_COMMITS: Each commit represents at least one interaction
#   - TOTAL_FILES / 3: Multi-file changes divided by 3 approximates distinct multi-file interactions
#   - +5: Fixed overhead for tool setup, session init, and non-commit interactions
ESTIMATED_INTERACTIONS=$((TOTAL_COMMITS + (TOTAL_FILES / 3) + 5))

# Get current timestamp
EXTRACTED_AT=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

# Detect AI tool (default to Claude Code if in Claude Code context)
AI_TOOL="Claude Code (Sonnet 4.5)"

# Generate output
if [ "$OUTPUT_FORMAT" = "json" ]; then
    # JSON output
    OUTPUT=$(cat <<EOF
{
  "sessionMetadata": {
    "extractedAt": "$EXTRACTED_AT",
    "projectPath": "$PROJECT_DIR",
    "projectName": "$PROJECT_NAME",
    "branch": "$CURRENT_BRANCH",
    "timeWindow": "${TIME_WINDOW}h",
    "sessionDuration": "$DURATION_HUMAN",
    "aiTool": "$AI_TOOL",
    "cliVersion": "$VERSION"
  },
  "gitHistory": {
    "commits": $COMMITS_JSON,
    "summary": {
      "totalCommits": $TOTAL_COMMITS,
      "totalFilesChanged": $TOTAL_FILES,
      "totalInsertions": $TOTAL_INSERTIONS,
      "totalDeletions": $TOTAL_DELETIONS,
      "netLines": $NET_LINES,
      "durationSeconds": $DURATION_SECONDS
    }
  },
  "fileChanges": {
    "committedFiles": $MODIFIED_FILES,
    "uncommitted": {
      "modified": $UNCOMMITTED_MODIFIED,
      "new": $UNCOMMITTED_NEW,
      "deleted": $UNCOMMITTED_DELETED
    }
  },
  "tokenUsage": {
    "inputTokens": $TOKEN_INPUT,
    "outputTokens": $TOKEN_OUTPUT,
    "cachedTokens": $TOKEN_CACHED,
    "totalTokens": $((TOKEN_INPUT + TOKEN_OUTPUT)),
    "contextTokens": $CONTEXT_TOTAL,
    "cacheHits": $CACHE_HITS,
    "estimatedCostUSD": "$ESTIMATED_COST",
    "note": "Token data can be provided via --token-* flags or captured automatically from Claude Code"
  },
  "calculatedMetrics": {
    "estimatedInteractions": $ESTIMATED_INTERACTIONS,
    "avgFilesPerCommit": $AVG_FILES_PER_COMMIT,
    "avgLinesPerCommit": $AVG_LINES_PER_COMMIT,
    "commitFrequency": "$(echo "scale=2; $TOTAL_COMMITS / ($TIME_WINDOW + 0.01)" | bc) commits/hour"
  },
  "conversationData": {
    "note": "Conversation data must be captured manually during session. Use /use-case:document-session for automatic capture.",
    "prompts": [],
    "toolUses": [],
    "context": ""
  }
}
EOF
)
else
    # Markdown output
    OUTPUT=$(cat <<EOF
# AI Session Data Extract

**Extracted:** $EXTRACTED_AT
**Project:** $PROJECT_NAME
**Branch:** $CURRENT_BRANCH
**Time Window:** Last ${TIME_WINDOW} hours
**Duration:** $DURATION_HUMAN
**AI Tool:** $AI_TOOL

---

## Git History

### Commits
- **Total Commits:** $TOTAL_COMMITS
- **Files Changed:** $TOTAL_FILES
- **Lines Added:** +$TOTAL_INSERTIONS
- **Lines Removed:** -$TOTAL_DELETIONS
- **Net Change:** $NET_LINES lines

### Recent Commits
$(git log --since="${SINCE_DATE}" --pretty=format:'- %h - %s (%ar) - %an' | head -10)

---

## Calculated Metrics

- **Estimated Interactions:** ~$ESTIMATED_INTERACTIONS
- **Average Files per Commit:** $AVG_FILES_PER_COMMIT
- **Average Lines per Commit:** $AVG_LINES_PER_COMMIT
- **Commit Frequency:** $(echo "scale=2; $TOTAL_COMMITS / ($TIME_WINDOW + 0.01)" | bc) commits/hour

---

## Token Usage

- **Input Tokens:** $TOKEN_INPUT
- **Output Tokens:** $TOKEN_OUTPUT
- **Cached Tokens:** $TOKEN_CACHED
- **Total Tokens:** $((TOKEN_INPUT + TOKEN_OUTPUT))
- **Context Tokens:** $CONTEXT_TOTAL
- **Cache Hits:** $CACHE_HITS
- **Estimated Cost:** \$$ESTIMATED_COST USD

> **Note:** Token data provided via --token-* flags or captured from Claude Code

---

## File Changes

### Committed Files
$(echo "$MODIFIED_FILES" | jq -r '.[]' | sed 's/^/- /')

### Uncommitted Changes
$(git status --short)

---

## Conversation Data

> **Note:** Conversation data must be captured manually during the session.
> Use \`/use-case:document-session\` for automatic context capture.

**Prompts:** (to be filled)
**Tool Uses:** (to be filled)
**Key Decisions:** (to be filled)

---

**CLI Version:** $VERSION
EOF
)
fi

# Output to file or stdout
if [ -n "$OUTPUT_FILE" ]; then
    echo "$OUTPUT" > "$OUTPUT_FILE"
    echo -e "${GREEN}✓ Session data extracted to: ${OUTPUT_FILE}${NC}" >&2
    echo -e "${CYAN}View: cat ${OUTPUT_FILE}${NC}" >&2
else
    echo "$OUTPUT"
fi

echo "" >&2
echo -e "${BLUE}Summary:${NC}" >&2
echo -e "  ${GREEN}Commits:${NC} $TOTAL_COMMITS" >&2
echo -e "  ${GREEN}Files:${NC} $TOTAL_FILES" >&2
echo -e "  ${GREEN}Lines:${NC} +$TOTAL_INSERTIONS / -$TOTAL_DELETIONS" >&2
echo -e "  ${GREEN}Duration:${NC} $DURATION_HUMAN" >&2
echo -e "  ${GREEN}Estimated Interactions:${NC} ~$ESTIMATED_INTERACTIONS" >&2
