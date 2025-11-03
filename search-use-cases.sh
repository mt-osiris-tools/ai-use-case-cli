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
