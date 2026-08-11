#!/usr/bin/env bats
# Tests for main ai-use-case CLI entry point

load 'test_helper'

setup() {
    common_setup
    create_test_config "local" "$TEST_HUB_DIR"
}

teardown() {
    common_teardown
}

CLI="$(script_path ai-use-case)"

# ============================================
# Help Command Tests
# ============================================

@test "ai-use-case: shows help with --help" {
    run "$CLI" --help
    assert_success
    assert_output --partial "AI Use Case CLI"
    assert_output --partial "USAGE"
    assert_output --partial "COMMANDS"
}

@test "ai-use-case: shows help with -h" {
    run "$CLI" -h
    assert_success
    assert_output --partial "AI Use Case CLI"
}

@test "ai-use-case: shows help with 'help' command" {
    run "$CLI" help
    assert_success
    assert_output --partial "AI Use Case CLI"
}

@test "ai-use-case: shows help when no arguments provided" {
    run "$CLI"
    assert_success
    assert_output --partial "AI Use Case CLI"
}

@test "ai-use-case: help includes EXAMPLES section" {
    run "$CLI" --help
    assert_success
    assert_output --partial "EXAMPLES"
}

@test "ai-use-case: help includes ENVIRONMENT section" {
    run "$CLI" --help
    assert_success
    assert_output --partial "ENVIRONMENT"
}

@test "ai-use-case: help includes Claude Code integration section" {
    run "$CLI" --help
    assert_success
    assert_output --partial "CLAUDE CODE INTEGRATION"
}

# ============================================
# Version Command Tests
# ============================================

@test "ai-use-case: shows version with --version" {
    run "$CLI" --version
    assert_success
    assert_output --partial "ai-use-case version"
}

@test "ai-use-case: shows version with -v" {
    run "$CLI" -v
    assert_success
    assert_output --partial "ai-use-case version"
}

@test "ai-use-case: shows colored version with 'version' command" {
    run "$CLI" version
    assert_success
    assert_output --partial "version"
    # Should contain color codes
    assert_has_color_output
}

@test "ai-use-case: version matches scripts/utils/version.sh" {
    source "$(script_path scripts/utils/version.sh)"
    run "$CLI" --version
    assert_success
    assert_output --partial "$CLI_VERSION"
}

@test "ai-use-case: version follows semver format" {
    run "$CLI" --version
    assert_success
    # Output should contain a version in X.Y.Z format
    [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

# ============================================
# Update Command Tests
# ============================================

@test "ai-use-case update: exposes self-update help" {
    run "$CLI" update --help
    assert_success
    assert_output --partial "Self Update"
    assert_output --partial "--check"
    assert_output --partial "--dry-run"
}

@test "ai-use-case self-update: is an alias for update" {
    run "$CLI" self-update --help
    assert_success
    assert_output --partial "Self Update"
}

# ============================================
# Unknown Command Tests
# ============================================

@test "ai-use-case: shows error for unknown command" {
    run "$CLI" unknown-command-xyz
    assert_failure
    assert_output --partial "Error"
    assert_output --partial "Unknown command"
}

@test "ai-use-case: error includes the unknown command name" {
    run "$CLI" invalid-cmd
    assert_failure
    assert_output --partial "invalid-cmd"
}

@test "ai-use-case: suggests help for unknown command" {
    run "$CLI" nonexistent
    assert_failure
    assert_output --partial "help"
}

# ============================================
# Config Command Tests
# ============================================

@test "ai-use-case config show: displays configuration" {
    run "$CLI" config show
    assert_success
    assert_output --partial "Configuration"
}

@test "ai-use-case config show: displays hub mode" {
    run "$CLI" config show
    assert_success
    assert_output --partial "Hub Mode"
}

@test "ai-use-case config show: displays hub path" {
    run "$CLI" config show
    assert_success
    assert_output --partial "Hub Path"
}

@test "ai-use-case config: defaults to show when no subcommand" {
    run "$CLI" config
    assert_success
    assert_output --partial "Configuration"
}

# ============================================
# Search Command Tests
# ============================================

@test "ai-use-case search: requires search term" {
    run "$CLI" search
    assert_failure
    assert_output --partial "Search term required"
}

@test "ai-use-case search: accepts search term" {
    # Create a test use case in the hub
    mkdir -p "$TEST_HUB_DIR/by-project/test-project"
    echo "# Test feature" > "$TEST_HUB_DIR/by-project/test-project/2025-W49-12-01_TEST-001_test.md"

    run "$CLI" search "test"
    assert_success
    assert_output --partial "Search"
}

# ============================================
# Stats Command Tests
# ============================================

@test "ai-use-case stats: runs without error" {
    run "$CLI" stats
    assert_success
}

@test "ai-use-case stats: displays statistics header" {
    run "$CLI" stats
    assert_success
    assert_output --partial "Statistics"
}

# ============================================
# List Command Tests
# ============================================

@test "ai-use-case list: runs or shows hub not found" {
    run "$CLI" list
    # May succeed or fail if hub not configured - just shouldn't crash unexpectedly
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "ai-use-case list-projects: runs or shows hub not found" {
    run "$CLI" list-projects
    # May succeed or fail if hub not configured - just shouldn't crash unexpectedly
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

# ============================================
# Agents Command Tests
# ============================================

@test "ai-use-case agents: requires subcommand" {
    run "$CLI" agents
    # May show help or error depending on implementation
    # Just check it doesn't crash
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "ai-use-case agents list: shows available agents" {
    run "$CLI" agents list
    assert_success
    assert_output --partial "agent"
}

# ============================================
# Tracing Command Tests
# ============================================

@test "ai-use-case tracing status: shows tracing status" {
    run "$CLI" tracing status
    assert_success
    assert_output --partial "Tracing"
}

# ============================================
# Document Command (Deprecated) Tests
# ============================================

@test "ai-use-case document: shows deprecation notice" {
    run "$CLI" document
    assert_failure
    assert_output --partial "COMMAND CHANGED"
}

@test "ai-use-case document: suggests Claude Code command" {
    run "$CLI" document
    assert_failure
    assert_output --partial "/use-case:document-session"
}

# ============================================
# Exit Code Tests
# ============================================

@test "ai-use-case: returns exit code 0 for help" {
    run "$CLI" --help
    assert_exit_code 0
}

@test "ai-use-case: returns exit code 0 for version" {
    run "$CLI" --version
    assert_exit_code 0
}

@test "ai-use-case: returns non-zero exit code for unknown command" {
    run "$CLI" this-command-does-not-exist
    [ "$status" -ne 0 ]
}

# ============================================
# Script Path Resolution Tests
# ============================================

@test "ai-use-case: can be executed from any directory" {
    cd "$TEST_TEMP_DIR"
    run "$CLI" --version
    assert_success
}

@test "ai-use-case: resolves script directory correctly" {
    # Run from a different directory
    cd /tmp
    run "$CLI" --help
    assert_success
    assert_output --partial "AI Use Case CLI"
}
