#!/bin/bash
# AI Use Case CLI - Self Update
# Updates the CLI installation to the latest version from git

set -euo pipefail

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

# Parse flags
AUTO_CONFIRM=false
UPDATE_PROJECTS=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_CONFIRM=true
            shift
            ;;
        --update-projects)
            UPDATE_PROJECTS=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            cat <<EOF
${BLUE}AI Use Case CLI - Self Update${NC}

Updates the CLI installation to the latest version from the git repository.

${YELLOW}Usage:${NC}
  $0 [options]

${YELLOW}Options:${NC}
  -y, --yes              Skip confirmation and update automatically
  --update-projects      Also update all registered projects after CLI update
  --dry-run              Show what would be updated without making changes
  -h, --help             Show this help message

${YELLOW}Examples:${NC}
  $0                        # Check and update CLI (with confirmation)
  $0 -y                     # Update CLI automatically
  $0 -y --update-projects   # Update CLI and all registered projects
  $0 --dry-run              # See what would be updated

${YELLOW}Description:${NC}
  This command updates the CLI installation by pulling the latest changes
  from the git repository. It ensures you're always using the newest
  features and bug fixes.

  Use --update-projects to automatically update all registered projects
  to use the latest CLI components (slash commands, git hooks).

EOF
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option '$1'${NC}"
            echo "Run '$0 --help' for usage information."
            exit 1
            ;;
    esac
done

echo -e "${BLUE}=== AI Use Case CLI Self-Update ===${NC}"
echo ""

# Check if CLI_ROOT is a git repository
if [ ! -d "$CLI_ROOT/.git" ]; then
    echo -e "${RED}Error: CLI installation is not a git repository${NC}"
    echo "Location: $CLI_ROOT"
    echo ""
    echo "The CLI must be installed from git to use self-update."
    echo "Please reinstall using:"
    echo "  git clone https://github.com/mt-osiris-tools/ai-use-case-cli.git ~/.local/share/ai-use-case-cli"
    exit 1
fi

# Get current version and commit
cd "$CLI_ROOT"
CURRENT_COMMIT=$(git rev-parse --short HEAD)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
CURRENT_VERSION=$(grep 'export CLI_VERSION=' "$CLI_ROOT/scripts/utils/version.sh" 2>/dev/null | head -1 | cut -d'"' -f2 || echo "unknown")

echo "Current installation:"
echo "  Location: $CLI_ROOT"
echo "  Version: ${CYAN}$CURRENT_VERSION${NC}"
echo "  Branch: $CURRENT_BRANCH"
echo "  Commit: $CURRENT_COMMIT"
echo ""

# Check for local changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${YELLOW}⚠ Warning: Local changes detected${NC}"
    git status --short
    echo ""
    echo "The CLI installation has uncommitted changes."
    echo "These changes may be lost during update."
    echo ""
    if [ "$AUTO_CONFIRM" = false ]; then
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Update cancelled"
            exit 0
        fi
    fi
fi

# Fetch latest changes
echo -e "${BLUE}Checking for updates...${NC}"
git fetch origin --quiet

# Get remote version
REMOTE_COMMIT=$(git rev-parse --short "origin/$CURRENT_BRANCH")
REMOTE_VERSION=$(git show "origin/$CURRENT_BRANCH:scripts/utils/version.sh" 2>/dev/null | grep 'export CLI_VERSION=' | head -1 | cut -d'"' -f2 || echo "unknown")

# Check if update is needed
if [ "$CURRENT_COMMIT" = "$REMOTE_COMMIT" ]; then
    echo -e "${GREEN}✓ CLI is already up to date!${NC}"
    echo ""
    echo "Current version: $CURRENT_VERSION ($CURRENT_COMMIT)"
    exit 0
fi

# Show what will be updated
echo -e "${YELLOW}Update available:${NC}"
echo "  Current: $CURRENT_VERSION ($CURRENT_COMMIT)"
echo "  Latest:  ${GREEN}$REMOTE_VERSION ($REMOTE_COMMIT)${NC}"
echo ""

# Show changes
echo -e "${CYAN}Changes:${NC}"
git --no-pager log --oneline --pretty=format:"  %C(yellow)%h%C(reset) - %s %C(green)(%ar)%C(reset)" HEAD..origin/"$CURRENT_BRANCH" | head -10
echo ""
echo ""

# Dry run mode
if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}[DRY RUN]${NC} Would update CLI from $CURRENT_VERSION to $REMOTE_VERSION"
    if [ "$UPDATE_PROJECTS" = true ]; then
        echo -e "${BLUE}[DRY RUN]${NC} Would then update all registered projects"
    fi
    exit 0
fi

# Confirm update
if [ "$AUTO_CONFIRM" = false ]; then
    echo -e "${YELLOW}Update CLI to version $REMOTE_VERSION?${NC}"
    read -p "[Y/n] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
        echo "Update cancelled"
        exit 0
    fi
fi

# Perform update
echo ""
echo -e "${BLUE}Updating CLI...${NC}"

# Stash local changes if any
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${CYAN}Stashing local changes...${NC}"
    git stash push -m "auto-stash before self-update at $(date)" --quiet
    STASHED=true
else
    STASHED=false
fi

# Pull latest changes
NEW_VERSION="unknown"  # Initialize to prevent undefined variable errors
NEW_COMMIT="unknown"

if git pull origin "$CURRENT_BRANCH" --quiet; then
    NEW_COMMIT=$(git rev-parse --short HEAD)
    NEW_VERSION=$(grep 'export CLI_VERSION=' "$CLI_ROOT/scripts/utils/version.sh" 2>/dev/null | head -1 | cut -d'"' -f2 || echo "unknown")

    echo -e "${GREEN}✓ CLI updated successfully!${NC}"
    echo ""
    echo "Updated to: ${GREEN}$NEW_VERSION ($NEW_COMMIT)${NC}"

    # Restore stashed changes
    if [ "$STASHED" = true ]; then
        echo ""
        echo -e "${CYAN}Restoring local changes...${NC}"
        if git stash pop --quiet 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Local changes restored"
        else
            echo -e "${YELLOW}⚠${NC} Could not restore local changes automatically"
            echo "Changes saved in: git stash list"
        fi
    fi
else
    echo -e "${RED}✗ Update failed${NC}"
    echo "Please check the error messages above"
    exit 1
fi

# Update projects if requested
if [ "$UPDATE_PROJECTS" = true ]; then
    echo ""
    echo -e "${BLUE}Updating registered projects...${NC}"
    echo ""

    if [ -f "$CLI_ROOT/scripts/project/check-updates.sh" ]; then
        # Get list of outdated projects
        OUTDATED_PROJECTS=$(bash "$CLI_ROOT/scripts/project/check-updates.sh" --paths-only 2>/dev/null)

        if [ -z "$OUTDATED_PROJECTS" ]; then
            echo -e "${GREEN}✓ All projects are already up to date${NC}"
        else
            PROJECT_COUNT=$(echo "$OUTDATED_PROJECTS" | wc -l)
            echo "Found $PROJECT_COUNT project(s) to update"
            echo ""

            for project_path in $OUTDATED_PROJECTS; do
                echo -e "${CYAN}Updating: $project_path${NC}"
                UPDATE_OUTPUT=$(bash "$CLI_ROOT/scripts/project/update-project.sh" -y "$project_path" 2>&1)
                UPDATE_EXIT=$?
                echo "$UPDATE_OUTPUT"
                if [ $UPDATE_EXIT -ne 0 ]; then
                    echo -e "${RED}✗ Failed to update project${NC}"
                fi
                echo ""
            done

            echo -e "${GREEN}✓ Project updates complete${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Cannot update projects: check-updates.sh not found${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=== Update Complete ===${NC}"
echo ""
echo "CLI version: $NEW_VERSION"
echo "Location: $CLI_ROOT"
echo ""

if [ "$UPDATE_PROJECTS" = false ]; then
    echo -e "${CYAN}Tip:${NC} Run 'ai-use-case check-updates' to see if any projects need updating"
fi
