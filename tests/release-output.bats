#!/usr/bin/env bats
# Tests for compact release validation output.

load 'test_helper'

setup() {
    common_setup
}

teardown() {
    common_teardown
}

@test "run-tests: quiet mode shows summary without passing cases" {
    run bash "$(script_path run-tests.sh)" --quiet version

    assert_success
    assert_output --partial "Running 1 test file(s) in quiet mode..."
    assert_output --partial "All tests passed!"
    refute_output --partial "ok 1 version.sh:"
}

@test "validate-versions: quiet mode shows compact success summary" {
    run bash "$(script_path scripts/utils/validate-versions.sh)" --quiet

    assert_success
    assert_output "Version validation passed: 3.14.0"
}

@test "quiet modes are documented in command help" {
    run bash "$(script_path run-tests.sh)" --help
    assert_success
    assert_output --partial "--quiet, -q"

    run bash "$(script_path scripts/utils/validate-versions.sh)" --help
    assert_success
    assert_output --partial "--quiet, -q"
}
