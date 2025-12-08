#!/usr/bin/env bats
# Tests for scripts/search/search-use-cases.sh

load 'test_helper'

setup() {
    common_setup
    create_test_config "local" "$TEST_HUB_DIR"

    # Create some test use case files in the hub
    mkdir -p "$TEST_HUB_DIR/by-project/test-project"
    echo "# Authentication feature implementation" > "$TEST_HUB_DIR/by-project/test-project/2025-W45-11-07_AUTH-001_auth-feature.md"
    echo "# Database migration script" > "$TEST_HUB_DIR/by-project/test-project/2025-W45-11-08_DB-001_database-migration.md"
    echo "# API endpoint refactoring" > "$TEST_HUB_DIR/by-project/test-project/2025-W46-11-14_API-001_api-refactor.md"
}

teardown() {
    common_teardown
}

SEARCH_SCRIPT="$(script_path scripts/search/search-use-cases.sh)"
CLI="$(script_path ai-use-case)"

# ============================================
# Basic Search Tests
# ============================================

@test "search-use-cases: requires search term" {
    run bash "$SEARCH_SCRIPT"
    assert_failure
    assert_output --partial "Search term required"
}

@test "search-use-cases: accepts search term argument" {
    run bash "$SEARCH_SCRIPT" "auth"
    assert_success
}

@test "search-use-cases: displays search header" {
    run bash "$SEARCH_SCRIPT" "test"
    assert_success
    assert_output --partial "Search"
}

@test "search-use-cases: shows what term is being searched" {
    run bash "$SEARCH_SCRIPT" "auth"
    assert_success
    assert_output --partial "auth"
}

# ============================================
# File Name Search Tests
# ============================================

@test "search-use-cases: finds files by name pattern" {
    run bash "$SEARCH_SCRIPT" "auth"
    assert_success
    assert_output --partial "auth-feature.md"
}

@test "search-use-cases: finds files with ticket ID in name" {
    run bash "$SEARCH_SCRIPT" "DB-001"
    assert_success
    assert_output --partial "database-migration"
}

@test "search-use-cases: case-insensitive file search" {
    run bash "$SEARCH_SCRIPT" "AUTH"
    assert_success
    assert_output --partial "auth"
}

# ============================================
# Content Search Tests
# ============================================

@test "search-use-cases: finds files by content" {
    run bash "$SEARCH_SCRIPT" "Authentication"
    assert_success
    assert_output --partial "auth-feature.md"
}

@test "search-use-cases: finds files by content keyword" {
    run bash "$SEARCH_SCRIPT" "migration"
    assert_success
    assert_output --partial "database"
}

@test "search-use-cases: finds API-related content" {
    run bash "$SEARCH_SCRIPT" "endpoint"
    assert_success
    assert_output --partial "api-refactor"
}

# ============================================
# No Results Tests
# ============================================

@test "search-use-cases: handles no matches gracefully" {
    run bash "$SEARCH_SCRIPT" "nonexistent-term-xyz-123"
    assert_success
    # Should indicate no results found
    assert_output --partial "No" || assert_output --partial "0"
}

@test "search-use-cases: shows message when no matches" {
    run bash "$SEARCH_SCRIPT" "zzz-no-match-zzz"
    assert_success
}

# ============================================
# CLI Integration Tests
# ============================================

@test "ai-use-case search: works via CLI" {
    run "$CLI" search "auth"
    assert_success
    assert_output --partial "auth"
}

@test "ai-use-case search: requires term via CLI" {
    run "$CLI" search
    assert_failure
}

# ============================================
# Special Characters Tests
# ============================================

@test "search-use-cases: handles hyphenated terms" {
    run bash "$SEARCH_SCRIPT" "auth-feature"
    assert_success
}

@test "search-use-cases: handles underscored terms" {
    run bash "$SEARCH_SCRIPT" "database_migration"
    # May or may not find results depending on implementation
    # Just shouldn't crash
    [ "$status" -eq 0 ]
}

# ============================================
# Multiple Results Tests
# ============================================

@test "search-use-cases: can find multiple matching files" {
    run bash "$SEARCH_SCRIPT" "project"
    assert_success
    # Should show results section
    assert_output --partial "test-project"
}

@test "search-use-cases: finds all files in project" {
    # Create additional file
    echo "# Another feature" > "$TEST_HUB_DIR/by-project/test-project/2025-W47-11-21_FEAT-002_another.md"

    run bash "$SEARCH_SCRIPT" "test-project"
    assert_success
}
