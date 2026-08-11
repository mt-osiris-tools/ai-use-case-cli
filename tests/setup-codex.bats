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

@test "setup-codex: does not require project initialization" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    run bash "$SETUP_CODEX_SCRIPT" --local "$project_dir"
    assert_success
    assert_file_exists "$project_dir/.codex/skills/ai-use-case-documentation/SKILL.md"
}

# ============================================
# Setup Structure Tests
# ============================================

@test "setup-codex: creates .codex directory in home" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_dir_exists "$HOME/.codex"
}

@test "setup-codex: creates .codex/prompts directory in home" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_dir_exists "$HOME/.codex/prompts"
}

@test "setup-codex: copies document-session prompt to home" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_file_exists "$HOME/.codex/prompts/use-case-document-session.md"
    # Verify it's a copy, not a symlink
    run test ! -L "$HOME/.codex/prompts/use-case-document-session.md"
    assert_success
}

@test "setup-codex: copies publish-confluence prompt to home" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_file_exists "$HOME/.codex/prompts/use-case-publish-confluence.md"
}

@test "setup-codex: creates copies not symlinks (key difference from Claude)" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"
    bash "$SETUP_CODEX_SCRIPT" "$project_dir"

    # Verify files are NOT symlinks (unlike Claude integration which uses symlinks)
    run test ! -L "$HOME/.codex/prompts/use-case-document-session.md"
    assert_success
    run test ! -L "$HOME/.codex/prompts/use-case-publish-confluence.md"
    assert_success
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
    run grep -q "^---$" <(head -1 "$HOME/.codex/prompts/use-case-document-session.md")
    assert_success
    run grep -q "^---$" <(head -1 "$HOME/.codex/prompts/use-case-publish-confluence.md")
    assert_success
}

@test "setup-codex: prompts have description in frontmatter" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"
    bash "$SETUP_CODEX_SCRIPT" "$project_dir"

    # Check for description field
    run grep "^description:" "$HOME/.codex/prompts/use-case-document-session.md"
    assert_success
    run grep "^description:" "$HOME/.codex/prompts/use-case-publish-confluence.md"
    assert_success
}

# ============================================
# Update Tests
# ============================================

@test "setup-codex: preserves files when they differ unless forced" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"
    bash "$SETUP_CODEX_SCRIPT" "$project_dir"

    # Modify one of the prompts in home directory
    echo "# Modified" >> "$HOME/.codex/prompts/use-case-document-session.md"

    # Run again - should preserve the user modification
    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_output --partial "Preserved modified file"
}

@test "setup-codex: force updates files when they differ" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"
    bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    echo "# Modified" >> "$HOME/.codex/prompts/use-case-document-session.md"

    run bash "$SETUP_CODEX_SCRIPT" --force "$project_dir"
    assert_success
    assert_output --partial "Updating"
}

@test "setup-codex: supports project-local installation without project initialization" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    run bash "$SETUP_CODEX_SCRIPT" --local "$project_dir"
    assert_success
    assert_file_exists "$project_dir/.codex/prompts/use-case-document-session.md"
    assert_file_exists "$project_dir/.codex/skills/ai-use-case-documentation/SKILL.md"
}

@test "setup-codex: supports dry-run JSON output without writing" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    run bash "$SETUP_CODEX_SCRIPT" --local --dry-run --json "$project_dir"
    assert_success
    assert_output --partial '"dry_run":true'
    run test ! -e "$project_dir/.codex"
    assert_success
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

    # Files should still exist in home directory
    assert_file_exists "$HOME/.codex/prompts/use-case-document-session.md"
    assert_file_exists "$HOME/.codex/prompts/use-case-publish-confluence.md"
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
    assert_output --partial "Setup complete"
}

@test "setup-codex: displays installed targets" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_output --partial "Prompts:"
    assert_output --partial "Skill:"
}

@test "setup-codex: reports installation counts" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    # Initialize project first
    bash "$SETUP_PROJECT_SCRIPT" "$project_dir"

    run bash "$SETUP_CODEX_SCRIPT" "$project_dir"
    assert_success
    assert_output --partial "Installed:"
    assert_output --partial "Skipped:"
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
    assert_dir_exists "$HOME/.codex/prompts"
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
    assert_dir_exists "$HOME/.codex/prompts"
}

@test "ai-use-case setup-codex: forwards local mode" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    cd "$project_dir"
    run "$CLI" setup-codex --local
    assert_success
    assert_file_exists "$project_dir/.codex/skills/ai-use-case-documentation/SKILL.md"
}

@test "ai-use-case setup-codex: JSON output is machine-readable" {
    local project_dir
    project_dir="$(create_test_git_repo)"

    cd "$project_dir"
    run "$CLI" setup-codex --local --json
    assert_success
    [[ "$output" == \{"mode":"local"*\} ]]
}
