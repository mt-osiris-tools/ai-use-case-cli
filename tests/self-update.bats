#!/usr/bin/env bats

load 'test_helper'

setup() {
    common_setup
    UPDATE_ROOT="$TEST_TEMP_DIR/cli-install"
    UPDATE_REMOTE="$TEST_TEMP_DIR/cli-remote.git"
    UPDATE_PUBLISHER="$TEST_TEMP_DIR/cli-publisher"
}

teardown() {
    common_teardown
}

create_update_fixture() {
    mkdir -p "$UPDATE_ROOT/scripts/utils"
    cp "$(script_path scripts/utils/self-update.sh)" "$UPDATE_ROOT/scripts/utils/self-update.sh"
    printf 'export CLI_VERSION="3.13.0"\n' > "$UPDATE_ROOT/scripts/utils/version.sh"

    git init -q --bare "$UPDATE_REMOTE"
    git -C "$UPDATE_ROOT" init -q
    git -C "$UPDATE_ROOT" config user.email "test@example.com"
    git -C "$UPDATE_ROOT" config user.name "Test User"
    git -C "$UPDATE_ROOT" branch -M main
    git -C "$UPDATE_ROOT" add scripts
    git -C "$UPDATE_ROOT" commit -q -m "Initial CLI"
    git -C "$UPDATE_ROOT" remote add origin "$UPDATE_REMOTE"
    git -C "$UPDATE_ROOT" push -q -u origin main
    git --git-dir="$UPDATE_REMOTE" symbolic-ref HEAD refs/heads/main
    git clone -q "$UPDATE_REMOTE" "$UPDATE_PUBLISHER"
    git -C "$UPDATE_PUBLISHER" config user.email "test@example.com"
    git -C "$UPDATE_PUBLISHER" config user.name "Test User"
}

@test "self-update: fails clearly outside a git installation" {
    local script_root="$TEST_TEMP_DIR/no-git/scripts/utils"
    mkdir -p "$script_root"
    cp "$(script_path scripts/utils/self-update.sh)" "$script_root/self-update.sh"

    run bash "$script_root/self-update.sh" --check
    assert_failure
    assert_output --partial "not a git repository"
}

@test "self-update: check reports an up-to-date installation" {
    create_update_fixture

    run bash "$UPDATE_ROOT/scripts/utils/self-update.sh" --check
    assert_success
    assert_output --partial "already up to date"
}

@test "self-update: check reports an available update without changing the checkout" {
    create_update_fixture
    printf 'export CLI_VERSION="3.14.0"\n' > "$UPDATE_PUBLISHER/scripts/utils/version.sh"
    git -C "$UPDATE_PUBLISHER" add scripts/utils/version.sh
    git -C "$UPDATE_PUBLISHER" commit -q -m "Release next CLI"
    git -C "$UPDATE_PUBLISHER" push -q origin main
    local current_commit
    current_commit="$(git -C "$UPDATE_ROOT" rev-parse HEAD)"

    run bash "$UPDATE_ROOT/scripts/utils/self-update.sh" --check
    assert_success
    assert_output --partial "Update available"
    assert_output --partial "No changes were applied"
    [ "$(git -C "$UPDATE_ROOT" rev-parse HEAD)" = "$current_commit" ]
}
