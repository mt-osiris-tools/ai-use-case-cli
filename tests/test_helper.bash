#!/bin/bash
# tests/test_helper.bash - Common test utilities for AI Use Case CLI tests
#
# This file provides setup, teardown, and helper functions for all bats tests.
# It ensures test isolation by using temporary directories and overriding HOME.

set -euo pipefail

# Get the directory containing this script
BATS_TEST_DIRNAME="${BATS_TEST_DIRNAME:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"

# Load bats libraries
load "${BATS_TEST_DIRNAME}/bats/bats-support/load"
load "${BATS_TEST_DIRNAME}/bats/bats-assert/load"
load "${BATS_TEST_DIRNAME}/bats/bats-file/load"

# Test environment variables
export TEST_TEMP_DIR=""
export TEST_CONFIG_DIR=""
export TEST_HUB_DIR=""
export ORIGINAL_HOME=""
export ORIGINAL_XDG_CONFIG_HOME=""
export ORIGINAL_NO_COLOR=""
export ORIGINAL_NO_COLOR_SET=false
export ORIGINAL_FORCE_COLOR=""
export ORIGINAL_FORCE_COLOR_SET=false

# Colors (matching project conventions)
export TEST_GREEN=$'\033[0;32m'
export TEST_YELLOW=$'\033[1;33m'
export TEST_RED=$'\033[0;31m'
export TEST_BLUE=$'\033[0;34m'
export TEST_CYAN=$'\033[0;36m'
export TEST_NC=$'\033[0m'

# ============================================
# SETUP AND TEARDOWN
# ============================================

# Create isolated test environment
# Call this from setup() in each test file
setup_test_environment() {
    # Save original environment
    ORIGINAL_HOME="$HOME"
    ORIGINAL_XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-}"
    if [ "${NO_COLOR+x}" = x ]; then
        ORIGINAL_NO_COLOR="$NO_COLOR"
        ORIGINAL_NO_COLOR_SET=true
    else
        ORIGINAL_NO_COLOR_SET=false
    fi
    if [ "${FORCE_COLOR+x}" = x ]; then
        ORIGINAL_FORCE_COLOR="$FORCE_COLOR"
        ORIGINAL_FORCE_COLOR_SET=true
    else
        ORIGINAL_FORCE_COLOR_SET=false
    fi

    # Create temporary directories for test isolation
    TEST_TEMP_DIR="$(mktemp -d)"
    TEST_CONFIG_DIR="${TEST_TEMP_DIR}/.config/ai-use-case-cli"
    TEST_HUB_DIR="${TEST_TEMP_DIR}/hub"

    mkdir -p "$TEST_CONFIG_DIR"
    mkdir -p "$TEST_HUB_DIR/by-project"
    mkdir -p "$TEST_HUB_DIR/by-date"
    mkdir -p "$TEST_HUB_DIR/by-topic"

    # Override HOME and XDG_CONFIG_HOME to use test directory
    export HOME="$TEST_TEMP_DIR"
    export XDG_CONFIG_HOME="${TEST_TEMP_DIR}/.config"

    # Disable tracing during tests (avoid side effects)
    export AI_USECASE_TRACING_ENABLED=false

    # Force color output for tests (since tests don't run in a TTY)
    unset NO_COLOR
    export FORCE_COLOR=1

    # Set AI_USECASES_DIR to test hub (don't unset - scripts may use set -u)
    export AI_USECASES_DIR="$TEST_HUB_DIR"
}

# Clean up test environment
# Call this from teardown() in each test file
teardown_test_environment() {
    # Restore original HOME
    if [ -n "$ORIGINAL_HOME" ]; then
        export HOME="$ORIGINAL_HOME"
    fi

    # Restore original XDG_CONFIG_HOME
    if [ -n "$ORIGINAL_XDG_CONFIG_HOME" ]; then
        export XDG_CONFIG_HOME="$ORIGINAL_XDG_CONFIG_HOME"
    else
        unset XDG_CONFIG_HOME
    fi

    if [ "$ORIGINAL_NO_COLOR_SET" = true ]; then
        export NO_COLOR="$ORIGINAL_NO_COLOR"
    else
        unset NO_COLOR
    fi
    if [ "$ORIGINAL_FORCE_COLOR_SET" = true ]; then
        export FORCE_COLOR="$ORIGINAL_FORCE_COLOR"
    else
        unset FORCE_COLOR
    fi

    # Clean up temporary directories
    if [ -n "$TEST_TEMP_DIR" ] && [ -d "$TEST_TEMP_DIR" ]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Standard setup function - call from individual test files
common_setup() {
    setup_test_environment
}

# Standard teardown function - call from individual test files
common_teardown() {
    teardown_test_environment
}

# ============================================
# FIXTURE HELPERS
# ============================================

# Copy fixtures to test environment
setup_fixtures() {
    local fixture_type="${1:-all}"
    local fixtures_dir="${BATS_TEST_DIRNAME}/fixtures"

    case "$fixture_type" in
        config)
            if [ -f "${fixtures_dir}/config/config.json" ]; then
                cp "${fixtures_dir}/config/config.json" "$TEST_CONFIG_DIR/"
            fi
            ;;
        hub)
            if [ -d "${fixtures_dir}/hub" ]; then
                cp -r "${fixtures_dir}/hub/"* "$TEST_HUB_DIR/" 2>/dev/null || true
            fi
            ;;
        use-cases)
            if [ -d "${fixtures_dir}/use-cases" ]; then
                mkdir -p "${TEST_TEMP_DIR}/project/.usecase/cases"
                cp -r "${fixtures_dir}/use-cases/"* "${TEST_TEMP_DIR}/project/.usecase/cases/" 2>/dev/null || true
            fi
            ;;
        all)
            setup_fixtures config
            setup_fixtures hub
            setup_fixtures use-cases
            ;;
    esac
}

# Create a minimal test config file
create_test_config() {
    local mode="${1:-local}"
    local hub_path="${2:-$TEST_HUB_DIR}"
    local git_url="${3:-}"

    mkdir -p "$TEST_CONFIG_DIR"

    if [ -n "$git_url" ]; then
        cat > "${TEST_CONFIG_DIR}/config.json" << EOF
{
  "version": "1.0.0",
  "hubMode": "${mode}",
  "hubPath": "${hub_path}",
  "gitUrl": "${git_url}",
  "gitRequired": false
}
EOF
    else
        cat > "${TEST_CONFIG_DIR}/config.json" << EOF
{
  "version": "1.0.0",
  "hubMode": "${mode}",
  "hubPath": "${hub_path}",
  "gitRequired": false
}
EOF
    fi
}

# Create a test git repository
create_test_git_repo() {
    local repo_path="${1:-${TEST_TEMP_DIR}/project}"

    mkdir -p "$repo_path"
    (
        cd "$repo_path"
        git init -q
        git config user.email "test@example.com"
        git config user.name "Test User"

        # Create initial commit
        echo "# Test Project" > README.md
        git add README.md
        git commit -q -m "Initial commit"
    )

    echo "$repo_path"
}

# Create a test use case file
create_test_use_case() {
    local dir="${1:-${TEST_TEMP_DIR}/project/.usecase/cases}"
    local ticket="${2:-TEST-001}"
    local description="${3:-sample-test}"

    mkdir -p "$dir"

    local date_part
    date_part="$(date +%Y-W%V-%m-%d)"
    local filename="${date_part}_${ticket}_${description}.md"

    cat > "${dir}/${filename}" << EOF
# ${description}

## Context
Test use case for automated testing.

## Implementation
- Test step 1
- Test step 2

## Outcome
Test completed successfully.

## AI Tool Used
Claude Code (Sonnet 4.5)

## Time Saved
~2 hours
EOF

    echo "${dir}/${filename}"
}

# ============================================
# PATH HELPERS
# ============================================

# Get path to a file/script in the project
script_path() {
    echo "${PROJECT_ROOT}/$1"
}

# Get the main CLI path
cli_path() {
    echo "${PROJECT_ROOT}/ai-use-case"
}

# ============================================
# ASSERTION HELPERS
# ============================================

# Assert output contains ANSI color codes
assert_has_color_output() {
    assert_output --partial $'\033['
}

# Assert output does NOT contain ANSI color codes
assert_no_color_output() {
    refute_output --partial $'\033['
}

# Assert output contains success indicator (checkmark)
assert_success_indicator() {
    # Match common success indicators
    if [[ "$output" == *"✓"* ]] || [[ "$output" == *"✔"* ]] || [[ "$output" == *"[0;32m"* ]]; then
        return 0
    fi
    fail "Expected success indicator in output"
}

# Assert output contains error message pattern
assert_error_message() {
    local expected="${1:-Error}"
    assert_output --partial "$expected"
}

# Assert file contains expected content
assert_file_contains() {
    local file="$1"
    local expected="$2"

    assert_file_exists "$file"
    if ! grep -q "$expected" "$file"; then
        fail "File '$file' does not contain expected content: $expected"
    fi
}

# Assert directory contains expected number of files
assert_dir_file_count() {
    local dir="$1"
    local expected_count="$2"
    local pattern="${3:-*}"

    assert_dir_exists "$dir"
    local actual_count
    actual_count=$(find "$dir" -maxdepth 1 -name "$pattern" -type f | wc -l)

    if [ "$actual_count" -ne "$expected_count" ]; then
        fail "Expected $expected_count files in '$dir', found $actual_count"
    fi
}

# Assert command exit code
assert_exit_code() {
    local expected="$1"
    if [ "$status" -ne "$expected" ]; then
        fail "Expected exit code $expected, got $status"
    fi
}

# ============================================
# VERSION HELPERS
# ============================================

# Get current CLI version from version.sh
get_cli_version() {
    source "$(script_path scripts/utils/version.sh)"
    echo "$CLI_VERSION"
}

# Assert version matches semver pattern
assert_valid_semver() {
    local version="$1"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        fail "Invalid semver format: $version"
    fi
}

# ============================================
# DEBUG HELPERS
# ============================================

# Print debug info (only shown with --verbose)
debug_info() {
    echo "# DEBUG: $*" >&3
}

# Print test environment info
debug_test_env() {
    debug_info "TEST_TEMP_DIR: $TEST_TEMP_DIR"
    debug_info "TEST_CONFIG_DIR: $TEST_CONFIG_DIR"
    debug_info "TEST_HUB_DIR: $TEST_HUB_DIR"
    debug_info "HOME: $HOME"
}
