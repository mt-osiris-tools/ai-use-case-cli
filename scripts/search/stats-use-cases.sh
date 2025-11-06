#!/bin/bash
# AI Use Cases Statistics
# Show statistics about documented use cases

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

echo -e "${BLUE}=== AI Use Cases Statistics ===${NC}"
echo ""

cd "$HUB_DIR"

if [ ! -d "by-project" ]; then
    echo -e "${YELLOW}No use cases found${NC}"
    exit 0
fi

# Total use cases
total=$(find by-project -name "*.md" -type f | wc -l)
echo -e "${GREEN}Total use cases:${NC} $total"

# Total projects
projects=$(find by-project -mindepth 1 -maxdepth 1 -type d | wc -l)
echo -e "${GREEN}Projects:${NC} $projects"

echo ""
echo -e "${YELLOW}Use cases per project:${NC}"
for dir in by-project/*/; do
    if [ -d "$dir" ]; then
        project=$(basename "$dir")
        count=$(find "$dir" -name "*.md" -type f | wc -l)
        echo "  $project: $count"
    fi
done | sort -t: -k2 -rn

echo ""
echo -e "${YELLOW}Most common AI tools:${NC}"
grep -h "Agent Used:" by-project/*/*.md 2>/dev/null | \
    sed 's/.*Agent Used:\*\* //' | \
    sort | uniq -c | sort -rn | head -5 || echo "  No data available"

echo ""
echo -e "${YELLOW}Total time saved (from documented sessions):${NC}"
time_saved=$(grep -h "Time Saved:" by-project/*/*.md 2>/dev/null | \
    grep -oP '\d+(\.\d+)?' | \
    awk '{sum+=$1} END {print sum}' || echo "0")
echo "  ~${time_saved} hours"

echo ""
echo -e "${GREEN}Hub location:${NC} $HUB_DIR"
