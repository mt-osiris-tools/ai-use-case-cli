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

# ============================================================================
# Color Codes - ANSI terminal colors for consistent output formatting
# ============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ============================================================================
# Default Paths - Standard locations for config, data, and hub
# ============================================================================

# Default hub directory (can be overridden by AI_USECASES_DIR environment variable)
readonly DEFAULT_HUB_DIR="$HOME/.local/share/ai-use-case-cli/hub"

# CLI root directory (typically set at runtime)
# Note: This is expected to be set by the main CLI script
CLI_ROOT="${CLI_ROOT:-}"

# Configuration directory (XDG compliant)
CONFIG_DIR="$HOME/.config/ai-use-case-cli"

# Configuration files
CONFIG_FILE="$CONFIG_DIR/config.json"
TRACING_CONFIG_FILE="$CONFIG_DIR/tracing.json"
AGENTS_CONFIG_FILE="$CONFIG_DIR/agents.json"

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
