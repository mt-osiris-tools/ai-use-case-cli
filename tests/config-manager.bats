#!/usr/bin/env bats
# Tests for scripts/utils/config-manager.sh

load 'test_helper'

setup() {
    common_setup
}

teardown() {
    common_teardown
}

# ============================================
# ensure_config_dir() tests
# ============================================

@test "ensure_config_dir: creates config directory if missing" {
    source "$(script_path scripts/utils/config-manager.sh)"

    # Remove config dir if exists
    rm -rf "$TEST_CONFIG_DIR"
    [ ! -d "$TEST_CONFIG_DIR" ]

    ensure_config_dir
    assert_dir_exists "$TEST_CONFIG_DIR"
}

@test "ensure_config_dir: does not fail if directory exists" {
    source "$(script_path scripts/utils/config-manager.sh)"

    mkdir -p "$TEST_CONFIG_DIR"
    run ensure_config_dir
    assert_success
}

# ============================================
# init_config() tests
# ============================================

@test "init_config: creates config file in correct location" {
    source "$(script_path scripts/utils/config-manager.sh)"

    init_config "local" "$TEST_HUB_DIR"
    assert_file_exists "${TEST_CONFIG_DIR}/config.json"
}

@test "init_config: sets local mode correctly" {
    source "$(script_path scripts/utils/config-manager.sh)"

    init_config "local" "$TEST_HUB_DIR"
    run get_hub_mode
    assert_success
    assert_output "local"
}

@test "init_config: sets hub path correctly" {
    source "$(script_path scripts/utils/config-manager.sh)"

    init_config "local" "$TEST_HUB_DIR"
    run get_hub_path
    assert_success
    assert_output "$TEST_HUB_DIR"
}

@test "init_config: handles private-git mode" {
    source "$(script_path scripts/utils/config-manager.sh)"

    init_config "private-git" "$TEST_HUB_DIR" "git@github.com:test/repo.git"
    run get_hub_mode
    assert_output "private-git"
}

@test "init_config: stores git URL for private-git mode" {
    source "$(script_path scripts/utils/config-manager.sh)"

    local git_url="git@github.com:test/repo.git"
    init_config "private-git" "$TEST_HUB_DIR" "$git_url"
    run get_git_url
    assert_output "$git_url"
}

@test "init_config: uses default path for local mode when not specified" {
    source "$(script_path scripts/utils/config-manager.sh)"

    init_config "local"
    run get_hub_path
    assert_success
    assert_output --partial ".local/share/ai-use-case-cli/hub"
}

# ============================================
# get_hub_path() tests
# ============================================

@test "get_hub_path: returns configured path" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    run get_hub_path
    assert_success
    assert_output "$TEST_HUB_DIR"
}

@test "get_hub_path: respects AI_USECASES_DIR environment variable" {
    create_test_config "local" "$TEST_HUB_DIR"
    export AI_USECASES_DIR="/custom/override/path"
    source "$(script_path scripts/utils/config-manager.sh)"

    run get_hub_path
    assert_success
    assert_output "/custom/override/path"

    # Restore to test hub dir
    export AI_USECASES_DIR="$TEST_HUB_DIR"
}

@test "get_hub_path: returns default when no config exists" {
    # Don't create config
    source "$(script_path scripts/utils/config-manager.sh)"

    run get_hub_path
    assert_success
    assert_output --partial ".local/share/ai-use-case-cli/hub"
}

@test "get_hub_path: environment variable takes precedence over config" {
    create_test_config "local" "/config/path"
    export AI_USECASES_DIR="/env/path"
    source "$(script_path scripts/utils/config-manager.sh)"

    run get_hub_path
    assert_success
    assert_output "/env/path"

    # Restore to test hub dir
    export AI_USECASES_DIR="$TEST_HUB_DIR"
}

# ============================================
# get_hub_mode() tests
# ============================================

@test "get_hub_mode: returns local when configured" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    run get_hub_mode
    assert_success
    assert_output "local"
}

@test "get_hub_mode: returns private-git when configured" {
    create_test_config "private-git" "$TEST_HUB_DIR" "git@github.com:test/repo.git"
    source "$(script_path scripts/utils/config-manager.sh)"

    run get_hub_mode
    assert_success
    assert_output "private-git"
}

@test "get_hub_mode: defaults to local when no config" {
    # Don't create config
    source "$(script_path scripts/utils/config-manager.sh)"

    run get_hub_mode
    assert_success
    assert_output "local"
}

# ============================================
# is_git_mode() tests
# ============================================

@test "is_git_mode: returns false for local mode" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    run is_git_mode
    assert_failure
}

@test "is_git_mode: returns true for private-git mode" {
    create_test_config "private-git" "$TEST_HUB_DIR" "git@github.com:test/repo.git"
    source "$(script_path scripts/utils/config-manager.sh)"

    run is_git_mode
    assert_success
}

# ============================================
# get_config() tests
# ============================================

@test "get_config: returns value for existing key" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    run get_config "hubMode"
    assert_success
    assert_output "local"
}

@test "get_config: returns empty for non-existent key" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    run get_config "nonexistent"
    # Should succeed but return empty
    [ -z "$output" ] || [ "$output" = "" ]
}

@test "get_config: fails when config file missing" {
    # Don't create config
    source "$(script_path scripts/utils/config-manager.sh)"

    run get_config "hubMode"
    assert_failure
}

# ============================================
# show_config() tests
# ============================================

@test "show_config: displays configuration header" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    run show_config
    assert_success
    assert_output --partial "Current Configuration"
}

@test "show_config: displays hub mode" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    run show_config
    assert_success
    assert_output --partial "Hub Mode"
    assert_output --partial "local"
}

@test "show_config: displays hub path" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    run show_config
    assert_success
    assert_output --partial "Hub Path"
}

@test "show_config: warns when no config found" {
    # Don't create config
    source "$(script_path scripts/utils/config-manager.sh)"

    run show_config
    assert_failure
    assert_output --partial "No configuration found"
}

# ============================================
# Config file structure tests
# ============================================

@test "config file: has valid JSON structure" {
    create_test_config "local" "$TEST_HUB_DIR"

    # Check if jq can parse it (if available)
    if command -v jq &> /dev/null; then
        run jq '.' "${TEST_CONFIG_DIR}/config.json"
        assert_success
    fi
}

@test "config file: contains required fields" {
    create_test_config "local" "$TEST_HUB_DIR"

    # Check for required fields
    assert_file_contains "${TEST_CONFIG_DIR}/config.json" "hubMode"
    assert_file_contains "${TEST_CONFIG_DIR}/config.json" "hubPath"
}

@test "config file: contains version field" {
    create_test_config "local" "$TEST_HUB_DIR"

    assert_file_contains "${TEST_CONFIG_DIR}/config.json" "version"
}

# ============================================
# Git Required Configuration Tests
# ============================================

@test "init_config: sets gitRequired to false by default" {
    source "$(script_path scripts/utils/config-manager.sh)"

    init_config "local" "$TEST_HUB_DIR"
    run get_git_required
    assert_success
    assert_output "false"
}

@test "get_git_required: returns false by default" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    run get_git_required
    assert_success
    assert_output "false"
}

@test "set_git_required: sets git required to true" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    run set_git_required "true"
    assert_success

    run get_git_required
    assert_output "true"
}

@test "set_git_required: sets git required to false" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    # First set to true
    set_git_required "true"

    # Then set to false
    run set_git_required "false"
    assert_success

    run get_git_required
    assert_output "false"
}

@test "set_git_required: fails with invalid value" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    run set_git_required "invalid"
    assert_failure
    assert_output --partial "Invalid value"
}

@test "is_git_required: returns true when git is required" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    set_git_required "true"
    run is_git_required
    assert_success
}

@test "is_git_required: returns false when git is not required" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    set_git_required "false"
    run is_git_required
    assert_failure
}

@test "show_config: displays git required status" {
    create_test_config "local" "$TEST_HUB_DIR"
    source "$(script_path scripts/utils/config-manager.sh)"

    run show_config
    assert_success
    assert_output --partial "Git Required"
}
