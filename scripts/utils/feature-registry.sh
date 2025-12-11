#!/bin/bash
# Feature Registry for AI Use Case CLI
# Defines command classifications for light/full installation modes

# =============================================================================
# CLI COMMANDS
# =============================================================================

# Core CLI commands (always visible in light mode)
# These are essential for the basic documentation workflow
CORE_CLI_COMMANDS=(
    "--init"
    "init"
    "--link-claude"
    "config"
    "sync"
    "search"
    "list"
    "stats"
    "view"
    "push"
    "publish-confluence"
    "list-projects"
    "check-updates"
    "update-project"
    "reset"
    "update"
    "self-update"
    "uninstall"
    "--version"
    "-v"
    "version"
    "--help"
    "-h"
    "help"
    "enable-advanced"
    "disable-advanced"
    "status"
)

# Advanced CLI commands (hidden in light mode unless enabled)
# These provide additional functionality for power users
ADVANCED_CLI_COMMANDS=(
    "agents"
    "review-quality"
    "analyze-patterns"
    "extract"
    "tracing"
    "bump-version"
)

# =============================================================================
# SLASH COMMANDS (Claude Code / AI Tools)
# =============================================================================

# Core slash commands (always installed)
# These are essential for the basic documentation workflow
CORE_SLASH_COMMANDS=(
    "document-session"
    "setup-project"
    "sync-usecases"
    "search-usecases"
    "list-projects"
    "check-updates"
    "update-project"
    "publish-confluence"
    "quick-start"
)

# Advanced slash commands (hidden in light mode unless enabled)
# These provide additional AI-powered analysis features
ADVANCED_SLASH_COMMANDS=(
    "analyze-patterns"
    "review-quality"
    "extract-session"
)

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Check if a CLI command is advanced
# Usage: is_advanced_cli_command "agents"
is_advanced_cli_command() {
    local cmd="$1"
    for advanced_cmd in "${ADVANCED_CLI_COMMANDS[@]}"; do
        if [ "$cmd" = "$advanced_cmd" ]; then
            return 0  # true
        fi
    done
    return 1  # false
}

# Check if a slash command is advanced
# Usage: is_advanced_slash_command "analyze-patterns"
is_advanced_slash_command() {
    local cmd="$1"
    for advanced_cmd in "${ADVANCED_SLASH_COMMANDS[@]}"; do
        if [ "$cmd" = "$advanced_cmd" ]; then
            return 0  # true
        fi
    done
    return 1  # false
}

# Get all CLI commands as a space-separated string
get_all_cli_commands() {
    echo "${CORE_CLI_COMMANDS[*]} ${ADVANCED_CLI_COMMANDS[*]}"
}

# Get all slash commands as a space-separated string
get_all_slash_commands() {
    echo "${CORE_SLASH_COMMANDS[*]} ${ADVANCED_SLASH_COMMANDS[*]}"
}

# Get core slash commands as a space-separated string
get_core_slash_commands() {
    echo "${CORE_SLASH_COMMANDS[*]}"
}

# Get advanced slash commands as a space-separated string
get_advanced_slash_commands() {
    echo "${ADVANCED_SLASH_COMMANDS[*]}"
}
