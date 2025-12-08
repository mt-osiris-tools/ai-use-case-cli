#!/bin/bash
# AI Use Case CLI - Pattern Analysis Agent
# Analyzes documentation patterns across projects and hubs

set -e

# Color definitions
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
YELLOW=$'\033[1;33m'
MAGENTA=$'\033[0;35m'
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

# Source hub utilities
if [ -f "$SCRIPT_DIR/../utils/hub-utils.sh" ]; then
    source "$SCRIPT_DIR/../utils/hub-utils.sh"
fi

# Usage function
usage() {
    cat <<EOF
${CYAN}AI Use Case CLI - Pattern Analysis Agent${NC}

${YELLOW}Usage:${NC}
  $(basename "$0") [options]
  $(basename "$0") --project <name> [options]
  $(basename "$0") --hub [options]

${YELLOW}Analysis Modes:${NC}
  --project <name>    Analyze patterns for a specific project
  --hub               Analyze patterns across entire hub (all projects)
  (default)           Analyze current project (.usecase/cases/)

${YELLOW}Options:${NC}
  --period <period>   Time period to analyze:
                      - all (default): All available documentation
                      - 1month, 3months, 6months, 1year: Relative periods
                      - YYYY-MM-DD:YYYY-MM-DD: Custom date range
  --format <fmt>      Output format: text (default) or json
  --no-cache          Skip cache and force fresh analysis
  --include-quality   Include quality scores in analysis (slower)
  --compare           Compare projects (hub mode only)
  --focus <area>      Focus analysis on specific area:
                      - patterns: Documentation patterns (default)
                      - trends: Trend analysis
                      - recommendations: Prioritized recommendations
                      - all: Complete analysis

${YELLOW}Examples:${NC}
  # Analyze current project
  $(basename "$0")

  # Analyze specific project from hub
  $(basename "$0") --project ai-use-case-cli

  # Analyze entire hub with project comparison
  $(basename "$0") --hub --compare

  # Analyze last 6 months with quality scores
  $(basename "$0") --period 6months --include-quality

  # Get only recommendations in JSON
  $(basename "$0") --focus recommendations --format json

  # Custom date range analysis
  $(basename "$0") --period 2025-01-01:2025-06-30

${YELLOW}Output:${NC}
  Text format provides:
  - Summary statistics (sessions, time saved, ROI)
  - Pattern breakdown (session types, complexity, tools)
  - Trend analysis (documentation frequency, quality trends)
  - Insights (strengths and opportunities)
  - Prioritized recommendations

  JSON format provides raw agent response for programmatic use.

EOF
    exit 0
}

# Parse period to date range
parse_period() {
    local period="$1"
    local end_date=$(date +%Y-%m-%d)
    local start_date=""

    case "$period" in
        all|"")
            start_date="1970-01-01"
            ;;
        1month)
            start_date=$(date -d "-1 month" +%Y-%m-%d 2>/dev/null || date -v-1m +%Y-%m-%d 2>/dev/null)
            ;;
        3months)
            start_date=$(date -d "-3 months" +%Y-%m-%d 2>/dev/null || date -v-3m +%Y-%m-%d 2>/dev/null)
            ;;
        6months)
            start_date=$(date -d "-6 months" +%Y-%m-%d 2>/dev/null || date -v-6m +%Y-%m-%d 2>/dev/null)
            ;;
        1year)
            start_date=$(date -d "-1 year" +%Y-%m-%d 2>/dev/null || date -v-1y +%Y-%m-%d 2>/dev/null)
            ;;
        *:*)
            # Custom date range: YYYY-MM-DD:YYYY-MM-DD
            start_date="${period%%:*}"
            end_date="${period##*:}"
            ;;
        *)
            echo -e "${RED}Error: Invalid period format: $period${NC}"
            echo -e "${CYAN}Valid formats: all, 1month, 3months, 6months, 1year, YYYY-MM-DD:YYYY-MM-DD${NC}"
            exit 1
            ;;
    esac

    echo "$start_date:$end_date"
}

# Collect documents from directory
collect_documents() {
    local dir="$1"
    local start_date="$2"
    local end_date="$3"
    local docs_json="[]"

    if [ ! -d "$dir" ]; then
        echo "[]"
        return
    fi

    # Find markdown files and filter by date
    while IFS= read -r -d '' file; do
        local filename=$(basename "$file")

        # Extract date from filename (format: YYYY-Www-MM-DD_...)
        local file_date=""
        if [[ "$filename" =~ ^([0-9]{4})-W[0-9]{2}-([0-9]{2})-([0-9]{2})_ ]]; then
            local year="${BASH_REMATCH[1]}"
            local month="${BASH_REMATCH[2]}"
            local day="${BASH_REMATCH[3]}"
            file_date="$year-$month-$day"
        fi

        # Check if date is within range
        if [ -n "$file_date" ]; then
            if [[ "$file_date" < "$start_date" ]] || [[ "$file_date" > "$end_date" ]]; then
                continue
            fi
        fi

        # Determine session type from filename
        local session_type="implementation"
        if [[ "$filename" =~ RESEARCH ]]; then
            session_type="research"
        fi

        # Read file content (limit to first 5000 chars for performance)
        local content=$(head -c 5000 "$file" 2>/dev/null | jq -Rs '.')

        # Add to docs array
        docs_json=$(echo "$docs_json" | jq \
            --arg file "$file" \
            --arg filename "$filename" \
            --arg session_type "$session_type" \
            --arg date "$file_date" \
            --argjson content "$content" \
            '. + [{
                "file": $file,
                "filename": $filename,
                "session_type": $session_type,
                "date": $date,
                "content": $content
            }]')

    done < <(find "$dir" -maxdepth 1 -name "*.md" -type f -print0 2>/dev/null)

    echo "$docs_json"
}

# Format text output for patterns
format_patterns_output() {
    local result="$1"

    # Extract key fields
    local scope=$(echo "$result" | jq -r '.scope // "unknown"')
    local doc_count=$(echo "$result" | jq -r '.document_count // 0')
    local period=$(echo "$result" | jq -r '.period_analyzed // "all"')

    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Pattern Analysis Results${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Scope:${NC} $scope"
    echo -e "${CYAN}Documents Analyzed:${NC} $doc_count"
    echo -e "${CYAN}Period:${NC} $period"
    echo ""

    # Summary section
    echo -e "${GREEN}📊 Summary${NC}"
    echo "$result" | jq -r '.summary | to_entries[] | "  \(.key): \(.value)"' 2>/dev/null || echo "  Summary unavailable"
    echo ""

    # Patterns section
    echo -e "${BLUE}🔍 Detected Patterns${NC}"

    # Session types
    echo -e "  ${YELLOW}Session Types:${NC}"
    echo "$result" | jq -r '.patterns.session_types | to_entries[] | "    \(.key): \(.value.count) sessions (\(.value.percentage)%)"' 2>/dev/null || echo "    No session type data"

    # Complexity distribution
    echo -e "  ${YELLOW}Complexity Distribution:${NC}"
    echo "$result" | jq -r '.patterns.complexity_distribution | to_entries[] | "    \(.key): \(.value.count) (\(.value.percentage)%)"' 2>/dev/null || echo "    No complexity data"

    # Common tools
    echo -e "  ${YELLOW}Top Tools/Technologies:${NC}"
    echo "$result" | jq -r '.patterns.common_tools[:5][] | "    \(.tool): \(.occurrences) uses (\(.percentage)%)"' 2>/dev/null || echo "    No tool data"
    echo ""

    # Trends section
    echo -e "${MAGENTA}📈 Trends${NC}"
    local freq_trend=$(echo "$result" | jq -r '.trends.documentation_frequency.trend // "unknown"')
    local freq_change=$(echo "$result" | jq -r '.trends.documentation_frequency.change_percent // 0')
    echo -e "  Documentation Frequency: ${GREEN}$freq_trend${NC} ($freq_change% change)"

    local quality_trend=$(echo "$result" | jq -r '.trends.quality_trend.trend // "unknown"')
    local avg_quality=$(echo "$result" | jq -r '.trends.quality_trend.avg_score // "N/A"')
    echo -e "  Quality Trend: ${GREEN}$quality_trend${NC} (avg score: $avg_quality)"
    echo ""

    # Insights section
    echo -e "${GREEN}💡 Insights${NC}"

    # Strengths
    local strengths=$(echo "$result" | jq -r '.insights | map(select(.type == "strength")) | length')
    if [ "$strengths" -gt 0 ]; then
        echo -e "  ${GREEN}Strengths:${NC}"
        echo "$result" | jq -r '.insights | map(select(.type == "strength"))[:3][] | "    ✓ \(.finding)"' 2>/dev/null
    fi

    # Opportunities
    local opportunities=$(echo "$result" | jq -r '.insights | map(select(.type == "opportunity")) | length')
    if [ "$opportunities" -gt 0 ]; then
        echo -e "  ${YELLOW}Opportunities:${NC}"
        echo "$result" | jq -r '.insights | map(select(.type == "opportunity"))[:3][] | "    ⚡ \(.finding)"' 2>/dev/null
    fi
    echo ""

    # Recommendations section
    echo -e "${CYAN}📋 Recommendations${NC}"
    echo "$result" | jq -r '.recommendations[:5][] | "
  [\(.priority | ascii_upcase)] \(.title)
    \(.description)
    → Action: \(.action)
    → Impact: \(.expected_impact)
"' 2>/dev/null || echo "  No recommendations available"

    # Classifications
    echo -e "${BLUE}🏷️  Classifications${NC}"
    echo -e "  Project Type: $(echo "$result" | jq -r '.classifications.project_type // "unknown"')"
    echo -e "  Maturity: $(echo "$result" | jq -r '.classifications.documentation_maturity // "unknown"')"
    echo -e "  Focus: $(echo "$result" | jq -r '.classifications.primary_focus // "unknown"')"
    echo ""
}

# Analyze single project
analyze_project() {
    local project_name="$1"
    local period="$2"
    local format="${3:-text}"
    local include_quality="${4:-false}"
    local focus="${5:-all}"
    local no_cache="${6:-false}"

    # Parse period
    local date_range=$(parse_period "$period")
    local start_date="${date_range%%:*}"
    local end_date="${date_range##*:}"

    # Determine project directory
    local project_dir=""

    if [ -n "$project_name" ]; then
        # Look for project in hub
        local hub_path=$(get_hub_path 2>/dev/null || echo "")
        if [ -z "$hub_path" ]; then
            echo -e "${RED}Error: Hub not configured${NC}"
            return 1
        fi
        project_dir="$hub_path/by-project/$project_name"

        if [ ! -d "$project_dir" ]; then
            echo -e "${RED}Error: Project not found: $project_name${NC}"
            echo -e "${CYAN}Available projects:${NC}"
            ls -1 "$hub_path/by-project/" 2>/dev/null || echo "  None"
            return 1
        fi
    else
        # Use current project's .usecase/cases directory
        project_dir=".usecase/cases"
        project_name=$(basename "$(pwd)")

        if [ ! -d "$project_dir" ]; then
            echo -e "${RED}Error: No .usecase/cases directory found${NC}"
            echo -e "${CYAN}Run 'ai-use-case --init' to initialize${NC}"
            return 1
        fi
    fi

    echo -e "${CYAN}Analyzing project: $project_name${NC}"
    echo -e "${CYAN}Period: $start_date to $end_date${NC}"
    echo ""

    # Collect documents
    local documents=$(collect_documents "$project_dir" "$start_date" "$end_date")
    local doc_count=$(echo "$documents" | jq 'length')

    if [ "$doc_count" -eq 0 ]; then
        echo -e "${YELLOW}No documents found in the specified period${NC}"
        return 0
    fi

    echo -e "${GREEN}Found $doc_count documents${NC}"
    echo ""

    # Build context for agent
    local context=$(jq -n \
        --arg type "project" \
        --arg name "$project_name" \
        --arg period "$period" \
        --arg start "$start_date" \
        --arg end "$end_date" \
        --argjson docs "$documents" \
        --arg quality "$include_quality" \
        --arg focus "$focus" \
        '{
            "analysis_type": $type,
            "project_name": $name,
            "documents": $docs,
            "period": $period,
            "date_range": {
                "start": $start,
                "end": $end
            },
            "options": {
                "include_quality_scores": ($quality == "true"),
                "focus": $focus
            }
        }')

    # Invoke agent safely without eval to prevent shell injection
    local result=""
    local invoke_args=("pattern-analyzer" "--context" "$context")
    [ "$format" = "json" ] && invoke_args+=("--format" "json")
    [ "$no_cache" = "true" ] && invoke_args+=("--no-cache")

    if result=$(invoke_agent "${invoke_args[@]}" 2>&1); then
        if [ "$format" = "json" ]; then
            echo "$result"
        else
            format_patterns_output "$result"
        fi
        return 0
    else
        echo -e "${RED}Error: Pattern analysis failed${NC}"
        echo "$result"
        return 1
    fi
}

# Analyze entire hub
analyze_hub() {
    local period="$1"
    local format="${2:-text}"
    local include_quality="${3:-false}"
    local compare="${4:-false}"
    local focus="${5:-all}"
    local no_cache="${6:-false}"

    # Parse period
    local date_range=$(parse_period "$period")
    local start_date="${date_range%%:*}"
    local end_date="${date_range##*:}"

    # Get hub path
    local hub_path=$(get_hub_path 2>/dev/null || echo "")
    if [ -z "$hub_path" ]; then
        echo -e "${RED}Error: Hub not configured${NC}"
        echo -e "${CYAN}Run 'ai-use-case config' to configure${NC}"
        return 1
    fi

    echo -e "${CYAN}Analyzing hub: $hub_path${NC}"
    echo -e "${CYAN}Period: $start_date to $end_date${NC}"
    echo ""

    # Collect all projects
    local projects_json="[]"
    local all_documents="[]"
    local projects_dir="$hub_path/by-project"

    if [ -d "$projects_dir" ]; then
        for project_dir in "$projects_dir"/*/; do
            if [ -d "$project_dir" ]; then
                local project_name=$(basename "$project_dir")

                # Collect documents for this project
                local project_docs=$(collect_documents "$project_dir" "$start_date" "$end_date")
                local project_doc_count=$(echo "$project_docs" | jq 'length')

                if [ "$project_doc_count" -gt 0 ]; then
                    # Add project to list
                    projects_json=$(echo "$projects_json" | jq \
                        --arg name "$project_name" \
                        --argjson count "$project_doc_count" \
                        '. + [{
                            "name": $name,
                            "document_count": $count
                        }]')

                    # Add documents to all_documents
                    all_documents=$(echo "$all_documents" | jq --argjson docs "$project_docs" '. + $docs')
                fi
            fi
        done
    fi

    local total_projects=$(echo "$projects_json" | jq 'length')
    local total_docs=$(echo "$all_documents" | jq 'length')

    if [ "$total_docs" -eq 0 ]; then
        echo -e "${YELLOW}No documents found in the hub for the specified period${NC}"
        return 0
    fi

    echo -e "${GREEN}Found $total_docs documents across $total_projects projects${NC}"
    echo ""

    # Build context for agent
    local context=$(jq -n \
        --arg type "hub" \
        --arg hub_path "$hub_path" \
        --arg period "$period" \
        --arg start "$start_date" \
        --arg end "$end_date" \
        --argjson projects "$projects_json" \
        --argjson docs "$all_documents" \
        --arg quality "$include_quality" \
        --arg compare "$compare" \
        --arg focus "$focus" \
        '{
            "analysis_type": $type,
            "hub_path": $hub_path,
            "projects": $projects,
            "documents": $docs,
            "period": $period,
            "date_range": {
                "start": $start,
                "end": $end
            },
            "options": {
                "include_quality_scores": ($quality == "true"),
                "compare_projects": ($compare == "true"),
                "focus": $focus
            }
        }')

    # Invoke agent safely without eval to prevent shell injection
    local result=""
    local invoke_args=("pattern-analyzer" "--context" "$context")
    [ "$format" = "json" ] && invoke_args+=("--format" "json")
    [ "$no_cache" = "true" ] && invoke_args+=("--no-cache")

    if result=$(invoke_agent "${invoke_args[@]}" 2>&1); then
        if [ "$format" = "json" ]; then
            echo "$result"
        else
            format_patterns_output "$result"

            # Show project comparison if requested
            if [ "$compare" = "true" ]; then
                echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
                echo -e "${CYAN}Project Comparison${NC}"
                echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
                echo ""
                echo "$result" | jq -r '.comparisons.projects[]? | "  \(.name): \(.sessions) sessions, avg quality \(.avg_quality), \(.time_saved)h saved"' 2>/dev/null || echo "  Comparison data unavailable"
                echo ""
            fi
        fi
        return 0
    else
        echo -e "${RED}Error: Hub pattern analysis failed${NC}"
        echo "$result"
        return 1
    fi
}

# Main function
main() {
    if [ $# -eq 0 ]; then
        # Default: analyze current project
        analyze_project "" "all" "text" "false" "all" "false"
        exit $?
    fi

    local project_name=""
    local hub_mode=false
    local period="all"
    local format="text"
    local include_quality=false
    local compare=false
    local focus="all"
    local no_cache=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --project)
                project_name="$2"
                shift 2
                ;;
            --hub)
                hub_mode=true
                shift
                ;;
            --period)
                period="$2"
                shift 2
                ;;
            --format)
                format="$2"
                shift 2
                ;;
            --include-quality)
                include_quality=true
                shift
                ;;
            --compare)
                compare=true
                shift
                ;;
            --focus)
                focus="$2"
                shift 2
                ;;
            --no-cache)
                no_cache=true
                shift
                ;;
            --help|-h)
                usage
                ;;
            *)
                echo -e "${RED}Error: Unknown option: $1${NC}"
                usage
                ;;
        esac
    done

    # Determine analysis mode
    if [ "$hub_mode" = true ]; then
        analyze_hub "$period" "$format" "$include_quality" "$compare" "$focus" "$no_cache"
    else
        analyze_project "$project_name" "$period" "$format" "$include_quality" "$focus" "$no_cache"
    fi
}

# Run main if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
