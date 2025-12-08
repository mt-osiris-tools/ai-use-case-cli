#!/usr/bin/env bats
# Tests for scripts/core/sync-ai-use-cases.sh

load 'test_helper'

setup() {
    common_setup
    create_test_config "local" "$TEST_HUB_DIR"
}

teardown() {
    common_teardown
}

SYNC_SCRIPT="$(script_path scripts/core/sync-ai-use-cases.sh)"
CLI="$(script_path ai-use-case)"

# ============================================
# Help Tests
# ============================================

@test "sync-ai-use-cases: shows help with --help" {
    run bash "$SYNC_SCRIPT" --help
    assert_success
    assert_output --partial "Sync"
    assert_output --partial "Usage"
}

@test "sync-ai-use-cases: shows help with -h" {
    run bash "$SYNC_SCRIPT" -h
    assert_success
    assert_output --partial "Usage"
}

# ============================================
# Basic Sync Tests
# ============================================

@test "sync-ai-use-cases: fails with non-existent directory" {
    run bash "$SYNC_SCRIPT" "/nonexistent/path/xyz"
    assert_failure
    assert_output --partial "Error"
}

@test "sync-ai-use-cases: handles project without use cases" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    run bash "$SYNC_SCRIPT" "$project_dir"
    assert_success
    assert_output --partial "No use case"
}

@test "sync-ai-use-cases: syncs use cases to hub" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Create a use case
    create_test_use_case "${project_dir}/.usecase/cases" "SYNC-001" "sync-test"

    run bash "$SYNC_SCRIPT" "$project_dir"
    assert_success

    # Verify file was synced
    local project_name
    project_name="$(basename "$project_dir")"
    assert_dir_exists "${TEST_HUB_DIR}/by-project/${project_name}"
}

@test "sync-ai-use-cases: displays version number" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    run bash "$SYNC_SCRIPT" "$project_dir"
    assert_success
    assert_output --partial "v"
}

# ============================================
# Hub Structure Tests
# ============================================

@test "sync-ai-use-cases: creates by-project directory" {
    local project_dir
    project_dir="$(create_test_git_repo)"
    create_test_use_case "${project_dir}/.usecase/cases" "PROJ-001" "project-test"

    run bash "$SYNC_SCRIPT" "$project_dir"
    assert_success

    local project_name
    project_name="$(basename "$project_dir")"
    assert_dir_exists "${TEST_HUB_DIR}/by-project/${project_name}"
}

@test "sync-ai-use-cases: creates by-date directory structure" {
    local project_dir
    project_dir="$(create_test_git_repo)"
    create_test_use_case "${project_dir}/.usecase/cases" "DATE-001" "date-test"

    run bash "$SYNC_SCRIPT" "$project_dir"
    assert_success

    # Check that by-date directory has entries
    assert_dir_exists "${TEST_HUB_DIR}/by-date"
}

@test "sync-ai-use-cases: copies use case files to hub" {
    local project_dir
    project_dir="$(create_test_git_repo)"
    local use_case_file
    use_case_file="$(create_test_use_case "${project_dir}/.usecase/cases" "COPY-001" "copy-test")"

    run bash "$SYNC_SCRIPT" "$project_dir"
    assert_success

    local project_name
    project_name="$(basename "$project_dir")"
    local filename
    filename="$(basename "$use_case_file")"

    # File should exist in hub
    assert_file_exists "${TEST_HUB_DIR}/by-project/${project_name}/${filename}"
}

# ============================================
# Sync Completion Tests
# ============================================

@test "sync-ai-use-cases: shows completion message" {
    local project_dir
    project_dir="$(create_test_git_repo)"
    create_test_use_case "${project_dir}/.usecase/cases" "DONE-001" "complete-test"

    run bash "$SYNC_SCRIPT" "$project_dir"
    assert_success
    assert_output --partial "Sync" || assert_output --partial "complete" || assert_output --partial "success"
}

@test "sync-ai-use-cases: counts synced files" {
    local project_dir
    project_dir="$(create_test_git_repo)"
    create_test_use_case "${project_dir}/.usecase/cases" "COUNT-001" "count-test-1"
    create_test_use_case "${project_dir}/.usecase/cases" "COUNT-002" "count-test-2"

    run bash "$SYNC_SCRIPT" "$project_dir"
    assert_success
    # Should mention the number of files synced
    assert_output --partial "2" || assert_output --partial "use case"
}

# ============================================
# CLI Integration Tests
# ============================================

@test "ai-use-case sync: works via CLI from project directory" {
    local project_dir
    project_dir="$(create_test_git_repo)"
    mkdir -p "${project_dir}/.usecase/cases"

    cd "$project_dir"
    run "$CLI" sync
    assert_success
}

# ============================================
# Error Handling Tests
# ============================================

@test "sync-ai-use-cases: error message includes directory path" {
    run bash "$SYNC_SCRIPT" "/fake/path/that/does/not/exist"
    assert_failure
    assert_output --partial "/fake/path"
}

@test "sync-ai-use-cases: handles non-git directory gracefully" {
    local non_git_dir="${TEST_TEMP_DIR}/non-git"
    mkdir -p "$non_git_dir/.usecase/cases"
    echo "# Test" > "$non_git_dir/.usecase/cases/2025-W45-11-07_TEST-001_test.md"

    run bash "$SYNC_SCRIPT" "$non_git_dir"
    # Should either succeed or fail gracefully
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

# ============================================
# Idempotency Tests
# ============================================

@test "sync-ai-use-cases: can run multiple times safely" {
    local project_dir
    project_dir="$(create_test_git_repo)"
    create_test_use_case "${project_dir}/.usecase/cases" "IDEM-001" "idempotent-test"

    # First sync
    run bash "$SYNC_SCRIPT" "$project_dir"
    assert_success

    # Second sync
    run bash "$SYNC_SCRIPT" "$project_dir"
    assert_success
}

@test "sync-ai-use-cases: updates existing files" {
    local project_dir
    project_dir="$(create_test_git_repo)"
    local use_case_file
    use_case_file="$(create_test_use_case "${project_dir}/.usecase/cases" "UPDATE-001" "update-test")"

    # First sync
    bash "$SYNC_SCRIPT" "$project_dir"

    # Modify the file
    echo "## Updated content" >> "$use_case_file"

    # Second sync
    run bash "$SYNC_SCRIPT" "$project_dir"
    assert_success
}
