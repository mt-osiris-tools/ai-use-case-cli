#!/bin/bash
# Setup GitHub Copilot Custom Prompts Script
# Creates .github/prompts/use-case/ directory with symlinks to CLI prompt templates
#
# Usage:
#   ./setup-copilot.sh [project_path]
#   If no path provided, uses current directory

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get script directory and CLI root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_ROOT="${AI_USECASES_CLI_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# Parse arguments
PROJECT_PATH="${1:-.}"

# Verify directory exists before trying to resolve absolute path
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Directory $PROJECT_PATH does not exist${NC}"
    exit 1
fi

# Resolve to absolute path
PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"

# Define paths
AI_TOOLS_COMMANDS="$PROJECT_PATH/.ai-tools/commands/use-case"
GITHUB_PROMPTS_DIR="$PROJECT_PATH/.github/prompts"
COPILOT_PROMPTS_DIR="$PROJECT_PATH/.github/prompts/use-case"
CLI_COPILOT_PROMPTS="$CLI_ROOT/.github/prompts/use-case"

echo -e "${BLUE}=== Setup GitHub Copilot Custom Prompts ===${NC}"
echo "Project: $PROJECT_PATH"
echo "CLI Root: $CLI_ROOT"
echo ""

# Check if .ai-tools exists (project should be initialized first)
if [ ! -d "$AI_TOOLS_COMMANDS" ]; then
    echo -e "${RED}Error: .ai-tools/commands/use-case/ not found${NC}"
    echo ""
    echo "This project hasn't been set up with ai-use-case yet."
    echo "Please run 'ai-use-case --init' first."
    exit 1
fi

# Check if CLI has Copilot prompts
if [ ! -d "$CLI_COPILOT_PROMPTS" ]; then
    echo -e "${RED}Error: CLI Copilot prompts not found at $CLI_COPILOT_PROMPTS${NC}"
    echo ""
    echo "Please update your ai-use-case-cli installation to get Copilot support."
    exit 1
fi

# Count available Copilot prompts
PROMPT_COUNT=$(find "$CLI_COPILOT_PROMPTS" -name "*.prompt.md" -type f 2>/dev/null | wc -l)
echo -e "${GREEN}✓${NC} Found $PROMPT_COUNT Copilot prompt(s) in CLI"

# Create .github directory if needed
if [ ! -d "$PROJECT_PATH/.github" ]; then
    mkdir -p "$PROJECT_PATH/.github"
    echo -e "${GREEN}✓${NC} Created: .github/"
fi

# Create .github/prompts directory if needed
if [ ! -d "$GITHUB_PROMPTS_DIR" ]; then
    mkdir -p "$GITHUB_PROMPTS_DIR"
    echo -e "${GREEN}✓${NC} Created: .github/prompts/"
fi

# Calculate relative path from .github/prompts/ to CLI installation
# This ensures the symlink works regardless of where the project is located
# Using Python for cross-platform compatibility (macOS doesn't have realpath by default)
RELATIVE_PATH=$(python3 -c "import os; print(os.path.relpath('$CLI_COPILOT_PROMPTS', '$GITHUB_PROMPTS_DIR'))")

# Create or verify use-case symlink
echo ""
echo "Setting up Copilot prompts symlink..."

if [ ! -e "$COPILOT_PROMPTS_DIR" ]; then
    # Create new symlink
    ln -s "$RELATIVE_PATH" "$COPILOT_PROMPTS_DIR"
    echo -e "${GREEN}✓${NC} Created symlink: .github/prompts/use-case → $RELATIVE_PATH"
elif [ -L "$COPILOT_PROMPTS_DIR" ]; then
    # Symlink exists, verify it points to the right place
    LINK_TARGET=$(readlink "$COPILOT_PROMPTS_DIR")
    if [ "$LINK_TARGET" = "$RELATIVE_PATH" ]; then
        echo -e "${GREEN}✓${NC} Symlink already configured correctly"
    else
        echo -e "${YELLOW}⚠${NC} Symlink exists but points to: $LINK_TARGET"
        echo -e "${YELLOW}⚠${NC} Expected: $RELATIVE_PATH"
        echo ""
        echo "To update, remove the old symlink and re-run this script:"
        echo "  rm $COPILOT_PROMPTS_DIR"
        echo "  ai-use-case --setup-copilot"
    fi
elif [ -d "$COPILOT_PROMPTS_DIR" ]; then
    # Directory exists (not a symlink)
    echo -e "${YELLOW}⚠${NC} .github/prompts/use-case exists as a directory (not a symlink)"
    echo -e "${YELLOW}⚠${NC} To enable automatic updates, remove it and re-run this script:"
    echo "  rm -rf $COPILOT_PROMPTS_DIR"
    echo "  ai-use-case --setup-copilot"
else
    # File exists (not symlink or directory)
    echo -e "${YELLOW}⚠${NC} .github/prompts/use-case exists as a file"
    echo -e "${YELLOW}⚠${NC} Please remove it and re-run this script"
fi

echo ""
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo ""
echo "GitHub Copilot can now use ai-use-case prompts in VS Code."
echo ""
echo "Available commands (invoke in Copilot Chat with /):"

# List available prompts
if [ -L "$COPILOT_PROMPTS_DIR" ] && [ -d "$CLI_COPILOT_PROMPTS" ]; then
    for prompt_file in "$CLI_COPILOT_PROMPTS"/*.prompt.md; do
        if [ -f "$prompt_file" ]; then
            prompt_name=$(basename "$prompt_file" .prompt.md)
            # Extract description from YAML frontmatter
            description=$(sed -n '/^---$/,/^---$/p' "$prompt_file" | grep "^description:" | cut -d':' -f2- | sed 's/^ *//' | head -1)
            echo "  /use-case:$prompt_name"
            if [ -n "$description" ]; then
                echo "    └─ $description"
            fi
        fi
    done
fi

echo ""
echo "Example usage in VS Code:"
echo "  1. Open GitHub Copilot Chat (Ctrl+Alt+I / Cmd+Alt+I)"
echo "  2. Type: /use-case:document-session"
echo "  3. Follow the interactive prompts"
echo ""
echo -e "${YELLOW}Note:${NC} Copilot prompts are workspace-specific (.github/prompts/)."
echo "Symlinks ensure prompts auto-update when CLI is updated."
echo "You may need to reload VS Code window to detect new prompts."
echo ""
