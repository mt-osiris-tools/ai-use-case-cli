#!/bin/bash
# Configuration Manager for AI Use Case CLI
# Handles hub configuration: local-only or private git

# Configuration file location
CONFIG_DIR="$HOME/.config/ai-use-case-cli"
CONFIG_FILE="$CONFIG_DIR/config.json"

# Colors for output - only set if not already defined (allows parent script to control)
# Respects NO_COLOR (https://no-color.org/) and FORCE_COLOR environment variables
if [ -z "${GREEN:-}" ]; then
    if [[ -t 1 || -n "${FORCE_COLOR:-}" ]] && [[ -z "${NO_COLOR:-}" ]]; then
        # Colors enabled (TTY detected or FORCE_COLOR set, and NO_COLOR not set)
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        RED='\033[0;31m'
        CYAN='\033[0;36m'
        BOLD='\033[1m'
        NC='\033[0m'
    else
        # Colors disabled (not a TTY, piped, redirected, or NO_COLOR set)
        GREEN=''
        YELLOW=''
        BLUE=''
        RED=''
        CYAN=''
        BOLD=''
        NC=''
    fi
fi

# Default tracing configuration (single source of truth)
readonly DEFAULT_TRACING_CONFIG='{
  "enabled": false,
  "endpoint": "http://localhost:4318",
  "sampling_ratio": 1.0,
  "export_timeout": 30
}'

# Ensure config directory exists
ensure_config_dir() {
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
    fi
}

# Validate directory path
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

# Initialize default configuration
init_config() {
    local hub_mode="${1:-local}"
    local hub_path="${2:-}"
    local git_url="${3:-}"
    local git_required="${4:-false}"

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
  "gitRequired": $git_required
}
EOF

    echo -e "${GREEN}✓${NC} Configuration initialized: $CONFIG_FILE" >&2
}

# Read configuration value
# Note: Uses simple sed/grep parsing suitable for our flat JSON structure.
# This avoids requiring jq as a dependency. If the JSON structure becomes
# more complex (nested objects, arrays), consider using jq instead.
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

    # Ensure temp file is cleaned up on exit or interruption
    cleanup_temp_file() {
        [ -f "$temp_file" ] && rm -f "$temp_file"
    }
    trap cleanup_temp_file EXIT INT TERM

    # Simple JSON update (works for simple structure)
    sed "s|\"$key\": \"[^\"]*\"|\"$key\": \"$value\"|" "$CONFIG_FILE" > "$temp_file"

    # Atomically move temp file to config file
    mv "$temp_file" "$CONFIG_FILE"

    # Remove trap and cleanup function
    trap - EXIT INT TERM
    unset -f cleanup_temp_file

    echo -e "${GREEN}✓${NC} Configuration updated: $key = $value"
}

# Get hub mode (local, private-git)
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
get_hub_path() {
    # Check environment variable first (highest priority)
    if [ -n "$AI_USECASES_DIR" ]; then
        echo "$AI_USECASES_DIR"
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
is_git_mode() {
    local mode=$(get_hub_mode)
    [ "$mode" = "private-git" ]
}

# Get git required status
get_git_required() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "false"
        return 0
    fi

    # Parse gitRequired field (boolean, not quoted in JSON)
    local git_required=$(grep "\"gitRequired\"" "$CONFIG_FILE" | sed 's/.*: *\([^,}]*\).*/\1/' | tr -d ' ')

    # Default to false if not set
    if [ -z "$git_required" ] || [ "$git_required" = "null" ]; then
        echo "false"
    else
        echo "$git_required"
    fi
}

# Check if git is required for projects
is_git_required() {
    local required=$(get_git_required)
    [ "$required" = "true" ]
}

# Set git required status
set_git_required() {
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
        trap "rm -f '$temp_file'" EXIT

        # Convert string to boolean for jq
        local bool_value=$( [ "$value" = "true" ] && echo "true" || echo "false" )

        # Add or update gitRequired field
        if grep -q '"gitRequired"' "$CONFIG_FILE"; then
            jq --argjson required "$bool_value" '.gitRequired = $required' "$CONFIG_FILE" > "$temp_file"
        else
            jq --argjson required "$bool_value" '. + {gitRequired: $required}' "$CONFIG_FILE" > "$temp_file"
        fi

        if [ -s "$temp_file" ] && jq empty "$temp_file" 2>/dev/null; then
            mv "$temp_file" "$CONFIG_FILE"
            trap - EXIT
        else
            echo -e "${RED}Error: Failed to update configuration${NC}" >&2
            trap - EXIT
            rm -f "$temp_file"
            return 1
        fi
    else
        # Fallback: simple sed-based update
        # Cross-platform sed -i (BSD/macOS vs GNU/Linux)
        if grep -q '"gitRequired"' "$CONFIG_FILE"; then
            if [[ "$(uname)" == "Darwin" ]]; then
                sed -i '' "s|\"gitRequired\": [^,}]*|\"gitRequired\": $value|" "$CONFIG_FILE"
            else
                sed -i "s|\"gitRequired\": [^,}]*|\"gitRequired\": $value|" "$CONFIG_FILE"
            fi
        else
            # Add field before closing brace
            if [[ "$(uname)" == "Darwin" ]]; then
                sed -i '' "s|}$|,\n  \"gitRequired\": $value\n}|" "$CONFIG_FILE"
            else
                sed -i "s|}$|,\n  \"gitRequired\": $value\n}|" "$CONFIG_FILE"
            fi
        fi
    fi

    echo -e "${GREEN}✓${NC} Git requirement: $( [ "$value" = "true" ] && echo "enabled" || echo "disabled" )"
}

# Get installation mode (light or full)
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

# Get advanced enabled status
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
# Returns 0 (true) if enabled, 1 (false) if disabled
is_advanced_enabled() {
    local advanced=$(get_advanced_enabled)
    [ "$advanced" = "true" ]
}

# Set installation mode
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
        trap "rm -f '$temp_file'" EXIT

        # Add or update installMode field
        if grep -q '"installMode"' "$CONFIG_FILE"; then
            jq --arg mode "$mode" '.installMode = $mode' "$CONFIG_FILE" > "$temp_file"
        else
            jq --arg mode "$mode" '. + {installMode: $mode}' "$CONFIG_FILE" > "$temp_file"
        fi

        if [ -s "$temp_file" ] && jq empty "$temp_file" 2>/dev/null; then
            mv "$temp_file" "$CONFIG_FILE"
            trap - EXIT
        else
            echo -e "${RED}Error: Failed to update configuration${NC}" >&2
            rm -f "$temp_file"
            trap - EXIT
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

# Set advanced enabled status
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
        trap "rm -f '$temp_file'" EXIT

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
            trap - EXIT
        else
            echo -e "${RED}Error: Failed to update configuration${NC}" >&2
            trap - EXIT
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

# Interactive hub mode selection
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

# Show current configuration
show_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}No configuration found${NC}"
        echo "Run 'ai-use-case --init' to configure"
        return 1
    fi

    echo -e "${BLUE}=== Current Configuration ===${NC}"
    echo ""
    echo -e "Hub Mode:      ${GREEN}$(get_hub_mode)${NC}"
    echo -e "Hub Path:      ${CYAN}$(get_hub_path)${NC}"

    if is_git_mode; then
        echo -e "Git URL:       ${CYAN}$(get_git_url)${NC}"
    fi

    local git_req=$(get_git_required)
    if [ "$git_req" = "true" ]; then
        echo -e "Git Required:  ${GREEN}Yes${NC} (projects must be git repositories)"
    else
        echo -e "Git Required:  ${YELLOW}No${NC} (projects can be non-git directories)"
    fi

    echo ""
    echo -e "Config file: ${CYAN}$CONFIG_FILE${NC}"
}

# Function to validate and repair tracing configuration
validate_and_repair_tracing_config() {
    local tracing_config_file="$CONFIG_DIR/tracing.json"

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

# Function to initialize tracing configuration (atomic operation)
init_tracing_config() {
    local tracing_config_file="$CONFIG_DIR/tracing.json"
    local temp_file=$(mktemp)

    # Ensure config directory exists
    ensure_config_dir

    # Write to temp file first (using shared constant)
    echo "$DEFAULT_TRACING_CONFIG" > "$temp_file"

    # Validate the content
    if [ ! -s "$temp_file" ]; then
        echo -e "${RED}Error: Failed to create tracing configuration${NC}" >&2
        rm -f "$temp_file"
        return 1
    fi

    # Validate JSON syntax if jq available
    if command -v jq &> /dev/null; then
        if ! jq empty "$temp_file" 2>/dev/null; then
            echo -e "${RED}Error: Invalid JSON in tracing configuration${NC}" >&2
            rm -f "$temp_file"
            return 1
        fi
    fi

    # Atomic move (safer than cp)
    if ! mv "$temp_file" "$tracing_config_file" 2>/dev/null; then
        echo -e "${RED}Error: Failed to save tracing configuration${NC}" >&2
        rm -f "$temp_file"
        return 1
    fi

    echo -e "${GREEN}✓${NC} Tracing configuration initialized" >&2
    return 0
}

# Function to get tracing configuration
get_tracing_config() {
    local tracing_config_file="$CONFIG_DIR/tracing.json"

    if [ -f "$tracing_config_file" ]; then
        cat "$tracing_config_file"
    else
        echo "$DEFAULT_TRACING_CONFIG"
    fi
}

# Function to set tracing configuration
set_tracing_config() {
    local key="$1"
    local value="$2"
    local tracing_config_file="$CONFIG_DIR/tracing.json"

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
    # Setup cleanup trap (EXIT only to avoid firing on every function return)
    trap "rm -f '$temp_file'" EXIT

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
        trap - EXIT
        rm -f "$temp_file"
        return 1
    fi

    if ! jq empty "$temp_file" 2>/dev/null; then
        echo -e "${RED}Error: Failed to update configuration (invalid JSON)${NC}" >&2
        trap - EXIT
        rm -f "$temp_file"
        return 1
    fi

    # Atomic move
    if ! mv "$temp_file" "$tracing_config_file" 2>/dev/null; then
        echo -e "${RED}Error: Failed to save configuration${NC}" >&2
        trap - EXIT
        rm -f "$temp_file"
        return 1
    fi

    trap - EXIT
    echo "Updated tracing.$key = $value"
    return 0
}

# Function to show tracing configuration
show_tracing_config() {
    local tracing_config_file="$CONFIG_DIR/tracing.json"
    
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

# Function to configure tracing interactively
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

# Function to configure Confluence integration
configure_confluence() {
    echo -e "${BLUE}=== Configure Confluence Integration ===${NC}"
    echo ""
    echo "This will configure Confluence REST API access for publishing documentation."
    echo ""
    echo -e "${YELLOW}Prerequisites:${NC}"
    echo "  1. A Confluence Cloud account"
    echo "  2. Permission to create pages in your target space"
    echo "  3. A Personal Access Token (PAT) or API token"
    echo ""
    echo -e "${CYAN}Generate API Token:${NC}"
    echo "  Visit: https://id.atlassian.com/manage-profile/security/api-tokens"
    echo "  Or: {your-site}.atlassian.net/wiki/people/me/preferences/personal-access-tokens"
    echo ""
    
    read -p "Press Enter to continue or Ctrl+C to cancel..."
    echo ""
    
    # Get base URL
    local base_url
    read -p "Confluence base URL (e.g., https://mycompany.atlassian.net): " -r base_url
    if [ -z "$base_url" ]; then
        echo -e "${RED}Error: Base URL is required${NC}" >&2
        return 1
    fi
    
    # Remove trailing slash if present
    base_url="${base_url%/}"
    
    # Validate URL format
    if ! [[ "$base_url" =~ ^https?:// ]]; then
        echo -e "${YELLOW}Warning: URL should start with http:// or https://${NC}"
        read -p "Continue anyway? (y/N): " -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    echo ""
    
    # Get email
    local email
    read -p "Your Confluence email address: " -r email
    if [ -z "$email" ]; then
        echo -e "${RED}Error: Email is required${NC}" >&2
        return 1
    fi
    
    echo ""
    
    # Get API token
    local api_token
    read -sp "API Token (input hidden): " api_token
    echo ""

    # Trim leading/trailing whitespace
    api_token="$(echo -n "$api_token" | xargs)"

    if [ -z "$api_token" ]; then
        echo -e "${RED}Error: API token is required${NC}" >&2
        return 1
    fi

    # Check minimum length (Atlassian tokens are typically 24+ chars)
    if [ "${#api_token}" -lt 24 ]; then
        echo -e "${YELLOW}Warning: API token is unusually short (${#api_token} characters). Atlassian tokens are typically 24+ characters.${NC}"
        read -p "Continue anyway? (y/N): " -r short_confirm
        if [[ ! "$short_confirm" =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi

    # Warn if token contains spaces (likely a password or copy-paste error)
    if [[ "$api_token" =~ [[:space:]] ]]; then
        echo -e "${YELLOW}Warning: API token contains whitespace. This may indicate a copy-paste error or a password, not an API token.${NC}"
        read -p "Continue anyway? (y/N): " -r space_confirm
        if [[ ! "$space_confirm" =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    echo ""
    
    # Save to config
    ensure_config_dir
    
    # Create or update config with confluence section
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq not available. Cannot update configuration safely.${NC}" >&2
        echo "Install jq: sudo apt-get install jq  # or appropriate package manager" >&2
        return 1
    fi
    
    local temp_file=$(mktemp)
    trap "rm -f '$temp_file'" EXIT
    
    # Add or update confluence section
    if [ ! -f "$CONFIG_FILE" ]; then
        # Create new config with confluence section
        jq -n \
            --arg baseUrl "$base_url" \
            --arg email "$email" \
            --arg apiToken "$api_token" \
            '{
                version: "1.0.0",
                hubMode: "local",
                hubPath: ($ENV.HOME + "/.local/share/ai-use-case-cli/hub"),
                gitUrl: "",
                confluence: {
                    baseUrl: $baseUrl,
                    email: $email,
                    apiToken: $apiToken,
                    authMethod: "api-token"
                }
            }' > "$temp_file"
    else
        # Update existing config with confluence section
        jq \
            --arg baseUrl "$base_url" \
            --arg email "$email" \
            --arg apiToken "$api_token" \
            '.confluence = {
                baseUrl: $baseUrl,
                email: $email,
                apiToken: $apiToken,
                authMethod: "api-token"
            }' "$CONFIG_FILE" > "$temp_file"
    fi
    
    # Validate temp file
    if [ ! -s "$temp_file" ] || ! jq empty "$temp_file" 2>/dev/null; then
        echo -e "${RED}Error: Failed to update configuration${NC}" >&2
        trap - EXIT
        rm -f "$temp_file"
        return 1
    fi
    
    # Atomic move
    mv "$temp_file" "$CONFIG_FILE"
    trap - EXIT
    
    # Set restrictive permissions on config file (contains API token)
    chmod 600 "$CONFIG_FILE"
    
    echo ""
    echo -e "${GREEN}✓ Confluence integration configured successfully${NC}"
    echo ""
    echo -e "${CYAN}Configuration saved to:${NC} $CONFIG_FILE"
    echo -e "${CYAN}File permissions:${NC} 600 (owner read/write only)"
    echo ""
    echo -e "${YELLOW}Test the integration:${NC}"
    echo "  ai-use-case publish-confluence --help"
    echo ""
    echo -e "${YELLOW}Security Note:${NC}"
    echo "  Your API token is stored locally in $CONFIG_FILE"
    echo "  Keep this file secure and never commit it to version control"
    echo "  The file has restricted permissions (600) for security"
}

# Function to show Confluence configuration
show_confluence_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}No configuration found${NC}"
        echo "Run 'ai-use-case config confluence' to configure"
        return 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq not available${NC}" >&2
        return 1
    fi
    
    echo -e "${BLUE}=== Confluence Configuration ===${NC}"
    echo ""
    
    local has_confluence
    has_confluence=$(jq -r '.confluence // empty' "$CONFIG_FILE" 2>/dev/null)
    
    if [ -z "$has_confluence" ]; then
        echo -e "${YELLOW}Confluence not configured${NC}"
        echo "Run 'ai-use-case config confluence' to configure"
        return 0
    fi
    
    local base_url email auth_method
    base_url=$(jq -r '.confluence.baseUrl // "not set"' "$CONFIG_FILE")
    email=$(jq -r '.confluence.email // "not set"' "$CONFIG_FILE")
    auth_method=$(jq -r '.confluence.authMethod // "api-token"' "$CONFIG_FILE")
    
    echo -e "${GREEN}Base URL:${NC}      $base_url"
    echo -e "${GREEN}Email:${NC}         $email"
    echo -e "${GREEN}Auth Method:${NC}   $auth_method"
    echo -e "${GREEN}API Token:${NC}     ${CYAN}(configured - hidden for security)${NC}"
    echo ""
    echo -e "${CYAN}Config file:${NC} $CONFIG_FILE"
}

# Main CLI interface
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    case "${1:-}" in
        init)
            shift
            prompt_hub_mode
            ;;
        get)
            get_config "${2:-}"
            ;;
        set)
            set_config "${2:-}" "${3:-}"
            ;;
        confluence)
            case "$2" in
                show)
                    show_confluence_config
                    ;;
                configure|setup)
                    configure_confluence
                    ;;
                *)
                    if [ -z "$2" ]; then
                        # Default action: configure
                        configure_confluence
                    else
                        echo "Error: Unknown confluence command '${2:-}'"
                        echo "Available: show, configure"
                        exit 1
                    fi
                    ;;
            esac
            ;;
        tracing)
            case "$2" in
                init)
                    echo -e "${BLUE}Initializing tracing configuration...${NC}"
                    if ! init_tracing_config; then
                        exit 1
                    fi
                    echo ""
                    echo -e "${CYAN}Checking dependencies...${NC}"
                    # Get script directory
                    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

                    # Check if tracing dependencies are available (more robust than parsing output)
                    # Source the tracing script to access TRACING_AVAILABLE variable
                    if source "$SCRIPT_DIR/tracing.sh" && [ "$TRACING_AVAILABLE" = true ]; then
                        echo -e "${GREEN}✓${NC} Tracing dependencies already installed"
                    else
                        echo -e "${YELLOW}Installing tracing dependencies...${NC}"
                        bash "$SCRIPT_DIR/tracing.sh" install-deps
                    fi
                    echo ""
                    echo -e "${GREEN}╭────────────────────────────────────────────────────────────╮${NC}"
                    echo -e "${GREEN}│${NC} ${BOLD}Tracing Initialization Complete${NC}                       ${GREEN}│${NC}"
                    echo -e "${GREEN}╰────────────────────────────────────────────────────────────╯${NC}"
                    echo ""
                    echo -e "${CYAN}Next steps:${NC}"
                    echo "  • Run: ${GREEN}ai-use-case tracing enable${NC}       (Enable tracing)"
                    echo "  • Run: ${GREEN}ai-use-case tracing configure${NC}    (Custom settings)"
                    echo "  • Run: ${GREEN}ai-use-case tracing test${NC}         (Test functionality)"
                    echo ""
                    ;;
                show)
                    show_tracing_config
                    ;;
                configure)
                    configure_tracing
                    ;;
                enable)
                    set_tracing_config "enabled" "true"
                    ;;
                disable)
                    set_tracing_config "enabled" "false"
                    ;;
                set)
                    if [ -z "$3" ] || [ -z "$4" ]; then
                        echo "Error: Usage: tracing set <key> <value>"
                        exit 1
                    fi
                    set_tracing_config "$3" "$4"
                    ;;
                *)
                    echo "Error: Unknown tracing command '${2:-}'"
                    echo "Available: init, show, configure, enable, disable, set"
                    exit 1
                    ;;
            esac
            ;;
        show)
            show_config
            ;;
        mode)
            get_hub_mode
            ;;
        path)
            get_hub_path
            ;;
        url)
            get_git_url
            ;;
        is-git)
            if is_git_mode; then
                echo "yes"
                exit 0
            else
                echo "no"
                exit 1
            fi
            ;;
        git-required)
            get_git_required
            ;;
        is-git-required)
            if is_git_required; then
                echo "yes"
                exit 0
            else
                echo "no"
                exit 1
            fi
            ;;
        set-git-required)
            set_git_required "${2:-}"
            ;;
        --help|-h)
            cat <<EOF
Configuration Manager for AI Use Case CLI

Usage:
  $(basename "$0") <command> [args]

Commands:
  init                    Interactive hub mode selection
  show                    Show current configuration
  mode                    Get hub mode
  path                    Get hub path
  url                     Get git URL
  is-git                  Check if git mode is enabled
  git-required            Get git required status
  is-git-required         Check if git is required for projects
  set-git-required <bool> Set git required status (true/false)
  get <key>               Get configuration value
  set <key> <val>         Set configuration value
  confluence <subcommand> Manage Confluence integration
    show                  Show Confluence configuration
    configure             Interactive Confluence setup
  tracing <subcommand>    Manage tracing configuration
    show                  Show tracing configuration
    configure             Interactive tracing setup
    enable                Enable tracing
    disable               Disable tracing
    set <key> <value>     Set tracing configuration value

Examples:
  $(basename "$0") init
  $(basename "$0") show
  $(basename "$0") mode
  $(basename "$0") set-git-required true
  $(basename "$0") confluence configure
  $(basename "$0") confluence show
EOF
            ;;
        *)
            echo "Error: Unknown command '${1:-}'"
            echo "Run '$(basename "$0") --help' for usage"
            exit 1
            ;;
    esac
fi
