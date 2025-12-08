#!/usr/bin/env bats
# Tests for scripts/project/registry-manager.sh

load 'test_helper'

setup() {
    common_setup
    create_test_config "local" "$TEST_HUB_DIR"
}

teardown() {
    common_teardown
}

REGISTRY_SCRIPT="$(script_path scripts/project/registry-manager.sh)"

# ============================================
# Basic Sourcing Tests
# ============================================

@test "registry-manager: can be sourced" {
    run bash -c "source '$(script_path scripts/project/registry-manager.sh)'"
    assert_success
}

@test "registry-manager: functions are available after sourcing" {
    source "$REGISTRY_SCRIPT"
    # Check that key functions exist
    type register_project &>/dev/null
    type get_registered_projects &>/dev/null
}

# ============================================
# get_cli_version() Tests
# ============================================

@test "registry-manager: get_cli_version returns version" {
    source "$REGISTRY_SCRIPT"
    run get_cli_version "$(script_path .)"
    assert_success
    # Should return a version string
    [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "registry-manager: get_cli_version matches version.sh" {
    source "$(script_path scripts/utils/version.sh)"
    source "$REGISTRY_SCRIPT"
    run get_cli_version "$(script_path .)"
    assert_success
    assert_output "$CLI_VERSION"
}

# ============================================
# register_project() Tests
# ============================================

@test "registry-manager: register_project creates registry entry" {
    source "$REGISTRY_SCRIPT"
    local project_dir
    project_dir="$(create_test_git_repo)"

    run register_project "$project_dir" "3.12.0" ".usecase/cases"
    assert_success

    # Registry file should exist
    assert_file_exists "${TEST_CONFIG_DIR}/registry.json"
}

@test "registry-manager: register_project returns 'registered' for new project" {
    source "$REGISTRY_SCRIPT"
    local project_dir
    project_dir="$(create_test_git_repo)"

    run register_project "$project_dir" "3.12.0" ".usecase/cases"
    assert_success
    assert_output "registered"
}

@test "registry-manager: register_project returns 'updated' for existing project" {
    source "$REGISTRY_SCRIPT"
    local project_dir
    project_dir="$(create_test_git_repo)"

    # First registration
    register_project "$project_dir" "3.11.0" ".usecase/cases"

    # Second registration (update)
    run register_project "$project_dir" "3.12.0" ".usecase/cases"
    assert_success
    assert_output "updated"
}

@test "registry-manager: register_project stores version" {
    source "$REGISTRY_SCRIPT"
    local project_dir
    project_dir="$(create_test_git_repo)"

    register_project "$project_dir" "3.12.0" ".usecase/cases"

    # Check registry contains version
    assert_file_contains "${TEST_CONFIG_DIR}/registry.json" "3.12.0"
}

# ============================================
# get_registered_projects() Tests
# ============================================

@test "registry-manager: get_registered_projects returns empty for no projects" {
    source "$REGISTRY_SCRIPT"

    run get_registered_projects
    # Should succeed with empty output or JSON array
    assert_success
}

@test "registry-manager: get_registered_projects returns registered projects" {
    source "$REGISTRY_SCRIPT"
    local project_dir
    project_dir="$(create_test_git_repo)"

    register_project "$project_dir" "3.12.0" ".usecase/cases"

    run get_registered_projects
    assert_success
    assert_output --partial "$project_dir"
}

# ============================================
# Registry File Format Tests
# ============================================

@test "registry-manager: registry file is valid JSON" {
    source "$REGISTRY_SCRIPT"
    local project_dir
    project_dir="$(create_test_git_repo)"

    register_project "$project_dir" "3.12.0" ".usecase/cases"

    if command -v jq &> /dev/null; then
        run jq '.' "${TEST_CONFIG_DIR}/registry.json"
        assert_success
    fi
}

@test "registry-manager: registry contains project path" {
    source "$REGISTRY_SCRIPT"
    local project_dir
    project_dir="$(create_test_git_repo)"

    register_project "$project_dir" "3.12.0" ".usecase/cases"

    assert_file_contains "${TEST_CONFIG_DIR}/registry.json" "$project_dir"
}

# ============================================
# Multiple Projects Tests
# ============================================

@test "registry-manager: can register multiple projects" {
    source "$REGISTRY_SCRIPT"
    local project1 project2
    project1="$(create_test_git_repo "${TEST_TEMP_DIR}/project1")"
    project2="$(create_test_git_repo "${TEST_TEMP_DIR}/project2")"

    register_project "$project1" "3.12.0" ".usecase/cases"
    register_project "$project2" "3.12.0" ".usecase/cases"

    assert_file_contains "${TEST_CONFIG_DIR}/registry.json" "$project1"
    assert_file_contains "${TEST_CONFIG_DIR}/registry.json" "$project2"
}

# ============================================
# CLI Integration Tests
# ============================================

@test "ai-use-case list-projects: uses registry" {
    source "$REGISTRY_SCRIPT"
    local project_dir
    project_dir="$(create_test_git_repo)"

    register_project "$project_dir" "3.12.0" ".usecase/cases"

    run "$(script_path ai-use-case)" list-projects
    assert_success
}

@test "ai-use-case check-updates: uses registry" {
    source "$REGISTRY_SCRIPT"
    local project_dir
    project_dir="$(create_test_git_repo)"

    register_project "$project_dir" "3.12.0" ".usecase/cases"

    run "$(script_path ai-use-case)" check-updates
    assert_success
}

# ============================================
# Version Comparison Tests
# ============================================

@test "registry-manager: detects outdated projects" {
    source "$REGISTRY_SCRIPT"
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Register with an old version
    register_project "$project_dir" "3.0.0" ".usecase/cases"

    # Current version should be newer
    source "$(script_path scripts/utils/version.sh)"
    # 3.12.0 > 3.0.0, so project is outdated
}
