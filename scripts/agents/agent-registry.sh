#!/bin/bash
# AI Use Case CLI - Agent Registry Manager
# Manages the agent registry for intelligent agents integration

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
TEMPLATE_FILE="$SCRIPT_DIR/agents-template.json"

# Config directory
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ai-use-case-cli"
REGISTRY_FILE="$CONFIG_DIR/agents.json"

# Source utilities if available
if [ -f "$SCRIPT_DIR/../utils/version.sh" ]; then
    source "$SCRIPT_DIR/../utils/version.sh"
fi

# Usage function
usage() {
    cat <<EOF
${CYAN}AI Use Case CLI - Agent Registry Manager${NC}

${YELLOW}Usage:${NC}
  $(basename "$0") <command> [options]

${YELLOW}Commands:${NC}
  init                  Initialize agent registry
  list [--enabled|--disabled|--all]
                        List agents (default: all)
  enable <agent-id>     Enable an agent
  disable <agent-id>    Disable an agent
  info <agent-id>       Show detailed agent information
  register <agent-id> --name <name> --subagent-type <type> --description <desc>
                        Register a new agent
  stats [agent-id]      Show agent statistics
  reset                 Reset registry to default (requires confirmation)

${YELLOW}Examples:${NC}
  $(basename "$0") init
  $(basename "$0") list --enabled
  $(basename "$0") enable quality-reviewer
  $(basename "$0") info quality-reviewer
  $(basename "$0") stats quality-reviewer

EOF
    exit 0
}

# Initialize registry
init_registry() {
    echo -e "${CYAN}Initializing agent registry...${NC}"

    # Create config directory
    mkdir -p "$CONFIG_DIR"

    # Check if registry already exists
    if [ -f "$REGISTRY_FILE" ]; then
        echo -e "${YELLOW}Registry already exists at: $REGISTRY_FILE${NC}"
        read -p "Overwrite? (y/N): " overwrite
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Keeping existing registry${NC}"
            return 0
        fi
    fi

    # Copy template to config location
    if [ ! -f "$TEMPLATE_FILE" ]; then
        echo -e "${RED}Error: Template file not found: $TEMPLATE_FILE${NC}"
        exit 1
    fi

    cp "$TEMPLATE_FILE" "$REGISTRY_FILE"
    chmod 600 "$REGISTRY_FILE"

    echo -e "${GREEN}✓ Registry initialized at: $REGISTRY_FILE${NC}"
    echo -e "${CYAN}  Run 'list' to see available agents${NC}"
}

# Ensure registry exists
ensure_registry() {
    if [ ! -f "$REGISTRY_FILE" ]; then
        echo -e "${YELLOW}Registry not found. Initializing...${NC}"
        init_registry
    fi
}

# List agents
list_agents() {
    ensure_registry

    local filter="${1:-all}"

    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}AI Use Case CLI - Available Agents${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo ""

    # Get agents based on filter
    local jq_filter='.agents[]'
    case "$filter" in
        --enabled)
            jq_filter='.agents[] | select(.enabled == true)'
            echo -e "${GREEN}Showing: Enabled agents only${NC}"
            ;;
        --disabled)
            jq_filter='.agents[] | select(.enabled == false)'
            echo -e "${YELLOW}Showing: Disabled agents only${NC}"
            ;;
        --all|*)
            echo -e "${BLUE}Showing: All agents${NC}"
            ;;
    esac
    echo ""

    # Read and display agents
    local count=0
    while IFS= read -r agent; do
        # Skip empty lines
        [ -z "$agent" ] && continue

        local id=$(echo "$agent" | jq -r '.id')
        local name=$(echo "$agent" | jq -r '.name')
        local description=$(echo "$agent" | jq -r '.description')
        local enabled=$(echo "$agent" | jq -r '.enabled')
        local invocations=$(echo "$agent" | jq -r '.statistics.invocations')

        # Status icon
        local status_icon="${RED}○${NC}"
        local status_text="${RED}disabled${NC}"
        if [ "$enabled" = "true" ]; then
            status_icon="${GREEN}●${NC}"
            status_text="${GREEN}enabled${NC}"
        fi

        echo -e "${status_icon} ${YELLOW}$id${NC} - $status_text"
        echo -e "   ${CYAN}Name:${NC} $name"
        echo -e "   ${CYAN}Description:${NC} $description"
        echo -e "   ${CYAN}Invocations:${NC} $invocations"
        echo ""

        ((count++)) || true
    done < <(jq -c "$jq_filter" "$REGISTRY_FILE" 2>/dev/null || true)

    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}No agents found matching filter${NC}"
    else
        echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
        echo -e "${GREEN}Total: $count agent(s)${NC}"
    fi

    return 0
}

# Enable agent
enable_agent() {
    ensure_registry

    local agent_id="$1"

    if [ -z "$agent_id" ]; then
        echo -e "${RED}Error: Agent ID required${NC}"
        echo "Usage: $(basename "$0") enable <agent-id>"
        exit 1
    fi

    # Check if agent exists
    local exists=$(jq -r ".agents[] | select(.id == \"$agent_id\") | .id" "$REGISTRY_FILE")
    if [ -z "$exists" ]; then
        echo -e "${RED}Error: Agent '$agent_id' not found${NC}"
        echo "Run 'list' to see available agents"
        exit 1
    fi

    # Check if already enabled
    local already_enabled=$(jq -r ".agents[] | select(.id == \"$agent_id\") | .enabled" "$REGISTRY_FILE")
    if [ "$already_enabled" = "true" ]; then
        echo -e "${YELLOW}Agent '$agent_id' is already enabled${NC}"
        return 0
    fi

    # Enable the agent
    jq "(.agents[] | select(.id == \"$agent_id\") | .enabled) = true" "$REGISTRY_FILE" > "${REGISTRY_FILE}.tmp"
    mv "${REGISTRY_FILE}.tmp" "$REGISTRY_FILE"

    echo -e "${GREEN}✓ Enabled agent: $agent_id${NC}"
}

# Disable agent
disable_agent() {
    ensure_registry

    local agent_id="$1"

    if [ -z "$agent_id" ]; then
        echo -e "${RED}Error: Agent ID required${NC}"
        echo "Usage: $(basename "$0") disable <agent-id>"
        exit 1
    fi

    # Check if agent exists
    local exists=$(jq -r ".agents[] | select(.id == \"$agent_id\") | .id" "$REGISTRY_FILE")
    if [ -z "$exists" ]; then
        echo -e "${RED}Error: Agent '$agent_id' not found${NC}"
        exit 1
    fi

    # Disable the agent
    jq "(.agents[] | select(.id == \"$agent_id\") | .enabled) = false" "$REGISTRY_FILE" > "${REGISTRY_FILE}.tmp"
    mv "${REGISTRY_FILE}.tmp" "$REGISTRY_FILE"

    echo -e "${YELLOW}✓ Disabled agent: $agent_id${NC}"
}

# Show agent info
show_agent_info() {
    ensure_registry

    local agent_id="$1"

    if [ -z "$agent_id" ]; then
        echo -e "${RED}Error: Agent ID required${NC}"
        echo "Usage: $(basename "$0") info <agent-id>"
        exit 1
    fi

    # Get agent data
    local agent=$(jq -c ".agents[] | select(.id == \"$agent_id\")" "$REGISTRY_FILE")

    if [ -z "$agent" ]; then
        echo -e "${RED}Error: Agent '$agent_id' not found${NC}"
        exit 1
    fi

    # Extract fields
    local name=$(echo "$agent" | jq -r '.name')
    local description=$(echo "$agent" | jq -r '.description')
    local subagent_type=$(echo "$agent" | jq -r '.subagent_type')
    local enabled=$(echo "$agent" | jq -r '.enabled')
    local version=$(echo "$agent" | jq -r '.version')
    local capabilities=$(echo "$agent" | jq -r '.capabilities | join(", ")')
    local dependencies=$(echo "$agent" | jq -r '.dependencies | join(", ")')

    # Statistics
    local invocations=$(echo "$agent" | jq -r '.statistics.invocations')
    local successes=$(echo "$agent" | jq -r '.statistics.successes')
    local failures=$(echo "$agent" | jq -r '.statistics.failures')
    local success_rate=$(echo "$agent" | jq -r '.statistics.success_rate')
    local last_invoked=$(echo "$agent" | jq -r '.statistics.last_invoked')
    local avg_duration=$(echo "$agent" | jq -r '.statistics.avg_duration_seconds')

    # Status
    local status_text="${RED}Disabled${NC}"
    if [ "$enabled" = "true" ]; then
        status_text="${GREEN}Enabled${NC}"
    fi

    # Display info
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Agent Information: ${YELLOW}$agent_id${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Name:${NC} $name"
    echo -e "${CYAN}Description:${NC} $description"
    echo -e "${CYAN}Status:${NC} $status_text"
    echo -e "${CYAN}Version:${NC} $version"
    echo -e "${CYAN}Subagent Type:${NC} $subagent_type"
    echo ""
    echo -e "${CYAN}Capabilities:${NC}"
    echo -e "  $capabilities"
    echo ""
    echo -e "${CYAN}Dependencies:${NC}"
    echo -e "  $dependencies"
    echo ""
    echo -e "${CYAN}Statistics:${NC}"
    echo -e "  ${CYAN}Total Invocations:${NC} $invocations"
    echo -e "  ${CYAN}Successes:${NC} ${GREEN}$successes${NC}"
    echo -e "  ${CYAN}Failures:${NC} ${RED}$failures${NC}"
    echo -e "  ${CYAN}Success Rate:${NC} $(printf "%.1f" "$success_rate")%"
    echo -e "  ${CYAN}Avg Duration:${NC} $(printf "%.1f" "$avg_duration")s"

    if [ "$last_invoked" != "null" ] && [ -n "$last_invoked" ]; then
        echo -e "  ${CYAN}Last Invoked:${NC} $last_invoked"
    fi
    echo ""
}

# Register new agent
register_agent() {
    ensure_registry

    local agent_id=""
    local name=""
    local subagent_type=""
    local description=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --name)
                name="$2"
                shift 2
                ;;
            --subagent-type)
                subagent_type="$2"
                shift 2
                ;;
            --description)
                description="$2"
                shift 2
                ;;
            *)
                if [ -z "$agent_id" ]; then
                    agent_id="$1"
                fi
                shift
                ;;
        esac
    done

    # Validate required fields
    if [ -z "$agent_id" ] || [ -z "$name" ] || [ -z "$subagent_type" ] || [ -z "$description" ]; then
        echo -e "${RED}Error: Missing required parameters${NC}"
        echo ""
        echo "Usage: $(basename "$0") register <agent-id> --name <name> --subagent-type <type> --description <desc>"
        exit 1
    fi

    # Check if agent already exists
    local exists=$(jq -r ".agents[] | select(.id == \"$agent_id\") | .id" "$REGISTRY_FILE")
    if [ -n "$exists" ]; then
        echo -e "${RED}Error: Agent '$agent_id' already exists${NC}"
        exit 1
    fi

    # Create new agent object
    local new_agent=$(cat <<EOF
{
  "id": "$agent_id",
  "name": "$name",
  "description": "$description",
  "subagent_type": "$subagent_type",
  "enabled": false,
  "version": "1.0.0",
  "capabilities": [],
  "dependencies": ["claude-code"],
  "statistics": {
    "invocations": 0,
    "successes": 0,
    "failures": 0,
    "last_invoked": null,
    "last_success": null,
    "last_failure": null,
    "success_rate": 0.0,
    "avg_duration_seconds": 0.0
  }
}
EOF
)

    # Add to registry
    jq ".agents += [$new_agent]" "$REGISTRY_FILE" > "${REGISTRY_FILE}.tmp"
    mv "${REGISTRY_FILE}.tmp" "$REGISTRY_FILE"

    echo -e "${GREEN}✓ Registered new agent: $agent_id${NC}"
    echo -e "${CYAN}  Use 'enable $agent_id' to activate it${NC}"
}

# Show statistics
show_stats() {
    ensure_registry

    local agent_id="${1:-}"

    if [ -n "$agent_id" ]; then
        # Show stats for specific agent
        show_agent_info "$agent_id"
    else
        # Show overall stats
        echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
        echo -e "${CYAN}Agent Registry Statistics${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
        echo ""

        local total=$(jq '.agents | length' "$REGISTRY_FILE")
        local enabled=$(jq '[.agents[] | select(.enabled == true)] | length' "$REGISTRY_FILE")
        local disabled=$(jq '[.agents[] | select(.enabled == false)] | length' "$REGISTRY_FILE")
        local total_invocations=$(jq '[.agents[].statistics.invocations] | add // 0' "$REGISTRY_FILE")

        echo -e "${CYAN}Total Agents:${NC} $total"
        echo -e "${GREEN}Enabled:${NC} $enabled"
        echo -e "${YELLOW}Disabled:${NC} $disabled"
        echo -e "${CYAN}Total Invocations:${NC} $total_invocations"
        echo ""
    fi
}

# Reset registry
reset_registry() {
    echo -e "${YELLOW}⚠ WARNING: This will reset the registry to default${NC}"
    echo -e "${YELLOW}All agent statistics will be lost${NC}"
    echo ""
    read -p "Are you sure? Type 'yes' to confirm: " confirm

    if [ "$confirm" != "yes" ]; then
        echo -e "${BLUE}Reset cancelled${NC}"
        exit 0
    fi

    # Remove existing registry
    if [ -f "$REGISTRY_FILE" ]; then
        rm "$REGISTRY_FILE"
        echo -e "${GREEN}✓ Removed existing registry${NC}"
    fi

    # Initialize fresh registry
    init_registry
}

# Main command dispatcher
main() {
    if [ $# -eq 0 ]; then
        usage
    fi

    local command="$1"
    shift

    case "$command" in
        init)
            init_registry
            ;;
        list)
            list_agents "$@"
            ;;
        enable)
            enable_agent "$@"
            ;;
        disable)
            disable_agent "$@"
            ;;
        info)
            show_agent_info "$@"
            ;;
        register)
            register_agent "$@"
            ;;
        stats)
            show_stats "$@"
            ;;
        reset)
            reset_registry
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            echo -e "${RED}Error: Unknown command: $command${NC}"
            echo ""
            usage
            ;;
    esac
}

# Run main if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
