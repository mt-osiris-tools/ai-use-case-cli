#!/bin/bash
# View Use Cases Hub
# Open the hub directory in file explorer

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

echo -e "${BLUE}=== View Use Cases Hub ===${NC}"

if [ -d "$HUB_DIR/by-project" ]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open "$HUB_DIR" &
    elif command -v open &> /dev/null; then
        open "$HUB_DIR" &
    else
        echo "Hub location: $HUB_DIR"
    fi
    echo -e "${GREEN}✓${NC} Opened hub directory"
else
    echo -e "${RED}Error: Hub not found at $HUB_DIR${NC}"
    exit 1
fi
