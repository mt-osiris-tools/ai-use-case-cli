#!/bin/bash
# AI Use Case CLI - Release workflow

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERSION_FILE="$REPO_ROOT/lib/core/version.sh"
BUMP_SCRIPT="$SCRIPT_DIR/bump-version.sh"
VALIDATE_SCRIPT="$SCRIPT_DIR/validate-versions.sh"

usage() {
    cat <<EOF
AI Use Case CLI release workflow

Usage:
  ai-use-case release prepare <major|minor|patch|X.Y.Z>
  ai-use-case release publish <X.Y.Z>

prepare updates version metadata on a release/* branch without committing,
tagging, or pushing. Open a PR with the resulting changes.

publish validates merged main, runs tests, pushes vX.Y.Z, and starts the
tag-triggered draft GitHub Release workflow.
EOF
}

fail() {
    echo "Error: $*" >&2
    exit 1
}

current_version() {
    # shellcheck disable=SC1090
    source "$VERSION_FILE"
    printf '%s\n' "$CLI_VERSION"
}

require_clean_tree() {
    [[ -z "$(git -C "$REPO_ROOT" status --porcelain)" ]] || fail "working tree must be clean"
}

prepare_release() {
    local bump_type="${1:-}"
    [[ -n "$bump_type" ]] || fail "version bump is required"
    local branch
    branch="$(git -C "$REPO_ROOT" branch --show-current)"
    [[ "$branch" == release/* ]] || fail "prepare must run on a release/* branch (current: $branch)"
    require_clean_tree
    bash "$BUMP_SCRIPT" "$bump_type" --no-commit --no-tag --no-push --yes
    echo "Release prepared. Review the changes, commit them, and open the release PR."
}

publish_release() {
    local version="${1:-}"
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "publish requires a version in X.Y.Z format"
    local branch actual_version
    branch="$(git -C "$REPO_ROOT" branch --show-current)"
    [[ "$branch" == main ]] || fail "publish must run on main (current: $branch)"
    require_clean_tree

    if git -C "$REPO_ROOT" show-ref --verify --quiet refs/remotes/origin/main; then
        git -C "$REPO_ROOT" fetch origin main --quiet
        git -C "$REPO_ROOT" diff --quiet origin/main...HEAD || fail "local main is not up to date with origin/main"
    fi

    actual_version="$(current_version)"
    [[ "$actual_version" == "$version" ]] || fail "version.sh is $actual_version, expected $version"
    git -C "$REPO_ROOT" show-ref --verify --quiet "refs/tags/v$version" && fail "tag v$version already exists"
    "$VALIDATE_SCRIPT"
    "$REPO_ROOT/run-tests.sh"
    git -C "$REPO_ROOT" tag -a "v$version" -m "Release v$version"
    git -C "$REPO_ROOT" push origin "v$version"
    echo "Published tag v$version. GitHub Actions will create a draft release."
}

main() {
    case "${1:-}" in
        prepare) shift; prepare_release "$@" ;;
        publish) shift; publish_release "$@" ;;
        --help|-h|help|"") usage ;;
        *) usage >&2; exit 2 ;;
    esac
}

main "$@"
