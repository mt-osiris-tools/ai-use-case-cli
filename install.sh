#!/bin/bash
# AI Use Case CLI - Installation Script
#
# Quick install:
#   curl -fsSL https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/install.sh | bash
#
# Or manual:
#   git clone https://github.com/mt-osiris-tools/ai-use-case-cli.git ~/.local/share/ai-use-case-cli
#   cd ~/.local/share/ai-use-case-cli
#   ./install.sh

set -e

# Color definitions
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m' # No Color

# Function to get remote version
get_remote_version() {
    local remote_version=""
    if command -v curl &> /dev/null; then
        remote_version=$(curl -s -m 2 https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/ai-use-case 2>/dev/null | grep '^VERSION=' | head -1 | cut -d'"' -f2)
    elif command -v wget &> /dev/null; then
        remote_version=$(wget -qO- -T 2 https://raw.githubusercontent.com/mt-osiris-tools/ai-use-case-cli/main/ai-use-case 2>/dev/null | grep '^VERSION=' | head -1 | cut -d'"' -f2)
    fi
    echo "$remote_version"
}

# Function to get installed version
get_installed_version() {
    local install_dir="$HOME/.local/share/ai-use-case-cli"
    if [ -f "$install_dir/ai-use-case" ]; then
        grep '^VERSION=' "$install_dir/ai-use-case" 2>/dev/null | head -1 | cut -d'"' -f2
    else
        echo ""
    fi
}

# Get version info
REMOTE_VERSION=$(get_remote_version)
INSTALLED_VERSION=$(get_installed_version)

cat <<EOF
${CYAN}
 █████╗ ██╗    ██╗   ██╗███████╗███████╗     ██████╗ █████╗ ███████╗███████╗
██╔══██╗██║    ██║   ██║██╔════╝██╔════╝    ██╔════╝██╔══██╗██╔════╝██╔════╝
███████║██║    ██║   ██║███████╗█████╗█████╗██║     ███████║███████╗█████╗
██╔══██║██║    ██║   ██║╚════██║██╔══╝╚════╝██║     ██╔══██║╚════██║██╔══╝
██║  ██║██║    ╚██████╔╝███████║███████╗    ╚██████╗██║  ██║███████║███████╗
╚═╝  ╚═╝╚═╝     ╚═════╝ ╚══════╝╚══════╝     ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝
${NC}
${YELLOW}        📊 AI-Assisted Development Session Documentator${NC}
                          Powered by MedTrainer - Osiris${NC}
${GREEN}        ═══════════════════════════════════════════════${NC}

EOF

# Display version info
if [ -n "$REMOTE_VERSION" ]; then
    if [ -n "$INSTALLED_VERSION" ]; then
        echo -e "${YELLOW}        Installing version: ${GREEN}v$REMOTE_VERSION${NC} ${YELLOW}(current: ${CYAN}v$INSTALLED_VERSION${YELLOW})${NC}"
    else
        echo -e "${YELLOW}        Installing version: ${GREEN}v$REMOTE_VERSION${NC}"
    fi
    echo ""
fi
echo -e "${NC}"

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
                        if git pull origin main 2>/dev/null || git pull origin master 2>/dev/null; then
                            echo -e "${GREEN}✓${NC} Repository updated successfully"
                        else
                            echo -e "${RED}✗ Failed to update repository${NC}"
                            echo "You may need to update manually:"
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

echo ""
echo -e "${BLUE}=== Installation ===${NC}"
echo "Install directory: $INSTALL_DIR"
echo ""

# Make scripts executable
echo -e "${CYAN}Making scripts executable...${NC}"
chmod +x ai-use-case
chmod +x setup-project.sh
chmod +x sync-ai-use-cases.sh
chmod +x document-ai-session.sh
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

# Setup documentation hub (optional)
echo ""
echo -e "${YELLOW}Documentation Hub Setup:${NC}"
echo "The CLI tools require a separate documentation hub repository."
echo "Default location: ~/Documents/ai-use-case-hub"
echo ""
read -p "Set up documentation hub now? (Y/n): " setup_hub
setup_hub=${setup_hub:-y}

if [[ "$setup_hub" =~ ^[Yy]$ ]]; then
    HUB_DIR="$HOME/Documents/ai-use-case-hub"

    if [ -d "$HUB_DIR" ]; then
        echo -e "${GREEN}✓${NC} Hub already exists at $HUB_DIR"
    else
        echo -e "${CYAN}Cloning documentation hub...${NC}"
        mkdir -p "$(dirname "$HUB_DIR")"
        if git clone https://github.com/mt-osiris-tools/ai-use-case-hub.git "$HUB_DIR"; then
            echo -e "${GREEN}✓${NC} Hub repository cloned to $HUB_DIR"
        else
            echo -e "${YELLOW}Note: Hub repository not yet available publicly${NC}"
            echo -e "Creating hub directory structure manually at $HUB_DIR"
            mkdir -p "$HUB_DIR"/{by-project,by-date,by-topic}
            echo -e "${GREEN}✓${NC} Hub directory created at $HUB_DIR"
        fi
    fi

    # Add AI_USECASES_DIR to shell profile
    SHELL_PROFILE=""
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        SHELL_PROFILE="$HOME/.zshrc"
    fi

    if [ -n "$SHELL_PROFILE" ]; then
        if ! grep -q "AI_USECASES_DIR" "$SHELL_PROFILE"; then
            echo '' >> "$SHELL_PROFILE"
            echo '# AI Use Case Hub' >> "$SHELL_PROFILE"
            echo "export AI_USECASES_DIR=\"$HUB_DIR\"" >> "$SHELL_PROFILE"
            echo -e "${GREEN}✓${NC} Added AI_USECASES_DIR to $SHELL_PROFILE"
        else
            echo -e "${YELLOW}AI_USECASES_DIR already in $SHELL_PROFILE${NC}"
        fi
    fi
else
    echo -e "${YELLOW}Skipped hub setup.${NC} You can set it up later with:"
    echo -e "  ${CYAN}git clone https://github.com/mt-osiris-tools/ai-use-case-hub.git ~/Documents/ai-use-case-hub${NC}"
    echo -e "  ${CYAN}export AI_USECASES_DIR=\"\$HOME/Documents/ai-use-case-hub\"${NC}"
fi

echo ""
echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo ""
echo -e "${YELLOW}Quick Start:${NC}"
echo -e "  1. Reload your shell: ${CYAN}source ~/.bashrc${NC}"
echo -e "  2. Navigate to a project: ${CYAN}cd /path/to/your-project${NC}"
echo -e "  3. Setup the project: ${CYAN}ai-use-case --init${NC}"
echo -e "  4. Document AI sessions: ${CYAN}ai-use-case document${NC}"
echo ""
echo -e "${YELLOW}Available Commands:${NC}"
echo -e "  ${GREEN}ai-use-case --init${NC}       Setup current project"
echo -e "  ${GREEN}ai-use-case document${NC}     Document an AI session"
echo -e "  ${GREEN}ai-use-case sync${NC}         Sync use cases to hub"
echo -e "  ${GREEN}ai-use-case search <term>${NC} Search use cases"
echo -e "  ${GREEN}ai-use-case stats${NC}        View statistics"
echo -e "  ${GREEN}ai-use-case --help${NC}       Show all commands"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  Run ${CYAN}ai-use-case --help${NC} for full usage guide"
echo -e "  Read ${CYAN}$INSTALL_DIR/README.md${NC} for detailed documentation"
echo ""
echo -e "${BLUE}Happy documenting! 🎉${NC}"
