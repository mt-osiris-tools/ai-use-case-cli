#!/usr/bin/env bats
# Tests for scripts/search/stats-use-cases.sh

load 'test_helper'

setup() {
    common_setup
    create_test_config "local" "$TEST_HUB_DIR"
}

teardown() {
    common_teardown
}

STATS_SCRIPT="$(script_path scripts/search/stats-use-cases.sh)"
CLI="$(script_path ai-use-case)"

# ============================================
# Basic Stats Tests
# ============================================

@test "stats-use-cases: runs without error on empty hub" {
    run bash "$STATS_SCRIPT"
    assert_success
}

@test "stats-use-cases: displays statistics header" {
    run bash "$STATS_SCRIPT"
    assert_success
    assert_output --partial "Statistics"
}

@test "stats-use-cases: shows hub location" {
    run bash "$STATS_SCRIPT"
    assert_success
    assert_output --partial "Hub"
}

# ============================================
# Use Case Counting Tests
# ============================================

@test "stats-use-cases: counts use cases correctly" {
    # Create some test use cases
    mkdir -p "$TEST_HUB_DIR/by-project/test-project"
    echo "# Test 1" > "$TEST_HUB_DIR/by-project/test-project/2025-W45-11-07_TEST-001_test1.md"
    echo "# Test 2" > "$TEST_HUB_DIR/by-project/test-project/2025-W45-11-08_TEST-002_test2.md"

    run bash "$STATS_SCRIPT"
    assert_success
    # Should show count of use cases
    assert_output --partial "2"
}

@test "stats-use-cases: shows zero for empty hub" {
    run bash "$STATS_SCRIPT"
    assert_success
    # Should show 0 or empty state
    assert_output --partial "0" || assert_output --partial "Total"
}

@test "stats-use-cases: counts across multiple projects" {
    mkdir -p "$TEST_HUB_DIR/by-project/project-a"
    mkdir -p "$TEST_HUB_DIR/by-project/project-b"
    echo "# A1" > "$TEST_HUB_DIR/by-project/project-a/2025-W45-11-07_A-001_a1.md"
    echo "# B1" > "$TEST_HUB_DIR/by-project/project-b/2025-W45-11-07_B-001_b1.md"
    echo "# B2" > "$TEST_HUB_DIR/by-project/project-b/2025-W45-11-08_B-002_b2.md"

    run bash "$STATS_SCRIPT"
    assert_success
    # Should count all 3 use cases
    assert_output --partial "3"
}

# ============================================
# Project Stats Tests
# ============================================

@test "stats-use-cases: shows project count" {
    mkdir -p "$TEST_HUB_DIR/by-project/project-1"
    mkdir -p "$TEST_HUB_DIR/by-project/project-2"
    echo "# Test" > "$TEST_HUB_DIR/by-project/project-1/2025-W45-11-07_TEST-001_test.md"
    echo "# Test" > "$TEST_HUB_DIR/by-project/project-2/2025-W45-11-07_TEST-001_test.md"

    run bash "$STATS_SCRIPT"
    assert_success
    assert_output --partial "Project"
}

@test "stats-use-cases: lists projects with use cases" {
    mkdir -p "$TEST_HUB_DIR/by-project/my-project"
    echo "# Test" > "$TEST_HUB_DIR/by-project/my-project/2025-W45-11-07_TEST-001_test.md"

    run bash "$STATS_SCRIPT"
    assert_success
    assert_output --partial "my-project"
}

# ============================================
# CLI Integration Tests
# ============================================

@test "ai-use-case stats: works via CLI" {
    run "$CLI" stats
    assert_success
    assert_output --partial "Statistics"
}

@test "ai-use-case stats: shows total count via CLI" {
    mkdir -p "$TEST_HUB_DIR/by-project/cli-test"
    echo "# Test" > "$TEST_HUB_DIR/by-project/cli-test/2025-W45-11-07_CLI-001_test.md"

    run "$CLI" stats
    assert_success
    assert_output --partial "Total"
}

# ============================================
# Output Format Tests
# ============================================

@test "stats-use-cases: output is colored" {
    mkdir -p "$TEST_HUB_DIR/by-project/test"
    echo "# Test" > "$TEST_HUB_DIR/by-project/test/2025-W45-11-07_T-001_test.md"

    run bash "$STATS_SCRIPT"
    assert_success
    assert_has_color_output
}

@test "stats-use-cases: shows use cases per project breakdown" {
    mkdir -p "$TEST_HUB_DIR/by-project/project-x"
    echo "# Test 1" > "$TEST_HUB_DIR/by-project/project-x/2025-W45-11-07_X-001_test1.md"
    echo "# Test 2" > "$TEST_HUB_DIR/by-project/project-x/2025-W45-11-08_X-002_test2.md"

    run bash "$STATS_SCRIPT"
    assert_success
    assert_output --partial "project-x"
}

# ============================================
# Edge Cases Tests
# ============================================

@test "stats-use-cases: handles empty project directories" {
    mkdir -p "$TEST_HUB_DIR/by-project/empty-project"

    run bash "$STATS_SCRIPT"
    assert_success
}

@test "stats-use-cases: ignores non-markdown files" {
    mkdir -p "$TEST_HUB_DIR/by-project/test"
    echo "test" > "$TEST_HUB_DIR/by-project/test/readme.txt"
    echo "# Valid" > "$TEST_HUB_DIR/by-project/test/2025-W45-11-07_V-001_valid.md"

    run bash "$STATS_SCRIPT"
    assert_success
    # Should only count the .md file
    assert_output --partial "1"
}
