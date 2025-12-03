#!/bin/bash
# AI Use Case CLI - Documentation Quality Agent
# Reviews documentation quality and provides improvement suggestions

set -e

# Color definitions
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source agent invoker
if [ -f "$SCRIPT_DIR/invoke-agent.sh" ]; then
    source "$SCRIPT_DIR/invoke-agent.sh"
else
    echo -e "${RED}Error: invoke-agent.sh not found${NC}"
    exit 1
fi

# Usage function
usage() {
    cat <<EOF
${CYAN}AI Use Case CLI - Documentation Quality Agent${NC}

${YELLOW}Usage:${NC}
  $(basename "$0") <file> [options]
  $(basename "$0") --batch <pattern> [options]
  $(basename "$0") --project <name> [options]

${YELLOW}Options:${NC}
  --format <fmt>        Output format: text (default) or json
  --no-cache            Skip cache and force fresh analysis
  --min-score <score>   Only show files below this score (for batch mode)
  --sort <field>        Sort results by: score, file, grade (for batch mode)

${YELLOW}Examples:${NC}
  # Review single file
  $(basename "$0") .usecase/cases/2025-W49-12-02_HUB-001_example.md

  # Review with JSON output
  $(basename "$0") file.md --format json

  # Review all files in project (batch mode)
  $(basename "$0") --batch '.usecase/cases/*.md'

  # Review specific project from hub
  $(basename "$0") --project ai-use-case-cli

  # Show only files scoring below 8.0
  $(basename "$0") --batch '*.md' --min-score 8.0

${YELLOW}Output:${NC}
  Text format provides:
  - Overall quality score (0-10)
  - Category breakdown with scores
  - List of strengths
  - Specific improvement suggestions with examples
  - Summary and grade

  JSON format provides raw agent response for programmatic use.

EOF
    exit 0
}

# Validate file
validate_file() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: File not found: $file${NC}"
        return 1
    fi

    if [[ ! "$file" =~ \.md$ ]]; then
        echo -e "${YELLOW}Warning: File is not markdown (.md)${NC}"
    fi

    return 0
}

# Format text output
format_text_output() {
    local result="$1"

    # Extract key fields using jq
    local file=$(echo "$result" | jq -r '.file // "unknown"')
    local score=$(echo "$result" | jq -r '.overall_score // 0')
    local grade=$(echo "$result" | jq -r '.grade // "N/A"')
    local summary=$(echo "$result" | jq -r '.summary // "No summary available"')

    # Display header
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Documentation Quality Analysis${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}File:${NC} $file"
    echo -e "${CYAN}Overall Score:${NC} ${GREEN}$score/10${NC}"
    echo -e "${CYAN}Grade:${NC} ${GREEN}$grade${NC}"
    echo ""

    # Display category scores
    echo -e "${CYAN}Category Scores:${NC}"
    echo "$result" | jq -r '.quality_assessment | to_entries[] | "  \(.key): \(.value.score)/10 (weight: \(.value.weight * 100)%)"' 2>/dev/null || echo "  Score breakdown unavailable"
    echo ""

    # Display strengths
    local strengths_count=$(echo "$result" | jq '.strengths | length' 2>/dev/null || echo 0)
    if [ "$strengths_count" -gt 0 ]; then
        echo -e "${GREEN}✓ Strengths:${NC}"
        echo "$result" | jq -r '.strengths[] | "  • \(.)"' 2>/dev/null
        echo ""
    fi

    # Display improvements
    local improvements_count=$(echo "$result" | jq '.improvements | length' 2>/dev/null || echo 0)
    if [ "$improvements_count" -gt 0 ]; then
        echo -e "${YELLOW}⚠ Improvement Suggestions:${NC}"
        echo "$result" | jq -r '.improvements[] | "
\(.severity | ascii_upcase) - \(.section):
  Issue: \(.issue)
  Recommendation: \(.recommendation)
  Example: \(.example)
"' 2>/dev/null
    fi

    # Display summary
    echo -e "${CYAN}Summary:${NC}"
    echo "$summary" | fold -s -w 70 | sed 's/^/  /'
    echo ""
}

# Review single file
review_file() {
    local file="$1"
    local format="${2:-text}"
    local no_cache="${3:-false}"

    # Validate file
    if ! validate_file "$file"; then
        return 1
    fi

    echo -e "${CYAN}Analyzing documentation quality...${NC}"
    echo -e "${CYAN}File: $file${NC}"
    echo ""

    # Prepare invocation parameters
    local invoke_params="quality-reviewer --file \"$file\""
    [ "$format" = "json" ] && invoke_params="$invoke_params --format json"
    [ "$no_cache" = "true" ] && invoke_params="$invoke_params --no-cache"

    # Invoke agent
    local result=""
    if result=$(eval "invoke_agent $invoke_params" 2>&1); then
        if [ "$format" = "json" ]; then
            echo "$result"
        else
            format_text_output "$result"
        fi
        return 0
    else
        echo -e "${RED}Error: Quality analysis failed${NC}"
        echo "$result"
        return 1
    fi
}

# Review multiple files (batch mode)
review_batch() {
    local pattern="$1"
    local format="${2:-text}"
    local min_score="${3:-0}"
    local sort_by="${4:-score}"
    local no_cache="${5:-false}"

    echo -e "${CYAN}Batch Quality Analysis${NC}"
    echo -e "${CYAN}Pattern: $pattern${NC}"
    echo -e "${CYAN}Minimum score filter: $min_score${NC}"
    echo ""

    # Find files matching pattern
    local files=()
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find . -path "$pattern" -type f -print0 2>/dev/null)

    if [ ${#files[@]} -eq 0 ]; then
        echo -e "${YELLOW}No files found matching pattern: $pattern${NC}"
        return 1
    fi

    echo -e "${GREEN}Found ${#files[@]} file(s) to analyze${NC}"
    echo ""

    # Results array (for sorting)
    declare -a results_data=()

    # Analyze each file
    local count=0
    for file in "${files[@]}"; do
        ((count++))
        echo -e "${BLUE}[$count/${#files[@]}] Analyzing: $file${NC}"

        local result=""
        if result=$(invoke_agent quality-reviewer --file "$file" --format json 2>&1); then
            local score=$(echo "$result" | jq -r '.overall_score // 0')

            # Filter by minimum score
            if (( $(echo "$score < $min_score" | bc -l) )); then
                results_data+=("$score|$file|$result")
            fi
        else
            echo -e "${RED}  Error analyzing file${NC}"
        fi
        echo ""
    done

    # Sort results if requested
    if [ "$sort_by" = "score" ]; then
        IFS=$'\n' results_data=($(sort -t'|' -k1 -n <<<"${results_data[*]}"))
    fi

    # Display results
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Batch Analysis Results${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo ""

    if [ ${#results_data[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ All files meet minimum score requirement!${NC}"
    else
        for result_line in "${results_data[@]}"; do
            local score=$(echo "$result_line" | cut -d'|' -f1)
            local file=$(echo "$result_line" | cut -d'|' -f2)
            local result=$(echo "$result_line" | cut -d'|' -f3-)

            if [ "$format" = "json" ]; then
                echo "$result"
            else
                echo -e "${YELLOW}File:${NC} $file"
                echo -e "${YELLOW}Score:${NC} $score/10"
                echo ""
            fi
        done

        echo -e "${CYAN}Total files below threshold: ${#results_data[@]}${NC}"
    fi
}

# Review project
review_project() {
    local project_name="$1"
    local format="${2:-text}"
    local min_score="${3:-0}"
    local no_cache="${4:-false}"

    # Source hub utilities to find project
    if [ -f "$SCRIPT_DIR/../utils/hub-utils.sh" ]; then
        source "$SCRIPT_DIR/../utils/hub-utils.sh"
    fi

    # Get hub path
    local hub_path=$(get_hub_path 2>/dev/null || echo "")
    if [ -z "$hub_path" ]; then
        echo -e "${RED}Error: Could not determine hub path${NC}"
        return 1
    fi

    # Find project directory
    local project_dir="$hub_path/by-project/$project_name"
    if [ ! -d "$project_dir" ]; then
        echo -e "${RED}Error: Project not found: $project_name${NC}"
        echo -e "${CYAN}Available projects:${NC}"
        ls -1 "$hub_path/by-project/" 2>/dev/null || echo "  None"
        return 1
    fi

    # Use batch mode on project directory
    review_batch "$project_dir/*.md" "$format" "$min_score" "score" "$no_cache"
}

# Main function
main() {
    if [ $# -eq 0 ]; then
        usage
    fi

    local file=""
    local batch_pattern=""
    local project_name=""
    local format="text"
    local no_cache=false
    local min_score=0
    local sort_by="score"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --batch)
                batch_pattern="$2"
                shift 2
                ;;
            --project)
                project_name="$2"
                shift 2
                ;;
            --format)
                format="$2"
                shift 2
                ;;
            --no-cache)
                no_cache=true
                shift
                ;;
            --min-score)
                min_score="$2"
                shift 2
                ;;
            --sort)
                sort_by="$2"
                shift 2
                ;;
            --help|-h)
                usage
                ;;
            *)
                if [ -z "$file" ]; then
                    file="$1"
                fi
                shift
                ;;
        esac
    done

    # Determine mode
    if [ -n "$project_name" ]; then
        review_project "$project_name" "$format" "$min_score" "$no_cache"
    elif [ -n "$batch_pattern" ]; then
        review_batch "$batch_pattern" "$format" "$min_score" "$sort_by" "$no_cache"
    elif [ -n "$file" ]; then
        review_file "$file" "$format" "$no_cache"
    else
        echo -e "${RED}Error: No file, batch pattern, or project specified${NC}"
        usage
    fi
}

# Run main if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
