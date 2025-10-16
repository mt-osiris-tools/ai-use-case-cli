#!/bin/bash
# Publish AI Use Case Documentation to Confluence
# Creates a child page under a specified parent page using Atlassian MCP
#
# Usage:
#   publish-confluence.sh [options] <markdown-file> <parent-page-url>
#
# Options:
#   --title <title>       Override page title (default: from filename)
#   --space <space-key>   Confluence space key (default: from URL)
#   --dry-run            Show what would be published without doing it
#   --help               Show this help message
#
# Prerequisites:
#   - Atlassian MCP server configured in Claude Code
#   - Valid Confluence authentication (SSE or token)

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
DRY_RUN=false
CUSTOM_TITLE=""
CUSTOM_SPACE=""

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
  ${GREEN}--title <title>${NC}       Override page title (default: from filename)
  ${GREEN}--space <space-key>${NC}   Confluence space key (default: from URL)
  ${GREEN}--dry-run${NC}             Show what would be published without doing it
  ${GREEN}--help, -h${NC}            Show this help message

${YELLOW}Prerequisites:${NC}
  - Atlassian MCP server configured in Claude Code
  - Valid Confluence authentication (SSE or Personal Access Token)
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

${YELLOW}Authentication:${NC}
  Authentication is handled by the Atlassian MCP server in Claude Code.
  Supports both:
  - Atlassian SSE (Server-Sent Events) for OAuth
  - Personal Access Token (PAT)

  Configure in Claude Code MCP settings.

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

    # Pattern: YYYY-MM-DD_TICKET-XXX_description-slug
    if [[ $filename =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}_([A-Z]+-[0-9]+)_(.+)$ ]]; then
        local ticket="${BASH_REMATCH[1]}"
        local slug="${BASH_REMATCH[2]}"

        # Convert slug to title case
        local title=$(echo "$slug" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

        echo "$ticket: $title"
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

# Generate Claude Code prompt
generate_claude_prompt() {
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

${YELLOW}Next Steps:${NC}
  This operation requires Claude Code with Atlassian MCP.

  ${BLUE}Option 1: Use Claude Code${NC}
  If you're using Claude Code, run the slash command:

    ${GREEN}/publish-confluence $MARKDOWN_FILE $PARENT_URL${NC}

  ${BLUE}Option 2: Manual Setup${NC}
  1. Open the markdown file in Confluence
  2. Create a new page under the parent
  3. Copy/paste the content
  4. Format as needed

${YELLOW}Prerequisites:${NC}
  ${GREEN}✓${NC} Atlassian MCP server configured in Claude Code
  ${GREEN}✓${NC} Valid Confluence authentication (SSE or token)
  ${GREEN}✓${NC} Permission to create pages in space: $CONFLUENCE_SPACE

${YELLOW}Configuration Help:${NC}
  To configure Atlassian MCP in Claude Code:
  1. Open Claude Code settings
  2. Navigate to MCP servers
  3. Add Atlassian MCP server
  4. Configure authentication (SSE or Personal Access Token)

  See: https://docs.claude.com/mcp for detailed instructions

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

    # Dry run or actual publish
    if [ "$DRY_RUN" = true ]; then
        show_dry_run
    else
        generate_claude_prompt
    fi

    exit 0
}

# Run main function
main "$@"
