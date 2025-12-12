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

# Detect CLI installation directory with robust safety checks
CLI_DIR=""

# Method 1: If running from CLI source directory, verify it's actually the CLI
# Requires both the main script AND CLI-specific directories to be present
if [ -f "ai-use-case" ] && [ -d ".git" ] && [ -d "scripts/install" ]; then
    # Additional safety: ensure this is NOT the hub by checking for CLI-specific files
    if [ -f "scripts/install/uninstall.sh" ] && [ -f "scripts/core/sync-ai-use-cases.sh" ]; then
        CLI_DIR="$(pwd)"
    fi
fi

# Method 2: Check standard installation location
if [ -z "$CLI_DIR" ] && [ -d "$HOME/.local/share/ai-use-case-cli" ]; then
    # Verify it's actually a CLI installation by checking for CLI-specific structure
    if [ -f "$HOME/.local/share/ai-use-case-cli/ai-use-case" ] && \
       [ -d "$HOME/.local/share/ai-use-case-cli/scripts/install" ] && \
       [ -f "$HOME/.local/share/ai-use-case-cli/scripts/core/sync-ai-use-cases.sh" ]; then
        CLI_DIR="$HOME/.local/share/ai-use-case-cli"
    fi
fi

# Method 3: Try to determine from symlink (if it exists)
if [ -z "$CLI_DIR" ] && [ -L "$HOME/.local/bin/ai-use-case" ]; then
    # Cross-platform readlink: macOS doesn't support -f flag
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS: Use a while loop to resolve symlinks with infinite loop protection
        SYMLINK_TARGET="$HOME/.local/bin/ai-use-case"
        MAX_SYMLINK_DEPTH=10
        SYMLINK_DEPTH=0

        while [ -L "$SYMLINK_TARGET" ] && [ $SYMLINK_DEPTH -lt $MAX_SYMLINK_DEPTH ]; do
            SYMLINK_DIR="$(dirname "$SYMLINK_TARGET")"
            LINK_VALUE="$(readlink "$SYMLINK_TARGET" 2>/dev/null)"

            # Break if readlink fails or returns empty
            if [ -z "$LINK_VALUE" ]; then
                SYMLINK_TARGET=""
                break
            fi

            # Handle relative symlinks: always resolve relative to the symlink's directory
            case "$LINK_VALUE" in
                /*) SYMLINK_TARGET="$LINK_VALUE" ;;  # absolute path
                *) SYMLINK_TARGET="$SYMLINK_DIR/$LINK_VALUE" ;;
            esac

            SYMLINK_DEPTH=$((SYMLINK_DEPTH + 1))
        done

        # If maximum symlink depth reached, clear SYMLINK_TARGET to avoid using unresolved symlink
        if [ $SYMLINK_DEPTH -ge $MAX_SYMLINK_DEPTH ]; then
            SYMLINK_TARGET=""
        fi
    else
        # Linux/WSL: Use readlink -f
        SYMLINK_TARGET="$(readlink -f "$HOME/.local/bin/ai-use-case" 2>/dev/null)"
    fi

    if [ -n "$SYMLINK_TARGET" ] && [ -f "$SYMLINK_TARGET" ]; then
        # Get the directory containing the ai-use-case script
        POTENTIAL_CLI_DIR="$(dirname "$SYMLINK_TARGET")"
        # Verify this is actually the CLI directory by checking for CLI-specific structure
        if [ -d "$POTENTIAL_CLI_DIR/scripts/install" ] && [ -f "$POTENTIAL_CLI_DIR/scripts/core/sync-ai-use-cases.sh" ]; then
            CLI_DIR="$POTENTIAL_CLI_DIR"
        fi
    fi
fi

# CRITICAL SAFETY CHECK: Never remove directories that look like the hub
# Check if this looks like the hub (has characteristic hub directories)
if [ -n "$CLI_DIR" ] && { [ -d "$CLI_DIR/by-project" ] || [ -d "$CLI_DIR/by-date" ] || [ -d "$CLI_DIR/by-topic" ]; }; then
    echo -e "${RED}╭────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${RED}│${NC}  ${RED}⚠ SAFETY CHECK FAILED${NC}                                  ${RED}│${NC}"
    echo -e "${RED}│${NC}                                                            ${RED}│${NC}"
    echo -e "${RED}│${NC}  Detected directory looks like the documentation hub!     ${RED}│${NC}"
    echo -e "${RED}│${NC}                                                            ${RED}│${NC}"
    echo -e "${RED}│${NC}  ${YELLOW}The hub should NEVER be removed by this script.${NC}        ${RED}│${NC}"
    echo -e "${RED}╰────────────────────────────────────────────────────────────╯${NC}"
    echo -e "${YELLOW}Refusing to remove path:${NC} $CLI_DIR"
    echo ""
    CLI_DIR=""
fi

# Additional safety: Check if path contains "hub" as a directory component (case-insensitive)
if [ -n "$CLI_DIR" ] && [[ "$CLI_DIR" =~ (^|/)[Hh][Uu][Bb](/|$) ]]; then
    echo -e "${YELLOW}⚠ Warning: Path contains 'hub' as a directory component: $CLI_DIR${NC}"
    echo -e "${YELLOW}Please verify this is the CLI directory and not the hub.${NC}"
    read -p "Is this the CLI directory? (y/N): " verify_cli
    if [[ ! "$verify_cli" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Skipping directory removal for safety${NC}"
        CLI_DIR=""
    fi
fi

echo ""
echo "This will:"
echo "  - Remove symlink from ~/.local/bin/"
echo "  - Optionally remove the CLI tools directory"
echo "  - Optionally clean up shell profile entries"
echo ""
echo -e "${YELLOW}Note: This only removes CLI tools. The documentation hub"
echo -e "(at your configured hub location) is separate and will not be touched.${NC}"
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

                # Remove lines related to CLI (cross-platform sed -i)
                if [[ "$(uname)" == "Darwin" ]]; then
                    sed -i '' '/# AI Use Case CLI/d' "$profile" 2>/dev/null || true
                    sed -i '' '/\.local\/bin.*PATH/d' "$profile" 2>/dev/null || true
                else
                    sed -i '/# AI Use Case CLI/d' "$profile" 2>/dev/null || true
                    sed -i '/\.local\/bin.*PATH/d' "$profile" 2>/dev/null || true
                fi

                # Only remove AI_USECASES_DIR if user confirms
                if grep -q "AI_USECASES_DIR" "$profile"; then
                    echo ""
                    echo -e "${YELLOW}Found AI_USECASES_DIR in $profile${NC}"
                    read -p "Remove AI_USECASES_DIR? (y/N): " remove_env
                    if [[ "$remove_env" =~ ^[Yy]$ ]]; then
                        if [[ "$(uname)" == "Darwin" ]]; then
                            sed -i '' '/AI_USECASES_DIR/d' "$profile" 2>/dev/null || true
                            sed -i '' '/# AI Use Case Hub/d' "$profile" 2>/dev/null || true
                        else
                            sed -i '/AI_USECASES_DIR/d' "$profile" 2>/dev/null || true
                            sed -i '/# AI Use Case Hub/d' "$profile" 2>/dev/null || true
                        fi
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
echo "  - Documentation hub at ~/.local/share/ai-use-case-cli/hub (if installed)"
echo "  - Project-level setups (docs/ai-use-cases/ and git hooks in your projects)"
echo ""
echo "To remove the documentation hub separately:"
echo "  rm -rf ~/.local/share/ai-use-case-cli/hub"
echo ""
echo "To reinstall CLI: https://github.com/mt-osiris-tools/ai-use-case-cli"
