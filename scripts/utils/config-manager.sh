#!/bin/bash
# Configuration Manager for AI Use Case CLI
# Handles hub configuration: local-only or private git

# Configuration file location
CONFIG_DIR="$HOME/.config/ai-use-case-cli"
CONFIG_FILE="$CONFIG_DIR/config.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

    ensure_config_dir

    # Set default hub path based on mode
    if [ -z "$hub_path" ]; then
        if [ "$hub_mode" = "local" ]; then
            hub_path="$HOME/.local/share/ai-use-case-cli/hub"
        else
            hub_path="$HOME/Documents/ai-use-case-hub"
        fi
    fi

    cat > "$CONFIG_FILE" <<EOF
{
  "version": "1.0.0",
  "hubMode": "$hub_mode",
  "hubPath": "$hub_path",
  "gitUrl": "$git_url"
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

    # Default based on mode if not set
    if [ -z "$path" ]; then
        local mode=$(get_hub_mode)
        if [ "$mode" = "local" ]; then
            echo "$HOME/.local/share/ai-use-case-cli/hub"
        else
            echo "$HOME/Documents/ai-use-case-hub"
        fi
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

                read -p "Local hub directory path [$HOME/Documents/ai-use-case-hub]: " hub_path
                hub_path=${hub_path:-$HOME/Documents/ai-use-case-hub}

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
    echo -e "Hub Mode:  ${GREEN}$(get_hub_mode)${NC}"
    echo -e "Hub Path:  ${CYAN}$(get_hub_path)${NC}"

    if is_git_mode; then
        echo -e "Git URL:   ${CYAN}$(get_git_url)${NC}"
    fi

    echo ""
    echo -e "Config file: ${CYAN}$CONFIG_FILE${NC}"
}

# Function to get tracing configuration
get_tracing_config() {
    local tracing_config_file="$CONFIG_DIR/tracing.json"

    # Default tracing configuration (opt-in, not opt-out)
    local default_config='{
  "enabled": false,
  "endpoint": "http://localhost:4318",
  "sampling_ratio": 1.0,
  "export_timeout": 30
}'
    
    if [ -f "$tracing_config_file" ]; then
        cat "$tracing_config_file"
    else
        echo "$default_config"
    fi
}

# Function to set tracing configuration
set_tracing_config() {
    local key="$1"
    local value="$2"
    local tracing_config_file="$CONFIG_DIR/tracing.json"
    
    ensure_config_dir
    
    # Create config file if it doesn't exist
    if [ ! -f "$tracing_config_file" ]; then
        get_tracing_config > "$tracing_config_file"
    fi
    
    # Update the configuration using jq if available
    if command -v jq &> /dev/null; then
        local temp_file=$(mktemp)
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
        mv "$temp_file" "$tracing_config_file"
        echo "Updated tracing.$key = $value"
    else
        echo "jq not available. Please manually edit $tracing_config_file"
        echo "Set $key = $value"
    fi
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
        tracing)
            case "$2" in
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
                    echo "Available: show, configure, enable, disable, set"
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
  get <key>               Get configuration value
  set <key> <val>         Set configuration value
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
EOF
            ;;
        *)
            echo "Error: Unknown command '${1:-}'"
            echo "Run '$(basename "$0") --help' for usage"
            exit 1
            ;;
    esac
fi
