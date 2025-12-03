#!/bin/bash
# AI Use Case CLI - Agent Invoker
# Invokes specialized AI agents via Claude Code Task tool

set -euo pipefail

# Color definitions
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Config directory
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ai-use-case-cli"
REGISTRY_FILE="$CONFIG_DIR/agents.json"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ai-use-case-cli/agents"

# Source registry manager
source "$SCRIPT_DIR/agent-registry.sh" 2>/dev/null || true

# Usage function
usage() {
    cat <<EOF
${CYAN}AI Use Case CLI - Agent Invoker${NC}

${YELLOW}Usage:${NC}
  $(basename "$0") <agent-id> [options]

${YELLOW}Options:${NC}
  --file <path>         File to analyze (for file-based agents)
  --project <name>      Project name (for project-based agents)
  --context <json>      Additional context as JSON string
  --timeout <seconds>   Timeout for agent execution (default: from config)
  --no-cache            Skip cache check and force fresh invocation
  --format <fmt>        Output format: text (default) or json
  --param <key=value>   Additional parameter (can be used multiple times)

${YELLOW}Examples:${NC}
  $(basename "$0") quality-reviewer --file .usecase/cases/example.md
  $(basename "$0") pattern-analyzer --project my-project
  $(basename "$0") session-selector --context '{"branch": "main"}'

${YELLOW}Note:${NC}
  This script requires Claude Code to be available. Agents will not work
  in standalone CLI mode. The CLI will show a friendly message if Claude Code
  is unavailable.

EOF
    exit 0
}

# Check Claude Code availability
check_claude_code() {
    # For now, we'll assume Claude Code is available if we're running in an interactive session
    # In actual implementation, this would check for Claude Code CLI or API availability

    # Placeholder: In Phase 2-5, this will be implemented properly
    # For Phase 1, we just validate the agent framework works

    return 0
}

# Validate agent
validate_agent() {
    local agent_id="$1"

    if [ ! -f "$REGISTRY_FILE" ]; then
        echo -e "${RED}Error: Agent registry not initialized${NC}"
        echo -e "${CYAN}Run: ai-use-case agents init${NC}"
        return 1
    fi

    # Check if agent exists
    local exists=$(jq -r ".agents[] | select(.id == \"$agent_id\") | .id" "$REGISTRY_FILE" 2>/dev/null)
    if [ -z "$exists" ]; then
        echo -e "${RED}Error: Agent '$agent_id' not found${NC}"
        echo -e "${CYAN}Run: ai-use-case agents list${NC}"
        return 1
    fi

    # Check if agent is enabled
    local enabled=$(jq -r ".agents[] | select(.id == \"$agent_id\") | .enabled" "$REGISTRY_FILE")
    if [ "$enabled" != "true" ]; then
        echo -e "${RED}Error: Agent '$agent_id' is disabled${NC}"
        echo -e "${CYAN}Run: ai-use-case agents enable $agent_id${NC}"
        return 1
    fi

    return 0
}

# Get agent subagent_type
get_subagent_type() {
    local agent_id="$1"
    jq -r ".agents[] | select(.id == \"$agent_id\") | .subagent_type" "$REGISTRY_FILE"
}

# Get timeout from config or use default
get_timeout() {
    local timeout=$(jq -r '.config.default_timeout // 120' "$REGISTRY_FILE" 2>/dev/null)
    echo "$timeout"
}

# Sanitize agent ID for safe file path usage
sanitize_agent_id() {
    local agent_id="$1"
    # Only allow alphanumeric, underscore, hyphen, and dot
    echo "$agent_id" | sed 's/[^a-zA-Z0-9._-]/_/g'
}

# Check cache
check_cache() {
    local agent_id="$1"
    local cache_key="$2"

    # Check if caching is enabled
    local cache_enabled=$(jq -r '.config.cache_results // true' "$REGISTRY_FILE" 2>/dev/null)
    if [ "$cache_enabled" != "true" ]; then
        return 1
    fi

    # Create cache directory if it doesn't exist
    mkdir -p "$CACHE_DIR"

    # Sanitize agent_id to prevent path traversal
    local safe_id=$(sanitize_agent_id "$agent_id")
    local cache_file="$CACHE_DIR/${safe_id}_${cache_key}.json"

    # Validate the resolved path is within CACHE_DIR
    local cache_dir_real=$(cd "$CACHE_DIR" && pwd -P)
    local cache_file_real=$(realpath -m "$cache_file")
    if [[ "$cache_file_real" != "$cache_dir_real"/* ]]; then
        echo -e "${RED}Error: Invalid cache path${NC}" >&2
        return 1
    fi

    if [ ! -f "$cache_file" ]; then
        return 1
    fi

    # Check cache age
    local cache_duration=$(jq -r '.config.cache_duration // 3600' "$REGISTRY_FILE" 2>/dev/null)
    local cache_age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0)))

    if [ $cache_age -gt $cache_duration ]; then
        # Cache expired
        return 1
    fi

    # Cache is valid
    echo "$cache_file"
    return 0
}

# Save to cache
save_cache() {
    local agent_id="$1"
    local cache_key="$2"
    local result="$3"

    mkdir -p "$CACHE_DIR"

    # Sanitize agent_id to prevent path traversal
    local safe_id=$(sanitize_agent_id "$agent_id")
    local cache_file="$CACHE_DIR/${safe_id}_${cache_key}.json"

    # Validate the resolved path is within CACHE_DIR
    local cache_dir_real=$(cd "$CACHE_DIR" && pwd -P)
    local cache_file_real=$(realpath -m "$cache_file")
    if [[ "$cache_file_real" != "$cache_dir_real"/* ]]; then
        echo -e "${RED}Error: Invalid cache path${NC}" >&2
        return 1
    fi

    # Save to cache
    echo "$result" > "$cache_file"
}

# Update agent statistics
update_statistics() {
    local agent_id="$1"
    local success="$2"  # true or false
    local duration="$3"  # in seconds

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Get current stats
    local agent_json=$(jq ".agents[] | select(.id == \"$agent_id\")" "$REGISTRY_FILE")
    local invocations=$(echo "$agent_json" | jq -r '.statistics.invocations')
    local successes=$(echo "$agent_json" | jq -r '.statistics.successes')
    local failures=$(echo "$agent_json" | jq -r '.statistics.failures')
    local avg_duration=$(echo "$agent_json" | jq -r '.statistics.avg_duration_seconds')

    # Update counts
    invocations=$((invocations + 1))

    if [ "$success" = "true" ]; then
        successes=$((successes + 1))
    else
        failures=$((failures + 1))
    fi

    # Calculate new average duration
    if [ "$invocations" -eq 1 ]; then
        avg_duration="$duration"
    else
        avg_duration=$(awk "BEGIN {print (($avg_duration * ($invocations - 1)) + $duration) / $invocations}")
    fi

    # Calculate success rate
    local success_rate=$(awk "BEGIN {print ($successes / $invocations) * 100}")

    # Update registry
    local update_filter="
        (.agents[] | select(.id == \"$agent_id\") | .statistics.invocations) = $invocations |
        (.agents[] | select(.id == \"$agent_id\") | .statistics.successes) = $successes |
        (.agents[] | select(.id == \"$agent_id\") | .statistics.failures) = $failures |
        (.agents[] | select(.id == \"$agent_id\") | .statistics.success_rate) = $success_rate |
        (.agents[] | select(.id == \"$agent_id\") | .statistics.avg_duration_seconds) = $avg_duration |
        (.agents[] | select(.id == \"$agent_id\") | .statistics.last_invoked) = \"$timestamp\"
    "

    if [ "$success" = "true" ]; then
        update_filter="$update_filter | (.agents[] | select(.id == \"$agent_id\") | .statistics.last_success) = \"$timestamp\""
    else
        update_filter="$update_filter | (.agents[] | select(.id == \"$agent_id\") | .statistics.last_failure) = \"$timestamp\""
    fi

    jq "$update_filter" "$REGISTRY_FILE" > "${REGISTRY_FILE}.tmp"
    mv "${REGISTRY_FILE}.tmp" "$REGISTRY_FILE"
}

# Invoke agent (placeholder for Phase 1)
# In Phase 2-5, this will actually call Claude Code Task tool
invoke_agent_implementation() {
    local agent_id="$1"
    local subagent_type="$2"
    local context="$3"
    local timeout="$4"

    # For Phase 1, this is a placeholder that returns success
    # In actual implementation (Phase 2+), this would:
    # 1. Call Claude Code Task tool with subagent_type
    # 2. Pass context as parameters
    # 3. Wait for response with timeout
    # 4. Return formatted result

    cat <<EOF
{
  "success": true,
  "agent_id": "$agent_id",
  "subagent_type": "$subagent_type",
  "message": "Agent framework initialized successfully",
  "note": "Actual agent implementation will be added in Phase 2-5",
  "context_received": $context,
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

    return 0
}

# Main invocation function
invoke_agent() {
    local agent_id=""
    local file_path=""
    local project_name=""
    local context_json="{}"
    local timeout=""
    local use_cache=true
    local output_format="text"
    declare -A params

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --file)
                file_path="$2"
                shift 2
                ;;
            --project)
                project_name="$2"
                shift 2
                ;;
            --context)
                context_json="$2"
                shift 2
                ;;
            --timeout)
                timeout="$2"
                shift 2
                ;;
            --no-cache)
                use_cache=false
                shift
                ;;
            --format)
                output_format="$2"
                shift 2
                ;;
            --param)
                local key_value="$2"
                local key="${key_value%%=*}"
                local value="${key_value#*=}"
                params["$key"]="$value"
                shift 2
                ;;
            --help|-h)
                usage
                ;;
            *)
                if [ -z "$agent_id" ]; then
                    agent_id="$1"
                fi
                shift
                ;;
        esac
    done

    # Validate agent ID
    if [ -z "$agent_id" ]; then
        echo -e "${RED}Error: Agent ID required${NC}"
        usage
    fi

    # Validate agent
    if ! validate_agent "$agent_id"; then
        exit 1
    fi

    # Check Claude Code (placeholder for Phase 1)
    if ! check_claude_code; then
        echo -e "${RED}Error: Claude Code not available${NC}"
        echo -e "${CYAN}Agents require Claude Code to function${NC}"
        echo -e "${CYAN}Install from: https://claude.com/claude-code${NC}"
        exit 1
    fi

    # Get subagent type
    local subagent_type=$(get_subagent_type "$agent_id")

    # Get timeout
    if [ -z "$timeout" ]; then
        timeout=$(get_timeout)
    fi

    # Build context with all params in a single jq invocation for efficiency
    local full_context
    # Check if params array has elements (safe for set -u)
    local params_count=0
    if [ -n "${params[*]+x}" ]; then
        params_count="${#params[@]}"
    fi

    if [ "$params_count" -gt 0 ]; then
        # Build jq args for all params
        local jq_args="--arg file \"$file_path\" --arg project \"$project_name\" --argjson base \"$context_json\""
        local jq_obj_parts="\$base + {file: \$file, project: \$project"

        for key in "${!params[@]}"; do
            jq_args="$jq_args --arg param_$key \"${params[$key]}\""
            jq_obj_parts="$jq_obj_parts, $key: \$param_$key"
        done
        jq_obj_parts="$jq_obj_parts}"

        full_context=$(eval "jq -n $jq_args '$jq_obj_parts'")
    else
        # No params, simpler invocation
        full_context=$(jq -n \
            --arg file "$file_path" \
            --arg project "$project_name" \
            --argjson base "$context_json" \
            '$base + {file: $file, project: $project}')
    fi

    # Generate cache key
    local cache_key=$(echo "$full_context" | md5sum | cut -d' ' -f1)

    # Check cache
    if [ "$use_cache" = true ]; then
        local cache_file=$(check_cache "$agent_id" "$cache_key" 2>/dev/null || echo "")
        if [ -n "$cache_file" ] && [ -f "$cache_file" ]; then
            echo -e "${CYAN}Using cached result...${NC}"
            cat "$cache_file"
            return 0
        fi
    fi

    # Show progress
    echo -e "${CYAN}Invoking agent: $agent_id${NC}"
    echo -e "${CYAN}This may take up to $timeout seconds...${NC}"
    echo ""

    # Start timer
    local start_time=$(date +%s)

    # Invoke agent
    local result=""
    local success=false

    if result=$(invoke_agent_implementation "$agent_id" "$subagent_type" "$full_context" "$timeout" 2>&1); then
        success=true

        # Save to cache
        if [ "$use_cache" = true ]; then
            save_cache "$agent_id" "$cache_key" "$result"
        fi

        # Format output
        if [ "$output_format" = "json" ]; then
            echo "$result"
        else
            # Pretty print for text format
            echo -e "${GREEN}✓ Agent completed successfully${NC}"
            echo ""
            echo "$result" | jq -r '.message // .'
        fi
    else
        success=false
        echo -e "${RED}✗ Agent invocation failed${NC}"
        echo ""
        echo "$result"
    fi

    # Calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Update statistics
    update_statistics "$agent_id" "$success" "$duration"

    if [ "$success" = true ]; then
        return 0
    else
        return 1
    fi
}

# Main entry point
main() {
    if [ $# -eq 0 ]; then
        usage
    fi

    invoke_agent "$@"
}

# Run main if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
