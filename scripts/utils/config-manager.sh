#!/bin/bash
# Configuration Manager for AI Use Case CLI
# Handles hub configuration: local-only, private git, or shared git

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

    echo -e "${GREEN}✓${NC} Configuration initialized: $CONFIG_FILE"
}

# Read configuration value
get_config() {
    local key="$1"

    if [ ! -f "$CONFIG_FILE" ]; then
        return 1
    fi

    # Simple JSON parsing (works for simple structure)
    grep "\"$key\"" "$CONFIG_FILE" | sed 's/.*: "\(.*\)".*/\1/' | tr -d ','
}

# Update configuration value
set_config() {
    local key="$1"
    local value="$2"

    if [ ! -f "$CONFIG_FILE" ]; then
        init_config
    fi

    # Create temporary file with updated value
    local temp_file=$(mktemp)

    # Simple JSON update (works for simple structure)
    sed "s|\"$key\": \"[^\"]*\"|\"$key\": \"$value\"|" "$CONFIG_FILE" > "$temp_file"

    mv "$temp_file" "$CONFIG_FILE"

    echo -e "${GREEN}✓${NC} Configuration updated: $key = $value"
}

# Get hub mode (local, private-git, shared-git)
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
    local url=$(get_config "gitUrl")

    # Default to shared hub if not set
    if [ -z "$url" ]; then
        echo "https://github.com/mt-osiris-tools/ai-use-case-hub.git"
    else
        echo "$url"
    fi
}

# Check if hub mode uses git
is_git_mode() {
    local mode=$(get_hub_mode)
    [ "$mode" = "private-git" ] || [ "$mode" = "shared-git" ]
}

# Interactive hub mode selection
prompt_hub_mode() {
    echo -e "${BLUE}=== Hub Configuration ===${NC}"
    echo ""
    echo "How would you like to store AI use case documentation?"
    echo ""
    echo -e "  ${GREEN}1${NC}. Local only (no git repository)"
    echo "     Files stored locally, no version control or remote sync"
    echo ""
    echo -e "  ${GREEN}2${NC}. Private git repository"
    echo "     Connect to your own private repository for version control"
    echo ""
    echo -e "  ${GREEN}3${NC}. Shared hub repository (default)"
    echo "     Use the shared mt-osiris-tools hub for collaboration"
    echo ""

    while true; do
        read -p "Select option (1-3) [3]: " choice
        choice=${choice:-3}

        case $choice in
            1)
                echo ""
                echo -e "${BLUE}Local mode selected${NC}"
                read -p "Hub directory path [$HOME/.local/share/ai-use-case-cli/hub]: " hub_path
                hub_path=${hub_path:-$HOME/.local/share/ai-use-case-cli/hub}

                init_config "local" "$hub_path" ""
                echo "$hub_path"
                return 0
                ;;
            2)
                echo ""
                echo -e "${BLUE}Private git mode selected${NC}"
                read -p "Git repository URL: " git_url

                if [ -z "$git_url" ]; then
                    echo -e "${RED}Error: Git URL is required for private git mode${NC}"
                    continue
                fi

                read -p "Local hub directory path [$HOME/Documents/ai-use-case-hub]: " hub_path
                hub_path=${hub_path:-$HOME/Documents/ai-use-case-hub}

                init_config "private-git" "$hub_path" "$git_url"
                echo "$hub_path"
                return 0
                ;;
            3)
                echo ""
                echo -e "${BLUE}Shared hub mode selected${NC}"
                read -p "Local hub directory path [$HOME/Documents/ai-use-case-hub]: " hub_path
                hub_path=${hub_path:-$HOME/Documents/ai-use-case-hub}

                init_config "shared-git" "$hub_path" "https://github.com/mt-osiris-tools/ai-use-case-hub.git"
                echo "$hub_path"
                return 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please select 1, 2, or 3.${NC}"
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

# Main function for standalone execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
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
  init              Interactive hub mode selection
  show              Show current configuration
  mode              Get hub mode
  path              Get hub path
  url               Get git URL
  is-git            Check if git mode is enabled
  get <key>         Get configuration value
  set <key> <val>   Set configuration value

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
