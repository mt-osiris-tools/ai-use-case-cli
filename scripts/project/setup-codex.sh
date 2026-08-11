#!/bin/bash
# Install AI Use Case workflows for Codex.

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_ROOT="${AI_USECASES_CLI_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
PROJECT_PATH="."
INSTALL_MODE="global"
DRY_RUN=false
FORCE=false
JSON_OUTPUT=false

show_help() {
    cat <<'EOF'
Usage: setup-codex.sh [options] [project_path]

Install AI Use Case documentation workflows for Codex.

Options:
  --global       Install to the configured Codex home (default)
  --local        Install to <project>/.codex/
  --dry-run      Show planned changes without writing files
  --force        Replace files that differ from packaged versions
  --json         Emit one machine-readable result object
  -h, --help     Show this help
EOF
}

error() {
    echo -e "${RED}Error:${NC} $*" >&2
    exit 2
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --global) INSTALL_MODE="global"; shift ;;
        --local) INSTALL_MODE="local"; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        --force) FORCE=true; shift ;;
        --json) JSON_OUTPUT=true; shift ;;
        -h|--help) show_help; exit 0 ;;
        --*) error "Unknown option: $1" ;;
        *)
            if [ "$PROJECT_PATH" != "." ]; then error "Only one project path may be provided"; fi
            PROJECT_PATH="$1"
            shift
            ;;
    esac
done

[ -d "$PROJECT_PATH" ] || error "Directory does not exist: $PROJECT_PATH"
PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
PROMPTS_SOURCE="$CLI_ROOT/.codex/prompts"
SKILL_SOURCE="$CLI_ROOT/codex-skills/ai-use-case-documentation"
[ -d "$PROMPTS_SOURCE" ] || error "Packaged Codex prompts not found: $PROMPTS_SOURCE"
[ -f "$SKILL_SOURCE/SKILL.md" ] || error "Packaged Codex skill not found: $SKILL_SOURCE/SKILL.md"

codex_home="${CODEX_HOME:-$HOME/.codex}"
if [ "$INSTALL_MODE" = "local" ]; then target_root="$PROJECT_PATH/.codex"; else target_root="$codex_home"; fi
target_prompts="$target_root/prompts"
target_skill="$target_root/skills/ai-use-case-documentation"

log() { [ "$JSON_OUTPUT" = true ] || echo -e "$*"; }
if [ "$JSON_OUTPUT" = false ]; then
    echo -e "${BLUE}=== Setup Codex integration ===${NC}"
    echo "Project: $PROJECT_PATH"
    echo "Install mode: $INSTALL_MODE"
    echo "Target: $target_root"
    echo ""
fi

planned=0; installed=0; updated=0; skipped=0
install_file() {
    local source_file="$1" target_file="$2" label="$3"
    planned=$((planned + 1))
    if [ -f "$target_file" ]; then
        if cmp -s "$source_file" "$target_file"; then
            skipped=$((skipped + 1)); log "${GREEN}✓${NC} Already current: $label"; return 0
        fi
        if [ "$FORCE" = false ]; then
            skipped=$((skipped + 1)); log "${YELLOW}⚠${NC} Preserved modified file: $target_file (use --force to replace)"; return 0
        fi
        updated=$((updated + 1)); log "${YELLOW}⚠${NC} Updating: $label"
    else
        installed=$((installed + 1)); log "${GREEN}✓${NC} Installing: $label"
    fi
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$(dirname "$target_file")"
        cp "$source_file" "$target_file"
    fi
}

if [ "$DRY_RUN" = false ]; then mkdir -p "$target_prompts" "$target_skill"; fi
shopt -s nullglob
prompt_files=("$PROMPTS_SOURCE"/*.md)
shopt -u nullglob
[ "${#prompt_files[@]}" -gt 0 ] || error "No packaged Codex prompts found in $PROMPTS_SOURCE"
for prompt_file in "${prompt_files[@]}"; do
    install_file "$prompt_file" "$target_prompts/$(basename "$prompt_file")" "$(basename "$prompt_file")"
done
install_file "$SKILL_SOURCE/SKILL.md" "$target_skill/SKILL.md" "ai-use-case-documentation/SKILL.md"

if [ "$DRY_RUN" = false ] && [ -d "$target_prompts" ]; then
    shopt -s nullglob
    for installed_prompt in "$target_prompts"/use-case-*.md; do
        prompt_name="$(basename "$installed_prompt")"
        if [ ! -f "$PROMPTS_SOURCE/$prompt_name" ]; then log "${YELLOW}⚠${NC} Stale installed prompt retained: $installed_prompt"; fi
    done
    shopt -u nullglob
fi

if [ "$JSON_OUTPUT" = true ]; then
    printf '{"mode":"%s","target":"%s","dry_run":%s,"force":%s,"planned":%d,"installed":%d,"updated":%d,"skipped":%d}\n' "$INSTALL_MODE" "$target_root" "$DRY_RUN" "$FORCE" "$planned" "$installed" "$updated" "$skipped"
else
    echo ""
    echo -e "${GREEN}=== Setup complete ===${NC}"
    echo "Prompts: $target_prompts"
    echo "Skill:   $target_skill"
    echo "Planned: $planned | Installed: $installed | Updated: $updated | Skipped: $skipped"
    [ "$INSTALL_MODE" = "global" ] && echo "Use --local to install a project-scoped copy instead."
fi
