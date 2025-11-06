#!/bin/bash
# AI Use Case CLI - Update Project
# Updates a registered project to the latest CLI version

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
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]] || [ -z "$1" ]; then
    cat <<EOF
${BLUE}AI Use Case CLI - Update Project${NC}

Updates a registered project to the latest CLI version by re-running
the setup script.

${YELLOW}Usage:${NC}
  $0 <project_path>

${YELLOW}Arguments:${NC}
  project_path    Path to the project to update

${YELLOW}Options:${NC}
  -h, --help      Show this help message

${YELLOW}Examples:${NC}
  $0 /path/to/project          # Update specific project
  $0 .                         # Update current directory
  $0 ~/Projects/my-app         # Update project by path

${YELLOW}Description:${NC}
  This command updates a project's CLI installation by:
  1. Verifying the project is registered
  2. Checking if an update is needed
  3. Re-running the setup script
  4. Updating the registry with the new version

  The command is safe to run multiple times and will skip if the
  project is already up to date.

${YELLOW}Update All Projects:${NC}
  To update all outdated projects at once:

  for p in \$(./check-updates.sh --paths-only); do
    ./update-project.sh "\$p"
  done

EOF
    exit 0
fi

# Get project path
PROJECT_PATH="$1"

# Verify project exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Directory does not exist: $PROJECT_PATH${NC}"
    exit 1
fi

# Get absolute path
PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"

# Check if project is registered
PROJECT_INFO=$(get_project_info "$PROJECT_PATH")

if [ "$PROJECT_INFO" = "null" ]; then
    echo -e "${RED}Error: Project is not registered${NC}"
    echo ""
    echo "This project has not been set up with the AI Use Case CLI."
    echo "To set it up, run: ./setup-project.sh \"$PROJECT_PATH\""
    exit 1
fi

# Get project details
PROJECT_NAME=$(echo "$PROJECT_INFO" | jq -r '.name')
PROJECT_VERSION=$(echo "$PROJECT_INFO" | jq -r '.version')

# Get current CLI version
CLI_VERSION=$(get_cli_version "$SCRIPT_DIR")

echo -e "${BLUE}=== Update Project ===${NC}"
echo "Project: $PROJECT_NAME"
echo "Path: $PROJECT_PATH"
echo "Current version: $PROJECT_VERSION"
echo "Latest version: $CLI_VERSION"
echo ""

# Check if update is needed
if [ "$PROJECT_VERSION" = "$CLI_VERSION" ]; then
    echo -e "${GREEN}✓ Project is already up to date!${NC}"
    exit 0
fi

echo -e "${YELLOW}⚠ Update needed: $PROJECT_VERSION → $CLI_VERSION${NC}"
echo ""

# Confirm update
read -p "Update project? [Y/n] " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    echo "Update cancelled"
    exit 0
fi

echo ""
echo -e "${BLUE}Running setup script...${NC}"
echo ""

# Run setup script
if "$SCRIPT_DIR/setup-project.sh" "$PROJECT_PATH"; then
    echo ""
    echo -e "${GREEN}=== Update Complete! ===${NC}"
    echo ""
    echo "Project updated from $PROJECT_VERSION to $CLI_VERSION"
    echo ""

    # Verify update in registry
    NEW_VERSION=$(get_project_info "$PROJECT_PATH" | jq -r '.version')
    if [ "$NEW_VERSION" = "$CLI_VERSION" ]; then
        echo -e "${GREEN}✓${NC} Registry updated successfully"
    else
        echo -e "${YELLOW}⚠${NC} Warning: Registry may not have updated correctly"
    fi
else
    echo ""
    echo -e "${RED}Update failed${NC}"
    echo "Please check the error messages above and try again"
    exit 1
fi
