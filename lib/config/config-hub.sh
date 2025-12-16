#!/bin/bash
# Config Hub - Hub configuration management for AI Use Case CLI
#
# This module handles all hub-related configuration including hub mode (local vs git),
# hub path management, git URL configuration, and interactive setup.
#
# Usage:
#   source lib/core/constants.sh
#   source lib/config/config-core.sh
#   source lib/config/config-hub.sh
#
#   mode=$(get_hub_mode)
#   path=$(get_hub_path)
#   if is_git_mode; then
#     url=$(get_git_url)
#   fi
#
# Dependencies:
#   - lib/core/constants.sh (for colors, config paths, hub mode constants)
#   - lib/config/config-core.sh (for get_config, set_config, init_config, validate_path)
#
# Functions:
#   - get_hub_mode()         Get current hub mode (local or private-git)
#   - get_hub_path()         Get hub directory path (respects AI_USECASES_DIR)
#   - get_git_url()          Get git repository URL (for git modes)
#   - is_git_mode()          Check if hub uses git
#   - prompt_hub_mode()      Interactive hub configuration
#   - show_hub_config()      Display hub configuration

# Source guard - prevent multiple sourcing
if [ -n "${_CONFIG_HUB_SH_LOADED:-}" ]; then
    return 0
fi
readonly _CONFIG_HUB_SH_LOADED=1

# Source dependencies (use local variable to avoid collision with caller's SCRIPT_DIR)
_LIB_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_LIB_SCRIPT_DIR/../core/constants.sh"
source "$_LIB_SCRIPT_DIR/config-core.sh"

# ============================================================================
# Hub Configuration Queries
# ============================================================================

# Get hub mode (local, private-git)
# Returns the configured hub mode or "local" as default
#
# Usage:
#   mode=$(get_hub_mode)
#   echo "Hub mode: $mode"
#
# Returns:
#   Hub mode string (stdout)
get_hub_mode() {
    local mode=$(get_config "hubMode")

    # Default to local if not set
    if [ -z "$mode" ]; then
        echo "local"
    else
        echo "$mode"
    fi
}

# Get hub path
# Respects AI_USECASES_DIR environment variable (highest priority)
# Falls back to config file, then default path
#
# Usage:
#   path=$(get_hub_path)
#   echo "Hub directory: $path"
#
# Environment Variables:
#   AI_USECASES_DIR - Override hub path (highest priority)
#
# Returns:
#   Hub directory path (stdout)
get_hub_path() {
    # Check environment variable first (highest priority)
    if [ -n "${AI_USECASES_DIR:-}" ]; then
        echo "${AI_USECASES_DIR}"
        return 0
    fi

    # Check config file
    local path=$(get_config "hubPath")

    # Use default if not set
    if [ -z "$path" ]; then
        echo "$HOME/.local/share/ai-use-case-cli/hub"
    else
        echo "$path"
    fi
}

# Get git URL (for git modes)
# Returns the configured git repository URL
# Warns if private-git mode is configured without a URL
#
# Usage:
#   if is_git_mode; then
#     url=$(get_git_url)
#     echo "Git URL: $url"
#   fi
#
# Returns:
#   Git URL string (stdout), empty for local mode
get_git_url() {
    local mode=$(get_hub_mode)
    local url=$(get_config "gitUrl")

    case "$mode" in
        local)
            # In local mode, git URL is not applicable
            echo ""
            ;;
        private-git)
            if [ -z "$url" ]; then
                echo -e "${YELLOW}Warning: Private git mode configured but no git URL set${NC}" >&2
                echo -e "Please reconfigure: ai-use-case config reconfigure${NC}" >&2
            fi
            echo "$url"
            ;;
        *)
            echo "$url"
            ;;
    esac
}

# Check if hub mode uses git
# Returns 0 (true) if git mode, 1 (false) otherwise
#
# Usage:
#   if is_git_mode; then
#     echo "Using git for version control"
#   else
#     echo "Using local storage only"
#   fi
#
# Returns:
#   0 if git mode enabled, 1 if local mode
is_git_mode() {
    local mode=$(get_hub_mode)
    [ "$mode" = "private-git" ]
}

# ============================================================================
# Interactive Configuration
# ============================================================================

# Interactive hub mode selection
# Prompts user to choose between local-only and private git repository modes
# Validates paths and creates initial configuration
#
# Usage:
#   hub_path=$(prompt_hub_mode)
#
# Returns:
#   Selected hub path (stdout)
#   0 on success
#
# Modes:
#   1. Local only - No git repository, local storage only
#   2. Private git - Connect to private git repository for version control
prompt_hub_mode() {
    echo -e "${BLUE}=== Hub Configuration ===${NC}" >&2
    echo "" >&2
    echo "How would you like to store AI use case documentation?" >&2
    echo "" >&2
    echo -e "  ${GREEN}1${NC}. Local only (no git repository)" >&2
    echo "     Files stored locally, no version control or remote sync" >&2
    echo "     Best for: Personal use, quick local documentation" >&2
    echo "" >&2
    echo -e "  ${GREEN}2${NC}. Private git repository" >&2
    echo "     Connect to your own private repository for version control" >&2
    echo "     Best for: Private team documentation, version-controlled workflow" >&2
    echo "" >&2

    while true; do
        read -p "Select option (1-2) [1]: " choice
        choice=${choice:-1}

        case $choice in
            1)
                echo "" >&2
                echo -e "${BLUE}Local mode selected${NC}" >&2
                read -p "Hub directory path [$HOME/.local/share/ai-use-case-cli/hub]: " hub_path
                hub_path=${hub_path:-$HOME/.local/share/ai-use-case-cli/hub}

                # Validate path
                if ! validate_path "$hub_path"; then
                    echo -e "${RED}Invalid path. Please try again.${NC}" >&2
                    continue
                fi

                init_config "local" "$hub_path" ""
                echo "$hub_path"
                return 0
                ;;
            2)
                echo "" >&2
                echo -e "${BLUE}Private git mode selected${NC}" >&2
                read -p "Git repository URL: " git_url

                if [ -z "$git_url" ]; then
                    echo -e "${RED}Error: Git URL is required for private git mode${NC}" >&2
                    continue
                fi

                # Basic git URL validation
                if ! [[ "$git_url" =~ ^(https?://|git@|ssh://|file://) ]]; then
                    echo -e "${YELLOW}Warning: URL doesn't appear to be a valid git repository URL${NC}" >&2
                    echo "Valid formats: https://, http://, git@, ssh://, file://" >&2
                    read -p "Continue anyway? (y/n) " -n 1 -r
                    echo
                    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                        continue
                    fi
                fi

                read -p "Local hub directory path [$HOME/.local/share/ai-use-case-cli/hub]: " hub_path
                hub_path=${hub_path:-$HOME/.local/share/ai-use-case-cli/hub}

                # Validate path
                if ! validate_path "$hub_path"; then
                    echo -e "${RED}Invalid path. Please try again.${NC}" >&2
                    continue
                fi

                init_config "private-git" "$hub_path" "$git_url"
                echo "$hub_path"
                return 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please select 1 or 2.${NC}" >&2
                ;;
        esac
    done
}

# ============================================================================
# Display Configuration
# ============================================================================

# Show current hub configuration
# Displays hub mode, path, and git URL (if applicable)
#
# Usage:
#   show_hub_config
#
# Returns:
#   0 on success, 1 if not configured
show_hub_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}No configuration found${NC}"
        echo "Run 'ai-use-case --init' to configure"
        return 1
    fi

    echo -e "${BLUE}=== Current Configuration ===${NC}"
    echo ""
    echo -e "Hub Mode:  ${GREEN}$(get_hub_mode)${NC}"
    echo -e "Hub Path:  ${CYAN}$(get_hub_path)${NC}"

    if is_git_mode; then
        echo -e "Git URL:   ${CYAN}$(get_git_url)${NC}"
    fi

    echo ""
    echo -e "Config file: ${CYAN}$CONFIG_FILE${NC}"
}
