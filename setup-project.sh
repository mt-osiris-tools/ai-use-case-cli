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

# Configuration - Auto-detect locations
# SCRIPT_DIR = CLI installation directory (for scripts and hooks)
# CENTRAL_DIR = Documentation hub directory (for storing use cases)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CENTRAL_DIR=$(ensure_hub_exists)
POST_COMMIT_HOOK_SOURCE="$SCRIPT_DIR/git-hooks/post-commit"
PRE_COMMIT_HOOK_SOURCE="$SCRIPT_DIR/git-hooks/pre-commit"
SYNC_SCRIPT="$SCRIPT_DIR/sync-ai-use-cases.sh"

# Show help
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "AI Use Cases Setup Script"
    echo ""
    echo "Usage:"
    echo "  $0 [project_path]"
    echo ""
    echo "Description:"
    echo "  Sets up AI use case documentation automation for a project."
    echo "  Creates docs/ai-use-cases/ directory, installs git hook,"
    echo "  and performs initial sync to central repository."
    echo ""
    echo "Arguments:"
    echo "  project_path    Path to project directory (default: current directory)"
    echo ""
    echo "Examples:"
    echo "  $0                        # Setup current directory"
    echo "  $0 /path/to/project       # Setup specific project"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    exit 0
fi

# Get project path (use provided argument or current directory)
PROJECT_PATH="${1:-$(pwd)}"

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

# Create ai-use-cases directory if it doesn't exist
AI_USECASES_DIR="$PROJECT_PATH/docs/ai-use-cases"
if [ ! -d "$AI_USECASES_DIR" ]; then
    mkdir -p "$AI_USECASES_DIR"
    echo -e "${GREEN}✓${NC} Created: docs/ai-use-cases/"

    # Create a README
    cat > "$AI_USECASES_DIR/README.md" <<EOF
# AI Use Cases

This directory contains documentation of AI-assisted development workflows used in this project.

## Format

Each use case is documented in a markdown file with the following naming convention:
\`\`\`
YYYY-MM-DD_TICKET-XXXXX_brief-description.md
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
    echo -e "${GREEN}✓${NC} Created: docs/ai-use-cases/README.md"
else
    echo -e "${YELLOW}⚠${NC} docs/ai-use-cases/ already exists"
fi

# Install Claude Code slash commands
CLAUDE_COMMANDS_SOURCE="$SCRIPT_DIR/.claude/commands"
CLAUDE_COMMANDS_DIR="$PROJECT_PATH/.claude/commands"

if [ -d "$CLAUDE_COMMANDS_SOURCE" ]; then
    if [ ! -d "$CLAUDE_COMMANDS_DIR" ]; then
        mkdir -p "$CLAUDE_COMMANDS_DIR"
        echo -e "${GREEN}✓${NC} Created: .claude/commands/"
    fi

    # Copy all command files
    COMMANDS_COPIED=0
    for cmd_file in "$CLAUDE_COMMANDS_SOURCE"/*.md; do
        if [ -f "$cmd_file" ]; then
            cmd_name=$(basename "$cmd_file")
            target_file="$CLAUDE_COMMANDS_DIR/$cmd_name"

            if [ ! -f "$target_file" ]; then
                cp "$cmd_file" "$target_file"
                COMMANDS_COPIED=$((COMMANDS_COPIED + 1))
            fi
        fi
    done

    if [ $COMMANDS_COPIED -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Installed $COMMANDS_COPIED Claude Code slash command(s)"
    else
        echo -e "${YELLOW}⚠${NC} Claude Code slash commands already installed"
    fi
else
    echo -e "${YELLOW}⚠${NC} Claude Code commands not found in CLI installation"
fi

# Install git hooks
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
        echo -e "${YELLOW}⚠${NC} Git post-commit hook already installed"
    else
        # Backup existing hook
        BACKUP_HOOK="$POST_COMMIT_HOOK.backup.$(date +%Y%m%d%H%M%S)"
        cp "$POST_COMMIT_HOOK" "$BACKUP_HOOK"
        echo -e "${YELLOW}⚠${NC} Existing post-commit hook backed up to: $(basename "$BACKUP_HOOK")"

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
        echo -e "${YELLOW}⚠${NC} Git pre-commit hook already installed"
    else
        # Backup existing hook
        BACKUP_HOOK="$PRE_COMMIT_HOOK.backup.$(date +%Y%m%d%H%M%S)"
        cp "$PRE_COMMIT_HOOK" "$BACKUP_HOOK"
        echo -e "${YELLOW}⚠${NC} Existing pre-commit hook backed up to: $(basename "$BACKUP_HOOK")"

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
    if ! grep -q "^# AI Use Cases - ignore local notes" "$GITIGNORE"; then
        echo "" >> "$GITIGNORE"
        echo "# AI Use Cases - ignore local notes" >> "$GITIGNORE"
        echo "docs/ai-use-cases/*.draft.md" >> "$GITIGNORE"
        echo "docs/ai-use-cases/*.local.md" >> "$GITIGNORE"
        echo -e "${GREEN}✓${NC} Added AI use cases patterns to .gitignore"
    else
        echo -e "${YELLOW}⚠${NC} .gitignore already configured"
    fi
fi

# Perform initial sync
echo ""
echo -e "${BLUE}Performing initial sync...${NC}"
if "$SYNC_SCRIPT" "$PROJECT_PATH"; then
    echo ""
    echo -e "${GREEN}=== Setup Complete! ===${NC}"
    echo ""
    echo "What's next?"
    echo "1. Create AI use case docs in: $AI_USECASES_DIR"
    echo "2. Use format: YYYY-MM-DD_TICKET-XXXXX_description.md"
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
