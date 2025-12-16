#!/bin/bash
# Config Confluence - Confluence integration configuration for AI Use Case CLI
#
# This module manages Confluence REST API configuration including base URL,
# authentication credentials, and interactive setup for publishing documentation
# to Confluence Cloud.
#
# Usage:
#   source lib/core/constants.sh
#   source lib/config/config-core.sh
#   source lib/config/config-confluence.sh
#
#   configure_confluence    # Interactive setup
#   show_confluence_config  # Display config
#
# Dependencies:
#   - lib/core/constants.sh (for colors, CONFIG_FILE, CONFIG_DIR)
#   - lib/config/config-core.sh (for ensure_config_dir)
#   - jq (required for JSON manipulation)
#
# Functions:
#   - configure_confluence()      Interactive Confluence setup
#   - show_confluence_config()    Display Confluence configuration
#
# Security:
#   - API tokens are stored in config.json with 600 permissions
#   - Never commit config.json to version control
#   - Tokens are hidden in display output

# Source guard - prevent multiple sourcing
if [ -n "${_CONFIG_CONFLUENCE_SH_LOADED:-}" ]; then
    return 0
fi
readonly _CONFIG_CONFLUENCE_SH_LOADED=1

# Source dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../core/constants.sh"
source "$SCRIPT_DIR/config-core.sh"
source "$SCRIPT_DIR/../utils/file-utils.sh"

# ============================================================================
# Interactive Configuration
# ============================================================================

# Configure Confluence integration
# Interactive setup for Confluence REST API access
# Prompts for:
#   - Base URL (e.g., https://mycompany.atlassian.net)
#   - Email address
#   - API token (Personal Access Token)
# Validates inputs and stores securely with 600 permissions
#
# Usage:
#   configure_confluence
#
# Prerequisites:
#   - Confluence Cloud account
#   - Permission to create pages in target space
#   - Personal Access Token (PAT) or API token
#
# Token Generation:
#   Visit: https://id.atlassian.com/manage-profile/security/api-tokens
#   Or: {your-site}.atlassian.net/wiki/people/me/preferences/personal-access-tokens
#
# Returns:
#   0 on success, 1 on error
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
    setup_temp_file_cleanup "$temp_file"

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
        teardown_temp_file_cleanup
        return 1
    fi

    # Atomic move
    mv "$temp_file" "$CONFIG_FILE"

    # Remove trap and cleanup function
    teardown_temp_file_cleanup

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

# ============================================================================
# Display Configuration
# ============================================================================

# Show Confluence configuration
# Displays base URL, email, and auth method
# Hides API token for security
#
# Usage:
#   show_confluence_config
#
# Returns:
#   0 on success or not configured, 1 on error
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
