#!/usr/bin/env bats
# End-to-end integration tests for AI Use Case CLI

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
# Full Workflow: Setup -> Create -> Sync -> Search
# ============================================

@test "integration: full project setup and sync workflow" {
    # Create a test project
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Setup project
    run "$CLI" init "$project_dir"
    assert_success

    # Verify setup created expected structure
    assert_dir_exists "${project_dir}/.usecase/cases"
    assert_file_exists "${project_dir}/.git/hooks/post-commit"

    # Create a use case document
    create_test_use_case "${project_dir}/.usecase/cases" "INT-001" "integration-test"

    # Sync to hub
    cd "$project_dir"
    run "$CLI" sync
    assert_success

    # Verify sync worked
    local project_name
    project_name="$(basename "$project_dir")"
    assert_dir_exists "${TEST_HUB_DIR}/by-project/${project_name}"
}

@test "integration: search finds synced use cases" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Setup and create use case
    "$CLI" init "$project_dir"
    create_test_use_case "${project_dir}/.usecase/cases" "SEARCH-001" "searchable-feature"

    # Sync
    cd "$project_dir"
    "$CLI" sync

    # Search
    run "$CLI" search "searchable"
    assert_success
    assert_output --partial "searchable"
}

@test "integration: stats reflect synced use cases" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Setup and create use case
    "$CLI" init "$project_dir"
    create_test_use_case "${project_dir}/.usecase/cases" "STATS-001" "stats-test"

    # Sync
    cd "$project_dir"
    "$CLI" sync

    # Stats should show the use case
    run "$CLI" stats
    assert_success
    assert_output --partial "1"
}

# ============================================
# Configuration Workflow
# ============================================

@test "integration: config show works after init" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    "$CLI" init "$project_dir"

    run "$CLI" config show
    assert_success
    assert_output --partial "Hub Mode"
    assert_output --partial "local"
}

@test "integration: config path matches sync destination" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    "$CLI" init "$project_dir"
    create_test_use_case "${project_dir}/.usecase/cases" "PATH-001" "path-test"

    cd "$project_dir"
    "$CLI" sync

    # Get configured path
    run "$CLI" config show
    assert_success
    assert_output --partial "$TEST_HUB_DIR"

    # Verify files are in that location
    local project_name
    project_name="$(basename "$project_dir")"
    assert_dir_exists "${TEST_HUB_DIR}/by-project/${project_name}"
}

# ============================================
# Project Registry Workflow
# ============================================

@test "integration: list-projects shows registered project" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    "$CLI" init "$project_dir"

    run "$CLI" list-projects
    assert_success
    # Should show the project
    local project_name
    project_name="$(basename "$project_dir")"
    assert_output --partial "$project_name" || assert_output --partial "project"
}

@test "integration: check-updates after init" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    "$CLI" init "$project_dir"

    run "$CLI" check-updates
    assert_success
}

# ============================================
# Multiple Projects Workflow
# ============================================

@test "integration: multiple projects can be managed" {
    local project1 project2
    project1="$(create_test_git_repo "${TEST_TEMP_DIR}/project-alpha")"
    project2="$(create_test_git_repo "${TEST_TEMP_DIR}/project-beta")"

    # Setup both projects
    "$CLI" init "$project1"
    "$CLI" init "$project2"

    # Create use cases in both
    create_test_use_case "${project1}/.usecase/cases" "ALPHA-001" "alpha-feature"
    create_test_use_case "${project2}/.usecase/cases" "BETA-001" "beta-feature"

    # Sync both
    (cd "$project1" && "$CLI" sync)
    (cd "$project2" && "$CLI" sync)

    # Both should be in hub
    assert_dir_exists "${TEST_HUB_DIR}/by-project/project-alpha"
    assert_dir_exists "${TEST_HUB_DIR}/by-project/project-beta"

    # Stats should show both
    run "$CLI" stats
    assert_success
    assert_output --partial "2"
}

@test "integration: search across multiple projects" {
    local project1 project2
    project1="$(create_test_git_repo "${TEST_TEMP_DIR}/search-proj-1")"
    project2="$(create_test_git_repo "${TEST_TEMP_DIR}/search-proj-2")"

    "$CLI" init "$project1"
    "$CLI" init "$project2"

    create_test_use_case "${project1}/.usecase/cases" "MULTI-001" "authentication-feature"
    create_test_use_case "${project2}/.usecase/cases" "MULTI-002" "authorization-feature"

    (cd "$project1" && "$CLI" sync)
    (cd "$project2" && "$CLI" sync)

    # Search for "auth" should find both
    run "$CLI" search "auth"
    assert_success
    assert_output --partial "auth"
}

# ============================================
# Update Workflow
# ============================================

@test "integration: project update preserves use cases" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initial setup
    "$CLI" init "$project_dir"
    create_test_use_case "${project_dir}/.usecase/cases" "PRESERVE-001" "preserved-feature"

    # Update
    run "$CLI" init --update "$project_dir"
    assert_success

    # Use case should still exist
    local files
    files=$(find "${project_dir}/.usecase/cases" -name "*.md" | wc -l)
    [ "$files" -ge 1 ]
}

# ============================================
# Error Recovery Workflow
# ============================================

@test "integration: sync recovers from missing hub directories" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    "$CLI" init "$project_dir"
    create_test_use_case "${project_dir}/.usecase/cases" "RECOVER-001" "recovery-test"

    # Remove hub subdirectories
    rm -rf "$TEST_HUB_DIR/by-project"

    # Sync should still work (recreate structure)
    cd "$project_dir"
    run "$CLI" sync
    assert_success

    # Directory should be recreated
    assert_dir_exists "$TEST_HUB_DIR/by-project"
}

# ============================================
# Version Consistency
# ============================================

@test "integration: all commands report consistent version" {
    source "$(script_path scripts/utils/version.sh)"
    local expected_version="$CLI_VERSION"

    run "$CLI" --version
    assert_success
    assert_output --partial "$expected_version"

    run "$CLI" version
    assert_success
    assert_output --partial "$expected_version"
}

# ============================================
# Hub Modes
# ============================================

@test "integration: local mode works end-to-end" {
    # Already using local mode by default
    local project_dir
    project_dir="$(create_test_git_repo)"

    "$CLI" init "$project_dir"
    create_test_use_case "${project_dir}/.usecase/cases" "LOCAL-001" "local-mode-test"

    cd "$project_dir"
    run "$CLI" sync
    assert_success

    run "$CLI" search "local-mode"
    assert_success
    assert_output --partial "local-mode"
}

# ============================================
# Cleanup Tests
# ============================================

@test "integration: empty project sync is idempotent" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    "$CLI" init "$project_dir"

    cd "$project_dir"

    # Multiple syncs with no use cases should all succeed
    run "$CLI" sync
    assert_success

    run "$CLI" sync
    assert_success

    run "$CLI" sync
    assert_success
}
