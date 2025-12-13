#!/bin/bash
# Setup Codex CLI Commands Script
# Creates .codex/prompts/ directory with ai-use-case command wrappers
#
# Usage:
#   ./setup-codex.sh [project_path]
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
CODEX_DIR="$HOME/.codex"
CODEX_PROMPTS_DIR="$HOME/.codex/prompts"
CLI_CODEX_PROMPTS="$CLI_ROOT/.codex/prompts"

echo -e "${BLUE}=== Setup Codex CLI Commands ===${NC}"
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

# Check if CLI has Codex prompts
if [ ! -d "$CLI_CODEX_PROMPTS" ]; then
    echo -e "${RED}Error: CLI Codex prompts not found at $CLI_CODEX_PROMPTS${NC}"
    echo ""
    echo "Please update your ai-use-case-cli installation to get Codex support."
    exit 1
fi

# Count available Codex prompts
PROMPT_COUNT=$(find "$CLI_CODEX_PROMPTS" -name "*.md" -type f 2>/dev/null | wc -l)
echo -e "${GREEN}✓${NC} Found $PROMPT_COUNT Codex prompt(s) in CLI"

# Create .codex directory if needed
if [ ! -d "$CODEX_DIR" ]; then
    mkdir -p "$CODEX_DIR"
    echo -e "${GREEN}✓${NC} Created: ~/.codex/"
fi

# Create .codex/prompts directory if needed
if [ ! -d "$CODEX_PROMPTS_DIR" ]; then
    mkdir -p "$CODEX_PROMPTS_DIR"
    echo -e "${GREEN}✓${NC} Created: ~/.codex/prompts/"
fi

# Copy Codex prompt files (with frontmatter, can't use symlinks)
echo ""
echo "Installing Codex prompts..."

# Enable nullglob so glob expands to nothing if no files match
shopt -s nullglob

INSTALLED_COUNT=0
for prompt_file in "$CLI_CODEX_PROMPTS"/*.md; do
    prompt_name=$(basename "$prompt_file")
    target_file="$CODEX_PROMPTS_DIR/$prompt_name"

    if [ -f "$target_file" ]; then
        # Check if files are different
        if ! diff -q "$prompt_file" "$target_file" > /dev/null 2>&1; then
            echo -e "${YELLOW}⚠${NC} Updating: $prompt_name (file changed)"
            cp "$prompt_file" "$target_file"
        else
            echo -e "${GREEN}✓${NC} Already current: $prompt_name"
        fi
    else
        cp "$prompt_file" "$target_file"
        echo -e "${GREEN}✓${NC} Installed: $prompt_name"
    fi
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
done

# Restore default glob behavior
shopt -u nullglob

echo -e "${GREEN}✓${NC} Processed $INSTALLED_COUNT prompt file(s)"

echo ""
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo ""
echo "Codex CLI can now use the ai-use-case prompts."
echo ""
echo "Available commands (invoke in Codex CLI):"
for prompt_file in "$CODEX_PROMPTS_DIR"/*.md; do
    if [ -f "$prompt_file" ]; then
        prompt_name=$(basename "$prompt_file" .md)
        # Extract description from YAML frontmatter at the top of the file
        description=$(sed -n '/^---$/,/^---$/p' "$prompt_file" | grep "^description:" | cut -d':' -f2- | sed 's/^ *//' | head -1)
        echo "  /prompts:$prompt_name"
        if [ -n "$description" ]; then
            echo "    └─ $description"
        fi
    fi
done
echo ""
echo "Example usage:"
echo "  /prompts:use-case-document-session"
echo "  /prompts:use-case-publish-confluence FILE=myfile.md"
echo ""
echo -e "${YELLOW}Note:${NC} Codex prompts are installed in your home directory (~/.codex/prompts/)."
echo "These prompts are available globally across all projects."
echo "You may need to restart Codex CLI to detect new prompts."
echo ""
echo -e "${YELLOW}Migration guidance:${NC} If you previously ran setup-codex, you have old project-local"
echo ".codex/prompts/ directories that are no longer used. Delete them from your project roots"
echo "to avoid confusion."
echo ""
