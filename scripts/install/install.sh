#!/bin/bash
# AI Use Case CLI - Installation Script
#
# Quick install:
#   curl -fsSL https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/scripts/install/install.sh | bash
#
# Or manual:
#   git clone https://github.com/mt-osiris-tools/ai-use-case-cli.git ~/.local/share/ai-use-case-cli
#   cd ~/.local/share/ai-use-case-cli
#   scripts/install/install.sh

set -e

# Color definitions
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m' # No Color

# Parse installation flags
INSTALL_MODE=""  # Will be set during installation: "light" or "full"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --full)
            INSTALL_MODE="full"
            shift
            ;;
        --light)
            INSTALL_MODE="light"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Function to get remote version from version.sh (single source of truth)
get_remote_version() {
    local remote_version=""
    if command -v curl &> /dev/null; then
        remote_version=$(curl -s -m 2 https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/scripts/utils/version.sh 2>/dev/null | grep '^export CLI_VERSION=' | head -1 | cut -d'"' -f2)
    elif command -v wget &> /dev/null; then
        remote_version=$(wget -qO- -T 2 https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/scripts/utils/version.sh 2>/dev/null | grep '^export CLI_VERSION=' | head -1 | cut -d'"' -f2)
    fi
    echo "$remote_version"
}

# Function to get installed version from version.sh (single source of truth)
get_installed_version() {
    local install_dir="$HOME/.local/share/ai-use-case-cli"
    if [ -f "$install_dir/scripts/utils/version.sh" ]; then
        (source "$install_dir/scripts/utils/version.sh" && echo "$CLI_VERSION")
    else
        echo ""
    fi
}

# Get version info
REMOTE_VERSION=$(get_remote_version)
INSTALLED_VERSION=$(get_installed_version)

# Function to print the banner (can be called multiple times to refresh)
print_banner() {
    cat <<EOF
${CYAN}
 █████╗ ██╗    ██╗   ██╗███████╗███████╗     ██████╗ █████╗ ███████╗███████╗
██╔══██╗██║    ██║   ██║██╔════╝██╔════╝    ██╔════╝██╔══██╗██╔════╝██╔════╝
███████║██║    ██║   ██║███████╗█████╗█████╗██║     ███████║███████╗█████╗
██╔══██║██║    ██║   ██║╚════██║██╔══╝╚════╝██║     ██╔══██║╚════██║██╔══╝
██║  ██║██║    ╚██████╔╝███████║███████╗    ╚██████╗██║  ██║███████║███████╗
╚═╝  ╚═╝╚═╝     ╚═════╝ ╚══════╝╚══════╝     ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝
${NC}
${YELLOW}           Reduce documentation overhead, build knowledge${NC}
${GREEN}        ═══════════════════════════════════════════════════════${NC}

EOF

    # Display version info
    if [ -n "$REMOTE_VERSION" ]; then
        if [ -n "$INSTALLED_VERSION" ]; then
            echo -e "${YELLOW}        Installing version: ${GREEN}v$REMOTE_VERSION${NC} ${YELLOW}(current: ${CYAN}v$INSTALLED_VERSION${YELLOW})${NC}"
        else
            echo -e "${YELLOW}        Installing version: ${GREEN}v$REMOTE_VERSION${NC}"
        fi
    else
        echo -e "${YELLOW}        AI Use Case CLI - Installation${NC}"
    fi

    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Clear screen and print banner at top
clear
print_banner

# Determine install directory
if [ -f "ai-use-case" ] && [ -d ".git" ]; then
    # Already in the repository
    INSTALL_DIR="$(pwd)"
    echo -e "${GREEN}✓${NC} Detected existing repository"
else
    # Need to clone or update
    INSTALL_DIR="$HOME/.local/share/ai-use-case-cli"

    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}Repository already exists at $INSTALL_DIR${NC}"

        # Check if it's a git repository
        if [ -d "$INSTALL_DIR/.git" ]; then
            # Check if update is needed
            if [ -n "$REMOTE_VERSION" ] && [ -n "$INSTALLED_VERSION" ]; then
                if [ "$REMOTE_VERSION" != "$INSTALLED_VERSION" ]; then
                    echo -e "${BLUE}Update available: v$INSTALLED_VERSION → v$REMOTE_VERSION${NC}"
                    read -p "Update now? (Y/n): " update_choice
                    update_choice=${update_choice:-y}

                    if [[ "$update_choice" =~ ^[Yy]$ ]]; then
                        echo -e "${CYAN}Updating repository...${NC}"
                        cd "$INSTALL_DIR"

                        # Check for local changes
                        if ! git diff-index --quiet HEAD --; then
                            echo -e "${YELLOW}Local modifications detected, handling automatically...${NC}"

                            # Check if changes are only permission changes
                            TOTAL_CHANGES=$(git diff HEAD --numstat | wc -l)
                            PERMISSION_ONLY_CHANGES=$(git diff HEAD --numstat | awk '$1 == "0" && $2 == "0" {print}' | wc -l)

                            if [ "$TOTAL_CHANGES" -gt 0 ] && [ "$TOTAL_CHANGES" -eq "$PERMISSION_ONLY_CHANGES" ]; then
                                # Only permission changes, safe to discard
                                echo -e "${CYAN}Discarding permission-only changes...${NC}"
                                git reset --hard HEAD
                            else
                                # Content changes exist, stash them
                                echo -e "${CYAN}Stashing local changes...${NC}"
                                if ! git stash push -m "Auto-stash during update" 2>/dev/null; then
                                    echo -e "${RED}✗ Failed to stash local changes. Cannot safely update repository.${NC}"
                                    echo "Please resolve your local changes manually before updating."
                                    echo "  cd $INSTALL_DIR && git status"
                                    exit 1
                                fi
                            fi
                        fi

                        # Attempt to pull updates
                        if git pull origin main 2>/dev/null || git pull origin master 2>/dev/null; then
                            echo -e "${GREEN}✓${NC} Repository updated successfully"

                            # Check if there are stashed changes to re-apply
                            if git stash list | head -1 | grep -q "Auto-stash during update"; then
                                echo -e "${CYAN}Re-applying your local changes...${NC}"
                                if git stash apply 2>/dev/null; then
                                    # Successfully applied, drop the stash
                                    git stash drop "$(git stash list | grep "Auto-stash during update" | head -1 | cut -d: -f1)" 2>/dev/null
                                    echo -e "${GREEN}✓${NC} Local changes restored"
                                else
                                    echo -e "${YELLOW}⚠ Merge conflicts detected while restoring your changes${NC}"
                                    echo "Your changes are still preserved in the stash: git stash list"
                                    echo "Resolve conflicts in the files marked with <<<<<<<, =======, >>>>>>>"
                                    echo "After resolving, you can run:"
                                    echo "  git add <conflicted-files>"
                                    echo "  git stash drop \"\$(git stash list | grep 'Auto-stash during update' | head -1 | cut -d: -f1)\""
                                    echo "Or, if you want to abort the merge and restore the previous state:"
                                    echo "  git reset --hard"
                                    echo "  git stash apply"
                                fi
                            fi
                        else
                            echo -e "${RED}✗ Failed to update repository${NC}"
                            echo "You may need to update manually:"
                            echo "  cd $INSTALL_DIR && git status"
                            echo "  cd $INSTALL_DIR && git pull"
                            exit 1
                        fi
                    else
                        echo -e "${YELLOW}Skipping update, continuing with current version${NC}"
                        cd "$INSTALL_DIR"
                    fi
                else
                    echo -e "${GREEN}✓${NC} Already up to date (v$INSTALLED_VERSION)"
                    cd "$INSTALL_DIR"
                fi
            else
                # Can't determine versions, ask user
                read -p "Reinstall? (y/N): " reinstall
                if [[ "$reinstall" =~ ^[Yy]$ ]]; then
                    rm -rf "$INSTALL_DIR"
                    echo -e "${CYAN}Cloning repository...${NC}"
                    mkdir -p "$(dirname "$INSTALL_DIR")"
                    git clone https://github.com/mt-osiris-tools/ai-use-case-cli.git "$INSTALL_DIR"
                    cd "$INSTALL_DIR"
                else
                    echo -e "${YELLOW}Continuing with existing installation${NC}"
                    cd "$INSTALL_DIR"
                fi
            fi
        else
            # Not a git repo, offer to reinstall
            echo -e "${YELLOW}Warning: Not a git repository${NC}"
            read -p "Reinstall? (y/N): " reinstall
            if [[ "$reinstall" =~ ^[Yy]$ ]]; then
                rm -rf "$INSTALL_DIR"
                echo -e "${CYAN}Cloning repository...${NC}"
                mkdir -p "$(dirname "$INSTALL_DIR")"
                git clone https://github.com/mt-osiris-tools/ai-use-case-cli.git "$INSTALL_DIR"
                cd "$INSTALL_DIR"
            else
                echo "Installation cancelled"
                exit 0
            fi
        fi
    else
        # Fresh install
        echo -e "${CYAN}Cloning repository...${NC}"
        mkdir -p "$(dirname "$INSTALL_DIR")"
        git clone https://github.com/mt-osiris-tools/ai-use-case-cli.git "$INSTALL_DIR"
        cd "$INSTALL_DIR"
    fi
fi

# Refresh banner after git operations
clear
print_banner
echo -e "${BLUE}=== Installation ===${NC}"
echo "Install directory: $INSTALL_DIR"
echo ""

# Make scripts executable
echo -e "${CYAN}Making scripts executable...${NC}"
chmod +x ai-use-case
# Make all scripts in subdirectories executable
find scripts -name "*.sh" -type f -exec chmod +x {} \;
echo -e "${GREEN}✓${NC} Scripts are executable"

# Create symlink in user's bin directory
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

if [ -L "$BIN_DIR/ai-use-case" ]; then
    rm "$BIN_DIR/ai-use-case"
fi

ln -s "$INSTALL_DIR/ai-use-case" "$BIN_DIR/ai-use-case"
echo -e "${GREEN}✓${NC} Symlink created: $BIN_DIR/ai-use-case"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo ""
    echo -e "${YELLOW}⚠ $HOME/.local/bin is not in your PATH${NC}"
    echo ""
    echo "Add this to your shell profile (~/.bashrc or ~/.zshrc):"
    echo -e "${CYAN}"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    echo -e "${NC}"

    read -p "Add to ~/.bashrc now? (Y/n): " add_to_path
    add_to_path=${add_to_path:-y}

    if [[ "$add_to_path" =~ ^[Yy]$ ]]; then
        if [ -f "$HOME/.bashrc" ]; then
            echo '' >> "$HOME/.bashrc"
            echo '# AI Use Case CLI' >> "$HOME/.bashrc"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
            echo -e "${GREEN}✓${NC} Added to ~/.bashrc"
            echo -e "Run: ${CYAN}source ~/.bashrc${NC} to apply"
        else
            echo -e "${YELLOW}~/.bashrc not found, please add manually${NC}"
        fi
    fi
fi

# Installation Mode Selection (v3.13.0+)
echo ""
echo -e "${YELLOW}Installation Mode:${NC}"
echo ""

# Only prompt if mode wasn't set via command line flag
if [ -z "$INSTALL_MODE" ]; then
    echo "Choose how much functionality to install:"
    echo ""
    echo -e "  ${GREEN}1${NC}. Light (recommended) - Core documentation features"
    echo "     Document AI sessions and publish to Confluence"
    echo "     Simpler experience, fewer commands to learn"
    echo ""
    echo -e "  ${GREEN}2${NC}. Full - All features including advanced tools"
    echo "     Agents, pattern analysis, tracing, data extraction"
    echo "     For power users who want everything"
    echo ""

    read -p "Select mode (1-2) [1]: " mode_choice
    mode_choice=${mode_choice:-1}

    case "$mode_choice" in
        2)
            INSTALL_MODE="full"
            echo -e "${CYAN}Full installation selected${NC}"
            ;;
        *)
            INSTALL_MODE="light"
            echo -e "${CYAN}Light installation selected${NC}"
            ;;
    esac
else
    echo -e "Installation mode: ${CYAN}$INSTALL_MODE${NC} (from command line)"
fi

echo ""
echo -e "${BLUE}Note:${NC} You can change modes later with:"
echo "  ${CYAN}ai-use-case enable-advanced${NC}   Enable all features"
echo "  ${CYAN}ai-use-case disable-advanced${NC}  Hide advanced features"
echo ""

# Documentation Hub Configuration (v3.2.0+)
echo -e "${YELLOW}Documentation Hub Configuration:${NC}"
echo ""
echo "The CLI uses a flexible hub system (v3.2.0+) with two modes:"
echo "  ${GREEN}1. Local Only${NC} (default) - No git, stored in ~/.local/share/ai-use-case-cli/hub/"
echo "  ${GREEN}2. Private Git${NC} - Your own repository with full version control"
echo ""
echo -e "${CYAN}✓${NC} Default hub will be created automatically (local-only mode)"
echo "  You can configure it later with: ${CYAN}ai-use-case config reconfigure${NC}"
echo ""
echo -e "${BLUE}Note:${NC} No environment variables needed! Hub is configured via:"
echo "  ${CYAN}~/.config/ai-use-case-cli/config.json${NC}"
echo ""

read -p "Would you like to configure hub mode now? (y/N): " config_now
config_now=${config_now:-n}

if [[ "$config_now" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${CYAN}Hub configuration will run after installation completes.${NC}"
    echo "The CLI will guide you through the setup process."
    RUN_CONFIG_AFTER=true
else
    echo -e "${GREEN}✓${NC} Hub will use default local-only mode"
    echo "  Configure later with: ${CYAN}ai-use-case config reconfigure${NC}"
    RUN_CONFIG_AFTER=false
fi

# Run config if requested
if [ "$RUN_CONFIG_AFTER" = true ]; then
    echo ""
    echo -e "${CYAN}Starting hub configuration...${NC}"
    echo ""
    "$INSTALL_DIR/ai-use-case" config reconfigure
    echo ""
fi

# Write installation mode to config (v3.13.0+)
CONFIG_DIR="$HOME/.config/ai-use-case-cli"
CONFIG_FILE="$CONFIG_DIR/config.json"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Determine advancedEnabled based on install mode
ADVANCED_ENABLED="false"
if [ "$INSTALL_MODE" = "full" ]; then
    ADVANCED_ENABLED="true"
fi

# Update or create config with install mode
if command -v jq &> /dev/null && [ -f "$CONFIG_FILE" ]; then
    # Use jq if available to update existing config
    TEMP_FILE=$(mktemp)
    trap "rm -f '$TEMP_FILE'" EXIT

    jq --arg mode "$INSTALL_MODE" --argjson advanced "$ADVANCED_ENABLED" \
        '. + {installMode: $mode, advancedEnabled: $advanced}' "$CONFIG_FILE" > "$TEMP_FILE"

    # Validate output is non-empty and valid JSON before moving
    if [ -s "$TEMP_FILE" ] && jq empty "$TEMP_FILE" 2>/dev/null; then
        mv "$TEMP_FILE" "$CONFIG_FILE"
        trap - EXIT
        echo -e "${GREEN}✓${NC} Installation mode saved to config"
    else
        trap - EXIT
        rm -f "$TEMP_FILE"
    fi
elif [ -f "$CONFIG_FILE" ]; then
    # Fallback: Update or add fields using sed if config exists
    # Cross-platform sed -i (BSD/macOS vs GNU/Linux)

    # Update installMode if present, else add it
    if grep -q '"installMode"' "$CONFIG_FILE"; then
        if [[ "$(uname)" == "Darwin" ]]; then
            sed -i '' 's/"installMode": *"[^"]*"/"installMode": "'"$INSTALL_MODE"'"/' "$CONFIG_FILE"
        else
            sed -i 's/"installMode": *"[^"]*"/"installMode": "'"$INSTALL_MODE"'"/' "$CONFIG_FILE"
        fi
    else
        if [[ "$(uname)" == "Darwin" ]]; then
            sed -i '' 's/}$/,\n  "installMode": "'"$INSTALL_MODE"'"\n}/' "$CONFIG_FILE"
        else
            sed -i 's/}$/,\n  "installMode": "'"$INSTALL_MODE"'"\n}/' "$CONFIG_FILE"
        fi
    fi

    # Update advancedEnabled if present, else add it
    if grep -q '"advancedEnabled"' "$CONFIG_FILE"; then
        if [[ "$(uname)" == "Darwin" ]]; then
            sed -i '' 's/"advancedEnabled": *[a-z]*/"advancedEnabled": '"$ADVANCED_ENABLED"'/' "$CONFIG_FILE"
        else
            sed -i 's/"advancedEnabled": *[a-z]*/"advancedEnabled": '"$ADVANCED_ENABLED"'/' "$CONFIG_FILE"
        fi
    else
        if [[ "$(uname)" == "Darwin" ]]; then
            sed -i '' 's/}$/,\n  "advancedEnabled": '"$ADVANCED_ENABLED"'\n}/' "$CONFIG_FILE"
        else
            sed -i 's/}$/,\n  "advancedEnabled": '"$ADVANCED_ENABLED"'\n}/' "$CONFIG_FILE"
        fi
    fi

    echo -e "${GREEN}✓${NC} Installation mode saved to config"
else
    # Create minimal config if none exists
    cat > "$CONFIG_FILE" <<EOF
{
  "version": "1.0.0",
  "hubMode": "local",
  "hubPath": "$HOME/.local/share/ai-use-case-cli/hub",
  "gitUrl": "",
  "installMode": "$INSTALL_MODE",
  "advancedEnabled": $ADVANCED_ENABLED
}
EOF
    echo -e "${GREEN}✓${NC} Configuration created with $INSTALL_MODE mode"
fi

# Clear and show banner again with completion message
clear
print_banner
echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo -e "Installation mode: ${CYAN}$INSTALL_MODE${NC}"
echo ""
echo -e "${YELLOW}Quick Start:${NC}"
echo -e "  1. Reload your shell: ${CYAN}source ~/.bashrc${NC}"
echo -e "  2. Navigate to a project: ${CYAN}cd /path/to/your-project${NC}"
echo -e "  3. Setup the project: ${CYAN}ai-use-case --init${NC}"
echo -e "  4. Document AI sessions (Claude Code): ${CYAN}/use-case:document-session${NC}"
echo ""
echo -e "${YELLOW}Core Commands:${NC}"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case --init" "Setup current project"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case config show" "Show hub configuration"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case sync" "Sync use cases to hub"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case search <term>" "Search use cases"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case list" "List all registered projects"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case stats" "View statistics"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case status" "Show CLI status"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case publish-confluence" "Publish to Confluence"

# Show advanced commands only in full mode
if [ "$INSTALL_MODE" = "full" ]; then
    echo ""
    echo -e "${YELLOW}Advanced Commands:${NC}"
    printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case agents list" "Manage AI agents"
    printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case review-quality <file>" "Review documentation quality"
    printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case analyze-patterns" "Analyze documentation patterns"
    printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case extract [hours] [format]" "Extract session data"
    printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case tracing init" "Initialize tracing"
else
    echo ""
    echo -e "${YELLOW}More Features:${NC}"
    echo -e "  Run ${CYAN}ai-use-case enable-advanced${NC} to unlock:"
    echo "  - AI agents for quality review and pattern analysis"
    echo "  - Session data extraction for reporting"
    echo "  - OpenTelemetry tracing integration"
fi

echo ""
echo -e "${YELLOW}Claude Code Integration:${NC}"
printf "  ${CYAN}%-40s${NC} %s\n" "/use-case:document-session" "Document AI session (automatic)"
printf "  ${CYAN}%-40s${NC} %s\n" "/use-case:publish-confluence" "Publish to Confluence"
printf "  ${CYAN}%-40s${NC} %s\n" "/use-case:sync-usecases" "Sync to hub"
printf "  ${CYAN}%-40s${NC} %s\n" "/use-case:search-usecases" "Search use cases"
printf "  ${CYAN}%-40s${NC} %s\n" "/use-case:quick-start" "Quick start guide"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  • Run ${CYAN}ai-use-case --help${NC} for full usage guide"
echo -e "  • Run ${CYAN}ai-use-case status${NC} to see your configuration"
echo -e "  • Read ${CYAN}$INSTALL_DIR/README.md${NC} for detailed documentation"
echo ""
echo -e "${BLUE}Happy documenting! 🎉${NC}"
