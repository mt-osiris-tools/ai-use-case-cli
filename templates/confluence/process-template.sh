#!/usr/bin/env bash

# Template Processor for Confluence HTML Templates
# Converts AI use case markdown files to HTML using templates

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default template
DEFAULT_TEMPLATE="use-case-template-simple.html"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Usage function
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <markdown-file>

Process AI use case markdown file with Confluence HTML template

OPTIONS:
    -t, --template <file>    Template file to use (default: $DEFAULT_TEMPLATE)
    -o, --output <file>      Output HTML file (default: stdout)
    -r, --rich              Use rich template instead of simple
    -m, --metadata <file>    JSON file with additional metadata
    -d, --dry-run           Show extracted metadata without processing
    -h, --help              Show this help message

EXAMPLES:
    # Process with default template
    $(basename "$0") case.md > output.html

    # Use rich template
    $(basename "$0") --rich case.md

    # Save to file
    $(basename "$0") -o confluence.html case.md

    # Preview metadata extraction
    $(basename "$0") --dry-run case.md

EOF
    exit 0
}

# Error handler
error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Info message
info() {
    echo -e "${BLUE}ℹ $1${NC}" >&2
}

# Success message
success() {
    echo -e "${GREEN}✓ $1${NC}" >&2
}

# Extract metadata from filename
extract_filename_metadata() {
    local filename="$1"
    local basename_file
    basename_file=$(basename "$filename" .md)

    # Pattern: YYYY-Www-MM-DD_TICKET-XXX_description
    if [[ $basename_file =~ ^([0-9]{4})-(W[0-9]{2})-([0-9]{2})-([0-9]{2})_([A-Z]+-[0-9]+)_(.+)$ ]]; then
        export YEAR="${BASH_REMATCH[1]}"
        export WEEK="${BASH_REMATCH[2]}"
        export MONTH="${BASH_REMATCH[3]}"
        export DAY="${BASH_REMATCH[4]}"
        export TICKET_ID="${BASH_REMATCH[5]}"
        export SLUG="${BASH_REMATCH[6]}"

        # Format values
        export WEEK_NUMBER="Week ${WEEK#W}"
        export DATE="$YEAR-$MONTH-$DAY"

        # Convert slug to title (replace hyphens with spaces, capitalize)
        # Use awk for portability across BSD/GNU sed
        local title
        title=$(echo "$SLUG" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
        export DESCRIPTION="$title"

        return 0
    fi

    return 1
}

# Extract content sections from markdown
extract_markdown_sections() {
    local file="$1"
    local content
    content=$(cat "$file")

    # Extract executive summary (first paragraph after title)
    export EXECUTIVE_SUMMARY=$(echo "$content" | awk '/^#[^#]/{getline; getline; if(NF) print; exit}')

    # Extract context (look for Context section)
    export CONTEXT_CONTENT=$(echo "$content" | awk '/^##.*Context/,/^##/{if(!/^##/) print}' | head -n -1)

    # Extract implementation
    export IMPLEMENTATION_CONTENT=$(echo "$content" | awk '/^##.*Implementation/,/^##/{if(!/^##/) print}' | head -n -1)

    # Extract code blocks
    export CODE_EXAMPLES=$(echo "$content" | awk '/^```/,/^```/{print}' | head -n 20)

    # Extract challenges (if exists)
    export CHALLENGES_CONTENT=$(echo "$content" | awk '/^##.*Challenge/,/^##/{if(!/^##/) print}' | head -n -1)

    # Extract learnings
    export LEARNINGS_CONTENT=$(echo "$content" | awk '/^##.*Learning/,/^##/{if(!/^##/) print}' | head -n -1)

    # Extract prompts
    export PROMPTS_CONTENT=$(echo "$content" | awk '/^##.*Prompt/,/^##/{if(!/^##/) print}' | head -n -1)

    # Store original markdown
    export ORIGINAL_MARKDOWN="$content"
}

# Generate default values for missing metadata
generate_defaults() {
    # Page metadata defaults
    export PAGE_EMOJI="${PAGE_EMOJI:-🎯}"
    export PAGE_TITLE="${PAGE_TITLE:-$WEEK_NUMBER | $TICKET_ID: $DESCRIPTION}"
    export PAGE_DESCRIPTION="${PAGE_DESCRIPTION:-AI-assisted development use case documentation}"
    export STATUS="${STATUS:-Completed}"
    export STATUS_COLOR="${STATUS_COLOR:-Green}"
    export STATUS_CLASS="${STATUS_CLASS:-completed}"
    export PROJECT_NAME="${PROJECT_NAME:-AI Use Case}"
    export AUTHOR="${AUTHOR:-$(whoami)}"
    export TICKET_URL="${TICKET_URL:-#}"

    # Content defaults
    export EXECUTIVE_SUMMARY="${EXECUTIVE_SUMMARY:-This use case documents an AI-assisted development session.}"
    export CONTEXT_CONTENT="${CONTEXT_CONTENT:-<p>Context information not available.</p>}"
    export IMPLEMENTATION_CONTENT="${IMPLEMENTATION_CONTENT:-<p>Implementation details documented in the original markdown.</p>}"

    # Tools and metrics defaults
    export AI_TOOLS_BADGES="${AI_TOOLS_BADGES:-<div class=\"tool-badge\">Claude</div>}"
    export AI_TOOLS_LIST="${AI_TOOLS_LIST:-<li>Claude 3.5 Sonnet</li>}"
    export TIME_SAVED="${TIME_SAVED:-N/A}"
    export LINES_OF_CODE="${LINES_OF_CODE:-N/A}"
    export ITERATIONS="${ITERATIONS:-N/A}"
    export SUCCESS_RATE="${SUCCESS_RATE:-N/A}"

    # Lists and tables
    export CHALLENGES_TABLE_ROWS="${CHALLENGES_TABLE_ROWS:-<tr><td>N/A</td><td>N/A</td><td>N/A</td></tr>}"
    export KEY_LEARNINGS_LIST="${KEY_LEARNINGS_LIST:-<li>AI assistance improved development efficiency</li>}"
    export RELATED_RESOURCES="${RELATED_RESOURCES:-<li>📄 Original markdown documentation</li>}"
    export TAGS_LIST="${TAGS_LIST:-<span class=\"tag\">ai-assisted</span><span class=\"tag\">development</span>}"
    export CONFLUENCE_LABELS="${CONFLUENCE_LABELS:-ai-use-case,development}"
    export PROMPTS_CONTENT="${PROMPTS_CONTENT:-<p>Effective prompts and techniques used in this session.</p>}"
    export TIMELINE_ITEMS="${TIMELINE_ITEMS:-}"  # Empty by default for conditional sections

    # System info
    # Source version from central location
    SCRIPT_BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
    if [ -f "$SCRIPT_BASE_DIR/scripts/utils/version.sh" ]; then
        source "$SCRIPT_BASE_DIR/scripts/utils/version.sh"
        export CLI_VERSION="${VERSION}"
    else
        export CLI_VERSION="${CLI_VERSION:-unknown}"
    fi
    export LAST_UPDATED="${LAST_UPDATED:-$(date +'%Y-%m-%d %H:%M:%S')}"
    export CODE_LANGUAGE="${CODE_LANGUAGE:-bash}"
}

# Process template with replacements
process_template() {
    local template_file="$1"
    local output="$2"

    if [[ ! -f "$template_file" ]]; then
        error "Template file not found: $template_file"
    fi

    # Read template
    local template_content
    template_content=$(cat "$template_file")

    # Replace all placeholders
    template_content="${template_content//\{\{PAGE_EMOJI\}\}/$PAGE_EMOJI}"
    template_content="${template_content//\{\{PAGE_TITLE\}\}/$PAGE_TITLE}"
    template_content="${template_content//\{\{PAGE_DESCRIPTION\}\}/$PAGE_DESCRIPTION}"
    template_content="${template_content//\{\{WEEK_NUMBER\}\}/$WEEK_NUMBER}"
    template_content="${template_content//\{\{DATE\}\}/$DATE}"
    template_content="${template_content//\{\{TICKET_ID\}\}/$TICKET_ID}"
    template_content="${template_content//\{\{TICKET_URL\}\}/$TICKET_URL}"
    template_content="${template_content//\{\{STATUS\}\}/$STATUS}"
    template_content="${template_content//\{\{STATUS_COLOR\}\}/$STATUS_COLOR}"
    template_content="${template_content//\{\{STATUS_CLASS\}\}/$STATUS_CLASS}"
    template_content="${template_content//\{\{PROJECT_NAME\}\}/$PROJECT_NAME}"
    template_content="${template_content//\{\{AUTHOR\}\}/$AUTHOR}"

    # Content sections
    template_content="${template_content//\{\{EXECUTIVE_SUMMARY\}\}/$EXECUTIVE_SUMMARY}"
    template_content="${template_content//\{\{CONTEXT_CONTENT\}\}/$CONTEXT_CONTENT}"
    template_content="${template_content//\{\{IMPLEMENTATION_CONTENT\}\}/$IMPLEMENTATION_CONTENT}"
    template_content="${template_content//\{\{CODE_EXAMPLES\}\}/$CODE_EXAMPLES}"
    template_content="${template_content//\{\{CODE_LANGUAGE\}\}/$CODE_LANGUAGE}"

    # Tables and lists
    template_content="${template_content//\{\{CHALLENGES_TABLE_ROWS\}\}/$CHALLENGES_TABLE_ROWS}"
    template_content="${template_content//\{\{KEY_LEARNINGS_LIST\}\}/$KEY_LEARNINGS_LIST}"
    template_content="${template_content//\{\{AI_TOOLS_BADGES\}\}/$AI_TOOLS_BADGES}"
    template_content="${template_content//\{\{AI_TOOLS_LIST\}\}/$AI_TOOLS_LIST}"

    # Metrics
    template_content="${template_content//\{\{TIME_SAVED\}\}/$TIME_SAVED}"
    template_content="${template_content//\{\{LINES_OF_CODE\}\}/$LINES_OF_CODE}"
    template_content="${template_content//\{\{ITERATIONS\}\}/$ITERATIONS}"
    template_content="${template_content//\{\{SUCCESS_RATE\}\}/$SUCCESS_RATE}"

    # Prompts and Timeline
    template_content="${template_content//\{\{PROMPTS_CONTENT\}\}/$PROMPTS_CONTENT}"
    template_content="${template_content//\{\{TIMELINE_ITEMS\}\}/$TIMELINE_ITEMS}"

    # Resources and meta
    template_content="${template_content//\{\{RELATED_RESOURCES\}\}/$RELATED_RESOURCES}"
    template_content="${template_content//\{\{TAGS_LIST\}\}/$TAGS_LIST}"
    template_content="${template_content//\{\{CONFLUENCE_LABELS\}\}/$CONFLUENCE_LABELS}"
    template_content="${template_content//\{\{CLI_VERSION\}\}/$CLI_VERSION}"
    template_content="${template_content//\{\{LAST_UPDATED\}\}/$LAST_UPDATED}"

    # Original markdown (escape for HTML with proper handling of all special characters)
    local escaped_markdown
    escaped_markdown=$(printf '%s\n' "$ORIGINAL_MARKDOWN" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'\''/\&#39;/g')
    template_content="${template_content//\{\{ORIGINAL_MARKDOWN\}\}/$escaped_markdown}"

    # Handle conditional sections properly
    # Remove {{#if}} blocks only if variable is empty; otherwise, remove just the markers
    if [[ -z "$CODE_EXAMPLES" ]]; then
        template_content=$(echo "$template_content" | sed '/{{#if CODE_EXAMPLES}}/,/{{\/if}}/d' 2>/dev/null || echo "$template_content")
    else
        template_content="${template_content//\{\{#if CODE_EXAMPLES\}\}/}"
        template_content="${template_content//\{\{\/if\}\}/}"
    fi

    if [[ -z "$TIMELINE_ITEMS" ]]; then
        template_content=$(echo "$template_content" | sed '/{{#if TIMELINE_ITEMS}}/,/{{\/if}}/d' 2>/dev/null || echo "$template_content")
    else
        template_content="${template_content//\{\{#if TIMELINE_ITEMS\}\}/}"
        template_content="${template_content//\{\{\/if\}\}/}"
    fi

    if [[ -z "$ATTACHMENTS" ]]; then
        template_content=$(echo "$template_content" | sed '/{{#if ATTACHMENTS}}/,/{{\/if}}/d' 2>/dev/null || echo "$template_content")
    else
        template_content="${template_content//\{\{#if ATTACHMENTS\}\}/}"
        template_content="${template_content//\{\{\/if\}\}/}"
    fi

    # Output
    if [[ "$output" == "-" ]]; then
        echo "$template_content"
    else
        echo "$template_content" > "$output"
        success "HTML written to: $output"
    fi
}

# Main function
main() {
    local markdown_file=""
    local template_file="$SCRIPT_DIR/$DEFAULT_TEMPLATE"
    local output_file="-"
    local dry_run=false
    local metadata_file=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--template)
                if [[ -z "${2:-}" ]] || [[ "$2" == -* ]]; then
                    error "Option --template requires an argument"
                fi
                template_file="$2"
                shift 2
                ;;
            -o|--output)
                if [[ -z "${2:-}" ]] || [[ "$2" == -* ]]; then
                    error "Option --output requires an argument"
                fi
                output_file="$2"
                shift 2
                ;;
            -r|--rich)
                template_file="$SCRIPT_DIR/use-case-template.html"
                shift
                ;;
            -m|--metadata)
                if [[ -z "${2:-}" ]] || [[ "$2" == -* ]]; then
                    error "Option --metadata requires an argument"
                fi
                metadata_file="$2"
                shift 2
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                markdown_file="$1"
                shift
                ;;
        esac
    done

    # Validate input
    if [[ -z "$markdown_file" ]]; then
        error "No markdown file specified"
    fi

    if [[ ! -f "$markdown_file" ]]; then
        error "Markdown file not found: $markdown_file"
    fi

    info "Processing: $markdown_file"

    # Extract metadata from filename
    if ! extract_filename_metadata "$markdown_file"; then
        error "Failed to parse filename. Expected format: YYYY-Www-MM-DD_TICKET-XXX_description.md"
    fi

    info "Extracted: $TICKET_ID - $DESCRIPTION (Week $WEEK_NUMBER)"

    # Extract content sections
    extract_markdown_sections "$markdown_file"

    # Load additional metadata if provided
    if [[ -n "$metadata_file" ]] && [[ -f "$metadata_file" ]]; then
        info "Loading metadata from: $metadata_file"
        # Parse JSON metadata safely using jq
        if command -v jq >/dev/null 2>&1; then
            while IFS='=' read -r key value; do
                [[ -n "$key" ]] && export "$key=$value"
            done < <(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' "$metadata_file" 2>/dev/null || true)
        else
            error "jq is required to parse JSON metadata files. Install with: apt-get install jq (Debian/Ubuntu) or brew install jq (macOS)"
        fi
    fi

    # Generate defaults for missing values
    generate_defaults

    # Dry run - show metadata
    if [[ "$dry_run" == true ]]; then
        echo -e "\n${YELLOW}=== Extracted Metadata ===${NC}"
        echo "PAGE_TITLE: $PAGE_TITLE"
        echo "WEEK_NUMBER: $WEEK_NUMBER"
        echo "DATE: $DATE"
        echo "TICKET_ID: $TICKET_ID"
        echo "DESCRIPTION: $DESCRIPTION"
        echo "STATUS: $STATUS"
        echo -e "\n${YELLOW}=== Content Preview ===${NC}"
        echo "Executive Summary: ${EXECUTIVE_SUMMARY:0:100}..."
        echo "Context: ${CONTEXT_CONTENT:0:100}..."
        echo "Implementation: ${IMPLEMENTATION_CONTENT:0:100}..."
        exit 0
    fi

    # Process template
    info "Using template: $(basename "$template_file")"
    process_template "$template_file" "$output_file"

    if [[ "$output_file" == "-" ]]; then
        info "HTML output sent to stdout"
    fi
}

# Run main function
main "$@"