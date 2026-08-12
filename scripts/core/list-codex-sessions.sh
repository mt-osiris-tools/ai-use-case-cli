#!/bin/bash
# Discover and resolve Codex JSONL sessions for the Codex documentation workflow.

set -euo pipefail

codex_home="${CODEX_HOME:-${HOME:?}/.codex}"
sessions_root="$codex_home/sessions"
mode="list"
requested_uuid=""
repo_filter=""

usage() {
    cat <<'EOF'
Usage: list-codex-sessions.sh [options]

Discover local Codex sessions or resolve one session UUID.

Options:
  --uuid UUID       Resolve one session by UUID
  --repo PATH       Restrict listing to sessions recorded in PATH
  --all             List sessions from all repositories
  --json            Emit JSON instead of tab-separated text
  -h, --help        Show this help
EOF
}

error() {
    echo "Error: $*" >&2
    exit 2
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --uuid)
            [[ $# -ge 2 ]] || error "--uuid requires a value"
            requested_uuid="$2"
            mode="resolve"
            shift 2
            ;;
        --repo)
            [[ $# -ge 2 ]] || error "--repo requires a path"
            repo_filter="$2"
            shift 2
            ;;
        --all)
            repo_filter=""
            shift
            ;;
        --json)
            output_json=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "unknown option: $1"
            ;;
    esac
done

output_json="${output_json:-false}"

command -v jq >/dev/null 2>&1 || error "jq is required to inspect Codex session metadata"

if [[ -n "$requested_uuid" && ! "$requested_uuid" =~ ^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$ ]]; then
    error "invalid session UUID: $requested_uuid"
fi

normalize_path() {
    local path="$1"
    if [[ -d "$path" ]]; then
        (cd "$path" && pwd -P)
    else
        echo "$path"
    fi
}

if [[ -n "$repo_filter" ]]; then
    repo_filter="$(normalize_path "$repo_filter")"
fi

if [[ ! -d "$sessions_root" ]]; then
    if [[ "$output_json" == true ]]; then
        echo '[]'
    fi
    exit 0
fi

session_files=()
if [[ "$mode" == resolve ]]; then
    requested_uuid="${requested_uuid,,}"
    while IFS= read -r session_file; do
        [[ -n "$session_file" ]] && session_files+=("$session_file")
    done < <(find "$sessions_root" -type f -name "*-${requested_uuid}.jsonl" -print)
else
    while IFS= read -r session_file; do
        [[ -n "$session_file" ]] && session_files+=("$session_file")
    done < <(find "$sessions_root" -type f -name '*.jsonl' -print)
fi

records=()
for session_file in "${session_files[@]}"; do
    record="$(jq -c -s --arg path "$session_file" '
        map(select(.type == "session_meta")) | .[0].payload // empty |
        {id: (.id // .session_id), timestamp, cwd, originator, cli_version, path: $path}
    ' "$session_file" 2>/dev/null || true)"
    [[ -n "$record" ]] || continue

    session_id="$(jq -r '.id // empty' <<<"$record")"
    [[ "$session_id" =~ ^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$ ]] || continue
    [[ "$mode" != resolve || "${session_id,,}" == "$requested_uuid" ]] || continue

    session_cwd="$(jq -r '.cwd // empty' <<<"$record")"
    if [[ -n "$repo_filter" && "$(normalize_path "$session_cwd")" != "$repo_filter" ]]; then
        continue
    fi
    records+=("$record")
done

if [[ "$mode" == resolve && ${#records[@]} -eq 0 ]]; then
    error "session UUID not found: $requested_uuid"
fi

if [[ "$output_json" == true ]]; then
    printf '%s\n' "${records[@]:-}" | jq -s 'sort_by(.timestamp) | reverse'
    exit 0
fi

printf '%s\n' "${records[@]:-}" |
    jq -s -r 'sort_by(.timestamp) | reverse[] | [.id, .timestamp, (.cwd // ""), (.originator // ""), (.cli_version // ""), .path] | @tsv'
