#!/bin/bash
# List Projects with AI Use Cases
# Show all projects that have documented use cases and registry information

set -e

# Colors
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get CLI root directory (parent of parent of script directory)
CLI_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Function to ensure hub repository exists
ensure_hub_exists() {
    local hub_dir
    local default_hub="$HOME/.local/share/ai-use-case-cli/hub"

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

# Source registry manager if available
SHOW_REGISTRY=false
if [ -f "$SCRIPT_DIR/registry-manager.sh" ]; then
    source "$SCRIPT_DIR/registry-manager.sh"
    SHOW_REGISTRY=true
fi

# Show help
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    cat <<EOF
${BLUE}AI Use Case CLI - List Projects${NC}

Lists all projects with AI use cases from the hub and shows registry
information if available.

${YELLOW}Usage:${NC}
  $0 [options]

${YELLOW}Options:${NC}
  -h, --help        Show this help message
  --registry-only   Show only registry information
  --hub-only        Show only hub information

${YELLOW}Examples:${NC}
  $0                    # Show both hub and registry info
  $0 --registry-only    # Show only registered projects
  $0 --hub-only         # Show only hub projects

EOF
    exit 0
fi

# Handle registry-only mode
if [[ "$1" == "--registry-only" ]] && [ "$SHOW_REGISTRY" = true ]; then
    CLI_VERSION=$(get_cli_version "$CLI_ROOT")
    print_projects "$CLI_VERSION"

    # Show statistics
    echo -e "${BLUE}=== Statistics ===${NC}"
    stats=$(get_registry_stats "$CLI_VERSION")
    total=$(echo "$stats" | cut -d' ' -f1)
    outdated=$(echo "$stats" | cut -d' ' -f2)

    echo "Total projects: $total"
    if [ "$outdated" -gt 0 ]; then
        echo -e "Outdated projects: ${YELLOW}$outdated${NC}"
        echo ""
        echo -e "${YELLOW}Tip:${NC} Run ${CYAN}check-updates.sh${NC} to see which projects need updates"
    else
        echo -e "Outdated projects: ${GREEN}0${NC}"
    fi

    echo ""
    echo -e "${CYAN}Current CLI version: $CLI_VERSION${NC}"
    exit 0
fi

# Show hub information
if [[ "$1" != "--registry-only" ]]; then
    echo -e "${BLUE}=== Projects with AI Use Cases (Hub) ===${NC}"
    echo ""

    cd "$HUB_DIR"

    if [ ! -d "by-project" ]; then
        echo -e "${YELLOW}No projects found in hub${NC}"
    else
        for dir in by-project/*/; do
            if [ -d "$dir" ]; then
                project=$(basename "$dir")
                count=$(find "$dir" -name "*.md" -type f | wc -l)
                echo -e "${GREEN}$project${NC}: $count use case(s)"
            fi
        done
    fi
    echo ""
fi

# Show registry information
if [[ "$1" != "--hub-only" ]] && [ "$SHOW_REGISTRY" = true ]; then
    CLI_VERSION=$(get_cli_version "$CLI_ROOT")
    print_projects "$CLI_VERSION"

    # Show statistics
    echo -e "${BLUE}=== Statistics ===${NC}"
    stats=$(get_registry_stats "$CLI_VERSION")
    total=$(echo "$stats" | cut -d' ' -f1)
    outdated=$(echo "$stats" | cut -d' ' -f2)

    echo "Total projects: $total"
    if [ "$outdated" -gt 0 ]; then
        echo -e "Outdated projects: ${YELLOW}$outdated${NC}"
        echo ""
        echo -e "${YELLOW}Tip:${NC} Run ${CYAN}check-updates.sh${NC} to see which projects need updates"
    else
        echo -e "Outdated projects: ${GREEN}0${NC}"
    fi

    echo ""
    echo -e "${CYAN}Current CLI version: $CLI_VERSION${NC}"
fi
