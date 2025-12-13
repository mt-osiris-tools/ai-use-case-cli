#!/bin/bash
# Config Tracing - OpenTelemetry tracing configuration for AI Use Case CLI
#
# This module manages OpenTelemetry tracing configuration including enabling/disabling
# tracing, configuring endpoints, sampling ratios, and validating/repairing config files.
#
# Usage:
#   source lib/core/constants.sh
#   source lib/config/config-core.sh
#   source lib/config/config-tracing.sh
#
#   init_tracing_config
#   set_tracing_config "enabled" "true"
#   config=$(get_tracing_config)
#
# Dependencies:
#   - lib/core/constants.sh (for colors, CONFIG_DIR, TRACING_CONFIG_FILE)
#   - lib/config/config-core.sh (for ensure_config_dir)
#
# Functions:
#   - init_tracing_config()                Initialize tracing.json
#   - get_tracing_config()                 Get tracing configuration
#   - set_tracing_config()                 Update tracing field
#   - validate_and_repair_tracing_config() Validate and repair config
#   - show_tracing_config()                Display tracing config
#   - configure_tracing()                  Interactive setup

# Source guard - prevent multiple sourcing
if [ -n "${_CONFIG_TRACING_SH_LOADED:-}" ]; then
    return 0
fi
readonly _CONFIG_TRACING_SH_LOADED=1

# Source dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/constants.sh"
source "$SCRIPT_DIR/config-core.sh"

# ============================================================================
# Tracing Configuration Constants
# ============================================================================

# Default tracing configuration (single source of truth)
readonly DEFAULT_TRACING_CONFIG='{
  "enabled": false,
  "endpoint": "http://localhost:4318",
  "sampling_ratio": 1.0,
  "export_timeout": 30
}'

# ============================================================================
# Configuration Management
# ============================================================================

# Initialize tracing configuration (atomic operation)
# Creates tracing.json with default values
# Uses temporary file and atomic move for safety
#
# Usage:
#   init_tracing_config
#
# Returns:
#   0 on success, 1 on error
init_tracing_config() {
    local tracing_config_file="$TRACING_CONFIG_FILE"
    local temp_file=$(mktemp)
    trap "rm -f '$temp_file'" EXIT INT TERM

    # Ensure config directory exists
    ensure_config_dir

    # Write to temp file first (using shared constant)
    echo "$DEFAULT_TRACING_CONFIG" > "$temp_file"

    # Validate the content
    if [ ! -s "$temp_file" ]; then
        echo -e "${RED}Error: Failed to create tracing configuration${NC}" >&2
        trap - EXIT INT TERM
        rm -f "$temp_file"
        return 1
    fi

    # Validate JSON syntax if jq available
    if command -v jq &> /dev/null; then
        if ! jq empty "$temp_file" 2>/dev/null; then
            echo -e "${RED}Error: Invalid JSON in tracing configuration${NC}" >&2
            trap - EXIT INT TERM
            rm -f "$temp_file"
            return 1
        fi
    fi

    # Atomic move (safer than cp)
    if ! mv "$temp_file" "$tracing_config_file" 2>/dev/null; then
        echo -e "${RED}Error: Failed to save tracing configuration${NC}" >&2
        trap - EXIT INT TERM
        rm -f "$temp_file"
        return 1
    fi

    trap - EXIT INT TERM
    echo -e "${GREEN}✓${NC} Tracing configuration initialized" >&2
    return 0
}

# Get tracing configuration
# Returns the current tracing config or default if not configured
#
# Usage:
#   config=$(get_tracing_config)
#   echo "$config" | jq '.enabled'
#
# Returns:
#   JSON configuration (stdout)
get_tracing_config() {
    local tracing_config_file="$TRACING_CONFIG_FILE"

    if [ -f "$tracing_config_file" ]; then
        cat "$tracing_config_file"
    else
        echo "$DEFAULT_TRACING_CONFIG"
    fi
}

# Set tracing configuration
# Updates a specific field in tracing.json
# Handles boolean, numeric, and string values appropriately
# Requires jq for safe updates
#
# Usage:
#   set_tracing_config "enabled" "true"
#   set_tracing_config "endpoint" "http://localhost:4318"
#   set_tracing_config "sampling_ratio" "0.5"
#
# Arguments:
#   $1 - Configuration key (enabled, endpoint, sampling_ratio, export_timeout)
#   $2 - Configuration value
#
# Returns:
#   0 on success, 1 on error
set_tracing_config() {
    local key="$1"
    local value="$2"
    local tracing_config_file="$TRACING_CONFIG_FILE"

    ensure_config_dir

    # Initialize if doesn't exist or validate if exists
    if [ ! -f "$tracing_config_file" ]; then
        if ! init_tracing_config; then
            echo -e "${RED}Error: Failed to initialize tracing configuration${NC}" >&2
            return 1
        fi
    else
        # Validate existing file and repair if needed
        if ! validate_and_repair_tracing_config; then
            echo -e "${RED}Error: Failed to validate tracing configuration${NC}" >&2
            return 1
        fi
    fi

    # Require jq for safe updates
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq not available. Cannot update configuration safely.${NC}" >&2
        echo "Install jq: sudo apt-get install jq  # or appropriate package manager" >&2
        return 1
    fi

    local temp_file=$(mktemp)
    # Setup cleanup trap (EXIT, INT, TERM to ensure cleanup on interruption/termination)
    trap "rm -f '$temp_file'" EXIT INT TERM

    # Use --argjson for boolean/numeric keys, --arg for strings
    case "$key" in
        enabled)
            # Convert string "true"/"false" to boolean
            if [[ "$value" == "true" ]]; then
                jq --arg key "$key" '.[$key] = true' "$tracing_config_file" > "$temp_file"
            else
                jq --arg key "$key" '.[$key] = false' "$tracing_config_file" > "$temp_file"
            fi
            ;;
        sampling_ratio|export_timeout)
            # Numeric values
            jq --arg key "$key" --argjson value "$value" '.[$key] = $value' "$tracing_config_file" > "$temp_file"
            ;;
        *)
            # String values
            jq --arg key "$key" --arg value "$value" '.[$key] = $value' "$tracing_config_file" > "$temp_file"
            ;;
    esac

    # Validate temp file before moving
    if [ ! -s "$temp_file" ]; then
        echo -e "${RED}Error: Failed to update configuration (empty result)${NC}" >&2
        trap - EXIT INT TERM
        rm -f "$temp_file"
        return 1
    fi

    if ! jq empty "$temp_file" 2>/dev/null; then
        echo -e "${RED}Error: Failed to update configuration (invalid JSON)${NC}" >&2
        trap - EXIT INT TERM
        rm -f "$temp_file"
        return 1
    fi

    # Atomic move
    if ! mv "$temp_file" "$tracing_config_file" 2>/dev/null; then
        echo -e "${RED}Error: Failed to save configuration${NC}" >&2
        trap - EXIT INT TERM
        rm -f "$temp_file"
        return 1
    fi

    trap - EXIT INT TERM
    echo "Updated tracing.$key = $value"
    return 0
}

# ============================================================================
# Configuration Validation
# ============================================================================

# Validate and repair tracing configuration
# Checks for:
#   - File existence
#   - Empty files
#   - Invalid JSON syntax
# Repairs corrupted files by recreating with defaults
#
# Usage:
#   if validate_and_repair_tracing_config; then
#     echo "Config is valid"
#   fi
#
# Returns:
#   0 if valid or repaired successfully, 1 on error
validate_and_repair_tracing_config() {
    local tracing_config_file="$TRACING_CONFIG_FILE"

    # Check if file exists
    if [ ! -f "$tracing_config_file" ]; then
        return 0  # Not an error, will be created
    fi

    # Check if empty
    if [ ! -s "$tracing_config_file" ]; then
        echo -e "${YELLOW}Warning: Empty tracing config detected, repairing...${NC}" >&2
        rm -f "$tracing_config_file"
        init_tracing_config
        return $?
    fi

    # Check if valid JSON
    if command -v jq &> /dev/null; then
        if ! jq empty "$tracing_config_file" 2>/dev/null; then
            echo -e "${YELLOW}Warning: Corrupted tracing config detected, repairing...${NC}" >&2
            rm -f "$tracing_config_file"
            init_tracing_config
            return $?
        fi
    fi

    return 0
}

# ============================================================================
# Display Configuration
# ============================================================================

# Show tracing configuration
# Displays current tracing.json and relevant environment variables
#
# Usage:
#   show_tracing_config
#
# Environment Variables (displayed):
#   - AI_USECASE_TRACING_ENABLED
#   - AI_USECASE_TRACING_ENDPOINT
#   - AI_USECASE_TRACING_SAMPLING
show_tracing_config() {
    local tracing_config_file="$TRACING_CONFIG_FILE"

    echo -e "${BLUE}=== Tracing Configuration ===${NC}"
    echo ""

    if [ -f "$tracing_config_file" ]; then
        echo -e "${GREEN}Configuration file:${NC} $tracing_config_file"
        echo ""

        if command -v jq &> /dev/null; then
            jq '.' "$tracing_config_file"
        else
            cat "$tracing_config_file"
        fi
    else
        echo -e "${YELLOW}No tracing configuration found${NC}"
        echo "Default configuration:"
        get_tracing_config | jq '.' 2>/dev/null || get_tracing_config
    fi

    echo ""
    echo -e "${CYAN}Environment Variables:${NC}"
    printf "  %-30s %s\n" "AI_USECASE_TRACING_ENABLED" "${AI_USECASE_TRACING_ENABLED:-not set}"
    printf "  %-30s %s\n" "AI_USECASE_TRACING_ENDPOINT" "${AI_USECASE_TRACING_ENDPOINT:-not set}"
    printf "  %-30s %s\n" "AI_USECASE_TRACING_SAMPLING" "${AI_USECASE_TRACING_SAMPLING:-not set}"
}

# ============================================================================
# Interactive Configuration
# ============================================================================

# Configure tracing interactively
# Prompts user for:
#   - Enable/disable tracing
#   - OTLP endpoint URL
#   - Sampling ratio (0.0-1.0)
# Checks for AI Toolkit tracing endpoint availability
#
# Usage:
#   configure_tracing
#
# Returns:
#   0 on success
configure_tracing() {
    echo -e "${BLUE}=== Configure Tracing ===${NC}"
    echo ""

    # Check if AI Toolkit tracing is available
    if curl -s --max-time 2 http://localhost:4318/v1/traces >/dev/null 2>&1; then
        echo -e "${GREEN}✓ AI Toolkit tracing endpoint detected at localhost:4318${NC}"
    else
        echo -e "${YELLOW}⚠ AI Toolkit tracing endpoint not detected${NC}"
        echo "  Make sure AI Toolkit is running with tracing enabled"
    fi
    echo ""

    local enabled
    read -p "Enable tracing? (Y/n): " -r enabled
    enabled=${enabled:-Y}
    if [[ "$enabled" =~ ^[Yy]$ ]]; then
        set_tracing_config "enabled" "true"
    else
        set_tracing_config "enabled" "false"
        echo "Tracing disabled."
        return 0
    fi

    echo ""
    local endpoint
    read -p "OTLP endpoint (default: http://localhost:4318): " -r endpoint
    endpoint=${endpoint:-http://localhost:4318}
    set_tracing_config "endpoint" "$endpoint"

    echo ""
    local sampling
    read -p "Sampling ratio (0.0-1.0, default: 1.0): " -r sampling
    sampling=${sampling:-1.0}
    set_tracing_config "sampling_ratio" "$sampling"

    echo ""
    echo -e "${GREEN}✓ Tracing configured successfully${NC}"
    echo ""
    echo "To install tracing dependencies:"
    echo "  bash ~/.local/share/ai-use-case-cli/scripts/utils/tracing.sh install-deps"
}
