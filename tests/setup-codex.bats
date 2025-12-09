#!/usr/bin/env bats
# Tests for scripts/project/setup-codex.sh

load 'test_helper'

setup() {
    common_setup
    create_test_config "local" "$TEST_HUB_DIR"
}

teardown() {
    common_teardown
}

SETUP_CODEX_SCRIPT="$(script_path scripts/project/setup-codex.sh)"
SETUP_PROJECT_SCRIPT="$(script_path scripts/project/setup-project.sh)"
CLI="$(script_path ai-use-case)"

# ============================================
# Prerequisite Tests
# ============================================

@test "setup-codex: fails with non-existent directory" {
    run bash "$SETUP_CODEX_SCRIPT" "/nonexistent/path"
    assert_failure
    assert_output --partial "Error"
}

@test "setup-codex: fails without .ai-tools directory" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Don't run setup, so no .ai-tools exists
    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_failure
    assert_output --partial ".ai-tools"
}

@test "setup-codex: shows helpful message about running --init first" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_failure
    assert_output --partial "ai-use-case --init"
}

# ============================================
# Setup Structure Tests
# ============================================

@test "setup-codex: creates .codex directory" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_dir_exists "${project_dir}/.codex"
}

@test "setup-codex: creates .codex/prompts directory" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_dir_exists "${project_dir}/.codex/prompts"
}

@test "setup-codex: copies document-session prompt" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_file_exists "${project_dir}/.codex/prompts/use-case-document-session.md"
}

@test "setup-codex: copies publish-confluence prompt" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_file_exists "${project_dir}/.codex/prompts/use-case-publish-confluence.md"
}

# ============================================
# YAML Frontmatter Tests
# ============================================

@test "setup-codex: prompts have YAML frontmatter" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"
    bash "$SETUP_CODEX_SCRIPT" "$project_dir"

    # Check that files start with ---
    head -1 "${project_dir}/.codex/prompts/use-case-document-session.md" | grep -q "^---$"
    head -1 "${project_dir}/.codex/prompts/use-case-publish-confluence.md" | grep -q "^---$"
}

@test "setup-codex: prompts have description in frontmatter" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"
    bash "$SETUP_CODEX_SCRIPT" "$project_dir"

    # Check for description field
    grep -q "^description:" "${project_dir}/.codex/prompts/use-case-document-session.md"
    grep -q "^description:" "${project_dir}/.codex/prompts/use-case-publish-confluence.md"
}

# ============================================
# Update Tests
# ============================================

@test "setup-codex: updates files when they differ" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"
    bash "$SETUP_CODEX_SCRIPT" "$project_dir"

    # Modify one of the prompts
    echo "# Modified" >> "${project_dir}/.codex/prompts/use-case-document-session.md"

    # Run again - should update
    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_output --partial "Updating"
}

@test "setup-codex: reports already current when files unchanged" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"
    bash "$SETUP_CODEX_SCRIPT" "$project_dir"

    # Run again without changes
    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_output --partial "Already current"
}

# ============================================
# Idempotency Tests
# ============================================

@test "setup-codex: is idempotent" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    # Run setup-codex twice
    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success

    # Files should still exist
    assert_file_exists "${project_dir}/.codex/prompts/use-case-document-session.md"
    assert_file_exists "${project_dir}/.codex/prompts/use-case-publish-confluence.md"
}

# ============================================
# Output Tests
# ============================================

@test "setup-codex: shows completion message" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_output --partial "Setup Complete"
}

@test "setup-codex: displays available commands" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_output --partial "/prompts:use-case-document-session"
    assert_output --partial "/prompts:use-case-publish-confluence"
}

@test "setup-codex: extracts and displays descriptions" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    # Should show descriptions from frontmatter
    assert_output --partial "Document an AI coding session"
    assert_output --partial "Publish AI use case documentation"
}

@test "setup-codex: output is colored" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_has_color_output
}

# ============================================
# CLI Integration Tests
# ============================================

@test "ai-use-case --setup-codex: works via CLI" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    cd "$project_dir"
    "$CLI" --init

    # Run setup-codex via CLI
    run "$CLI" --setup-codex
    assert_success
    assert_dir_exists "${project_dir}/.codex/prompts"
}

@test "ai-use-case setup-codex: works via CLI (without dashes)" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    cd "$project_dir"
    "$CLI" init

    # Run setup-codex via CLI (without dashes)
    run "$CLI" setup-codex
    assert_success
    assert_dir_exists "${project_dir}/.codex/prompts"
}
