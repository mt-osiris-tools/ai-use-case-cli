#!/bin/bash
# Config Features - Feature flag management for AI Use Case CLI
#
# This module manages feature flags including installation mode (light/full)
# and advanced features enablement. These flags control which CLI commands
# and features are available to the user.
#
# Usage:
#   source lib/core/constants.sh
#   source lib/config/config-core.sh
#   source lib/config/config-features.sh
#
#   mode=$(get_install_mode)
#   if is_advanced_enabled; then
#     # Show advanced features
#   fi
#
# Dependencies:
#   - lib/core/constants.sh (for colors, config paths)
#   - lib/config/config-core.sh (for get_config)
#
# Functions:
#   - get_install_mode()         Get installation mode (light or full)
#   - set_install_mode()         Set installation mode
#   - get_advanced_enabled()     Get advanced features status
#   - is_advanced_enabled()      Check if advanced features enabled
#   - set_advanced_enabled()     Toggle advanced features

# Source guard - prevent multiple sourcing
if [ -n "${_CONFIG_FEATURES_SH_LOADED:-}" ]; then
    return 0
fi
readonly _CONFIG_FEATURES_SH_LOADED=1

# Source dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/constants.sh"
source "$SCRIPT_DIR/config-core.sh"

# ============================================================================
# Installation Mode
# ============================================================================

# Get installation mode (light or full)
# Handles legacy installs (no installMode field) by defaulting to "full"
# New installs default to "light"
#
# Usage:
#   mode=$(get_install_mode)
#   echo "Install mode: $mode"
#
# Returns:
#   "light" or "full" (stdout)
#
# Behavior:
#   - If config file exists but no installMode field: "full" (legacy install)
#   - If config file doesn't exist: "light" (new install default)
#   - Otherwise: value from config file
get_install_mode() {
    local mode=$(get_config "installMode")

    # Default to "light" for new installs, but legacy installs (no field) get "full"
    if [ -z "$mode" ]; then
        # Check if config file exists - if so, it's a legacy install
        if [ -f "$CONFIG_FILE" ]; then
            echo "full"  # Legacy installs get full access
        else
            echo "light"  # New installs default to light
        fi
    else
        echo "$mode"
    fi
}

# Set installation mode
# Updates the installMode field in config.json
# Uses jq for proper JSON handling, falls back to sed if jq not available
#
# Usage:
#   set_install_mode "light"
#   set_install_mode "full"
#
# Arguments:
#   $1 - Mode to set ("light" or "full")
#
# Returns:
#   0 on success, 1 on error
set_install_mode() {
    local mode="$1"

    if [ "$mode" != "light" ] && [ "$mode" != "full" ]; then
        echo -e "${RED}Error: Invalid install mode. Use 'light' or 'full'${NC}" >&2
        return 1
    fi

    # Check if config file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}Error: Configuration file not found${NC}" >&2
        return 1
    fi

    # Use jq if available for proper JSON handling, fallback to sed
    if command -v jq &> /dev/null; then
        local temp_file=$(mktemp)
        trap "rm -f '$temp_file'" EXIT INT TERM

        # Add or update installMode field
        if grep -q '"installMode"' "$CONFIG_FILE"; then
            jq --arg mode "$mode" '.installMode = $mode' "$CONFIG_FILE" > "$temp_file"
        else
            jq --arg mode "$mode" '. + {installMode: $mode}' "$CONFIG_FILE" > "$temp_file"
        fi

        if [ -s "$temp_file" ] && jq empty "$temp_file" 2>/dev/null; then
            mv "$temp_file" "$CONFIG_FILE"
            trap - EXIT INT TERM
        else
            echo -e "${RED}Error: Failed to update configuration${NC}" >&2
            rm -f "$temp_file"
            trap - EXIT INT TERM
            return 1
        fi
    else
        # Fallback: simple sed-based update (works for flat JSON)
        # Cross-platform sed -i (BSD/macOS vs GNU/Linux)
        if grep -q '"installMode"' "$CONFIG_FILE"; then
            if [[ "$(uname)" == "Darwin" ]]; then
                sed -i '' "s|\"installMode\": \"[^\"]*\"|\"installMode\": \"$mode\"|" "$CONFIG_FILE"
            else
                sed -i "s|\"installMode\": \"[^\"]*\"|\"installMode\": \"$mode\"|" "$CONFIG_FILE"
            fi
        else
            # Add field before closing brace
            if [[ "$(uname)" == "Darwin" ]]; then
                sed -i '' "s|}$|,\n  \"installMode\": \"$mode\"\n}|" "$CONFIG_FILE"
            else
                sed -i "s|}$|,\n  \"installMode\": \"$mode\"\n}|" "$CONFIG_FILE"
            fi
        fi
    fi

    echo -e "${GREEN}✓${NC} Installation mode set to: $mode"
}

# ============================================================================
# Advanced Features
# ============================================================================

# Get advanced enabled status
# Returns "true" if advanced features are enabled, "false" otherwise
# Handles both boolean and string values in JSON
# Legacy installs (no advancedEnabled field) default to "true"
#
# Usage:
#   status=$(get_advanced_enabled)
#   echo "Advanced: $status"
#
# Returns:
#   "true" or "false" (stdout)
#
# Behavior:
#   - If no config file: "false" (new install)
#   - If config exists but no advancedEnabled field: "true" (legacy install)
#   - Otherwise: value from config file
get_advanced_enabled() {
    if [ ! -f "$CONFIG_FILE" ]; then
        # No config file = new install = disabled by default
        echo "false"
        return
    fi

    # Check for advancedEnabled field (handles both boolean and string values)
    if grep -q '"advancedEnabled"' "$CONFIG_FILE"; then
        # Extract value - handles both true/false (boolean) and "true"/"false" (string)
        local value=$(grep '"advancedEnabled"' "$CONFIG_FILE" | sed 's/.*: *\([^,}]*\).*/\1/' | tr -d ' "')
        if [ "$value" = "true" ]; then
            echo "true"
        else
            echo "false"
        fi
    else
        # Field not present = legacy install = full access
        echo "true"
    fi
}

# Check if advanced features are enabled
# Boolean check function for conditional logic
#
# Usage:
#   if is_advanced_enabled; then
#     echo "Advanced features available"
#     # Show advanced commands
#   else
#     echo "Advanced features disabled"
#   fi
#
# Returns:
#   0 (true) if enabled, 1 (false) if disabled
is_advanced_enabled() {
    local advanced=$(get_advanced_enabled)
    [ "$advanced" = "true" ]
}

# Set advanced enabled status
# Enables or disables advanced features
# Uses jq for proper JSON boolean handling, falls back to sed
#
# Usage:
#   set_advanced_enabled "true"   # Enable advanced features
#   set_advanced_enabled "false"  # Disable advanced features
#
# Arguments:
#   $1 - Status to set ("true" or "false")
#
# Returns:
#   0 on success, 1 on error
set_advanced_enabled() {
    local value="$1"

    if [ "$value" != "true" ] && [ "$value" != "false" ]; then
        echo -e "${RED}Error: Invalid value. Use 'true' or 'false'${NC}" >&2
        return 1
    fi

    # Check if config file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}Error: Configuration file not found${NC}" >&2
        return 1
    fi

    # Use jq if available for proper JSON handling
    if command -v jq &> /dev/null; then
        local temp_file=$(mktemp)
        trap "rm -f '$temp_file'" EXIT INT TERM

        # Convert string to boolean for jq
        local bool_value=$( [ "$value" = "true" ] && echo "true" || echo "false" )

        # Add or update advancedEnabled field
        if grep -q '"advancedEnabled"' "$CONFIG_FILE"; then
            jq --argjson enabled "$bool_value" '.advancedEnabled = $enabled' "$CONFIG_FILE" > "$temp_file"
        else
            jq --argjson enabled "$bool_value" '. + {advancedEnabled: $enabled}' "$CONFIG_FILE" > "$temp_file"
        fi

        if [ -s "$temp_file" ] && jq empty "$temp_file" 2>/dev/null; then
            mv "$temp_file" "$CONFIG_FILE"
            trap - EXIT INT TERM
        else
            echo -e "${RED}Error: Failed to update configuration${NC}" >&2
            trap - EXIT INT TERM
            rm -f "$temp_file"
            return 1
        fi
    else
        # Fallback: simple sed-based update
        # Cross-platform sed -i (BSD/macOS vs GNU/Linux)
        if grep -q '"advancedEnabled"' "$CONFIG_FILE"; then
            if [[ "$(uname)" == "Darwin" ]]; then
                sed -i '' "s|\"advancedEnabled\": [^,}]*|\"advancedEnabled\": $value|" "$CONFIG_FILE"
            else
                sed -i "s|\"advancedEnabled\": [^,}]*|\"advancedEnabled\": $value|" "$CONFIG_FILE"
            fi
        else
            # Add field before closing brace
            if [[ "$(uname)" == "Darwin" ]]; then
                sed -i '' "s|}$|,\n  \"advancedEnabled\": $value\n}|" "$CONFIG_FILE"
            else
                sed -i "s|}$|,\n  \"advancedEnabled\": $value\n}|" "$CONFIG_FILE"
            fi
        fi
    fi

    echo -e "${GREEN}✓${NC} Advanced features: $( [ "$value" = "true" ] && echo "enabled" || echo "disabled" )"
}
