#!/usr/bin/env bats

load 'test_helper'

setup() {
    common_setup
}

teardown() {
    common_teardown
}

RESET_SCRIPT="$(script_path scripts/utils/reset.sh)"

@test "reset --config: removes config under XDG_CONFIG_HOME" {
    export XDG_CONFIG_HOME="${TEST_TEMP_DIR}/xdg-config"
    mkdir -p "$XDG_CONFIG_HOME/ai-use-case-cli"
    echo '{"hubMode":"local","hubPath":"/tmp"}' > "$XDG_CONFIG_HOME/ai-use-case-cli/config.json"

    run bash "$RESET_SCRIPT" --config --force
    assert_success

    [ ! -f "$XDG_CONFIG_HOME/ai-use-case-cli/config.json" ]
}
