#!/bin/bash
# AI Use Case CLI - Check for Updates
# Checks which registered projects need updates

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source registry manager
if [ ! -f "$SCRIPT_DIR/registry-manager.sh" ]; then
    echo -e "${RED}Error: registry-manager.sh not found${NC}"
    exit 1
fi

source "$SCRIPT_DIR/registry-manager.sh"

# Show help
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    cat <<EOF
${BLUE}AI Use Case CLI - Check for Updates${NC}

Checks which registered projects need updates to the latest CLI version.

${YELLOW}Usage:${NC}
  $0 [options]

${YELLOW}Options:${NC}
  -h, --help     Show this help message
  --json         Output in JSON format
  --paths-only   Output only project paths (one per line)

${YELLOW}Examples:${NC}
  $0                 # Check for outdated projects
  $0 --json          # Output in JSON format
  $0 --paths-only    # Output only paths for scripting

${YELLOW}Description:${NC}
  This command compares the CLI version installed in each registered
  project against the current CLI version and reports which projects
  need updates.

  Use this before running update-project.sh to update specific projects.

EOF
    exit 0
fi

# Get current CLI version
CLI_VERSION=$(get_cli_version "$SCRIPT_DIR")

# Initialize registry
init_registry

# Check if any projects exist
total=$(jq -r '.projects | length' "$REGISTRY_FILE")

if [ "$total" -eq 0 ]; then
    echo -e "${YELLOW}No projects registered yet${NC}"
    echo ""
    echo "Register projects using: ./setup-project.sh <path>"
    exit 0
fi

# Get outdated projects
outdated_json=$(check_updates "$CLI_VERSION")
outdated_count=0

# Handle JSON output
if [[ "$1" == "--json" ]]; then
    echo "{"
    echo "  \"currentVersion\": \"$CLI_VERSION\","
    echo "  \"outdatedProjects\": ["
    first=true
    while IFS= read -r project_json; do
        if [ -n "$project_json" ]; then
            if [ "$first" = true ]; then
                first=false
            else
                echo ","
            fi
            echo -n "    $project_json"
            outdated_count=$((outdated_count + 1))
        fi
    done <<< "$outdated_json"
    echo ""
    echo "  ],"
    echo "  \"totalOutdated\": $outdated_count"
    echo "}"
    exit 0
fi

# Handle paths-only output
if [[ "$1" == "--paths-only" ]]; then
    while IFS= read -r project_json; do
        if [ -n "$project_json" ]; then
            echo "$project_json" | jq -r '.key'
        fi
    done <<< "$outdated_json"
    exit 0
fi

# Pretty output
echo -e "${BLUE}=== Update Check ===${NC}"
echo -e "Current CLI version: ${GREEN}$CLI_VERSION${NC}"
echo ""

if [ -z "$outdated_json" ]; then
    echo -e "${GREEN}✓ All projects are up to date!${NC}"
    echo ""
    echo "Total projects: $total"
    echo "Outdated: 0"
    exit 0
fi

echo -e "${YELLOW}⚠ Found outdated projects:${NC}"
echo ""

while IFS= read -r project_json; do
    if [ -n "$project_json" ]; then
        outdated_count=$((outdated_count + 1))

        local path name version installed updated
        path=$(echo "$project_json" | jq -r '.key')
        name=$(echo "$project_json" | jq -r '.value.name')
        version=$(echo "$project_json" | jq -r '.value.version')
        installed=$(echo "$project_json" | jq -r '.value.installedAt')
        updated=$(echo "$project_json" | jq -r '.value.lastUpdated')

        echo -e "${CYAN}$outdated_count. $name${NC}"
        echo "   Path: $path"
        echo "   Current version: ${RED}$version${NC}"
        echo "   Latest version: ${GREEN}$CLI_VERSION${NC}"
        echo "   Last updated: $(date -d "$updated" +"%Y-%m-%d %H:%M" 2>/dev/null || echo "$updated")"
        echo ""
    fi
done <<< "$outdated_json"

echo -e "${BLUE}=== Summary ===${NC}"
echo "Total projects: $total"
echo -e "Outdated: ${YELLOW}$outdated_count${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review the outdated projects above"
echo "  2. Update a specific project: ${CYAN}./update-project.sh <path>${NC}"
echo "  3. Or update all: ${CYAN}for p in \$(./check-updates.sh --paths-only); do ./update-project.sh \"\$p\"; done${NC}"
