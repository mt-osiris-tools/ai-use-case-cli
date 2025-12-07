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

# Documentation Hub Configuration (v3.2.0+)
echo ""
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

# Clear and show banner again with completion message
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo ""
clear
print_banner
echo -e "${GREEN}=== Installation Complete! ===${NC}"
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
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case config reconfigure" "Change hub mode (local/git)"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case sync" "Sync use cases to hub"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case search <term>" "Search use cases"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case list" "List all registered projects"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case check-updates" "Check for outdated projects"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case stats" "View statistics"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case extract [hours] [format]" "Extract session data"
echo ""
echo -e "${YELLOW}Advanced Commands:${NC}"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case tracing init" "Initialize tracing (v3.6.0+)"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case tracing configure" "Configure tracing server"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case tracing status" "View tracing status"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case view" "View hub in file explorer"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case push" "Push hub changes (git mode)"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case publish-confluence" "Publish to Confluence"
printf "  ${GREEN}%-40s${NC} %s\n" "ai-use-case uninstall" "Uninstall the CLI"
echo ""
echo -e "${YELLOW}Claude Code Integration (Recommended):${NC}"
printf "  ${CYAN}%-40s${NC} %s\n" "/use-case:document-session" "Document AI session (automatic)"
printf "  ${CYAN}%-40s${NC} %s\n" "/use-case:setup-project" "Setup project"
printf "  ${CYAN}%-40s${NC} %s\n" "/use-case:sync-usecases" "Sync to hub"
printf "  ${CYAN}%-40s${NC} %s\n" "/use-case:list-projects" "List projects"
printf "  ${CYAN}%-40s${NC} %s\n" "/use-case:check-updates" "Check for updates"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  • Run ${CYAN}ai-use-case --help${NC} for full usage guide"
echo -e "  • Read ${CYAN}$INSTALL_DIR/README.md${NC} for detailed documentation"
echo -e "  • Configure hub: ${CYAN}ai-use-case config show${NC}"
echo ""
echo -e "${BLUE}Happy documenting! 🎉${NC}"
