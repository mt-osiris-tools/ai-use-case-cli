#!/bin/bash
# AI Use Cases Setup Script
# Sets up AI use case automation for any project
#
# Usage:
#   ./setup-project.sh [project_path]
#   If no path provided, uses current directory

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get script directory first (needed for config manager)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source configuration manager
CONFIG_MANAGER="$SCRIPT_DIR/../utils/config-manager.sh"
if [ -f "$CONFIG_MANAGER" ]; then
    source "$CONFIG_MANAGER"
    # Verify that essential functions were loaded
    if ! command -v get_hub_mode &> /dev/null || ! command -v get_hub_path &> /dev/null; then
        echo -e "${RED}Error: Failed to load configuration manager functions${NC}" >&2
        exit 1
    fi
else
    echo -e "${RED}Error: Configuration manager not found: $CONFIG_MANAGER${NC}" >&2
    echo "This script requires the configuration manager to function properly" >&2
    exit 1
fi

# Function to setup and initialize hub repository
# NOTE: This function is specifically for setup and includes interactive prompts.
# It differs from ensure_hub_exists() in hub-utils.sh which is for validation only.
ensure_hub_exists() {
    local hub_dir
    local hub_mode
    local git_url
    local config_exists=false

    # Check if configuration exists
    if [ -f "$HOME/.config/ai-use-case-cli/config.json" ]; then
        config_exists=true
        hub_mode=$(get_hub_mode)
        hub_dir=$(get_hub_path)
        git_url=$(get_git_url)
    else
        # No config exists - prompt user for hub mode
        echo -e "${BLUE}=== First Time Setup ===${NC}" >&2
        echo "" >&2
        hub_dir=$(prompt_hub_mode)
        hub_mode=$(get_hub_mode)
        git_url=$(get_git_url)
    fi

    # Check if hub directory exists
    if [ ! -d "$hub_dir" ]; then
        echo -e "${YELLOW}Hub directory not found at: $hub_dir${NC}" >&2

        # Create parent directory if needed
        mkdir -p "$(dirname "$hub_dir")"

        # Handle based on hub mode
        case "$hub_mode" in
            local)
                echo -e "${BLUE}Creating local hub directory...${NC}" >&2
                mkdir -p "$hub_dir"
                echo -e "${GREEN}✓${NC} Local hub directory created" >&2
                ;;
            private-git)
                echo -e "${BLUE}Cloning git repository...${NC}" >&2
                echo -e "${CYAN}URL: $git_url${NC}" >&2

                if git clone "$git_url" "$hub_dir" 2>/dev/null; then
                    echo -e "${GREEN}✓${NC} Hub repository cloned successfully" >&2
                else
                    echo -e "${RED}Error: Failed to clone hub repository${NC}" >&2
                    echo "Please clone manually:" >&2
                    echo "  git clone $git_url $hub_dir" >&2
                    echo "" >&2
                    echo "Or reconfigure:" >&2
                    echo "  rm ~/.config/ai-use-case-cli/config.json" >&2
                    echo "  ai-use-case --init" >&2
                    exit 1
                fi
                ;;
        esac
    fi

    # Verify and create hub structure
    if [ ! -d "$hub_dir/by-project" ]; then
        mkdir -p "$hub_dir/by-project" "$hub_dir/by-date" "$hub_dir/by-topic"
        echo -e "${GREEN}✓${NC} Hub directory structure created" >&2
    fi

    echo "$hub_dir"
}

# Configuration - Auto-detect locations
# SCRIPT_DIR = Script's parent directory (scripts/project) - already set above
# CLI_ROOT = CLI installation root directory (for scripts and hooks)
# CENTRAL_DIR = Documentation hub directory (for storing use cases)
CLI_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CENTRAL_DIR=$(ensure_hub_exists)
POST_COMMIT_HOOK_SOURCE="$CLI_ROOT/git-hooks/post-commit"
PRE_COMMIT_HOOK_SOURCE="$CLI_ROOT/git-hooks/pre-commit"
SYNC_SCRIPT="$CLI_ROOT/scripts/core/sync-ai-use-cases.sh"

# Parse flags
UPDATE_MODE=false
PROJECT_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --update)
            UPDATE_MODE=true
            shift
            ;;
        --help|-h)
            echo "AI Use Cases Setup Script"
            echo ""
            echo "Usage:"
            echo "  $0 [options] [project_path]"
            echo ""
            echo "Description:"
            echo "  Sets up AI use case documentation automation for a project."
            echo "  Creates .usecase/cases/ directory, installs git hooks,"
            echo "  and performs initial sync to central repository."
            echo ""
            echo "Options:"
            echo "  --update      Update existing installation (refresh slash commands and hooks)"
            echo "  -h, --help    Show this help message"
            echo ""
            echo "Arguments:"
            echo "  project_path  Path to project directory (default: current directory)"
            echo ""
            echo "Examples:"
            echo "  $0                        # Setup current directory"
            echo "  $0 /path/to/project       # Setup specific project"
            echo "  $0 --update               # Update current directory installation"
            echo "  $0 --update /path/to/proj # Update specific project installation"
            exit 0
            ;;
        *)
            PROJECT_PATH="$1"
            shift
            ;;
    esac
done

# Get project path (use provided argument or current directory)
PROJECT_PATH="${PROJECT_PATH:-$(pwd)}"

# Ensure we're in a project directory
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Directory $PROJECT_PATH does not exist${NC}"
    exit 1
fi

# Check if it's a git repository
if [ ! -d "$PROJECT_PATH/.git" ]; then
    echo -e "${RED}Error: $PROJECT_PATH is not a git repository${NC}"
    echo "Initialize git first: cd $PROJECT_PATH && git init"
    exit 1
fi

PROJECT_NAME=$(basename "$(git -C "$PROJECT_PATH" rev-parse --show-toplevel)")

echo -e "${BLUE}=== AI Use Cases Project Setup ===${NC}"
echo "Project: $PROJECT_NAME"
echo "Path: $PROJECT_PATH"
echo ""

# Validate environment configuration
if [ -z "$AI_USECASES_SYNC_SCRIPT" ]; then
    echo -e "${YELLOW}⚠ Warning: AI_USECASES_SYNC_SCRIPT environment variable not set${NC}"
    echo -e "${BLUE}ℹ${NC} Post-commit hooks may not work correctly after repository separation"
    echo -e "${BLUE}ℹ${NC} Add to your shell profile (~/.bashrc or ~/.zshrc):"
    echo -e "${CYAN}export AI_USECASES_SYNC_SCRIPT=\"\$HOME/.local/share/ai-use-case-cli/scripts/core/sync-ai-use-cases.sh\"${NC}"
    echo ""
fi

# Check for old structure and migrate if needed
OLD_USECASES_DIR="$PROJECT_PATH/docs/ai-use-cases"
AI_USECASES_DIR="$PROJECT_PATH/.usecase/cases"

if [ -d "$OLD_USECASES_DIR" ] && [ ! -d "$AI_USECASES_DIR" ]; then
    echo -e "${YELLOW}⚠ Detected old structure: docs/ai-use-cases/${NC}"
    echo -e "${BLUE}Migrating to new structure: .usecase/cases/${NC}"

    # Create new directory structure
    mkdir -p "$AI_USECASES_DIR"

    # Move all files (excluding README.md which we'll regenerate)
    if [ "$(ls -A "$OLD_USECASES_DIR")" ]; then
        find "$OLD_USECASES_DIR" -type f -name "*.md" ! -name "README.md" -exec mv {} "$AI_USECASES_DIR/" \;
        FILE_COUNT=$(find "$AI_USECASES_DIR" -type f -name "*.md" | wc -l)
        echo -e "${GREEN}✓${NC} Migrated $FILE_COUNT use case file(s)"
    fi

    # Remove old directory
    rm -rf "$OLD_USECASES_DIR"
    echo -e "${GREEN}✓${NC} Removed old docs/ai-use-cases/ directory"
fi

# Create use cases directory if it doesn't exist
if [ ! -d "$AI_USECASES_DIR" ]; then
    mkdir -p "$AI_USECASES_DIR"
    echo -e "${GREEN}✓${NC} Created: .usecase/cases/"

    # Create a README
    cat > "$AI_USECASES_DIR/README.md" <<EOF
# AI Use Cases

This directory contains documentation of AI-assisted development workflows used in this project.

## Format

Each use case is documented in a markdown file with the following naming convention:
\`\`\`
YYYY-Www-MM-DD_TICKET-XXXXX_brief-description.md
\`\`\`

## Syncing

Use cases are automatically synced to a central location at:
\`$CENTRAL_DIR\`

### Manual Sync

To manually sync use cases:
\`\`\`bash
$SYNC_SCRIPT $PROJECT_PATH
\`\`\`

### Automatic Sync

AI use cases are automatically synced after each git commit that modifies files in this directory.

## Template

See the central repository for use case templates and examples.
EOF
    echo -e "${GREEN}✓${NC} Created: .usecase/cases/README.md"
else
    echo -e "${YELLOW}⚠${NC} .usecase/cases/ already exists"
fi

# Install Claude Code slash commands
CLAUDE_COMMANDS_SOURCE="$CLI_ROOT/.claude/commands/use-case"
CLAUDE_COMMANDS_DIR="$PROJECT_PATH/.claude/commands/use-case"

if [ -d "$CLAUDE_COMMANDS_SOURCE" ]; then
    if [ ! -d "$CLAUDE_COMMANDS_DIR" ]; then
        mkdir -p "$CLAUDE_COMMANDS_DIR"
        echo -e "${GREEN}✓${NC} Created: .claude/commands/use-case/"
    fi

    # Copy all command files from use-case directory
    COMMANDS_COPIED=0
    COMMANDS_UPDATED=0
    for cmd_file in "$CLAUDE_COMMANDS_SOURCE"/*.md; do
        if [ -f "$cmd_file" ]; then
            cmd_name=$(basename "$cmd_file")
            target_file="$CLAUDE_COMMANDS_DIR/$cmd_name"

            # Skip if source and target are the same file (self-setup scenario)
            if [ "$cmd_file" -ef "$target_file" ]; then
                continue
            fi

            if [ ! -f "$target_file" ]; then
                cp "$cmd_file" "$target_file"
                COMMANDS_COPIED=$((COMMANDS_COPIED + 1))
            elif [ "$UPDATE_MODE" = true ]; then
                cp "$cmd_file" "$target_file"
                COMMANDS_UPDATED=$((COMMANDS_UPDATED + 1))
            fi
        fi
    done

    if [ $COMMANDS_COPIED -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Installed $COMMANDS_COPIED Claude Code slash command(s)"
    fi
    if [ $COMMANDS_UPDATED -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Updated $COMMANDS_UPDATED Claude Code slash command(s)"
    fi
    if [ $COMMANDS_COPIED -eq 0 ] && [ $COMMANDS_UPDATED -eq 0 ]; then
        echo -e "${YELLOW}⚠${NC} Claude Code slash commands already installed (use --update to refresh)"
    fi
else
    echo -e "${YELLOW}⚠${NC} Claude Code commands not found in CLI installation"
fi

# Install git hooks
GIT_HOOKS_DIR="$PROJECT_PATH/.git/hooks"
POST_COMMIT_HOOK="$GIT_HOOKS_DIR/post-commit"
PRE_COMMIT_HOOK="$GIT_HOOKS_DIR/pre-commit"
BACKUP_BASE_DIR="$PROJECT_PATH/.claude/backups"

# Verify hook sources exist
if [ ! -f "$POST_COMMIT_HOOK_SOURCE" ]; then
    echo -e "${RED}Error: Hook source not found: $POST_COMMIT_HOOK_SOURCE${NC}"
    exit 1
fi

if [ ! -f "$PRE_COMMIT_HOOK_SOURCE" ]; then
    echo -e "${RED}Error: Hook source not found: $PRE_COMMIT_HOOK_SOURCE${NC}"
    exit 1
fi

# Install post-commit hook
if [ -f "$POST_COMMIT_HOOK" ]; then
    # Check if our hook is already installed
    if grep -q "AI Use Cases" "$POST_COMMIT_HOOK"; then
        if [ "$UPDATE_MODE" = true ]; then
            # Backup existing hook
            mkdir -p "$BACKUP_BASE_DIR"
            BACKUP_HOOK="$BACKUP_BASE_DIR/post-commit.backup.$(date +%Y%m%d%H%M%S)"
            cp "$POST_COMMIT_HOOK" "$BACKUP_HOOK"
            echo -e "${BLUE}ℹ${NC} Existing post-commit hook backed up to: .claude/backups/$(basename "$BACKUP_HOOK")"

            # Check if existing hook is identical to our source (no customizations)
            if cmp -s "$POST_COMMIT_HOOK" "$POST_COMMIT_HOOK_SOURCE"; then
                # Safe to replace - hook contains only our code
                cp "$POST_COMMIT_HOOK_SOURCE" "$POST_COMMIT_HOOK"
                chmod +x "$POST_COMMIT_HOOK"
                echo -e "${GREEN}✓${NC} Git post-commit hook updated"
            else
                # Hook has customizations - do not overwrite
                echo -e "${YELLOW}⚠${NC} Git post-commit hook contains customizations"
                echo -e "${YELLOW}⚠${NC} Update skipped to preserve your changes (backup created)"
                echo -e "${BLUE}ℹ${NC} To manually update: compare $BACKUP_HOOK with $POST_COMMIT_HOOK_SOURCE"
            fi
        else
            echo -e "${YELLOW}⚠${NC} Git post-commit hook already installed (use --update to refresh)"
        fi
    else
        # Backup existing hook
        mkdir -p "$BACKUP_BASE_DIR"
        BACKUP_HOOK="$BACKUP_BASE_DIR/post-commit.backup.$(date +%Y%m%d%H%M%S)"
        cp "$POST_COMMIT_HOOK" "$BACKUP_HOOK"
        echo -e "${YELLOW}⚠${NC} Existing post-commit hook backed up to: .claude/backups/$(basename "$BACKUP_HOOK")"

        # Append our hook to existing hook
        echo "" >> "$POST_COMMIT_HOOK"
        cat "$POST_COMMIT_HOOK_SOURCE" >> "$POST_COMMIT_HOOK"
        echo -e "${GREEN}✓${NC} Git post-commit hook appended to existing hook"
    fi
else
    # Install fresh hook
    cp "$POST_COMMIT_HOOK_SOURCE" "$POST_COMMIT_HOOK"
    chmod +x "$POST_COMMIT_HOOK"
    echo -e "${GREEN}✓${NC} Git post-commit hook installed"
fi

# Install pre-commit hook
if [ -f "$PRE_COMMIT_HOOK" ]; then
    # Check if our hook is already installed
    if grep -q "Branch Protection" "$PRE_COMMIT_HOOK"; then
        if [ "$UPDATE_MODE" = true ]; then
            # Backup existing hook
            mkdir -p "$BACKUP_BASE_DIR"
            BACKUP_HOOK="$BACKUP_BASE_DIR/pre-commit.backup.$(date +%Y%m%d%H%M%S)"
            cp "$PRE_COMMIT_HOOK" "$BACKUP_HOOK"
            echo -e "${BLUE}ℹ${NC} Existing pre-commit hook backed up to: .claude/backups/$(basename "$BACKUP_HOOK")"

            # Check if existing hook is identical to our source (no customizations)
            if cmp -s "$PRE_COMMIT_HOOK" "$PRE_COMMIT_HOOK_SOURCE"; then
                # Safe to replace - hook contains only our code
                cp "$PRE_COMMIT_HOOK_SOURCE" "$PRE_COMMIT_HOOK"
                chmod +x "$PRE_COMMIT_HOOK"
                echo -e "${GREEN}✓${NC} Git pre-commit hook updated"
            else
                # Hook has customizations - do not overwrite
                echo -e "${YELLOW}⚠${NC} Git pre-commit hook contains customizations"
                echo -e "${YELLOW}⚠${NC} Update skipped to preserve your changes (backup created)"
                echo -e "${BLUE}ℹ${NC} To manually update: compare $BACKUP_HOOK with $PRE_COMMIT_HOOK_SOURCE"
            fi
        else
            echo -e "${YELLOW}⚠${NC} Git pre-commit hook already installed (use --update to refresh)"
        fi
    else
        # Backup existing hook
        mkdir -p "$BACKUP_BASE_DIR"
        BACKUP_HOOK="$BACKUP_BASE_DIR/pre-commit.backup.$(date +%Y%m%d%H%M%S)"
        cp "$PRE_COMMIT_HOOK" "$BACKUP_HOOK"
        echo -e "${YELLOW}⚠${NC} Existing pre-commit hook backed up to: .claude/backups/$(basename "$BACKUP_HOOK")"

        # Append our hook to existing hook
        echo "" >> "$PRE_COMMIT_HOOK"
        cat "$PRE_COMMIT_HOOK_SOURCE" >> "$PRE_COMMIT_HOOK"
        echo -e "${GREEN}✓${NC} Git pre-commit hook appended to existing hook"
    fi
else
    # Install fresh hook
    cp "$PRE_COMMIT_HOOK_SOURCE" "$PRE_COMMIT_HOOK"
    chmod +x "$PRE_COMMIT_HOOK"
    echo -e "${GREEN}✓${NC} Git pre-commit hook installed (prevents direct commits to main)"
fi

# Add to .gitignore if not already present
GITIGNORE="$PROJECT_PATH/.gitignore"
if [ -f "$GITIGNORE" ]; then
    # Check for old patterns and remove them
    if grep -q "^# AI Use Cases - ignore local notes" "$GITIGNORE"; then
        # Remove old patterns (platform-compatible)
        if [[ "$(uname)" == "Darwin" ]]; then
            # macOS (BSD sed)
            sed -i '' '/^# AI Use Cases - ignore local notes/d' "$GITIGNORE" || true
            sed -i '' '/^docs\/ai-use-cases\/\*\.draft\.md/d' "$GITIGNORE" || true
            sed -i '' '/^docs\/ai-use-cases\/\*\.local\.md/d' "$GITIGNORE" || true
        else
            # Linux (GNU sed)
            sed -i '/^# AI Use Cases - ignore local notes/d' "$GITIGNORE" || true
            sed -i '/^docs\/ai-use-cases\/\*\.draft\.md/d' "$GITIGNORE" || true
            sed -i '/^docs\/ai-use-cases\/\*\.local\.md/d' "$GITIGNORE" || true
        fi
        echo -e "${BLUE}Removed old gitignore patterns${NC}"
    fi

    # Add new patterns if not present
    if ! grep -q "^# Use Case Documentation" "$GITIGNORE"; then
        echo "" >> "$GITIGNORE"
        echo "# Use Case Documentation" >> "$GITIGNORE"
        echo ".usecase/cases/" >> "$GITIGNORE"
        echo ".claude/backups/" >> "$GITIGNORE"
        echo -e "${GREEN}✓${NC} Added .usecase/cases/ and .claude/backups/ to .gitignore"
    else
        # Check if backups line exists
        if ! grep -q "^\.claude/backups/" "$GITIGNORE"; then
            # Find the Use Case Documentation section and add backups line after .usecase/cases/
            if [[ "$(uname)" == "Darwin" ]]; then
                # macOS (BSD sed)
                sed -i '' '/^\.usecase\/cases\//a\
.claude/backups/' "$GITIGNORE"
            else
                # Linux (GNU sed)
                sed -i '/^\.usecase\/cases\//a .claude/backups/' "$GITIGNORE"
            fi
            echo -e "${GREEN}✓${NC} Added .claude/backups/ to .gitignore"
        else
            echo -e "${YELLOW}⚠${NC} .gitignore already configured"
        fi
    fi
fi

# Perform initial sync
echo ""
echo -e "${BLUE}Performing initial sync...${NC}"
if "$SYNC_SCRIPT" "$PROJECT_PATH"; then
    # Register project in the registry
    if [ -f "$SCRIPT_DIR/registry-manager.sh" ]; then
        source "$SCRIPT_DIR/registry-manager.sh"
        CLI_VERSION=$(get_cli_version "$CLI_ROOT")
        REGISTRY_STATUS=$(register_project "$PROJECT_PATH" "$CLI_VERSION" ".usecase/cases")
        if [ "$REGISTRY_STATUS" = "registered" ]; then
            echo -e "${GREEN}✓${NC} Project registered in CLI registry"
        elif [ "$REGISTRY_STATUS" = "updated" ]; then
            echo -e "${GREEN}✓${NC} Project registry updated"
        fi
    fi

    echo ""
    echo -e "${GREEN}=== Setup Complete! ===${NC}"
    echo ""
    echo "What's next?"
    echo "1. Create use case docs in: $AI_USECASES_DIR"
    echo "2. Use format: YYYY-Www-MM-DD_TICKET-XXXXX_description.md"
    echo "3. Commit changes - use cases will auto-sync!"
    echo ""
    echo "Available commands:"
    echo "  ai-use-case document      # Document an AI session"
    echo "  ai-use-case sync          # Manual sync"
    echo "  ai-use-case search <term> # Search use cases"
    echo ""
    if [ -d "$CLAUDE_COMMANDS_DIR" ]; then
        echo "Claude Code slash commands:"
        echo "  /use-case:document-session    # Document AI session automatically"
        echo "  /use-case:setup-project       # Setup another project"
        echo "  /use-case:sync-usecases       # Sync to hub"
        echo "  /use-case:search-usecases     # Search past use cases"
        echo "  /use-case:publish-confluence  # Publish to Confluence"
        echo ""
    fi
    echo "View synced: ls $CENTRAL_DIR/by-project/$PROJECT_NAME/"
else
    echo -e "${RED}Initial sync failed${NC}"
    exit 1
fi
