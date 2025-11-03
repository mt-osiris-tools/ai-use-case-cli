#!/bin/bash
# AI Use Case CLI - Project Registry Manager
# Manages a registry of projects using the CLI tool

set -e

# Registry configuration
REGISTRY_DIR="$HOME/.local/share/ai-use-case-cli"
REGISTRY_FILE="$REGISTRY_DIR/projects-registry.json"
REGISTRY_VERSION="1.0.0"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Ensure registry directory exists
ensure_registry_dir() {
    if [ ! -d "$REGISTRY_DIR" ]; then
        mkdir -p "$REGISTRY_DIR"
    fi
}

# Initialize registry file if it doesn't exist
init_registry() {
    ensure_registry_dir

    if [ ! -f "$REGISTRY_FILE" ]; then
        cat > "$REGISTRY_FILE" <<EOF
{
  "version": "$REGISTRY_VERSION",
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "projects": {}
}
EOF
    fi
}

# Get CLI version from version.sh (single source of truth)
get_cli_version() {
    local script_dir="$1"
    local version_file="$script_dir/version.sh"

    if [ -f "$version_file" ]; then
        # Source version.sh and return CLI_VERSION
        (source "$version_file" && echo "$CLI_VERSION")
    else
        echo "unknown"
    fi
}

# Add or update a project in the registry
# Usage: register_project <project_path> <cli_version> <hub_path>
register_project() {
    local project_path="$1"
    local cli_version="$2"
    local hub_path="${3:-docs/ai-use-cases}"

    init_registry

    # Get absolute path
    project_path="$(cd "$project_path" && pwd)"

    # Get project name from git
    local project_name
    if [ -d "$project_path/.git" ]; then
        project_name=$(basename "$(git -C "$project_path" rev-parse --show-toplevel)")
    else
        project_name=$(basename "$project_path")
    fi

    # Get current timestamp
    local timestamp
    timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    # Check if project already exists
    local existing_version
    existing_version=$(jq -r ".projects.\"$project_path\".version // \"none\"" "$REGISTRY_FILE")

    if [ "$existing_version" = "none" ]; then
        # New project - set installedAt
        jq --arg path "$project_path" \
           --arg name "$project_name" \
           --arg version "$cli_version" \
           --arg installed "$timestamp" \
           --arg updated "$timestamp" \
           --arg hub "$hub_path" \
           --arg reg_updated "$timestamp" \
           '.projects[$path] = {
               "name": $name,
               "version": $version,
               "installedAt": $installed,
               "lastUpdated": $updated,
               "hubPath": $hub
           } | .lastUpdated = $reg_updated' "$REGISTRY_FILE" > "$REGISTRY_FILE.tmp"
        mv "$REGISTRY_FILE.tmp" "$REGISTRY_FILE"
        echo "registered"
    else
        # Existing project - update version and lastUpdated
        jq --arg path "$project_path" \
           --arg version "$cli_version" \
           --arg updated "$timestamp" \
           --arg reg_updated "$timestamp" \
           '.projects[$path].version = $version |
            .projects[$path].lastUpdated = $updated |
            .lastUpdated = $reg_updated' "$REGISTRY_FILE" > "$REGISTRY_FILE.tmp"
        mv "$REGISTRY_FILE.tmp" "$REGISTRY_FILE"
        echo "updated"
    fi
}

# Get all registered projects
# Returns JSON array of projects
list_projects() {
    init_registry

    jq -r '.projects | to_entries | .[] | @json' "$REGISTRY_FILE"
}

# Get projects that need updates
# Usage: check_updates <current_cli_version>
check_updates() {
    local current_version="$1"
    init_registry

    jq -r --arg current "$current_version" \
        '.projects | to_entries | .[] |
         select(.value.version != $current) |
         @json' "$REGISTRY_FILE"
}

# Remove a project from the registry
# Usage: unregister_project <project_path>
unregister_project() {
    local project_path="$1"
    init_registry

    # Get absolute path
    project_path="$(cd "$project_path" && pwd)"

    # Check if project exists
    local exists
    exists=$(jq -r ".projects.\"$project_path\" // \"none\"" "$REGISTRY_FILE")

    if [ "$exists" = "none" ]; then
        echo "not_found"
        return 1
    fi

    # Remove project
    local timestamp
    timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    jq --arg path "$project_path" \
       --arg reg_updated "$timestamp" \
       'del(.projects[$path]) | .lastUpdated = $reg_updated' \
       "$REGISTRY_FILE" > "$REGISTRY_FILE.tmp"
    mv "$REGISTRY_FILE.tmp" "$REGISTRY_FILE"

    echo "removed"
}

# Get project info
# Usage: get_project_info <project_path>
get_project_info() {
    local project_path="$1"
    init_registry

    # Get absolute path
    project_path="$(cd "$project_path" && pwd)"

    jq -r ".projects.\"$project_path\" // null" "$REGISTRY_FILE"
}

# Get registry statistics
get_registry_stats() {
    init_registry

    local total
    local current_version="$1"

    total=$(jq -r '.projects | length' "$REGISTRY_FILE")

    if [ -n "$current_version" ]; then
        local outdated
        outdated=$(jq -r --arg current "$current_version" \
            '.projects | to_entries | map(select(.value.version != $current)) | length' \
            "$REGISTRY_FILE")

        echo "$total $outdated"
    else
        echo "$total"
    fi
}

# Pretty print project list
# Usage: print_projects [current_cli_version]
print_projects() {
    local current_version="${1:-}"
    init_registry

    local total
    total=$(jq -r '.projects | length' "$REGISTRY_FILE")

    if [ "$total" -eq 0 ]; then
        echo -e "${YELLOW}No projects registered yet${NC}"
        return
    fi

    echo -e "${BLUE}=== Registered Projects ===${NC}"
    echo ""

    local count=0
    while IFS= read -r project_json; do
        count=$((count + 1))

        local path name version installed updated
        path=$(echo "$project_json" | jq -r '.key')
        name=$(echo "$project_json" | jq -r '.value.name')
        version=$(echo "$project_json" | jq -r '.value.version')
        installed=$(echo "$project_json" | jq -r '.value.installedAt')
        updated=$(echo "$project_json" | jq -r '.value.lastUpdated')

        # Check if needs update
        local status_color="$GREEN"
        local status="✓ Up to date"
        if [ -n "$current_version" ] && [ "$version" != "$current_version" ]; then
            status_color="$YELLOW"
            status="⚠ Update available: $version → $current_version"
        fi

        echo -e "${CYAN}$count. $name${NC}"
        echo "   Path: $path"
        echo "   Version: $version"
        echo -e "   Status: ${status_color}${status}${NC}"
        echo "   Installed: $(date -d "$installed" +"%Y-%m-%d %H:%M" 2>/dev/null || echo "$installed")"
        echo ""
    done < <(list_projects)
}

# Export functions for use in other scripts
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    export -f ensure_registry_dir
    export -f init_registry
    export -f get_cli_version
    export -f register_project
    export -f list_projects
    export -f check_updates
    export -f unregister_project
    export -f get_project_info
    export -f get_registry_stats
    export -f print_projects
fi
