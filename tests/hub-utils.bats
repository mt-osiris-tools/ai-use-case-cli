#!/usr/bin/env bats
# Tests for scripts/utils/hub-utils.sh

load 'test_helper'

setup() {
    common_setup
    create_test_config "local" "$TEST_HUB_DIR"
}

teardown() {
    common_teardown
}

# ============================================
# ensure_hub_exists() tests
# ============================================

@test "ensure_hub_exists: returns hub directory path" {
    source "$(script_path scripts/utils/hub-utils.sh)"

    run ensure_hub_exists
    assert_success
    assert_output "$TEST_HUB_DIR"
}

@test "ensure_hub_exists: fails when hub directory missing" {
    rm -rf "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/hub-utils.sh)"

    run ensure_hub_exists
    assert_failure
    assert_output --partial "not found"
}

@test "ensure_hub_exists: creates missing subdirectories" {
    rm -rf "$TEST_HUB_DIR/by-project"
    source "$(script_path scripts/utils/hub-utils.sh)"

    run ensure_hub_exists
    assert_success
    assert_dir_exists "$TEST_HUB_DIR/by-project"
}

@test "ensure_hub_exists: creates by-date directory if missing" {
    rm -rf "$TEST_HUB_DIR/by-date"
    source "$(script_path scripts/utils/hub-utils.sh)"

    run ensure_hub_exists
    assert_success
    assert_dir_exists "$TEST_HUB_DIR/by-date"
}

@test "ensure_hub_exists: creates by-topic directory if missing" {
    rm -rf "$TEST_HUB_DIR/by-topic"
    source "$(script_path scripts/utils/hub-utils.sh)"

    run ensure_hub_exists
    assert_success
    assert_dir_exists "$TEST_HUB_DIR/by-topic"
}

@test "ensure_hub_exists: creates all subdirectories at once" {
    rm -rf "$TEST_HUB_DIR/by-project" "$TEST_HUB_DIR/by-date" "$TEST_HUB_DIR/by-topic"
    source "$(script_path scripts/utils/hub-utils.sh)"

    run ensure_hub_exists
    assert_success
    assert_dir_exists "$TEST_HUB_DIR/by-project"
    assert_dir_exists "$TEST_HUB_DIR/by-date"
    assert_dir_exists "$TEST_HUB_DIR/by-topic"
}

# ============================================
# get_hub_dir() tests
# ============================================

@test "get_hub_dir: returns configured hub path" {
    source "$(script_path scripts/utils/hub-utils.sh)"

    run get_hub_dir
    assert_success
    assert_output "$TEST_HUB_DIR"
}

@test "get_hub_dir: returns default when no config" {
    rm -f "${TEST_CONFIG_DIR}/config.json"
    source "$(script_path scripts/utils/hub-utils.sh)"

    run get_hub_dir
    assert_success
    assert_output --partial ".local/share/ai-use-case-cli/hub"
}

@test "get_hub_dir: respects AI_USECASES_DIR env var when no config" {
    rm -f "${TEST_CONFIG_DIR}/config.json"
    export AI_USECASES_DIR="/custom/hub/path"
    source "$(script_path scripts/utils/hub-utils.sh)"

    run get_hub_dir
    assert_success
    assert_output "/custom/hub/path"

    # Restore to test hub dir
    export AI_USECASES_DIR="$TEST_HUB_DIR"
}

@test "get_hub_dir: does not require hub directory to exist" {
    rm -rf "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/hub-utils.sh)"

    # get_hub_dir just returns the path, doesn't validate existence
    run get_hub_dir
    assert_success
    assert_output "$TEST_HUB_DIR"
}

# ============================================
# is_hub_git() tests
# ============================================

@test "is_hub_git: returns false for local mode" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/hub-utils.sh)"

    run is_hub_git
    assert_failure
}

@test "is_hub_git: returns true for private-git mode" {
    create_test_config "private-git" "$TEST_HUB_DIR" "git@github.com:test/repo.git"
    source "$(script_path scripts/utils/hub-utils.sh)"

    run is_hub_git
    assert_success
}

@test "is_hub_git: returns false when no config" {
    rm -f "${TEST_CONFIG_DIR}/config.json"
    source "$(script_path scripts/utils/hub-utils.sh)"

    run is_hub_git
    assert_failure
}

# ============================================
# Integration with config-manager tests
# ============================================

@test "hub-utils: sources config-manager correctly" {
    source "$(script_path scripts/utils/hub-utils.sh)"

    # get_hub_mode should be available from config-manager
    run get_hub_mode
    assert_success
}

@test "hub-utils: config-manager functions work after sourcing" {
    source "$(script_path scripts/utils/hub-utils.sh)"

    run get_hub_path
    assert_success
    assert_output "$TEST_HUB_DIR"
}

# ============================================
# Error handling tests
# ============================================

@test "ensure_hub_exists: shows helpful error message when hub missing" {
    rm -rf "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/hub-utils.sh)"

    run ensure_hub_exists
    assert_failure
    assert_output --partial "ai-use-case --init"
}

@test "ensure_hub_exists: error message includes hub path" {
    rm -rf "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/hub-utils.sh)"

    run ensure_hub_exists
    assert_failure
    assert_output --partial "$TEST_HUB_DIR"
}
