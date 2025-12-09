#!/usr/bin/env bats
# Tests for scripts/project/setup-project.sh

load 'test_helper'

setup() {
    common_setup
    create_test_config "local" "$TEST_HUB_DIR"
}

teardown() {
    common_teardown
}

SETUP_SCRIPT="$(script_path scripts/project/setup-project.sh)"
LINK_CLAUDE_SCRIPT="$(script_path scripts/project/link-claude.sh)"
CLI="$(script_path ai-use-case)"

# ============================================
# Help Tests
# ============================================

@test "setup-project: shows help with --help" {
    run bash "$SETUP_SCRIPT" --help
    assert_success
    assert_output --partial "Setup"
    assert_output --partial "Usage"
}

@test "setup-project: shows help with -h" {
    run bash "$SETUP_SCRIPT" -h
    assert_success
    assert_output --partial "Usage"
}

# ============================================
# Directory Validation Tests
# ============================================

@test "setup-project: fails with non-existent directory" {
    run bash "$SETUP_SCRIPT" "/nonexistent/path"
    assert_failure
    assert_output --partial "Error"
}

@test "setup-project: requires git repository" {
    local non_git_dir="${TEST_TEMP_DIR}/non-git-project"
    mkdir -p "$non_git_dir"

    run bash "$SETUP_SCRIPT" "$non_git_dir"
    assert_failure
    assert_output --partial "git"
}

# ============================================
# Setup Structure Tests
# ============================================

@test "setup-project: creates .usecase directory" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    run bash "$SETUP_SCRIPT" "$project_dir"
    assert_success
    assert_dir_exists "${project_dir}/.usecase"
}

@test "setup-project: creates .usecase/cases directory" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    run bash "$SETUP_SCRIPT" "$project_dir"
    assert_success
    assert_dir_exists "${project_dir}/.usecase/cases"
}

@test "setup-project: creates README in cases directory" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    run bash "$SETUP_SCRIPT" "$project_dir"
    assert_success
    assert_file_exists "${project_dir}/.usecase/cases/README.md"
}

# ============================================
# Git Hooks Tests
# ============================================

@test "setup-project: creates post-commit hook" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    run bash "$SETUP_SCRIPT" "$project_dir"
    assert_success
    assert_file_exists "${project_dir}/.git/hooks/post-commit"
}

@test "setup-project: post-commit hook is executable" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    bash "$SETUP_SCRIPT" "$project_dir"
    [ -x "${project_dir}/.git/hooks/post-commit" ]
}

# ============================================
# Completion Tests
# ============================================

@test "setup-project: shows completion message" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    run bash "$SETUP_SCRIPT" "$project_dir"
    assert_success
    assert_output --partial "Setup" || assert_output --partial "Complete" || assert_output --partial "Success"
}

@test "setup-project: output is colored" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    run bash "$SETUP_SCRIPT" "$project_dir"
    assert_success
    assert_has_color_output
}

# ============================================
# Update Mode Tests
# ============================================

@test "setup-project --update: works on existing installation" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initial setup
    bash "$SETUP_SCRIPT" "$project_dir"

    # Update
    run bash "$SETUP_SCRIPT" --update "$project_dir"
    assert_success
}

@test "setup-project --update: preserves existing use cases" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initial setup
    bash "$SETUP_SCRIPT" "$project_dir"

    # Create a use case
    echo "# Existing use case" > "${project_dir}/.usecase/cases/2025-W45-11-07_EXIST-001_existing.md"

    # Update
    run bash "$SETUP_SCRIPT" --update "$project_dir"
    assert_success

    # Use case should still exist
    assert_file_exists "${project_dir}/.usecase/cases/2025-W45-11-07_EXIST-001_existing.md"
}

# ============================================
# CLI Integration Tests
# ============================================

@test "ai-use-case --init: works via CLI" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    cd "$project_dir"
    run "$CLI" --init
    assert_success
}

@test "ai-use-case init: works via CLI" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    cd "$project_dir"
    run "$CLI" init
    assert_success
}

@test "ai-use-case --init --update: works via CLI" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initial setup
    cd "$project_dir"
    "$CLI" --init

    # Update
    run "$CLI" --init --update
    assert_success
}

# ============================================
# Idempotency Tests
# ============================================

@test "setup-project: can run multiple times safely" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # First setup
    run bash "$SETUP_SCRIPT" "$project_dir"
    assert_success

    # Second setup
    run bash "$SETUP_SCRIPT" "$project_dir"
    assert_success
}

@test "setup-project: does not duplicate hook content" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Run setup twice
    bash "$SETUP_SCRIPT" "$project_dir"
    bash "$SETUP_SCRIPT" "$project_dir"

    # Hook should not have duplicated content
    local hook_size
    hook_size=$(wc -l < "${project_dir}/.git/hooks/post-commit")
    # Reasonable hook size (not doubled)
    [ "$hook_size" -lt 100 ]
}

# ============================================
# Error Handling Tests
# ============================================

@test "setup-project: shows helpful error for non-git directory" {
    local non_git_dir="${TEST_TEMP_DIR}/not-a-repo"
    mkdir -p "$non_git_dir"

    run bash "$SETUP_SCRIPT" "$non_git_dir"
    assert_failure
    assert_output --partial "git"
}

@test "setup-project: error message includes path" {
    run bash "$SETUP_SCRIPT" "/invalid/path/here"
    assert_failure
    assert_output --partial "/invalid/path"
}

# ============================================
# Registry Tests
# ============================================

@test "setup-project: registers project in registry" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    run bash "$SETUP_SCRIPT" "$project_dir"
    assert_success

    # Registry file should exist
    assert_file_exists "${TEST_CONFIG_DIR}/registry.json"
}

# ============================================
# .ai-tools Decoupling Tests
# ============================================

@test "setup-project: creates .ai-tools without .claude folder" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Ensure no .claude folder exists
    rm -rf "${project_dir}/.claude"

    run bash "$SETUP_SCRIPT" "$project_dir"
    assert_success

    # .ai-tools should be created
    assert_dir_exists "${project_dir}/.ai-tools"
    assert_dir_exists "${project_dir}/.ai-tools/commands/use-case"
}

@test "setup-project: shows message when .claude missing" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Ensure no .claude folder exists
    rm -rf "${project_dir}/.claude"

    run bash "$SETUP_SCRIPT" "$project_dir"
    assert_success

    # Should show informational message about --link-claude
    assert_output --partial "link-claude"
}

@test "setup-project: does not create .claude symlink without .claude folder" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Ensure no .claude folder exists
    rm -rf "${project_dir}/.claude"

    run bash "$SETUP_SCRIPT" "$project_dir"
    assert_success

    # .claude/commands/use-case should NOT exist
    [ ! -e "${project_dir}/.claude/commands/use-case" ]
}

@test "setup-project: creates symlink when .claude exists" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Create .claude folder first
    mkdir -p "${project_dir}/.claude"

    run bash "$SETUP_SCRIPT" "$project_dir"
    assert_success

    # .claude/commands/use-case should be a symlink
    [ -L "${project_dir}/.claude/commands/use-case" ]
}

# ============================================
# --link-claude Command Tests
# ============================================

@test "link-claude: fails without .ai-tools" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Don't run setup, so no .ai-tools exists
    run bash "$LINK_CLAUDE_SCRIPT" "$project_dir"
    assert_failure
    assert_output --partial ".ai-tools"
}

@test "link-claude: creates .claude folder if missing" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Run setup first to create .ai-tools (without .claude)
    rm -rf "${project_dir}/.claude"
    bash "$SETUP_SCRIPT" "$project_dir"

    # Now run link-claude
    run bash "$LINK_CLAUDE_SCRIPT" "$project_dir"
    assert_success

    # .claude should be created
    assert_dir_exists "${project_dir}/.claude"
}

@test "link-claude: creates commands directory" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Run setup first (without .claude)
    rm -rf "${project_dir}/.claude"
    bash "$SETUP_SCRIPT" "$project_dir"

    # Now run link-claude
    run bash "$LINK_CLAUDE_SCRIPT" "$project_dir"
    assert_success

    # .claude/commands should be created
    assert_dir_exists "${project_dir}/.claude/commands"
}

@test "link-claude: creates correct symlink" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Run setup first (without .claude)
    rm -rf "${project_dir}/.claude"
    bash "$SETUP_SCRIPT" "$project_dir"

    # Now run link-claude
    run bash "$LINK_CLAUDE_SCRIPT" "$project_dir"
    assert_success

    # Check symlink exists and points to right place
    [ -L "${project_dir}/.claude/commands/use-case" ]
    local link_target
    link_target=$(readlink "${project_dir}/.claude/commands/use-case")
    [ "$link_target" = "../../.ai-tools/commands/use-case" ]
}

@test "link-claude: is idempotent" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Run setup first (without .claude)
    rm -rf "${project_dir}/.claude"
    bash "$SETUP_SCRIPT" "$project_dir"

    # Run link-claude twice
    run bash "$LINK_CLAUDE_SCRIPT" "$project_dir"
    assert_success

    run bash "$LINK_CLAUDE_SCRIPT" "$project_dir"
    assert_success

    # Symlink should still be correct
    [ -L "${project_dir}/.claude/commands/use-case" ]
}

@test "link-claude: warns when symlink points to wrong target" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Run setup first (without .claude)
    rm -rf "${project_dir}/.claude"
    bash "$SETUP_SCRIPT" "$project_dir"

    # Create .claude/commands with wrong symlink
    mkdir -p "${project_dir}/.claude/commands"
    ln -s "/wrong/path" "${project_dir}/.claude/commands/use-case"

    # Run link-claude - should fail with warning
    run bash "$LINK_CLAUDE_SCRIPT" "$project_dir"
    assert_failure
    assert_output --partial "points to"
}

@test "link-claude: warns when use-case exists as directory" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Run setup first (without .claude)
    rm -rf "${project_dir}/.claude"
    bash "$SETUP_SCRIPT" "$project_dir"

    # Create .claude/commands/use-case as a directory
    mkdir -p "${project_dir}/.claude/commands/use-case"

    # Run link-claude - should fail with warning
    run bash "$LINK_CLAUDE_SCRIPT" "$project_dir"
    assert_failure
    assert_output --partial "not a symlink"
}

@test "ai-use-case --link-claude: works via CLI" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Run setup first (without .claude)
    rm -rf "${project_dir}/.claude"
    cd "$project_dir"
    "$CLI" --init

    # Run link-claude via CLI
    run "$CLI" --link-claude
    assert_success

    # Symlink should exist
    [ -L "${project_dir}/.claude/commands/use-case" ]
}

@test "ai-use-case link-claude: works via CLI (without dashes)" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Run setup first (without .claude)
    rm -rf "${project_dir}/.claude"
    cd "$project_dir"
    "$CLI" init

    # Run link-claude via CLI (without dashes)
    run "$CLI" link-claude
    assert_success

    # Symlink should exist
    [ -L "${project_dir}/.claude/commands/use-case" ]
}
