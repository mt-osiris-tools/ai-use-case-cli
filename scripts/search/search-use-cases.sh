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
HUB_UTILS="$SCRIPT_DIR/../utils/hub-utils.sh"
if [ -f "$HUB_UTILS" ]; then
    source "$HUB_UTILS"
fi

# Ensure hub exists
HUB_DIR=$(ensure_hub_exists)

# Search term required
if [ -z "$1" ]; then
    echo -e "${RED}Error: Search term required${NC}"
    echo "Usage: search-use-cases.sh <term>"
    exit 1
fi

echo -e "${BLUE}=== Search AI Use Cases ===${NC}"
echo "Searching for: ${YELLOW}$1${NC}"
echo ""

cd "$HUB_DIR"

echo -e "${GREEN}📁 Files matching '$1':${NC}"
find by-project -name "*$1*" -type f 2>/dev/null | head -20 || echo "  No matches"

echo ""
echo -e "${GREEN}📝 Content matches:${NC}"
grep -r "$1" by-project --include="*.md" -l 2>/dev/null | head -20 || echo "  No matches"
