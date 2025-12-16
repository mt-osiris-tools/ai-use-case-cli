#!/bin/bash
# Core Constants - Shared constants across AI Use Case CLI
#
# This module provides standardized color codes, default paths, and configuration keys
# used throughout the CLI to ensure consistency and reduce duplication.
#
# Usage:
#   source lib/core/constants.sh
#   echo -e "${GREEN}Success!${NC}"
#   echo "Config directory: $CONFIG_DIR"
#
# Dependencies: None
#
# Note: This is a pure constants file with no functions or side effects.

# Source guard - prevent multiple sourcing
if [ -n "${_CONSTANTS_SH_LOADED:-}" ]; then
    return 0
fi
readonly _CONSTANTS_SH_LOADED=1

# ============================================================================
# Color Codes - ANSI terminal colors for consistent output formatting
# ============================================================================
# Note: Colors are defined with TTY detection for proper rendering
# They will be disabled when output is not to a terminal or NO_COLOR is set

# Detect if we should use colors
if [[ -t 1 || -n "${FORCE_COLOR:-}" ]] && [[ -z "${NO_COLOR:-}" ]]; then
    # Colors enabled (TTY detected or FORCE_COLOR set, and NO_COLOR not set)
    GREEN=$'\033[0;32m'
    YELLOW=$'\033[1;33m'
    BLUE=$'\033[0;34m'
    RED=$'\033[0;31m'
    CYAN=$'\033[0;36m'
    GRAY=$'\033[0;90m'
    BOLD=$'\033[1m'
    NC=$'\033[0m' # No Color
else
    # Colors disabled (not a TTY, piped, redirected, or NO_COLOR set)
    GREEN=''
    YELLOW=''
    BLUE=''
    RED=''
    CYAN=''
    GRAY=''
    BOLD=''
    NC=''
fi

# Make color variables readonly to prevent accidental modification
readonly GREEN YELLOW BLUE RED CYAN GRAY BOLD NC

# ============================================================================
# Default Paths - Standard locations for config, data, and hub
# ============================================================================

# Default hub directory (can be overridden by AI_USECASES_DIR environment variable)
readonly DEFAULT_HUB_DIR="$HOME/.local/share/ai-use-case-cli/hub"

# CLI root directory (set at runtime by main CLI script or callers)
# IMPORTANT: This must be set before sourcing this file if you need to reference
# CLI installation paths. The main `ai-use-case` script sets this automatically.
# For scripts that need CLI_ROOT, ensure it's set via environment or before sourcing.
# Example: CLI_ROOT="/path/to/cli" source lib/core/constants.sh
CLI_ROOT="${CLI_ROOT:-}"

# Configuration directory (XDG compliant)
readonly CONFIG_DIR="$HOME/.config/ai-use-case-cli"

# Configuration files
readonly CONFIG_FILE="$CONFIG_DIR/config.json"
readonly TRACING_CONFIG_FILE="$CONFIG_DIR/tracing.json"
readonly AGENTS_CONFIG_FILE="$CONFIG_DIR/agents.json"

# ============================================================================
# Configuration Keys - JSON field names used in config files
# ============================================================================

# Hub configuration keys
readonly CONFIG_KEY_HUB_MODE="hubMode"
readonly CONFIG_KEY_HUB_PATH="hubPath"
readonly CONFIG_KEY_GIT_URL="gitUrl"

# Feature flag keys
readonly CONFIG_KEY_INSTALL_MODE="installMode"
readonly CONFIG_KEY_ADVANCED_ENABLED="advancedEnabled"

# Valid hub modes
readonly HUB_MODE_LOCAL="local"
readonly HUB_MODE_PRIVATE_GIT="private-git"

# Valid install modes
readonly INSTALL_MODE_LIGHT="light"
readonly INSTALL_MODE_FULL="full"
