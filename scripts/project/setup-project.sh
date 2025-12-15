#!/bin/bash
# AI Use Cases Setup Script
# Sets up AI use case automation for any project
#
# Usage:
#   ./setup-project.sh [project_path]
#   If no path provided, uses current directory

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

# Source progress tracker
PROGRESS_TRACKER="$SCRIPT_DIR/../utils/progress-tracker.sh"
if [ -f "$PROGRESS_TRACKER" ]; then
    source "$PROGRESS_TRACKER"
    PROGRESS_ENABLED=true
else
    PROGRESS_ENABLED=false
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
SESSION_END_HOOK_SOURCE="$CLI_ROOT/claude-hooks/SessionEnd"
SYNC_SCRIPT="$CLI_ROOT/scripts/core/sync-ai-use-cases.sh"

# Parse flags
UPDATE_MODE=false
PROJECT_PATH=""
VERBOSE=${VERBOSE:-false}

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

# Check git requirement and availability
GIT_AVAILABLE=false
if [ -d "$PROJECT_PATH/.git" ]; then
    GIT_AVAILABLE=true
    PROJECT_NAME=$(basename "$(git -C "$PROJECT_PATH" rev-parse --show-toplevel)")
else
    # Not a git repository - check if git is required
    if is_git_required; then
        echo -e "${RED}Error: $PROJECT_PATH is not a git repository${NC}"
        echo "Git is required by configuration. Either:"
        echo "  1. Initialize git: cd $PROJECT_PATH && git init"
        echo "  2. Disable git requirement: ai-use-case config set-git-required false"
        exit 1
    else
        # Git not required - use directory name
        PROJECT_NAME=$(basename "$PROJECT_PATH")
        echo -e "${YELLOW}⚠${NC} Project is not a git repository - git features will be disabled"
        echo -e "${BLUE}ℹ${NC} To enable git features: cd $PROJECT_PATH && git init"
    fi
fi

echo -e "${BLUE}=== AI Use Cases Project Setup ===${NC}"
echo "Project: $PROJECT_NAME"
echo "Path: $PROJECT_PATH"
echo ""

# Initialize progress tracking
if [ "$PROGRESS_ENABLED" = true ]; then
    if [ "$UPDATE_MODE" = true ]; then
        if [ "$GIT_AVAILABLE" = true ]; then
            progress_init \
                "Validate project structure" \
                "Update AI tool slash commands" \
                "Update git hooks" \
                "Verify configuration"
        else
            progress_init \
                "Validate project structure" \
                "Update AI tool slash commands" \
                "Verify configuration"
        fi
    else
        if [ "$GIT_AVAILABLE" = true ]; then
            progress_init \
                "Validate project structure" \
                "Setup use case directory" \
                "Install AI tool slash commands" \
                "Install git hooks" \
                "Configure .gitignore" \
                "Perform initial sync" \
                "Register project"
        else
            progress_init \
                "Validate project structure" \
                "Setup use case directory" \
                "Install AI tool slash commands" \
                "Perform initial sync" \
                "Register project"
        fi
    fi
fi

# Validate environment configuration
[ "$PROGRESS_ENABLED" = true ] && progress_start "Validate project structure"

if [ -z "$AI_USECASES_SYNC_SCRIPT" ]; then
    echo -e "${YELLOW}⚠ Warning: AI_USECASES_SYNC_SCRIPT environment variable not set${NC}"
    echo -e "${BLUE}ℹ${NC} Post-commit hooks may not work correctly after repository separation"
    echo -e "${BLUE}ℹ${NC} Add to your shell profile (~/.bashrc or ~/.zshrc):"
    echo -e "${CYAN}export AI_USECASES_SYNC_SCRIPT=\"$CLI_ROOT/scripts/core/sync-ai-use-cases.sh\"${NC}"
    echo ""
fi

[ "$PROGRESS_ENABLED" = true ] && progress_complete "Validate project structure"

# Check for old structure and migrate if needed
[ "$PROGRESS_ENABLED" = true ] && [ "$UPDATE_MODE" = false ] && progress_start "Setup use case directory"
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

[ "$PROGRESS_ENABLED" = true ] && [ "$UPDATE_MODE" = false ] && progress_complete "Setup use case directory"

# Install AI tool slash commands (Claude Code, GitHub Copilot, etc.)
if [ "$PROGRESS_ENABLED" = true ]; then
    if [ "$UPDATE_MODE" = true ]; then
        progress_start "Update AI tool slash commands"
    else
        progress_start "Install AI tool slash commands"
    fi
fi
AI_COMMANDS_SOURCE="$CLI_ROOT/.ai-tools/commands/use-case"
AI_COMMANDS_DIR="$PROJECT_PATH/.ai-tools/commands/use-case"

if [ -d "$AI_COMMANDS_SOURCE" ]; then
    if [ ! -d "$AI_COMMANDS_DIR" ]; then
        mkdir -p "$AI_COMMANDS_DIR"
        echo -e "${GREEN}✓${NC} Created: .ai-tools/commands/use-case/"
    fi

    # Check if advanced features are enabled (v3.13.0+)
    ADVANCED_ENABLED=false
    if type is_advanced_enabled >/dev/null 2>&1 && is_advanced_enabled; then
        ADVANCED_ENABLED=true
    fi

    # Load manifest for command categorization
    MANIFEST_FILE="$AI_COMMANDS_SOURCE/manifest.json"

    # Helper function to check if command is advanced
    is_advanced_command() {
        local cmd_name="$1"
        local cmd_basename="${cmd_name%.md}"

        # If manifest exists and jq is available, use it
        if [ -f "$MANIFEST_FILE" ] && command -v jq >/dev/null 2>&1; then
            local category=$(jq -r ".commands[\"$cmd_basename\"].category // \"core\"" "$MANIFEST_FILE" 2>/dev/null)
            [ "$category" = "advanced" ]
            return $?
        fi

        # Fallback: hardcoded list of advanced commands
        case "$cmd_basename" in
            analyze-patterns|review-quality|extract-session)
                return 0  # true - is advanced
                ;;
            *)
                return 1  # false - is core
                ;;
        esac
    }

    # Copy command files based on mode
    COMMANDS_COPIED=0
    COMMANDS_UPDATED=0
    COMMANDS_SKIPPED=0
    for cmd_file in "$AI_COMMANDS_SOURCE"/*.md; do
        if [ -f "$cmd_file" ]; then
            cmd_name=$(basename "$cmd_file")
            target_file="$AI_COMMANDS_DIR/$cmd_name"

            # Skip if source and target are the same file (self-setup scenario)
            if [ "$cmd_file" -ef "$target_file" ]; then
                continue
            fi

            # Check if this is an advanced command
            if is_advanced_command "$cmd_name" && [ "$ADVANCED_ENABLED" = false ]; then
                # Skip advanced commands when advanced features are disabled
                # (existing advanced commands remain but are not updated)
                COMMANDS_SKIPPED=$((COMMANDS_SKIPPED + 1))
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

    # Copy manifest file as well (for reference)
    if [ -f "$MANIFEST_FILE" ]; then
        cp "$MANIFEST_FILE" "$AI_COMMANDS_DIR/"
    fi

    if [ $COMMANDS_COPIED -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Installed $COMMANDS_COPIED AI tool slash command(s)"
    fi
    if [ $COMMANDS_UPDATED -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Updated $COMMANDS_UPDATED AI tool slash command(s)"
    fi
    if [ $COMMANDS_SKIPPED -gt 0 ]; then
        echo -e "${BLUE}ℹ${NC} $COMMANDS_SKIPPED advanced command(s) available with '${CYAN}ai-use-case enable-advanced${NC}'"
    fi
    if [ $COMMANDS_COPIED -eq 0 ] && [ $COMMANDS_UPDATED -eq 0 ] && [ $COMMANDS_SKIPPED -eq 0 ]; then
        echo -e "${YELLOW}⚠${NC} AI tool slash commands already installed (use --update to refresh)"
    fi

    # Create symlink for Claude Code compatibility
    # Claude Code only discovers commands in .claude/commands/, not .ai-tools/commands/
    # We symlink only the use-case subdirectory to preserve any custom user commands
    CLAUDE_DIR="$PROJECT_PATH/.claude"
    CLAUDE_COMMANDS_DIR="$PROJECT_PATH/.claude/commands"
    CLAUDE_USECASE_SYMLINK="$CLAUDE_COMMANDS_DIR/use-case"
    EXPECTED_LINK_TARGET="../../.ai-tools/commands/use-case"

    # Check if .claude folder exists before creating symlinks
    if [ -d "$CLAUDE_DIR" ] || [ -L "$CLAUDE_COMMANDS_DIR" ]; then
        # Migrate from old full-directory symlink structure (if needed)
        if [ -L "$CLAUDE_COMMANDS_DIR" ]; then
            OLD_TARGET=$(readlink "$CLAUDE_COMMANDS_DIR")
            echo -e "${BLUE}Detected old symlink structure: .claude/commands → $OLD_TARGET${NC}"
            echo -e "${BLUE}Migrating to new subdirectory symlink structure...${NC}"

            # Remove old symlink
            rm "$CLAUDE_COMMANDS_DIR"
            echo -e "${GREEN}✓${NC} Removed old full-directory symlink"

            # Create new directory structure (will be created below)
            echo -e "${GREEN}✓${NC} Migration prepared - will create new structure"
        fi

        # Ensure .claude/commands/ directory exists
        if [ ! -d "$CLAUDE_COMMANDS_DIR" ]; then
            mkdir -p "$CLAUDE_COMMANDS_DIR"
            echo -e "${GREEN}✓${NC} Created: .claude/commands/"
        fi

        # Create or verify use-case symlink
        if [ ! -e "$CLAUDE_USECASE_SYMLINK" ]; then
            ln -s "$EXPECTED_LINK_TARGET" "$CLAUDE_USECASE_SYMLINK"
            echo -e "${GREEN}✓${NC} Created Claude Code symlink: .claude/commands/use-case → .ai-tools/commands/use-case"
        elif [ ! -L "$CLAUDE_USECASE_SYMLINK" ]; then
            echo -e "${YELLOW}⚠${NC} .claude/commands/use-case exists but is not a symlink"
            echo -e "${YELLOW}⚠${NC} To enable command syncing, remove it and run: ai-use-case --init --update"
        else
            # Symlink exists, verify it points to the right place
            LINK_TARGET=$(readlink "$CLAUDE_USECASE_SYMLINK")
            if [ "$LINK_TARGET" = "$EXPECTED_LINK_TARGET" ]; then
                echo -e "${GREEN}✓${NC} Claude Code symlink already configured"
            else
                echo -e "${YELLOW}⚠${NC} Claude Code symlink points to: $LINK_TARGET (expected: $EXPECTED_LINK_TARGET)"
            fi
        fi
    else
        # .claude folder doesn't exist - skip symlink creation and inform user
        echo -e "${BLUE}ℹ${NC} .claude folder not found - skipping Claude Code symlink creation"
        echo -e "${BLUE}ℹ${NC} Run '${GREEN}ai-use-case --link-claude${NC}' after setting up Claude Code to create symlinks"
    fi
else
    echo -e "${YELLOW}⚠${NC} AI tool commands not found in CLI installation"
fi

if [ "$PROGRESS_ENABLED" = true ]; then
    if [ "$UPDATE_MODE" = true ]; then
        progress_complete "Update AI tool slash commands"
    else
        progress_complete "Install AI tool slash commands"
    fi
fi

# Install git hooks (only if git is available)
if [ "$GIT_AVAILABLE" = true ]; then
    if [ "$PROGRESS_ENABLED" = true ]; then
        if [ "$UPDATE_MODE" = true ]; then
            progress_start "Update git hooks"
        else
            progress_start "Install git hooks"
        fi
    fi
    GIT_HOOKS_DIR="$PROJECT_PATH/.git/hooks"
    POST_COMMIT_HOOK="$GIT_HOOKS_DIR/post-commit"
    PRE_COMMIT_HOOK="$GIT_HOOKS_DIR/pre-commit"

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
                # Check if existing hook is identical to our source (no customizations)
                if cmp -s "$POST_COMMIT_HOOK" "$POST_COMMIT_HOOK_SOURCE"; then
                    # Safe to replace - hook contains only our code
                    cp "$POST_COMMIT_HOOK_SOURCE" "$POST_COMMIT_HOOK"
                    chmod +x "$POST_COMMIT_HOOK"
                    echo -e "${GREEN}✓${NC} Git post-commit hook updated"
                else
                    # Hook has customizations - do not overwrite
                    echo -e "${YELLOW}⚠${NC} Git post-commit hook contains customizations"
                    echo -e "${YELLOW}⚠${NC} Update skipped to preserve your changes"
                    echo -e "${BLUE}ℹ${NC} To manually update: compare your hook with $POST_COMMIT_HOOK_SOURCE"
                fi
            else
                echo -e "${YELLOW}⚠${NC} Git post-commit hook already installed (use --update to refresh)"
            fi
        else
            # Append our hook to existing hook
            echo -e "${BLUE}ℹ${NC} Existing post-commit hook detected - appending our hook"
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
                # Check if existing hook is identical to our source (no customizations)
                if cmp -s "$PRE_COMMIT_HOOK" "$PRE_COMMIT_HOOK_SOURCE"; then
                    # Safe to replace - hook contains only our code
                    cp "$PRE_COMMIT_HOOK_SOURCE" "$PRE_COMMIT_HOOK"
                    chmod +x "$PRE_COMMIT_HOOK"
                    echo -e "${GREEN}✓${NC} Git pre-commit hook updated"
                else
                    # Hook has customizations - do not overwrite
                    echo -e "${YELLOW}⚠${NC} Git pre-commit hook contains customizations"
                    echo -e "${YELLOW}⚠${NC} Update skipped to preserve your changes"
                    echo -e "${BLUE}ℹ${NC} To manually update: compare your hook with $PRE_COMMIT_HOOK_SOURCE"
                fi
            else
                echo -e "${YELLOW}⚠${NC} Git pre-commit hook already installed (use --update to refresh)"
            fi
        else
            # Append our hook to existing hook
            echo -e "${BLUE}ℹ${NC} Existing pre-commit hook detected - appending our hook"
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

    # Install Claude Code SessionEnd hook
    CLAUDE_HOOKS_DIR=".claude/hooks"
    mkdir -p "$CLAUDE_HOOKS_DIR"
    SESSION_END_HOOK="$CLAUDE_HOOKS_DIR/SessionEnd"

    if [ -f "$SESSION_END_HOOK_SOURCE" ]; then
        if [ -f "$SESSION_END_HOOK" ]; then
            # Check if existing hook matches our template
            if cmp -s "$SESSION_END_HOOK" "$SESSION_END_HOOK_SOURCE"; then
                if [ "$VERBOSE" = true ]; then
                    echo -e "${GREEN}✓${NC} Claude Code SessionEnd hook already up-to-date"
                fi
            else
                # Backup existing hook if it has customizations
                if [ "$UPDATE_MODE" = true ]; then
                    echo -e "${YELLOW}⚠${NC} Claude Code SessionEnd hook contains customizations"
                    echo -e "  ${YELLOW}→${NC} Backup created at: $SESSION_END_HOOK.backup"
                    cp "$SESSION_END_HOOK" "$SESSION_END_HOOK.backup"
                    cp "$SESSION_END_HOOK_SOURCE" "$SESSION_END_HOOK"
                    chmod +x "$SESSION_END_HOOK"
                    echo -e "${GREEN}✓${NC} Claude Code SessionEnd hook updated"
                else
                    echo -e "${YELLOW}⚠${NC} Claude Code SessionEnd hook differs from template"
                fi
            fi
        else
            # Install fresh hook
            cp "$SESSION_END_HOOK_SOURCE" "$SESSION_END_HOOK"
            chmod +x "$SESSION_END_HOOK"
            echo -e "${GREEN}✓${NC} Claude Code SessionEnd hook installed"
        fi
    else
        if [ "$VERBOSE" = true ]; then
            echo -e "${YELLOW}⚠${NC} Claude Code SessionEnd hook source not found: $SESSION_END_HOOK_SOURCE"
            echo -e "  ${BLUE}ℹ${NC} This feature may not be available in your CLI version"
        fi
    fi

    # Create session stats directory
    mkdir -p ".usecase/session-stats"

    if [ "$PROGRESS_ENABLED" = true ]; then
        if [ "$UPDATE_MODE" = true ]; then
            progress_complete "Update git hooks"
            progress_start "Verify configuration"
            progress_complete "Verify configuration"

            # Show progress summary and exit for UPDATE_MODE
            progress_summary

            echo ""
            echo -e "${GREEN}=== Update Complete! ===${NC}"
            echo ""
            echo "Updated components:"
            echo "  - Claude Code slash commands"
            echo "  - Git hooks"
            echo ""
            exit 0
        else
            progress_complete "Install git hooks"
            progress_start "Configure .gitignore"
        fi
    fi
else
    # Git not available - skip git hooks
    echo -e "${BLUE}ℹ${NC} Skipping git hooks installation (no git repository)"
    if [ "$PROGRESS_ENABLED" = true ]; then
        if [ "$UPDATE_MODE" = true ]; then
            progress_start "Verify configuration"
            progress_complete "Verify configuration"

            # Show progress summary and exit for UPDATE_MODE
            progress_summary

            echo ""
            echo -e "${GREEN}=== Update Complete! ===${NC}"
            echo ""
            echo "Updated components:"
            echo "  - Claude Code slash commands"
            echo ""
            exit 0
        fi
        # No else needed - we don't have Configure .gitignore in non-git mode
    fi
fi

# Add to .gitignore if not already present (only if git is available)
if [ "$GIT_AVAILABLE" = true ]; then
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
        echo ".usecase/" >> "$GITIGNORE"
        echo -e "${GREEN}✓${NC} Added .usecase/ to .gitignore"
    else
        echo -e "${YELLOW}⚠${NC} .gitignore already configured"
    fi
    fi

    [ "$PROGRESS_ENABLED" = true ] && [ "$UPDATE_MODE" = false ] && progress_complete "Configure .gitignore"
else
    # Git not available - skip .gitignore
    echo -e "${BLUE}ℹ${NC} Skipping .gitignore configuration (no git repository)"
fi

# Perform initial sync
[ "$PROGRESS_ENABLED" = true ] && [ "$UPDATE_MODE" = false ] && progress_start "Perform initial sync"
echo ""
echo -e "${BLUE}Performing initial sync...${NC}"
if "$SYNC_SCRIPT" "$PROJECT_PATH"; then
    [ "$PROGRESS_ENABLED" = true ] && [ "$UPDATE_MODE" = false ] && progress_complete "Perform initial sync"
    # Register project in the registry
    [ "$PROGRESS_ENABLED" = true ] && [ "$UPDATE_MODE" = false ] && progress_start "Register project"
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
    [ "$PROGRESS_ENABLED" = true ] && [ "$UPDATE_MODE" = false ] && progress_complete "Register project"

    # Show progress summary
    [ "$PROGRESS_ENABLED" = true ] && progress_summary

    echo ""
    echo -e "${GREEN}=== Setup Complete! ===${NC}"
    echo ""
    echo "What's next?"
    echo "1. Create use case docs in: $AI_USECASES_DIR"
    echo "2. Use format: YYYY-Www-MM-DD_TICKET-XXXXX_description.md"
    if [ "$GIT_AVAILABLE" = true ]; then
        echo "3. Commit changes - use cases will auto-sync!"
    else
        echo "3. Run 'ai-use-case sync' to sync use cases manually"
        echo "   (Auto-sync requires git repository)"
    fi
    echo ""
    echo "Available commands:"
    echo "  ai-use-case document      # Document an AI session"
    echo "  ai-use-case sync          # Manual sync"
    echo "  ai-use-case search <term> # Search use cases"
    echo ""
    if [ -d "$AI_COMMANDS_DIR" ]; then
        echo "AI tool slash commands (Claude Code, GitHub Copilot, etc.):"
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
