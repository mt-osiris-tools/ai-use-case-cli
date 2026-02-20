#!/bin/bash
# Hub Utilities for AI Use Case CLI
# Common functions for hub operations across all scripts

# Source configuration manager if available
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONSTANTS_SH="$UTILS_DIR/../../lib/core/constants.sh"
if [ -f "$CONSTANTS_SH" ]; then
    source "$CONSTANTS_SH"
else
    GREEN=''
    YELLOW=''
    BLUE=''
    RED=''
    CYAN=''
    NC=''
fi

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
    if [ -f "$CONFIG_FILE" ]; then
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

    # Verify and create hub structure if needed
    # Note: We auto-create subdirectories since they're just organizational structure
    # and might be missing due to manual deletion or corruption
    if [ ! -d "$hub_dir/by-project" ] || [ ! -d "$hub_dir/by-date" ] || [ ! -d "$hub_dir/by-topic" ]; then
        mkdir -p "$hub_dir/by-project" "$hub_dir/by-date" "$hub_dir/by-topic" 2>/dev/null || {
            echo -e "${RED}Error: Cannot create hub directory structure${NC}" >&2
            echo "Please check permissions for: $hub_dir" >&2
            exit 1
        }
    fi

    echo "$hub_dir"
}

# Function to get hub directory without ensuring it exists
# Useful for scripts that just need to know the configured path
get_hub_dir() {
    if [ -f "$CONFIG_FILE" ]; then
        get_hub_path
    else
        echo "${AI_USECASES_DIR:-$HOME/.local/share/ai-use-case-cli/hub}"
    fi
}

# Function to check if hub uses git
is_hub_git() {
    if [ -f "$CONFIG_FILE" ]; then
        is_git_mode
    else
        return 1
    fi
}
