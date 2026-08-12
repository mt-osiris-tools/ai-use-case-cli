#!/usr/bin/env bats
# Tests for scripts/utils/version.sh

load 'test_helper'

setup() {
    common_setup
}

teardown() {
    common_teardown
}

# ============================================
# Basic Sourcing Tests
# ============================================

@test "version.sh: can be sourced without error" {
    run bash -c "source '$(script_path scripts/utils/version.sh)'"
    assert_success
}

@test "version.sh: exports CLI_VERSION variable" {
    source "$(script_path scripts/utils/version.sh)"
    [ -n "$CLI_VERSION" ]
}

@test "version.sh: CLI_VERSION is available after sourcing" {
    source "$(script_path scripts/utils/version.sh)"
    run echo "$CLI_VERSION"
    assert_success
    assert_output --regexp '^[0-9]+\.[0-9]+\.[0-9]+$'
}

# ============================================
# Version Format Tests
# ============================================

@test "version.sh: CLI_VERSION follows semver format (X.Y.Z)" {
    source "$(script_path scripts/utils/version.sh)"
    [[ "$CLI_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "version.sh: CLI_VERSION major version is numeric" {
    source "$(script_path scripts/utils/version.sh)"
    local major
    major="${CLI_VERSION%%.*}"
    [[ "$major" =~ ^[0-9]+$ ]]
}

@test "version.sh: CLI_VERSION is not empty" {
    source "$(script_path scripts/utils/version.sh)"
    [ -n "$CLI_VERSION" ]
    [ "$CLI_VERSION" != "" ]
}

# ============================================
# Export Behavior Tests
# ============================================

@test "version.sh: CLI_VERSION is exported to subshells" {
    source "$(script_path scripts/utils/version.sh)"
    local result
    result=$(bash -c 'echo $CLI_VERSION')
    [ "$result" = "$CLI_VERSION" ]
}

@test "version.sh: can be sourced multiple times without error" {
    source "$(script_path scripts/utils/version.sh)"
    local first_version="$CLI_VERSION"
    source "$(script_path scripts/utils/version.sh)"
    [ "$CLI_VERSION" = "$first_version" ]
}

@test "version.sh: version is consistent across multiple sources" {
    source "$(script_path scripts/utils/version.sh)"
    local v1="$CLI_VERSION"
    unset CLI_VERSION
    source "$(script_path scripts/utils/version.sh)"
    local v2="$CLI_VERSION"
    [ "$v1" = "$v2" ]
}

# ============================================
# CLI Integration Tests
# ============================================

@test "version.sh: matches ai-use-case --version output" {
    source "$(script_path scripts/utils/version.sh)"
    run "$(script_path ai-use-case)" --version
    assert_success
    assert_output --partial "$CLI_VERSION"
}

@test "version.sh: matches ai-use-case -v output" {
    source "$(script_path scripts/utils/version.sh)"
    run "$(script_path ai-use-case)" -v
    assert_success
    assert_output --partial "$CLI_VERSION"
}

@test "version.sh: current version is at least 3.0.0" {
    source "$(script_path scripts/utils/version.sh)"
    local major
    major="${CLI_VERSION%%.*}"
    [ "$major" -ge 3 ]
}

@test "bump-version: dry run does not modify the working tree" {
    local before after
    before="$(git -C "$(script_path .)" status --porcelain)"
    run "$(script_path scripts/utils/bump-version.sh)" patch --dry-run --yes
    assert_success
    after="$(git -C "$(script_path .)" status --porcelain)"
    [ "$after" = "$before" ]
}

@test "release: rejects malformed publish versions" {
    run "$(script_path scripts/utils/release.sh)" publish 3.13
    assert_failure
    assert_output --partial "X.Y.Z format"
}

@test "constants: NO_COLOR disables colors for production commands" {
    run env NO_COLOR=1 bash -c "source '$(script_path lib/core/constants.sh)'; printf '%s' \"\$GREEN\""
    assert_success
    assert_output ""
}
