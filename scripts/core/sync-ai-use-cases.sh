#!/bin/bash
# AI Use Cases Sync Script
# Syncs AI use case documentation from project directories to a central location
# Uses symlinks to avoid duplication - files are stored once in by-project/
#
# Version is sourced from version.sh (single source of truth)
#
# Usage:
#   ./sync-ai-use-cases.sh [project_path]
#   If no path provided, uses current directory

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - Auto-detect hub location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source tracing utilities
if [ -f "$SCRIPT_DIR/../utils/tracing.sh" ]; then
    source "$SCRIPT_DIR/../utils/tracing.sh"
    # Enable tracing for this script
    enable_script_tracing "sync-ai-use-cases.sh" "$@" || true
else
    # Define no-op functions if tracing not available
    trace_operation() { true; }
    trace_file_operation() { true; }
    trace_hub_sync() { true; }
    trace_event() { true; }
    trace_attribute() { true; }
fi

# Source configuration manager
CONFIG_MANAGER="$SCRIPT_DIR/../utils/config-manager.sh"
if [ -f "$CONFIG_MANAGER" ]; then
    source "$CONFIG_MANAGER"
fi

# Source progress tracker
PROGRESS_TRACKER="$SCRIPT_DIR/../utils/progress-tracker.sh"
if [ -f "$PROGRESS_TRACKER" ]; then
    source "$PROGRESS_TRACKER"
    PROGRESS_ENABLED=true
else
    PROGRESS_ENABLED=false
fi

# Function to ensure hub repository exists
ensure_hub_exists() {
    local hub_dir
    local hub_mode

    # Check if configuration exists
    if [ -f "$HOME/.config/ai-use-case-cli/config.json" ]; then
        hub_mode=$(get_hub_mode)
        hub_dir=$(get_hub_path)
    else
        # Fallback to local mode if no config
        echo -e "${YELLOW}Warning: No configuration found. Using local mode.${NC}" >&2
        echo -e "${BLUE}Run 'ai-use-case --init' to configure hub mode.${NC}" >&2
        hub_dir="${AI_USECASES_DIR:-$HOME/.local/share/ai-use-case-cli/hub}"
        hub_mode="local"
    fi

    # Check if hub exists
    if [ ! -d "$hub_dir" ]; then
        echo -e "${RED}Error: Hub directory not found at: $hub_dir${NC}" >&2
        echo "Please run 'ai-use-case --init' to setup the hub" >&2
        exit 1
    fi

    # Verify hub structure
    if [ ! -d "$hub_dir/by-project" ]; then
        mkdir -p "$hub_dir/by-project" "$hub_dir/by-date" "$hub_dir/by-topic"
    fi

    echo "$hub_dir"
}

# Source version configuration (single source of truth)
if [ -f "$SCRIPT_DIR/../utils/version.sh" ]; then
    source "$SCRIPT_DIR/../utils/version.sh"
else
    # Fallback if version.sh is missing
    echo "Warning: version.sh not found, using fallback version" >&2
    CLI_VERSION="unknown"
fi

CENTRAL_DIR=$(ensure_hub_exists)
BY_PROJECT_DIR="$CENTRAL_DIR/by-project"
BY_DATE_DIR="$CENTRAL_DIR/by-date"
BY_TOPIC_DIR="$CENTRAL_DIR/by-topic"

# Show help
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "AI Use Cases Sync Script v${CLI_VERSION}"
    echo ""
    echo "Usage:"
    echo "  $0 [project_path]"
    echo ""
    echo "Description:"
    echo "  Syncs AI use case documentation from project to central repository."
    echo "  Files are stored in by-project/, with symlinks created in"
    echo "  by-date/ and by-topic/ for alternate views."
    echo ""
    echo "Arguments:"
    echo "  project_path    Path to project directory (default: current directory)"
    echo ""
    echo "Examples:"
    echo "  $0                        # Sync current directory"
    echo "  $0 /path/to/project       # Sync specific project"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    exit 0
fi

# Get project path (use provided argument or current directory)
PROJECT_PATH="${1:-$(pwd)}"

# Ensure we're in a project directory
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Directory $PROJECT_PATH does not exist${NC}"
    exit 1
fi

# Get project name from directory name or git repository
if [ -d "$PROJECT_PATH/.git" ]; then
    PROJECT_NAME=$(basename "$(git -C "$PROJECT_PATH" rev-parse --show-toplevel)")
else
    PROJECT_NAME=$(basename "$PROJECT_PATH")
fi

echo -e "${GREEN}=== AI Use Cases Sync v${CLI_VERSION} ===${NC}"
echo "Project: $PROJECT_NAME"
echo "Source: $PROJECT_PATH"
echo "Central: $CENTRAL_DIR"
echo ""

# Initialize progress tracking
if [ "$PROGRESS_ENABLED" = true ]; then
    progress_init \
        "Validate use case directories" \
        "Create project directory in hub" \
        "Sync use case files" \
        "Create by-date symlinks" \
        "Create by-topic symlinks" \
        "Commit to hub repository"
fi

# Find all use case files (support both new and old structure)
# New structure: .usecase/cases
# Old structure: docs/ai-use-cases (for backward compatibility)
[ "$PROGRESS_ENABLED" = true ] && progress_start "Validate use case directories"

NEW_STRUCTURE_DIR="$PROJECT_PATH/.usecase/cases"
OLD_STRUCTURE_DIR="$PROJECT_PATH/docs/ai-use-cases"

USE_CASE_DIRS=""
if [ -d "$NEW_STRUCTURE_DIR" ]; then
    USE_CASE_DIRS="$NEW_STRUCTURE_DIR"
elif [ -d "$OLD_STRUCTURE_DIR" ]; then
    USE_CASE_DIRS="$OLD_STRUCTURE_DIR"
    echo -e "${YELLOW}⚠ Using old structure. Consider running 'ai-use-case --init' to migrate.${NC}"
fi

if [ -z "$USE_CASE_DIRS" ]; then
    echo -e "${YELLOW}No use case directories found in $PROJECT_PATH${NC}"
    echo -e "${BLUE}Run 'ai-use-case --init' to set up use case documentation.${NC}"
    if [ "$PROGRESS_ENABLED" = true ]; then
        progress_skip "Validate use case directories" "no use case directories found"
        progress_skip "Create project directory in hub" "skipped due to missing use case directories"
        progress_skip "Sync use case files" "skipped due to missing use case directories"
        progress_skip "Create by-date symlinks" "skipped due to missing use case directories"
        progress_skip "Create by-topic symlinks" "skipped due to missing use case directories"
        progress_skip "Commit to hub repository" "skipped due to missing use case directories"
        progress_summary
    fi
    exit 0
fi

[ "$PROGRESS_ENABLED" = true ] && progress_complete "Validate use case directories"

# Create project directory in central location
[ "$PROGRESS_ENABLED" = true ] && progress_start "Create project directory in hub"
trace_operation "create_project_directory" "project=$PROJECT_NAME" "path=$BY_PROJECT_DIR/$PROJECT_NAME"
mkdir -p "$BY_PROJECT_DIR/$PROJECT_NAME"
[ "$PROGRESS_ENABLED" = true ] && progress_complete "Create project directory in hub"

[ "$PROGRESS_ENABLED" = true ] && progress_start "Sync use case files"

SYNC_COUNT=0
NEW_COUNT=0
UPDATED_COUNT=0

# Process each use case directory found
trace_operation "process_use_case_directories" "project=$PROJECT_NAME" "count=$(echo "$USE_CASE_DIRS" | wc -l)"
while IFS= read -r USE_CASE_DIR; do
    if [ ! -d "$USE_CASE_DIR" ]; then
        continue
    fi

    # Find all markdown files in the use case directory
    while IFS= read -r USE_CASE_FILE; do
        if [ ! -f "$USE_CASE_FILE" ]; then
            continue
        fi

        FILENAME=$(basename "$USE_CASE_FILE")

        # Skip README files
        if [[ "$FILENAME" == "README.md" ]]; then
            continue
        fi

        # Validate filename convention (warn but don't fail)
        # Pattern breakdown:
        #   ^[0-9]{4}-W[0-9]{2}-[0-9]{2}-[0-9]{2}  = Date: YYYY-Www-MM-DD
        #   _                                       = Separator
        #   [A-Z]+-[0-9]+                           = Ticket: UPPERCASE-DIGITS (exactly one dash)
        #   _                                       = Separator
        #   .+\.md$                                 = Description and .md extension
        if ! [[ "$FILENAME" =~ ^[0-9]{4}-W[0-9]{2}-[0-9]{2}-[0-9]{2}_[A-Z]+-[0-9]+_.+\.md$ ]]; then
            echo -e "${YELLOW}⚠ Warning${NC}: $FILENAME doesn't follow naming convention"
            echo "  Expected: YYYY-Www-MM-DD_TICKET-XXXXX_description.md"
            echo "  Example: 2025-W44-10-31_PROJ-1234_add-user-authentication.md"
        fi

        TARGET_FILE="$BY_PROJECT_DIR/$PROJECT_NAME/$FILENAME"

        # Copy/update file in by-project (canonical storage)
        if [ ! -f "$TARGET_FILE" ]; then
            trace_file_operation "create" "$TARGET_FILE"
            if cp "$USE_CASE_FILE" "$TARGET_FILE" 2>/dev/null; then
                echo -e "${GREEN}✓ New${NC}: $FILENAME"
                NEW_COUNT=$((NEW_COUNT + 1))
                trace_event "file_sync" "operation=new" "file=$FILENAME" "project=$PROJECT_NAME"
            else
                trace_event "file_sync_error" "operation=new" "file=$FILENAME" "error=copy_failed"
                echo -e "${RED}✗ Failed to copy${NC}: $FILENAME"
                continue
            fi
        elif ! cmp -s "$USE_CASE_FILE" "$TARGET_FILE"; then
            trace_file_operation "update" "$TARGET_FILE"
            if cp "$USE_CASE_FILE" "$TARGET_FILE" 2>/dev/null; then
                echo -e "${BLUE}↻ Updated${NC}: $FILENAME"
                UPDATED_COUNT=$((UPDATED_COUNT + 1))
                trace_event "file_sync" "operation=update" "file=$FILENAME" "project=$PROJECT_NAME"
            else
                trace_event "file_sync_error" "operation=update" "file=$FILENAME" "error=copy_failed"
                echo -e "${RED}✗ Failed to update${NC}: $FILENAME"
                continue
            fi
        fi

        # Extract date from filename (format: YYYY-Www-MM-DD)
        if [[ "$FILENAME" =~ ^([0-9]{4})-W([0-9]{2})-([0-9]{2})-([0-9]{2}) ]]; then
            YEAR="${BASH_REMATCH[1]}"
            WEEK="${BASH_REMATCH[2]}"
            MONTH="${BASH_REMATCH[3]}"
            DAY="${BASH_REMATCH[4]}"

            # Create by-date directory structure
            DATE_DIR="$BY_DATE_DIR/$YEAR/$MONTH"
            mkdir -p "$DATE_DIR"

            # Create symlink (with project prefix to avoid name conflicts)
            SYMLINK_PATH="$DATE_DIR/${PROJECT_NAME}_${FILENAME}"
            if [ ! -L "$SYMLINK_PATH" ] || [ ! -e "$SYMLINK_PATH" ]; then
                # Create absolute path symlink (simpler and works on all platforms)
                trace_file_operation "symlink_create" "$SYMLINK_PATH"
                ln -sf "$TARGET_FILE" "$SYMLINK_PATH" 2>/dev/null || {
                    trace_event "symlink_error" "type=date" "file=$FILENAME" "error=create_failed"
                    echo -e "${YELLOW}⚠ Warning${NC}: Failed to create date symlink for $FILENAME"
                }
            fi # End: if symlink doesn't exist
        fi # End: if filename matches date pattern

        # Extract topics from filename (after date and ticket)
        # Format: YYYY-Www-MM-DD_TICKET-XXXXX_topic-words.md
        if [[ "$FILENAME" =~ _([A-Z]+-[0-9]+)_(.+)\.md$ ]]; then
            TICKET="${BASH_REMATCH[1]}"
            TOPIC_SLUG="${BASH_REMATCH[2]}"

            # Create topic directory (use slug for directory name)
            TOPIC_DIR="$BY_TOPIC_DIR/$TOPIC_SLUG"
            mkdir -p "$TOPIC_DIR"

            # Create symlink (with project prefix to avoid name conflicts)
            SYMLINK_PATH="$TOPIC_DIR/${PROJECT_NAME}_${FILENAME}"
            if [ ! -L "$SYMLINK_PATH" ] || [ ! -e "$SYMLINK_PATH" ]; then
                # Create absolute path symlink (simpler and works on all platforms)
                trace_file_operation "symlink_create" "$SYMLINK_PATH"
                ln -sf "$TARGET_FILE" "$SYMLINK_PATH" 2>/dev/null || {
                    trace_event "symlink_error" "type=topic" "file=$FILENAME" "topic=$TOPIC_SLUG" "error=create_failed"
                    echo -e "${YELLOW}⚠ Warning${NC}: Failed to create topic symlink for $FILENAME"
                }
            fi # End: if symlink doesn't exist
        fi # End: if filename matches topic pattern

        SYNC_COUNT=$((SYNC_COUNT + 1))
    done < <(find "$USE_CASE_DIR" -type f -name "*.md")

done <<< "$USE_CASE_DIRS"

# Mark file sync and symlink creation as complete
[ "$PROGRESS_ENABLED" = true ] && progress_complete "Sync use case files"
[ "$PROGRESS_ENABLED" = true ] && progress_complete "Create by-date symlinks"
[ "$PROGRESS_ENABLED" = true ] && progress_complete "Create by-topic symlinks"

# Record sync completion metrics
trace_hub_sync "sync_complete" $((NEW_COUNT + UPDATED_COUNT))
trace_event "sync_summary" "project=$PROJECT_NAME" "total=$SYNC_COUNT" "new=$NEW_COUNT" "updated=$UPDATED_COUNT"

echo ""
if [ $NEW_COUNT -gt 0 ] || [ $UPDATED_COUNT -gt 0 ]; then
    echo -e "${GREEN}✓ Sync complete!${NC}"
    [ $NEW_COUNT -gt 0 ] && echo "  New: $NEW_COUNT file(s)"
    [ $UPDATED_COUNT -gt 0 ] && echo "  Updated: $UPDATED_COUNT file(s)"
else
    echo -e "${YELLOW}✓ Already in sync${NC} ($SYNC_COUNT file(s))"
fi
echo ""
echo "Storage: $BY_PROJECT_DIR/$PROJECT_NAME/ (canonical)"
echo "Views:"
echo "  By date:  $BY_DATE_DIR/ (symlinks)"
echo "  By topic: $BY_TOPIC_DIR/ (symlinks)"
echo ""
echo -e "${BLUE}💾 Disk usage:${NC} Files stored once, alternate views use symlinks"

# Git commit and push to hub repository (only for git modes)
if [ $NEW_COUNT -gt 0 ] || [ $UPDATED_COUNT -gt 0 ]; then
    # Get hub mode
    hub_mode=$(get_hub_mode 2>/dev/null || echo "local")

    # Skip git operations for local mode
    if [ "$hub_mode" = "local" ]; then
        [ "$PROGRESS_ENABLED" = true ] && progress_skip "Commit to hub repository" "local mode"
        echo ""
        echo -e "${GREEN}✓ Sync complete!${NC} (Local mode - no git operations)"
        echo -e "${BLUE}Note:${NC} Running in local-only mode. Files are stored locally without version control."
        echo "  To enable git sync, reconfigure: rm ~/.config/ai-use-case-cli/config.json && ai-use-case --init"
    else
        [ "$PROGRESS_ENABLED" = true ] && progress_start "Commit to hub repository"
        echo ""
        echo -e "${BLUE}=== Committing changes to hub repository ===${NC}"

        cd "$CENTRAL_DIR"

        # Check if hub is a git repository
        if [ -d ".git" ]; then
            # Stage all changes
            git add by-project/ by-date/ by-topic/ 2>/dev/null || true

            # Check if there are changes to commit
            if ! git diff --cached --quiet 2>/dev/null; then
                # Create commit message
                COMMIT_MSG="sync: Update from $PROJECT_NAME

- New files: $NEW_COUNT
- Updated files: $UPDATED_COUNT

Synced at: $(date '+%Y-%m-%d %H:%M:%S')"

                if git commit -m "$COMMIT_MSG" 2>/dev/null; then
                    echo -e "${GREEN}✓${NC} Changes committed to hub repository"
                    [ "$PROGRESS_ENABLED" = true ] && progress_complete "Commit to hub repository"

                    # Push to remote if configured
                    if git remote get-url origin &>/dev/null; then
                        echo ""
                        read -p "Push changes to remote hub repository? (y/n) " -n 1 -r
                        echo

                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            echo -e "${BLUE}Pushing to remote repository...${NC}"

                            if git push origin HEAD 2>&1 | grep -q "Everything up-to-date\|Total"; then
                                echo -e "${GREEN}✓${NC} Changes pushed to remote repository"
                            else
                                echo -e "${YELLOW}⚠ Warning${NC}: Failed to push changes to remote"
                                echo "  You can push manually later: cd $CENTRAL_DIR && git push"
                            fi
                        else
                            echo -e "${YELLOW}⚠ Note${NC}: Changes committed locally only"
                            echo "  To push later, run: ai-use-case push"
                        fi
                    else
                        echo -e "${YELLOW}⚠ Note${NC}: No remote configured - changes committed locally only"
                    fi
                else
                    echo -e "${RED}✗ Failed to commit changes${NC}"
                    [ "$PROGRESS_ENABLED" = true ] && progress_skip "Commit to hub repository" "commit failed"
                fi
            else
                echo -e "${YELLOW}✓ No git changes to commit${NC} (files already in sync)"
                [ "$PROGRESS_ENABLED" = true ] && progress_skip "Commit to hub repository" "no changes"
            fi
        else
            echo -e "${YELLOW}⚠ Note${NC}: Hub directory is not a git repository"
            echo "  To enable git sync, run: cd $CENTRAL_DIR && git init"
            [ "$PROGRESS_ENABLED" = true ] && progress_skip "Commit to hub repository" "not a git repo"
        fi
    fi
else
    # No new or updated files, skip git operations
    [ "$PROGRESS_ENABLED" = true ] && progress_skip "Commit to hub repository" "no changes"
fi

# Show progress summary at the end
if [ "$PROGRESS_ENABLED" = true ]; then
    progress_summary
fi
