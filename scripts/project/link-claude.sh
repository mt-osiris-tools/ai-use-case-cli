#!/bin/bash
# Link Claude Code Commands Script
# Creates symlinks in .claude/commands/ to .ai-tools/commands/use-case
#
# Usage:
#   ./link-claude.sh [project_path]
#   If no path provided, uses current directory

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse arguments
PROJECT_PATH="${1:-.}"

# Resolve to absolute path
PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"

# Verify we're in a valid directory
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Directory $PROJECT_PATH does not exist${NC}"
    exit 1
fi

# Define paths
AI_TOOLS_COMMANDS="$PROJECT_PATH/.ai-tools/commands/use-case"
CLAUDE_DIR="$PROJECT_PATH/.claude"
CLAUDE_COMMANDS_DIR="$PROJECT_PATH/.claude/commands"
CLAUDE_USECASE_SYMLINK="$CLAUDE_COMMANDS_DIR/use-case"
EXPECTED_LINK_TARGET="../../.ai-tools/commands/use-case"

echo -e "${BLUE}=== Link Claude Code Commands ===${NC}"
echo "Project: $PROJECT_PATH"
echo ""

# Check if .ai-tools exists
if [ ! -d "$AI_TOOLS_COMMANDS" ]; then
    echo -e "${RED}Error: .ai-tools/commands/use-case/ not found${NC}"
    echo ""
    echo "This project hasn't been set up with ai-use-case yet."
    echo "Please run 'ai-use-case --init' first."
    exit 1
fi

# Count command files
COMMAND_COUNT=$(find "$AI_TOOLS_COMMANDS" -name "*.md" -type f 2>/dev/null | wc -l)
echo -e "${GREEN}✓${NC} Found .ai-tools/commands/use-case/ with $COMMAND_COUNT command(s)"

# Create .claude directory if needed
if [ ! -d "$CLAUDE_DIR" ]; then
    mkdir -p "$CLAUDE_DIR"
    echo -e "${GREEN}✓${NC} Created: .claude/"
fi

# Create .claude/commands directory if needed
if [ ! -d "$CLAUDE_COMMANDS_DIR" ]; then
    mkdir -p "$CLAUDE_COMMANDS_DIR"
    echo -e "${GREEN}✓${NC} Created: .claude/commands/"
fi

# Handle symlink creation
# Note: Check for symlink first (-L) because -e returns false for broken symlinks
if [ -L "$CLAUDE_USECASE_SYMLINK" ]; then
    # It's a symlink - check if it points to the right place
    LINK_TARGET=$(readlink "$CLAUDE_USECASE_SYMLINK")
    if [ "$LINK_TARGET" = "$EXPECTED_LINK_TARGET" ]; then
        echo -e "${GREEN}✓${NC} Symlink already exists and points to correct location"
    else
        echo -e "${YELLOW}⚠${NC} Symlink exists but points to: $LINK_TARGET"
        echo -e "${YELLOW}⚠${NC} Expected: $EXPECTED_LINK_TARGET"
        echo ""
        echo "To fix this, remove the existing symlink and run this command again:"
        echo "  rm $CLAUDE_USECASE_SYMLINK"
        echo "  ai-use-case --link-claude"
        exit 1
    fi
elif [ -e "$CLAUDE_USECASE_SYMLINK" ]; then
    # It exists but is not a symlink (it's a directory or file)
    echo -e "${YELLOW}⚠${NC} .claude/commands/use-case exists but is not a symlink"
    echo ""
    echo "This may be a directory with custom commands or a file."
    echo "Please review and remove it manually if you want to use the symlink:"
    echo "  rm -rf $CLAUDE_USECASE_SYMLINK"
    echo "  ai-use-case --link-claude"
    exit 1
else
    # Create the symlink
    ln -s "$EXPECTED_LINK_TARGET" "$CLAUDE_USECASE_SYMLINK"
    echo -e "${GREEN}✓${NC} Created symlink: .claude/commands/use-case → .ai-tools/commands/use-case"
fi

echo ""
echo -e "${GREEN}=== Link Complete! ===${NC}"
echo ""
echo "Claude Code can now discover the ai-use-case slash commands."
echo "Available commands:"
if compgen -G "$AI_TOOLS_COMMANDS"/*.md > /dev/null; then
    for cmd_file in "$AI_TOOLS_COMMANDS"/*.md; do
        if [ -f "$cmd_file" ]; then
            cmd_name=$(basename "$cmd_file" .md)
            echo "  /use-case:$cmd_name"
        fi
    done
else
    echo "  (No commands found)"
fi
echo ""
