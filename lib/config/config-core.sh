#!/bin/bash
# Config Core - Core configuration utilities for AI Use Case CLI
#
# This module provides fundamental configuration management functions including
# JSON read/write operations, path validation, and config directory management.
#
# Usage:
#   source lib/core/constants.sh
#   source lib/config/config-core.sh
#
#   ensure_config_dir
#   set_config "hubMode" "local"
#   mode=$(get_config "hubMode")
#
# Dependencies:
#   - lib/core/constants.sh (for CONFIG_DIR, CONFIG_FILE, colors)
#
# Functions:
#   - ensure_config_dir()        Ensures config directory exists
#   - validate_path()            Validates directory paths
#   - init_config()              Initializes default configuration
#   - get_config()               Reads configuration value
#   - set_config()               Writes configuration value

# Source guard - prevent multiple sourcing
if [ -n "${_CONFIG_CORE_SH_LOADED:-}" ]; then
    return 0
fi
readonly _CONFIG_CORE_SH_LOADED=1

# Source dependencies (use local variable to avoid collision with caller's SCRIPT_DIR)
_LIB_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_LIB_SCRIPT_DIR/../core/constants.sh"
source "$_LIB_SCRIPT_DIR/../utils/file-utils.sh"

# ============================================================================
# Directory Management
# ============================================================================

# Ensure config directory exists
#
# Usage:
#   ensure_config_dir
#
# Returns:
#   0 on success (directory exists or was created)
ensure_config_dir() {
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
    fi
}

# ============================================================================
# Path Validation
# ============================================================================

# Validate directory path
# Checks for:
#   - Empty paths
#   - Invalid characters (quotes, backticks, $, ;)
#   - Parent directory existence and writability
#   - Directory writability (if exists)
#
# Usage:
#   if validate_path "/path/to/dir"; then
#     echo "Path is valid"
#   fi
#
# Arguments:
#   $1 - Path to validate
#
# Returns:
#   0 if valid, 1 if invalid
validate_path() {
    local path="$1"

    # Check for empty path
    if [ -z "$path" ]; then
        return 1
    fi

    # Check for problematic characters
    if [[ "$path" =~ [\'\"\`\$\;] ]]; then
        echo -e "${RED}Error: Path contains invalid characters (quotes, backticks, dollar signs, semicolons)${NC}" >&2
        return 1
    fi

    # Expand tilde to home directory
    path="${path/#\~/$HOME}"

    # Check if parent directory exists or can be created
    local parent_dir=$(dirname "$path")
    if [ ! -d "$parent_dir" ]; then
        echo -e "${YELLOW}Warning: Parent directory $parent_dir does not exist${NC}" >&2

        if [ ! -t 0 ]; then
            if ! mkdir -p "$parent_dir" 2>/dev/null; then
                echo -e "${RED}Error: Cannot create parent directory $parent_dir${NC}" >&2
                return 1
            fi
        else
            read -p "Create parent directory? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                return 1
            fi
            if ! mkdir -p "$parent_dir" 2>/dev/null; then
                echo -e "${RED}Error: Cannot create parent directory $parent_dir${NC}" >&2
                return 1
            fi
        fi
    fi

    # Check if directory is writable (if exists) or parent is writable (if not)
    if [ -d "$path" ]; then
        if [ ! -w "$path" ]; then
            echo -e "${RED}Error: Directory $path is not writable${NC}" >&2
            return 1
        fi
    else
        if [ ! -w "$parent_dir" ]; then
            echo -e "${RED}Error: Parent directory $parent_dir is not writable${NC}" >&2
            return 1
        fi
    fi

    return 0
}

# ============================================================================
# Configuration I/O
# ============================================================================

# Initialize default configuration
# Creates config.json with initial values
#
# Usage:
#   init_config "local" "/path/to/hub" "git@github.com:user/repo.git"
#
# Arguments:
#   $1 - Hub mode (default: "local")
#   $2 - Hub path (default: ~/.local/share/ai-use-case-cli/hub)
#   $3 - Git URL (optional, default: "")
#
# Returns:
#   0 on success
init_config() {
    local hub_mode="${1:-local}"
    local hub_path="${2:-}"
    local git_url="${3:-}"

    ensure_config_dir

    # Set default hub path if not provided
    if [ -z "$hub_path" ]; then
        hub_path="$HOME/.local/share/ai-use-case-cli/hub"
    fi

    cat > "$CONFIG_FILE" <<EOF
{
  "version": "1.0.0",
  "hubMode": "$hub_mode",
  "hubPath": "$hub_path",
  "gitUrl": "$git_url",
  "gitRequired": false
}
EOF

    echo -e "${GREEN}✓${NC} Configuration initialized: $CONFIG_FILE" >&2
}

# Read configuration value
# Simple JSON parsing suitable for flat JSON structure.
# Avoids requiring jq as a dependency.
#
# Usage:
#   mode=$(get_config "hubMode")
#   path=$(get_config "hubPath")
#
# Arguments:
#   $1 - Configuration key
#
# Returns:
#   Configuration value (stdout)
#   1 if config file doesn't exist
#
# Note:
#   If the JSON structure becomes more complex (nested objects, arrays),
#   consider using jq instead.
get_config() {
    local key="$1"

    if [ ! -f "$CONFIG_FILE" ]; then
        return 1
    fi

    # Simple JSON parsing (works for flat key-value structure)
    # Pattern matches: "key": "value" and extracts value
    grep "\"$key\"" "$CONFIG_FILE" | sed 's/.*: "\(.*\)".*/\1/' | tr -d ','
}

# Update configuration value
# Uses atomic file updates with temporary files
#
# Usage:
#   set_config "hubMode" "private-git"
#   set_config "hubPath" "/new/path"
#
# Arguments:
#   $1 - Configuration key
#   $2 - Configuration value
#
# Returns:
#   0 on success, 1 on error
set_config() {
    local key="$1"
    local value="$2"

    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}Error: Configuration file not found${NC}" >&2
        echo "Please run 'ai-use-case --init' to initialize configuration" >&2
        return 1
    fi

    # Create temporary file in config dir for atomic update
    local temp_file
    temp_file="$(mktemp "$CONFIG_DIR/config.json.tmp.XXXXXX")"
    setup_temp_file_cleanup "$temp_file"

    # Simple JSON update (works for simple structure)
    sed "s|\"$key\": \"[^\"]*\"|\"$key\": \"$value\"|" "$CONFIG_FILE" > "$temp_file"

    # Atomically move temp file to config file
    mv "$temp_file" "$CONFIG_FILE"

    # Remove trap and cleanup function
    teardown_temp_file_cleanup

    echo -e "${GREEN}✓${NC} Configuration updated: $key = $value"
}
