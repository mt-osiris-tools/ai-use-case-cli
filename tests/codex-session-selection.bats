#!/usr/bin/env bats

load 'test_helper'

setup() {
    common_setup
    export CODEX_HOME="$TEST_TEMP_DIR/codex"
    mkdir -p "$CODEX_HOME/sessions/2026/08/11"
    export SESSION_SCRIPT="$(script_path scripts/core/list-codex-sessions.sh)"
}

teardown() {
    common_teardown
}

write_session() {
    local uuid="$1"
    local timestamp="$2"
    local cwd="$3"
    local path="$CODEX_HOME/sessions/2026/08/11/rollout-${uuid}.jsonl"

    cat > "$path" <<EOF
{"type":"session_meta","payload":{"id":"$uuid","session_id":"$uuid","timestamp":"$timestamp","cwd":"$cwd","originator":"codex-tui","cli_version":"0.147.0"}}
{"type":"response_item","payload":{"type":"message","role":"user","content":[{"type":"input_text","text":"private session content"}]}}
EOF
}

@test "lists current repository sessions newest first" {
    local repo="$TEST_TEMP_DIR/project"
    mkdir -p "$repo"
    write_session "019ff40f-7141-78c3-94b5-b4f2b0ccec44" "2026-08-11T21:41:20Z" "$repo"
    write_session "019ff3fe-e3aa-7393-b6bd-cfceb34269f9" "2026-08-11T21:23:15Z" "$repo"
    write_session "019ff34e-1776-7451-bdd1-693f5a14ff15" "2026-08-11T18:10:09Z" "$TEST_TEMP_DIR/other"

    run "$SESSION_SCRIPT" --repo "$repo"
    assert_success
    assert_line --index 0 --partial "019ff40f-7141-78c3-94b5-b4f2b0ccec44"
    assert_line --index 1 --partial "019ff3fe-e3aa-7393-b6bd-cfceb34269f9"
    refute_output --partial "019ff34e-1776-7451-bdd1-693f5a14ff15"
}

@test "resolves a session UUID and returns its source path as JSON" {
    local repo="$TEST_TEMP_DIR/project"
    mkdir -p "$repo"
    local uuid="019ff40f-7141-78c3-94b5-b4f2b0ccec44"
    write_session "$uuid" "2026-08-11T21:41:20Z" "$repo"

    run "$SESSION_SCRIPT" --uuid "$uuid" --json
    assert_success
    [ "$(jq -r '.[0].id' <<<"$output")" = "$uuid" ]
    [ "$(jq -r '.[0].path' <<<"$output")" = "$CODEX_HOME/sessions/2026/08/11/rollout-${uuid}.jsonl" ]
    refute_output --partial "private session content"
}

@test "rejects malformed and unknown UUIDs" {
    run "$SESSION_SCRIPT" --uuid not-a-uuid
    assert_failure
    assert_output --partial "invalid session UUID"

    run "$SESSION_SCRIPT" --uuid "019ff40f-7141-78c3-94b5-b4f2b0ccec44"
    assert_failure
    assert_output --partial "session UUID not found"
}

@test "Codex prompt requires explicit session selection" {
    local prompt
    prompt="$(script_path .codex/prompts/use-case-document-session.md)"
    run rg -n "SESSION_UUID|Do not default|either choose a listed session or enter" "$prompt"
    assert_success
}

@test "Codex skill requires UUID resolution" {
    local skill
    skill="$(script_path codex-skills/ai-use-case-documentation/SKILL.md)"
    run rg -n "selected explicitly|--uuid|JSONL|never silently" "$skill"
    assert_success
}
