#!/bin/bash
# AI Use Case CLI - Uninstall Script

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== AI Use Case CLI Uninstaller ===${NC}"
echo ""

# Confirm uninstall
read -p "Are you sure you want to uninstall AI Use Case CLI? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled"
    exit 0
fi

# Detect CLI installation directory
if [ -f "ai-use-case" ] && [ -d ".git" ]; then
    CLI_DIR="$(pwd)"
elif [ -d "$HOME/.local/share/ai-use-case-cli" ]; then
    CLI_DIR="$HOME/.local/share/ai-use-case-cli"
else
    CLI_DIR=""
fi

echo ""
echo "This will:"
echo "  - Remove symlink from ~/.local/bin/"
echo "  - Optionally remove the CLI tools directory"
echo "  - Optionally clean up shell profile entries"
echo ""
echo -e "${YELLOW}Note: This only removes CLI tools. The documentation hub"
echo -e "(~/Documents/ai-use-case-hub) is separate and will not be touched.${NC}"
echo ""

# Remove symlink
if [ -L "$HOME/.local/bin/ai-use-case" ]; then
    rm "$HOME/.local/bin/ai-use-case"
    echo -e "${GREEN}✓${NC} Removed symlink from ~/.local/bin/"
else
    echo -e "${YELLOW}⚠${NC} Symlink not found in ~/.local/bin/"
fi

# Ask about CLI directory
if [ -n "$CLI_DIR" ] && [ -d "$CLI_DIR" ]; then
    echo ""
    read -p "Remove CLI tools directory ($CLI_DIR)? (y/N): " remove_dir
    if [[ "$remove_dir" =~ ^[Yy]$ ]]; then
        rm -rf "$CLI_DIR"
        echo -e "${GREEN}✓${NC} Removed CLI tools directory"
    else
        echo "Keeping CLI tools at: $CLI_DIR"
    fi
else
    echo -e "${YELLOW}⚠${NC} CLI tools directory not found"
fi

# Ask about shell profile cleanup
echo ""
read -p "Remove entries from shell profile? (y/N): " clean_profile
if [[ "$clean_profile" =~ ^[Yy]$ ]]; then
    for profile in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$profile" ]; then
            if grep -qE "AI_USECASES_DIR|AI Use Case CLI|ai-use-case" "$profile"; then
                # Create backup
                cp "$profile" "${profile}.backup"

                # Remove lines related to CLI
                sed -i '/# AI Use Case CLI/d' "$profile" 2>/dev/null || true
                sed -i '/\.local\/bin.*PATH/d' "$profile" 2>/dev/null || true

                # Only remove AI_USECASES_DIR if user confirms
                if grep -q "AI_USECASES_DIR" "$profile"; then
                    echo ""
                    echo -e "${YELLOW}Found AI_USECASES_DIR in $profile${NC}"
                    read -p "Remove AI_USECASES_DIR? (y/N): " remove_env
                    if [[ "$remove_env" =~ ^[Yy]$ ]]; then
                        sed -i '/AI_USECASES_DIR/d' "$profile" 2>/dev/null || true
                        sed -i '/# AI Use Case Hub/d' "$profile" 2>/dev/null || true
                    fi
                fi

                echo -e "${GREEN}✓${NC} Cleaned $(basename "$profile") (backup: ${profile}.backup)"
            fi
        fi
    done
fi

echo ""
echo -e "${GREEN}=== Uninstall Complete ===${NC}"
echo ""
echo "The AI Use Case CLI has been uninstalled."
echo ""
echo -e "${YELLOW}What remains:${NC}"
echo "  - Documentation hub at ~/Documents/ai-use-case-hub (if installed)"
echo "  - Project-level setups (docs/ai-use-cases/ and git hooks in your projects)"
echo ""
echo "To remove the documentation hub separately:"
echo "  rm -rf ~/Documents/ai-use-case-hub"
echo ""
echo "To reinstall CLI: https://github.com/james401/ai-use-case-cli"
