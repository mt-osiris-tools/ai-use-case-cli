#!/bin/bash
# Search AI Use Cases
# Find use cases by keyword/topic across all projects

set -e

# Colors
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
NC=$'\033[0m'

# Get script directory and source hub utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source tracing utilities
if [ -f "$SCRIPT_DIR/../utils/tracing.sh" ]; then
    source "$SCRIPT_DIR/../utils/tracing.sh"
    # Enable tracing for this script
    enable_script_tracing "search-use-cases.sh" "$@" || true
else
    # Define no-op functions if tracing not available
    trace_operation() { true; }
    trace_event() { true; }
    trace_attribute() { true; }
fi

HUB_UTILS="$SCRIPT_DIR/../utils/hub-utils.sh"
if [ -f "$HUB_UTILS" ]; then
    source "$HUB_UTILS"
fi

# Ensure hub exists
trace_operation "ensure_hub_exists"
HUB_DIR=$(ensure_hub_exists)

# Search term required
if [ -z "$1" ]; then
    trace_event "search_error" "error=missing_search_term"
    echo -e "${RED}Error: Search term required${NC}"
    echo "Usage: search-use-cases.sh <term>"
    exit 1
fi

trace_event "search_start" "term=$1" "hub_dir=$HUB_DIR"

echo -e "${BLUE}=== Search AI Use Cases ===${NC}"
echo "Searching for: ${YELLOW}$1${NC}"
echo ""

cd "$HUB_DIR"

trace_operation "search_files" "term=$1"
echo -e "${GREEN}📁 Files matching '$1':${NC}"
FILE_MATCHES=$(find by-project -type f -path "*$1*" 2>/dev/null | head -20)
if [ -n "$FILE_MATCHES" ]; then
    echo "$FILE_MATCHES"
    FILE_COUNT=$(echo "$FILE_MATCHES" | wc -l)
    trace_event "search_results" "type=filename" "count=$FILE_COUNT" "term=$1"
else
    echo "  No matches"
    trace_event "search_results" "type=filename" "count=0" "term=$1"
fi

echo ""
trace_operation "search_content" "term=$1"
echo -e "${GREEN}📝 Content matches:${NC}"
CONTENT_MATCHES=$(grep -r "$1" by-project --include="*.md" -l 2>/dev/null | head -20)
if [ -n "$CONTENT_MATCHES" ]; then
    echo "$CONTENT_MATCHES"
    CONTENT_COUNT=$(echo "$CONTENT_MATCHES" | wc -l)
    trace_event "search_results" "type=content" "count=$CONTENT_COUNT" "term=$1"
else
    echo "  No matches"
    trace_event "search_results" "type=content" "count=0" "term=$1"
fi
