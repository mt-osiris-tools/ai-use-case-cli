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

# Get CLI root directory (parent of parent of script directory)
CLI_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source registry manager
if [ ! -f "$SCRIPT_DIR/registry-manager.sh" ]; then
    echo -e "${RED}Error: registry-manager.sh not found${NC}"
    exit 1
fi

source "$SCRIPT_DIR/registry-manager.sh"

# Parse flags
AUTO_CONFIRM=false
PROJECT_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_CONFIRM=true
            shift
            ;;
        -h|--help)
            cat <<EOF
${BLUE}AI Use Case CLI - Update Project${NC}

Updates a registered project to the latest CLI version by re-running
the setup script.

${YELLOW}Usage:${NC}
  $0 [options] <project_path>

${YELLOW}Arguments:${NC}
  project_path    Path to the project to update

${YELLOW}Options:${NC}
  -y, --yes       Skip confirmation prompt and proceed automatically
  -h, --help      Show this help message

${YELLOW}Examples:${NC}
  $0 /path/to/project          # Update specific project (with prompt)
  $0 -y .                      # Update current directory (no prompt)
  $0 --yes ~/Projects/my-app   # Update project by path (no prompt)
EOF
            exit 0
            ;;
        *)
            if [ -z "$PROJECT_PATH" ]; then
                PROJECT_PATH="$1"
                shift
            else
                echo -e "${RED}Error: Unexpected argument '$1'${NC}"
                echo "Only one project path is allowed."
                echo ""
                echo "Usage: $0 [options] <project_path>"
                echo "Run '$0 --help' for more information."
                exit 1
            fi
            ;;
    esac
done

# Show help if no project path provided
if [ -z "$PROJECT_PATH" ]; then
    cat <<EOF
${BLUE}AI Use Case CLI - Update Project${NC}

Updates a registered project to the latest CLI version by re-running
the setup script.

${YELLOW}Usage:${NC}
  $0 [options] <project_path>

${YELLOW}Arguments:${NC}
  project_path    Path to the project to update

${YELLOW}Options:${NC}
  -y, --yes       Skip confirmation prompt and proceed automatically
  -h, --help      Show this help message

${YELLOW}Examples:${NC}
  $0 /path/to/project          # Update specific project (with prompt)
  $0 -y .                      # Update current directory (no prompt)
  $0 --yes ~/Projects/my-app   # Update project by path (no prompt)

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
    ./update-project.sh -y "\$p"
  done

EOF
    exit 0
fi

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
CLI_VERSION=$(get_cli_version "$CLI_ROOT")

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

# Confirm update (unless -y flag is used)
if [ "$AUTO_CONFIRM" = false ]; then
    read -p "Update project? [Y/n] " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
        echo "Update cancelled"
        exit 0
    fi
else
    echo "Auto-confirming update (--yes flag used)"
    echo ""
fi

echo ""
echo -e "${BLUE}Preparing for update...${NC}"
echo ""

# Force refresh slash commands by removing old ones and copying from running CLI
# This ensures outdated slash commands (with wrong paths) get replaced
# Support both old (.claude) and new (.ai-tools) directory names
LEGACY_COMMANDS_DIR="$PROJECT_PATH/.claude/commands/use-case"
AI_COMMANDS_DIR="$PROJECT_PATH/.ai-tools/commands/use-case"
CLI_COMMANDS_SOURCE="$CLI_ROOT/.ai-tools/commands/use-case"

# Remove old directory structure if it exists
if [ -d "$LEGACY_COMMANDS_DIR" ]; then
    echo -e "${CYAN}Removing old .claude directory structure...${NC}"
    rm -rf "$PROJECT_PATH/.claude"
    echo -e "${GREEN}✓${NC} Old .claude directory removed"
fi

if [ -d "$AI_COMMANDS_DIR" ]; then
    echo -e "${CYAN}Removing old AI tool slash commands...${NC}"
    rm -rf "$AI_COMMANDS_DIR"
    echo -e "${GREEN}✓${NC} Old commands removed"

    # Copy fresh commands from the running CLI installation
    if [ -d "$CLI_COMMANDS_SOURCE" ]; then
        mkdir -p "$AI_COMMANDS_DIR"

        # Check if .md files exist before attempting copy
        MD_FILES=("$CLI_COMMANDS_SOURCE"/*.md)
        if [ -e "${MD_FILES[0]}" ]; then
            cp "$CLI_COMMANDS_SOURCE"/*.md "$AI_COMMANDS_DIR/" 2>/dev/null
            COMMAND_COUNT=$(ls -1 "$AI_COMMANDS_DIR"/*.md 2>/dev/null | wc -l)
            echo -e "${GREEN}✓${NC} Installed $COMMAND_COUNT fresh AI tool slash command(s) from CLI v$CLI_VERSION"
        else
            echo -e "${YELLOW}⚠${NC} No .md slash command files found in $CLI_COMMANDS_SOURCE"
            echo -e "${YELLOW}⚠${NC} Setup script will attempt installation"
        fi
    else
        echo -e "${YELLOW}⚠${NC} Could not find CLI commands at $CLI_COMMANDS_SOURCE"
        echo -e "${YELLOW}⚠${NC} Setup script will attempt installation"
    fi
else
    echo -e "${CYAN}No existing slash commands found, setup will install them${NC}"
fi

# Check for and migrate old structure (docs/ai-use-cases → .usecase/cases)
OLD_USECASES_DIR="$PROJECT_PATH/docs/ai-use-cases"
NEW_USECASES_DIR="$PROJECT_PATH/.usecase/cases"
if [ -d "$OLD_USECASES_DIR" ] && [ ! -d "$NEW_USECASES_DIR" ]; then
    echo -e "${YELLOW}⚠ Detected old structure: docs/ai-use-cases/${NC}"
    echo -e "${CYAN}Will be migrated to: .usecase/cases/${NC}"
    # Setup script will handle the actual migration
fi

echo ""
echo -e "${BLUE}Running setup script...${NC}"
echo ""

# Run setup script with --update flag
if "$SCRIPT_DIR/setup-project.sh" --update "$PROJECT_PATH"; then
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
