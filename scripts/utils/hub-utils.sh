#!/bin/bash
# Hub Utilities for AI Use Case CLI
# Common functions for hub operations across all scripts

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Source configuration manager if available
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_MANAGER="$UTILS_DIR/config-manager.sh"
if [ -f "$CONFIG_MANAGER" ]; then
    source "$CONFIG_MANAGER"
fi

# Function to validate that hub repository exists
# NOTE: This is a validation-only function. It does not handle setup or prompts.
# For setup/initialization, use the version in setup-project.sh instead.
# Returns the hub directory path
ensure_hub_exists() {
    local hub_dir
    local hub_mode

    # Check if configuration exists
    if [ -f "$HOME/.config/ai-use-case-cli/config.json" ]; then
        hub_mode=$(get_hub_mode)
        hub_dir=$(get_hub_path)
    else
        # Fallback to local mode if no config
        # echo -e "${YELLOW}Warning: No configuration found. Using local mode.${NC}" >&2
        # echo -e "${BLUE}Run 'ai-use-case --init' to configure hub mode.${NC}" >&2
        hub_dir="${AI_USECASES_DIR:-$HOME/.local/share/ai-use-case-cli/hub}"
        hub_mode="local"
    fi

    # Check if hub exists
    if [ ! -d "$hub_dir" ]; then
        echo -e "${RED}Error: Hub directory not found at: $hub_dir${NC}" >&2
        echo "Please run 'ai-use-case --init' to setup the hub" >&2
        exit 1
    fi

    # Verify hub structure
    if [ ! -d "$hub_dir/by-project" ]; then
        mkdir -p "$hub_dir/by-project" "$hub_dir/by-date" "$hub_dir/by-topic"
    fi

    echo "$hub_dir"
}

# Function to get hub directory without ensuring it exists
# Useful for scripts that just need to know the configured path
get_hub_dir() {
    if [ -f "$HOME/.config/ai-use-case-cli/config.json" ]; then
        get_hub_path
    else
        echo "${AI_USECASES_DIR:-$HOME/.local/share/ai-use-case-cli/hub}"
    fi
}

# Function to check if hub uses git
is_hub_git() {
    if [ -f "$HOME/.config/ai-use-case-cli/config.json" ]; then
        is_git_mode
    else
        return 1
    fi
}
