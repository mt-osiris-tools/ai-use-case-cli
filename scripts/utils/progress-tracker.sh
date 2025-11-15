#!/bin/bash
# Progress Tracker Utility
# Provides visual progress tracking for command execution
#
# Usage:
#   source scripts/utils/progress-tracker.sh
#   progress_init "Task 1" "Task 2" "Task 3"
#   progress_start "Task 1"
#   progress_complete "Task 1"
#   progress_summary
#
# Features:
#   - Real-time task status tracking
#   - Visual progress indicators
#   - Colored output for better UX
#   - Summary report at completion

# Colors
PROGRESS_GREEN='\033[0;32m'
PROGRESS_YELLOW='\033[1;33m'
PROGRESS_BLUE='\033[0;34m'
PROGRESS_CYAN='\033[0;36m'
PROGRESS_GRAY='\033[0;90m'
PROGRESS_NC='\033[0m'

# Symbols
PROGRESS_TODO="[ ]"
PROGRESS_IN_PROGRESS="[▸]"
PROGRESS_DONE="[✓]"
PROGRESS_SKIP="[~]"

# Global arrays to track tasks
declare -a PROGRESS_TASKS=()
declare -A PROGRESS_STATUS=()
declare -A PROGRESS_TIMESTAMPS=()

# Initialize progress tracking with a list of tasks
# Usage: progress_init "Task 1" "Task 2" "Task 3"
progress_init() {
    PROGRESS_TASKS=("$@")

    # Initialize all tasks as pending
    for task in "${PROGRESS_TASKS[@]}"; do
        PROGRESS_STATUS["$task"]="pending"
        PROGRESS_TIMESTAMPS["$task"]=""
    done

    # Show initial status if PROGRESS_SHOW_INIT is set
    if [ "${PROGRESS_SHOW_INIT:-false}" = "true" ]; then
        progress_show
    fi
}

# Show current progress status
# Usage: progress_show
progress_show() {
    if [ ${#PROGRESS_TASKS[@]} -eq 0 ]; then
        return 0
    fi

    echo ""
    echo -e "${PROGRESS_BLUE}=== Progress ===${PROGRESS_NC}"

    for task in "${PROGRESS_TASKS[@]}"; do
        local status="${PROGRESS_STATUS[$task]}"

        case "$status" in
            pending)
                echo -e "${PROGRESS_GRAY}${PROGRESS_TODO} ${task}${PROGRESS_NC}"
                ;;
            in_progress)
                echo -e "${PROGRESS_YELLOW}${PROGRESS_IN_PROGRESS} ${task}...${PROGRESS_NC}"
                ;;
            completed)
                echo -e "${PROGRESS_GREEN}${PROGRESS_DONE} ${task}${PROGRESS_NC}"
                ;;
            skipped)
                echo -e "${PROGRESS_CYAN}${PROGRESS_SKIP} ${task} (skipped)${PROGRESS_NC}"
                ;;
        esac
    done
    echo ""
}

# Start a task (mark as in progress)
# Usage: progress_start "Task name"
progress_start() {
    local task="$1"

    if [ -z "${PROGRESS_STATUS[$task]}" ]; then
        echo -e "${PROGRESS_YELLOW}⚠ Warning: Task '$task' not found in progress tracker${PROGRESS_NC}" >&2
        return 1
    fi

    PROGRESS_STATUS["$task"]="in_progress"
    PROGRESS_TIMESTAMPS["$task"]=$(date +%s)

    # Show updated progress
    if [ "${PROGRESS_INLINE:-true}" = "true" ]; then
        echo -e "${PROGRESS_YELLOW}${PROGRESS_IN_PROGRESS}${PROGRESS_NC} ${task}..."
    else
        progress_show
    fi
}

# Complete a task (mark as done)
# Usage: progress_complete "Task name"
progress_complete() {
    local task="$1"

    if [ -z "${PROGRESS_STATUS[$task]}" ]; then
        echo -e "${PROGRESS_YELLOW}⚠ Warning: Task '$task' not found in progress tracker${PROGRESS_NC}" >&2
        return 1
    fi

    PROGRESS_STATUS["$task"]="completed"

    # Calculate duration if timestamp exists
    local duration=""
    if [ -n "${PROGRESS_TIMESTAMPS[$task]}" ]; then
        local start_time="${PROGRESS_TIMESTAMPS[$task]}"
        local end_time=$(date +%s)
        local elapsed=$((end_time - start_time))

        if [ $elapsed -gt 0 ]; then
            duration=" (${elapsed}s)"
        fi
    fi

    # Show completion
    if [ "${PROGRESS_INLINE:-true}" = "true" ]; then
        echo -e "${PROGRESS_GREEN}${PROGRESS_DONE}${PROGRESS_NC} ${task}${duration}"
    else
        progress_show
    fi
}

# Skip a task
# Usage: progress_skip "Task name" ["reason"]
progress_skip() {
    local task="$1"
    local reason="${2:-}"

    if [ -z "${PROGRESS_STATUS[$task]}" ]; then
        echo -e "${PROGRESS_YELLOW}⚠ Warning: Task '$task' not found in progress tracker${PROGRESS_NC}" >&2
        return 1
    fi

    PROGRESS_STATUS["$task"]="skipped"

    # Show skip message
    local skip_msg="${task}"
    if [ -n "$reason" ]; then
        skip_msg="${task} (${reason})"
    fi

    if [ "${PROGRESS_INLINE:-true}" = "true" ]; then
        echo -e "${PROGRESS_CYAN}${PROGRESS_SKIP}${PROGRESS_NC} ${skip_msg}"
    else
        progress_show
    fi
}

# Show progress summary
# Usage: progress_summary
progress_summary() {
    if [ ${#PROGRESS_TASKS[@]} -eq 0 ]; then
        return 0
    fi

    local total=${#PROGRESS_TASKS[@]}
    local completed=0
    local skipped=0
    local pending=0
    local in_progress=0

    # Count statuses
    for task in "${PROGRESS_TASKS[@]}"; do
        case "${PROGRESS_STATUS[$task]}" in
            completed) completed=$((completed + 1)) ;;
            skipped) skipped=$((skipped + 1)) ;;
            pending) pending=$((pending + 1)) ;;
            in_progress) in_progress=$((in_progress + 1)) ;;
        esac
    done

    echo ""
    echo -e "${PROGRESS_BLUE}=== Summary ===${PROGRESS_NC}"
    echo -e "${PROGRESS_GREEN}✓ Completed:${PROGRESS_NC} $completed/$total"

    if [ $skipped -gt 0 ]; then
        echo -e "${PROGRESS_CYAN}~ Skipped:${PROGRESS_NC} $skipped/$total"
    fi

    if [ $pending -gt 0 ] || [ $in_progress -gt 0 ]; then
        echo -e "${PROGRESS_YELLOW}⚠ Incomplete:${PROGRESS_NC} $((pending + in_progress))/$total"
    fi
    echo ""
}

# Check if all tasks are complete
# Returns 0 if all complete, 1 otherwise
# Usage: if progress_all_complete; then ...
progress_all_complete() {
    for task in "${PROGRESS_TASKS[@]}"; do
        local status="${PROGRESS_STATUS[$task]}"
        if [ "$status" != "completed" ] && [ "$status" != "skipped" ]; then
            return 1
        fi
    done
    return 0
}

# Get progress percentage (completed + skipped)
# Usage: percent=$(progress_percentage)
progress_percentage() {
    if [ ${#PROGRESS_TASKS[@]} -eq 0 ]; then
        echo "0"
        return 0
    fi

    local total=${#PROGRESS_TASKS[@]}
    local done=0

    for task in "${PROGRESS_TASKS[@]}"; do
        local status="${PROGRESS_STATUS[$task]}"
        if [ "$status" = "completed" ] || [ "$status" = "skipped" ]; then
            done=$((done + 1))
        fi
    done

    echo $((done * 100 / total))
}

# Reset progress tracker
# Usage: progress_reset
progress_reset() {
    PROGRESS_TASKS=()
    PROGRESS_STATUS=()
    PROGRESS_TIMESTAMPS=()
}

# Export functions for use in other scripts
export -f progress_init
export -f progress_show
export -f progress_start
export -f progress_complete
export -f progress_skip
export -f progress_summary
export -f progress_all_complete
export -f progress_percentage
export -f progress_reset
