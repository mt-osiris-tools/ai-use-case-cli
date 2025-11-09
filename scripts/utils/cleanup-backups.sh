#!/bin/bash
# AI Use Case CLI - Cleanup Backups
# Removes backup directories created during updates

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse flags
AUTO_CONFIRM=false
PROJECT_PATH=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_CONFIRM=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            cat <<EOF
${BLUE}AI Use Case CLI - Cleanup Backups${NC}

Removes backup directories created during project updates.

${YELLOW}Usage:${NC}
  $0 [options] [project_path]

${YELLOW}Arguments:${NC}
  project_path    Path to the project (default: current directory)

${YELLOW}Options:${NC}
  -y, --yes       Skip confirmation prompt
  -n, --dry-run   Show what would be deleted without deleting
  -h, --help      Show this help message

${YELLOW}Examples:${NC}
  $0                    # Cleanup backups in current directory (with prompt)
  $0 -y                 # Cleanup without confirmation
  $0 -n                 # Dry run to see what would be deleted
  $0 /path/to/project   # Cleanup specific project
EOF
            exit 0
            ;;
        *)
            if [ -z "$PROJECT_PATH" ]; then
                PROJECT_PATH="$1"
                shift
            else
                echo -e "${RED}Error: Unexpected argument '$1'${NC}"
                exit 1
            fi
            ;;
    esac
done

# Use current directory if no path provided
PROJECT_PATH="${PROJECT_PATH:-$(pwd)}"

# Verify project exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Directory does not exist: $PROJECT_PATH${NC}"
    exit 1
fi

# Get absolute path
PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"

echo -e "${BLUE}=== Cleanup Backups ===${NC}"
echo "Project: $(basename "$PROJECT_PATH")"
echo "Path: $PROJECT_PATH"
echo ""

# Find backup directories
BACKUP_DIRS=()

# Check for command backups in old location (.claude/commands/*.backup.*)
if [ -d "$PROJECT_PATH/.claude/commands" ]; then
    while IFS= read -r -d '' backup_dir; do
        BACKUP_DIRS+=("$backup_dir")
    done < <(find "$PROJECT_PATH/.claude/commands" -maxdepth 1 -name "*.backup.*" -type d -print0 2>/dev/null)
fi

# Check for command backups in new location (.claude/backups/)
if [ -d "$PROJECT_PATH/.claude/backups" ]; then
    while IFS= read -r -d '' backup_dir; do
        BACKUP_DIRS+=("$backup_dir")
    done < <(find "$PROJECT_PATH/.claude/backups" -maxdepth 1 -type d ! -name "backups" -print0 2>/dev/null)
fi

# Check for git hook backups
if [ -d "$PROJECT_PATH/.git/hooks" ]; then
    while IFS= read -r -d '' backup_file; do
        BACKUP_DIRS+=("$backup_file")
    done < <(find "$PROJECT_PATH/.git/hooks" -name "*.backup.*" -type f -print0 2>/dev/null)
fi

# Check if any backups found
if [ ${#BACKUP_DIRS[@]} -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No backup directories found"
    exit 0
fi

# Display backups
echo "Found ${#BACKUP_DIRS[@]} backup(s):"
echo ""
for backup in "${BACKUP_DIRS[@]}"; do
    RELATIVE_PATH="${backup#$PROJECT_PATH/}"
    SIZE=$(du -sh "$backup" 2>/dev/null | cut -f1)
    echo "  ${CYAN}${RELATIVE_PATH}${NC} (${SIZE})"
done
echo ""

# Dry run mode
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Dry run mode - nothing will be deleted${NC}"
    exit 0
fi

# Confirm deletion
if [ "$AUTO_CONFIRM" = false ]; then
    read -p "Delete these backups? [y/N] " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled"
        exit 0
    fi
else
    echo "Auto-confirming deletion (--yes flag used)"
fi

echo ""

# Delete backups
DELETED_COUNT=0
for backup in "${BACKUP_DIRS[@]}"; do
    RELATIVE_PATH="${backup#$PROJECT_PATH/}"
    if rm -rf "$backup" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Deleted: $RELATIVE_PATH"
        DELETED_COUNT=$((DELETED_COUNT + 1))
    else
        echo -e "${RED}✗${NC} Failed to delete: $RELATIVE_PATH"
    fi
done

echo ""
echo -e "${GREEN}=== Cleanup Complete ===${NC}"
echo "Deleted $DELETED_COUNT backup(s)"

# Note about Claude Code refresh
if [ "$DELETED_COUNT" -gt 0 ]; then
    echo ""
    echo -e "${CYAN}Note:${NC} If you still see duplicate slash commands in Claude Code,"
    echo "restart Claude Code to refresh the command list."
fi
