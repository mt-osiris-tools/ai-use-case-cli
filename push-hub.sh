#!/bin/bash
# Push Hub Changes
# Commit and push changes in the hub repository

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

echo -e "${BLUE}=== Push Hub Changes ===${NC}"
echo ""

cd "$HUB_DIR"

# Check if hub is a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Hub directory is not a git repository${NC}"
    echo "  Location: $HUB_DIR"
    echo "  To initialize git, run: cd $HUB_DIR && git init"
    exit 1
fi

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${YELLOW}Uncommitted changes detected${NC}"
    echo ""

    # Show status
    git status --short

    echo ""
    read -p "Commit these changes? (y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Stage all changes
        git add by-project/ by-date/ by-topic/ 2>/dev/null || true

        # Get commit message
        echo "Enter commit message (or press Enter for default):"
        read -r COMMIT_MSG

        if [ -z "$COMMIT_MSG" ]; then
            COMMIT_MSG="sync: Manual update

Synced at: $(date '+%Y-%m-%d %H:%M:%S')"
        fi

        if git commit -m "$COMMIT_MSG"; then
            echo -e "${GREEN}✓${NC} Changes committed"
        else
            echo -e "${RED}✗ Failed to commit changes${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Skipping commit${NC}"
        exit 0
    fi
else
    echo -e "${GREEN}✓ No uncommitted changes${NC}"
fi

# Push to remote
if git remote get-url origin &>/dev/null; then
    echo ""
    echo -e "${BLUE}Pushing to remote repository...${NC}"

    if git push origin HEAD; then
        echo -e "${GREEN}✓${NC} Changes pushed successfully"
    else
        echo -e "${RED}✗ Failed to push changes${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠ Warning${NC}: No remote repository configured"
    echo "  To add a remote, run:"
    echo "  cd $HUB_DIR && git remote add origin <repository-url>"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Hub synchronized with remote${NC}"
