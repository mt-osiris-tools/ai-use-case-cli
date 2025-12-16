#!/bin/bash
# File Utilities for AI Use Case CLI
# Provides common file operation patterns with automatic cleanup

# Setup automatic cleanup trap for a temp file
# Usage:
#   local temp_file=$(mktemp)
#   setup_temp_file_cleanup "$temp_file"
#   # ... do work with temp_file ...
#   cleanup_temp_file  # Call explicitly when done, or automatic on EXIT/INT/TERM
#
# This function creates a cleanup_temp_file function in the caller's scope
# and sets up trap handlers to call it automatically on exit or interruption.
setup_temp_file_cleanup() {
    local file_to_cleanup="$1"

    if [ -z "$file_to_cleanup" ]; then
        echo "Error: setup_temp_file_cleanup requires a file path" >&2
        return 1
    fi

    # Define cleanup function in caller's scope using eval
    # This allows the cleanup function to be called directly by the caller
    eval "cleanup_temp_file() { [ -f '$file_to_cleanup' ] && rm -f '$file_to_cleanup'; }"

    # Setup trap to ensure cleanup on exit or interruption
    trap cleanup_temp_file EXIT INT TERM
}

# Remove temp file cleanup trap and function
# Usage: teardown_temp_file_cleanup
#
# Call this after successfully processing the temp file to remove
# the trap and cleanup function from the caller's scope.
teardown_temp_file_cleanup() {
    trap - EXIT INT TERM
    unset -f cleanup_temp_file 2>/dev/null || true
}
