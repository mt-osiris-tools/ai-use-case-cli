#!/bin/bash
# Publish AI Use Case Documentation to Confluence
# Creates a child page under a specified parent page
#
# Supports multiple integration methods:
#   1. Atlassian MCP server (via AI coding assistants)
#   2. Confluence REST API with API token (universal)
#   3. Confluence REST API with OAuth (enterprise)
#
# Usage:
#   publish-confluence.sh [options] <markdown-file> <parent-page-url>
#
# Options:
#   --title <title>          Override page title (default: from filename)
#   --space <space-key>      Confluence space key (default: from URL)
#   --api-token <token>      Confluence API token (or use config/env)
#   --base-url <url>         Confluence base URL (or use config)
#   --email <email>          User email for API auth (or use config)
#   --dry-run                Show what would be published without doing it
#   --help                   Show this help message
#
# Authentication Methods (in order of precedence):
#   1. Command-line options (--api-token, --base-url, --email)
#   2. Environment variables (CONFLUENCE_API_TOKEN, CONFLUENCE_BASE_URL, CONFLUENCE_EMAIL)
#   3. Configuration file (~/.config/ai-use-case-cli/config.json)
#   4. MCP server (if available - for AI assistants only)
#
# Prerequisites:
#   - One authentication method configured (see above)
#   - curl (for REST API calls)
#   - Permission to create pages in target Confluence space

set -e

# Colors
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_MANAGER="$SCRIPT_DIR/../utils/config-manager.sh"
DRY_RUN=false
CUSTOM_TITLE=""
CUSTOM_SPACE=""
API_TOKEN=""
BASE_URL=""
USER_EMAIL=""
USE_REST_API=false

# Show help
show_help() {
    cat <<EOF
${BLUE}publish-confluence.sh${NC} - Publish AI use case documentation to Confluence

${YELLOW}Usage:${NC}
  publish-confluence.sh [options] <markdown-file> <parent-page-url>

${YELLOW}Arguments:${NC}
  ${GREEN}<markdown-file>${NC}       Path to markdown file to publish
  ${GREEN}<parent-page-url>${NC}     Confluence parent page URL

${YELLOW}Options:${NC}
  ${GREEN}--title <title>${NC}          Override page title (default: from filename)
  ${GREEN}--space <space-key>${NC}      Confluence space key (default: from URL)
  ${GREEN}--api-token <token>${NC}      Confluence API token (or use config/env)
  ${GREEN}--base-url <url>${NC}         Confluence base URL (or use config)
  ${GREEN}--email <email>${NC}          User email for API auth (or use config)
  ${GREEN}--dry-run${NC}                Show what would be published without doing it
  ${GREEN}--help, -h${NC}               Show this help message

${YELLOW}Authentication Methods:${NC}
  1. Command-line options (--api-token, --base-url, --email)
  2. Environment variables (CONFLUENCE_API_TOKEN, CONFLUENCE_BASE_URL, CONFLUENCE_EMAIL)
  3. Configuration file (~/.config/ai-use-case-cli/config.json)

${YELLOW}Prerequisites:${NC}
  - One authentication method configured (see above)
  - curl (for REST API calls)
  - Permission to create pages in target Confluence space

${YELLOW}Examples:${NC}
  # Basic usage
  publish-confluence.sh \\
    docs/ai-use-cases/2025-10-16_PROJ-123_auth.md \\
    https://company.atlassian.net/wiki/spaces/DOCS/pages/123456/Parent

  # With custom title
  publish-confluence.sh --title "PROJ-123: Full Implementation" \\
    docs/ai-use-cases/2025-10-16_PROJ-123_auth.md \\
    https://company.atlassian.net/wiki/spaces/DOCS/pages/123456/Parent

  # Dry run to preview
  publish-confluence.sh --dry-run \\
    docs/ai-use-cases/2025-10-16_PROJ-123_auth.md \\
    https://company.atlassian.net/wiki/spaces/DOCS/pages/123456/Parent

${YELLOW}Confluence URL Formats:${NC}
  Supported URL patterns:
  - https://{site}.atlassian.net/wiki/spaces/{space}/pages/{pageId}/{title}
  - https://{site}.atlassian.net/wiki/spaces/{space}/pages/edit-v2/{pageId}

${YELLOW}Authentication Setup:${NC}
  ${CYAN}Option 1: Configuration file (recommended)${NC}
    Run: ai-use-case config confluence
    This will prompt for API token, base URL, and email

  ${CYAN}Option 2: Environment variables${NC}
    export CONFLUENCE_API_TOKEN="your-api-token"
    export CONFLUENCE_BASE_URL="https://your-site.atlassian.net"
    export CONFLUENCE_EMAIL="your-email@company.com"

  ${CYAN}Option 3: Command-line options${NC}
    Use --api-token, --base-url, and --email flags

  ${CYAN}Generate API Token:${NC}
    https://your-site.atlassian.net/wiki/people/me/preferences/personal-access-tokens

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --title)
                CUSTOM_TITLE="$2"
                shift 2
                ;;
            --space)
                CUSTOM_SPACE="$2"
                shift 2
                ;;
            --api-token)
                API_TOKEN="$2"
                USE_REST_API=true
                shift 2
                ;;
            --base-url)
                BASE_URL="$2"
                USE_REST_API=true
                shift 2
                ;;
            --email)
                USER_EMAIL="$2"
                USE_REST_API=true
                shift 2
                ;;
            -*)
                echo -e "${RED}Error: Unknown option '$1'${NC}" >&2
                echo "Run with --help for usage information" >&2
                exit 1
                ;;
            *)
                # Positional arguments
                if [ -z "$MARKDOWN_FILE" ]; then
                    MARKDOWN_FILE="$1"
                elif [ -z "$PARENT_URL" ]; then
                    PARENT_URL="$1"
                else
                    echo -e "${RED}Error: Too many arguments${NC}" >&2
                    echo "Run with --help for usage information" >&2
                    exit 1
                fi
                shift
                ;;
        esac
    done

    # Validate required arguments
    if [ -z "$MARKDOWN_FILE" ]; then
        echo -e "${RED}Error: Markdown file not specified${NC}" >&2
        echo "Run with --help for usage information" >&2
        exit 1
    fi

    if [ -z "$PARENT_URL" ]; then
        echo -e "${RED}Error: Parent page URL not specified${NC}" >&2
        echo "Run with --help for usage information" >&2
        exit 1
    fi
}

# Validate markdown file exists
validate_file() {
    if [ ! -f "$MARKDOWN_FILE" ]; then
        echo -e "${RED}✗ Error: Markdown file not found${NC}" >&2
        echo "  File: $MARKDOWN_FILE" >&2
        exit 1
    fi

    if [ ! -r "$MARKDOWN_FILE" ]; then
        echo -e "${RED}✗ Error: Markdown file is not readable${NC}" >&2
        echo "  File: $MARKDOWN_FILE" >&2
        exit 1
    fi

    echo -e "${GREEN}✓${NC} Markdown file found: $(basename "$MARKDOWN_FILE")"
}

# Extract title from filename
extract_title() {
    local filename=$(basename "$MARKDOWN_FILE" .md)

    # Pattern: YYYY-Www-MM-DD_TICKET-XXX_description-slug
    if [[ $filename =~ ^([0-9]{4})-(W[0-9]{2})-[0-9]{2}-[0-9]{2}_([A-Z]+-[0-9]+)_(.+)$ ]]; then
        local year="${BASH_REMATCH[1]}"  # 2025
        local week="${BASH_REMATCH[2]}"  # W45
        local ticket="${BASH_REMATCH[3]}"  # FEATURE-001
        local slug="${BASH_REMATCH[4]}"  # description-slug

        # Convert slug to title case
        local title=$(echo "$slug" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

        # Format: 🎯 2025 W45 | TICKET-ID: Title
        echo "🎯 ${year} ${week} | ${ticket}: ${title}"
    else
        # Fallback: just use filename with underscores converted to spaces
        echo "$filename" | sed 's/_/ /g'
    fi
}

# Parse Confluence URL
parse_confluence_url() {
    local url="$1"

    # Extract domain
    if [[ $url =~ https?://([^/]+\.atlassian\.net) ]]; then
        CONFLUENCE_DOMAIN="${BASH_REMATCH[1]}"
    else
        echo -e "${RED}✗ Error: Invalid Confluence URL${NC}" >&2
        echo "  Expected: https://{site}.atlassian.net/wiki/..." >&2
        echo "  Provided: $url" >&2
        exit 1
    fi

    # Extract space key and page ID
    # Pattern 1: /wiki/spaces/{space}/pages/{pageId}/...
    if [[ $url =~ /wiki/spaces/([^/]+)/pages/([0-9]+) ]]; then
        CONFLUENCE_SPACE="${BASH_REMATCH[1]}"
        CONFLUENCE_PAGE_ID="${BASH_REMATCH[2]}"
    # Pattern 2: /wiki/spaces/{space}/pages/edit-v2/{pageId}
    elif [[ $url =~ /wiki/spaces/([^/]+)/pages/edit-v2/([0-9]+) ]]; then
        CONFLUENCE_SPACE="${BASH_REMATCH[1]}"
        CONFLUENCE_PAGE_ID="${BASH_REMATCH[2]}"
    else
        echo -e "${RED}✗ Error: Could not extract page ID from URL${NC}" >&2
        echo "  Supported formats:" >&2
        echo "    - https://{site}.atlassian.net/wiki/spaces/{space}/pages/{pageId}/..." >&2
        echo "    - https://{site}.atlassian.net/wiki/spaces/{space}/pages/edit-v2/{pageId}" >&2
        echo "  Provided: $url" >&2
        exit 1
    fi

    # Override space if provided
    if [ -n "$CUSTOM_SPACE" ]; then
        CONFLUENCE_SPACE="$CUSTOM_SPACE"
    fi

    echo -e "${GREEN}✓${NC} Parsed Confluence URL:"
    echo "  Domain: $CONFLUENCE_DOMAIN"
    echo "  Space: $CONFLUENCE_SPACE"
    echo "  Parent Page ID: $CONFLUENCE_PAGE_ID"
}

# Get file size in KB
get_file_size() {
    local size_bytes=$(stat -c%s "$MARKDOWN_FILE" 2>/dev/null || stat -f%z "$MARKDOWN_FILE" 2>/dev/null)
    echo "scale=1; $size_bytes / 1024" | bc
}

# Load Confluence configuration from config file
load_confluence_config() {
    if [ -f "$CONFIG_MANAGER" ]; then
        # Try to get confluence config from config file
        local config_file="$HOME/.config/ai-use-case-cli/config.json"
        if [ -f "$config_file" ] && command -v jq &>/dev/null; then
            # Load from config if not already set via command line or env
            if [ -z "$API_TOKEN" ] && [ -z "$CONFLUENCE_API_TOKEN" ]; then
                API_TOKEN=$(jq -r '.confluence.apiToken // empty' "$config_file" 2>/dev/null)
            fi
            if [ -z "$BASE_URL" ] && [ -z "$CONFLUENCE_BASE_URL" ]; then
                BASE_URL=$(jq -r '.confluence.baseUrl // empty' "$config_file" 2>/dev/null)
            fi
            if [ -z "$USER_EMAIL" ] && [ -z "$CONFLUENCE_EMAIL" ]; then
                USER_EMAIL=$(jq -r '.confluence.email // empty' "$config_file" 2>/dev/null)
            fi
        fi
    fi

    # Fall back to environment variables
    if [ -z "$API_TOKEN" ]; then
        API_TOKEN="${CONFLUENCE_API_TOKEN:-}"
    fi
    if [ -z "$BASE_URL" ]; then
        BASE_URL="${CONFLUENCE_BASE_URL:-}"
    fi
    if [ -z "$USER_EMAIL" ]; then
        USER_EMAIL="${CONFLUENCE_EMAIL:-}"
    fi
}

# Check if REST API authentication is configured
check_rest_api_auth() {
    load_confluence_config

    if [ -n "$API_TOKEN" ] && [ -n "$BASE_URL" ] && [ -n "$USER_EMAIL" ]; then
        USE_REST_API=true
        return 0
    fi
    return 1
}

# Convert basic markdown to Confluence storage format
# NOTE: This is a simplified converter suitable for basic markdown.
# 
# Supported:
#   - Headers (h1-h6)
#   - Bold and italic (simple cases)
#   - Links
#   - Basic paragraphs
#
# NOT supported (will be rendered as-is or may break):
#   - Code blocks (will appear as plain text)
#   - Tables (will not render as tables)
#   - Images (will not be embedded)
#   - Nested formatting (e.g., **bold _italic_**)
#   - Lists (bullets/numbered)
#   - Blockquotes
#   - Literal asterisks or special characters
#
# For documents with complex formatting, consider:
#   1. Using a proper markdown-to-confluence converter
#   2. Manual formatting in Confluence after publishing
#   3. Using Confluence's built-in markdown import
#
convert_markdown_to_confluence() {
    local markdown_content="$1"
    
    # Basic conversion - handles simple markdown only
    # Convert headers
    local html_content
    html_content=$(echo "$markdown_content" | sed -E '
        s/^# (.+)$/<h1>\1<\/h1>/g
        s/^## (.+)$/<h2>\1<\/h2>/g
        s/^### (.+)$/<h3>\1<\/h3>/g
        s/^#### (.+)$/<h4>\1<\/h4>/g
        s/^##### (.+)$/<h5>\1<\/h5>/g
        s/^###### (.+)$/<h6>\1<\/h6>/g
    ')
    
    # Convert bold and italic (simple cases only - no nested formatting)
    # Note: This will not handle complex cases like **bold _italic_** correctly
    html_content=$(echo "$html_content" | sed -E '
        s/\*\*([^*]+)\*\*/<strong>\1<\/strong>/g
        s/\*([^*]+)\*/<em>\1<\/em>/g
    ')
    
    # Convert links
    html_content=$(echo "$html_content" | sed -E 's/\[([^]]+)\]\(([^)]+)\)/<a href="\2">\1<\/a>/g')
    
    # Wrap in paragraphs (skip headers and empty lines)
    html_content=$(echo "$html_content" | sed -E '
        /^<[hH][1-6]>/!{
            /^$/!{
                s/^(.+)$/<p>\1<\/p>/
            }
        }
    ')
    
    echo "$html_content"
}

# Publish to Confluence via REST API
publish_via_rest_api() {
    local title="$1"
    local content="$2"
    local parent_id="$3"
    local space_key="$4"
    
    echo -e "${CYAN}Publishing via Confluence REST API...${NC}"
    
    # Convert markdown to Confluence storage format
    local confluence_content
    confluence_content=$(convert_markdown_to_confluence "$content")
    
    # Prepare JSON payload
    local json_payload
    json_payload=$(jq -n \
        --arg title "$title" \
        --arg content "$confluence_content" \
        --arg parentId "$parent_id" \
        --arg spaceKey "$space_key" \
        '{
            spaceKey: $spaceKey,
            status: "current",
            title: $title,
            parentId: $parentId,
            body: {
                representation: "storage",
                value: $content
            }
        }')
    
    # Make API request with Basic authentication (email:token base64-encoded)
    local auth_header
    auth_header=$(echo -n "$USER_EMAIL:$API_TOKEN" | base64)
    
    local response
    response=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Authorization: Basic $auth_header" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d "$json_payload" \
        "$BASE_URL/wiki/api/v2/pages")
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
        local page_id=$(echo "$body" | jq -r '.id // empty')
        local page_url=$(echo "$body" | jq -r '._links.webui // empty')
        
        echo -e "${GREEN}✓ Successfully published to Confluence!${NC}"
        echo ""
        echo "Page ID: $page_id"
        echo "Page URL: $BASE_URL$page_url"
        return 0
    else
        echo -e "${RED}✗ Failed to publish to Confluence${NC}" >&2
        echo "HTTP Status: $http_code" >&2
        echo "Response: $body" >&2
        return 1
    fi
}

# Show dry run preview
show_dry_run() {
    local title="${CUSTOM_TITLE:-$(extract_title)}"
    local file_size=$(get_file_size)

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}🔍 Dry Run - Publishing Preview${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Source File:${NC}"
    echo "  Path: $MARKDOWN_FILE"
    echo "  Size: ${file_size} KB"
    echo ""
    echo -e "${YELLOW}Target Confluence Page:${NC}"
    echo "  Title: $title"
    echo "  Domain: $CONFLUENCE_DOMAIN"
    echo "  Space: $CONFLUENCE_SPACE"
    echo "  Parent Page ID: $CONFLUENCE_PAGE_ID"
    echo ""
    echo -e "${YELLOW}Content Preview:${NC}"
    echo "────────────────────────────────────────────────────────────"
    head -20 "$MARKDOWN_FILE"
    echo "..."
    echo "────────────────────────────────────────────────────────────"
    echo ""
    echo -e "${GREEN}✓ Validation passed${NC}"
    echo -e "${BLUE}ℹ${NC} Run without ${YELLOW}--dry-run${NC} to publish to Confluence"
    echo ""
}

# Generate AI assistant prompt (for MCP-based publishing)
generate_ai_prompt() {
    local title="${CUSTOM_TITLE:-$(extract_title)}"

    cat <<EOF

${CYAN}═══════════════════════════════════════════════════════════${NC}
${CYAN}📤 Ready to Publish to Confluence${NC}
${CYAN}═══════════════════════════════════════════════════════════${NC}

${YELLOW}Publishing Information:${NC}
  File: $MARKDOWN_FILE
  Title: $title
  Domain: $CONFLUENCE_DOMAIN
  Space: $CONFLUENCE_SPACE
  Parent Page ID: $CONFLUENCE_PAGE_ID

${YELLOW}Integration Method:${NC}
  ${BLUE}Option 1: MCP Server${NC} (AI assistants with MCP support)
  If your AI tool supports Atlassian MCP, use the slash command:

    ${GREEN}/publish-confluence $MARKDOWN_FILE $PARENT_URL${NC}

  Supported AI tools:
  - Claude Code with Atlassian MCP
  - Other MCP-enabled AI assistants

  ${BLUE}Option 2: REST API${NC} (universal)
  Configure API credentials and run:

    ${GREEN}ai-use-case config confluence${NC}  (first time setup)
    ${GREEN}$0 $MARKDOWN_FILE $PARENT_URL${NC}

  ${BLUE}Option 3: Manual${NC}
  1. Open the markdown file
  2. Create a new page under the parent in Confluence
  3. Copy/paste the content
  4. Format as needed

${YELLOW}Configuration Help:${NC}
  For MCP (AI assistants):
    - See your AI tool's MCP configuration docs
    - Example (Claude Code): https://docs.claude.com/en/docs/claude-code/mcp

  For REST API (universal):
    1. Generate API token: https://{site}.atlassian.net/wiki/people/me/preferences/personal-access-tokens
    2. Run: ai-use-case config confluence
    3. Provide token, base URL, and email

  Documentation:
  - Setup Guide: docs/CONFLUENCE-INTEGRATION.md
  - Atlassian MCP: https://support.atlassian.com/atlassian-rovo-mcp-server/

EOF
}

# Main execution
main() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}📝 Publish to Confluence${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    # Parse arguments
    parse_args "$@"

    # Validate file
    validate_file

    # Parse URL
    parse_confluence_url "$PARENT_URL"

    echo ""

    # Dry run mode - just show preview
    if [ "$DRY_RUN" = true ]; then
        show_dry_run
        exit 0
    fi

    # Determine integration method
    local title="${CUSTOM_TITLE:-$(extract_title)}"
    
    # Try REST API if configured
    if check_rest_api_auth; then
        echo -e "${CYAN}Using REST API integration${NC}"
        echo ""
        
        # Read markdown content
        local markdown_content
        markdown_content=$(cat "$MARKDOWN_FILE")
        
        # Publish via REST API
        if publish_via_rest_api "$title" "$markdown_content" "$CONFLUENCE_PAGE_ID" "$CONFLUENCE_SPACE"; then
            exit 0
        else
            echo ""
            echo -e "${YELLOW}REST API publish failed. See error above.${NC}"
            exit 1
        fi
    else
        # No REST API configured - show guidance for AI assistants or manual setup
        echo -e "${YELLOW}No REST API credentials configured.${NC}"
        echo -e "${YELLOW}Showing integration options...${NC}"
        echo ""
        generate_ai_prompt
        exit 0
    fi
}

# Run main function
main "$@"
