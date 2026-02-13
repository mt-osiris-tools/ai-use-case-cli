# Agent Guide (ai-use-case-cli)
This file is the short, pragmatic guide for autonomous coding agents working in this repository.

## Canonical Rules (read these first)
- `CLAUDE.md` (repo root): primary engineering + workflow rules.
- `CONTRIBUTING.md`: PR workflow, docs requirements, version rules.
- `.github/copilot-instructions.md`: AI-agent-specific constraints and architecture guardrails.
- `docs/WORKFLOW.md` + `docs/COMMANDS.md`: detailed workflow + command reference.

Cursor rules: none found in `.cursor/rules/` or `.cursorrules`.

## Build / Test / Lint (commands you actually run)
There is no "build" step (this is primarily Bash). Validate by running CLI commands + tests.

### One-time setup (tests)
Tests use vendored bats submodules under `tests/bats/`.
```bash
git submodule update --init --recursive
```

### Automated tests (Bats)
Entry point: `./run-tests.sh`
```bash
./run-tests.sh
./run-tests.sh --help

# Run a single test file (name without .bats)
./run-tests.sh version

# Run multiple test files
./run-tests.sh version config-manager

# Filter by test name/description
./run-tests.sh --filter "help"

# Useful utilities
./run-tests.sh --list
./run-tests.sh --count
./run-tests.sh --verbose
./run-tests.sh --tap
```

### Quick manual checks (CLI)
```bash
./ai-use-case --help
./ai-use-case --version
```

### Version consistency (must pass before PRs)
```bash
./scripts/utils/validate-versions.sh --unreleased  # during development
./scripts/utils/validate-versions.sh               # before release / strict
```
Source of truth: `scripts/utils/version.sh` (`export CLI_VERSION="..."`).

### Shell linting (recommended)
There is no single repo-wide wrapper script for shellcheck; run it on what you touched.
```bash
shellcheck -x ai-use-case run-tests.sh
shopt -s globstar && shellcheck -x scripts/**/*.sh lib/**/*.sh
```
Guidelines: prefer fixing warnings; if you must suppress, use targeted `# shellcheck disable=SCXXXX` with a short reason.

### Markdown linting (optional)
- Repo config: `.markdownlint.json`
- `publish-confluence` auto-lints/auto-fixes if `markdownlint` is installed.
```bash
npm install -g markdownlint-cli
markdownlint "docs/**/*.md"
```

## Workflow Constraints (non-negotiable)
- Never commit directly to `main`.
- Branch prefixes: `feature/`, `fix/`, `docs/`, `refactor/`, `test/`.
- Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
- Documentation revision rule: update `CHANGELOG.md` (Unreleased) for all changes; update `README.md` + `docs/` for user-facing/behavior changes.
- Dual-repo architecture: CLI tooling lives here; hub content lives in a separate hub repo.
  - Never bake hub repo assumptions into this repo beyond the documented interface.

## Repository Architecture (how code is organized)
- `ai-use-case`: main command router; delegates to scripts under `scripts/`.
- `scripts/`: executable commands (setup, sync, document, publish, search, utils).
- `lib/`: shared modules (constants, config, observability, utils). Prefer shared modules over copy/paste.
- `tests/`: Bats tests + helper library; `tests/test_helper.bash` creates isolated temp env.

Hub interactions: use `ensure_hub_exists()` before reading/writing hub paths; prefer `scripts/utils/hub-utils.sh`.

Config interactions: `scripts/utils/config-manager.sh` is a deprecated facade; new code should source specific modules:

```bash
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_SCRIPT_DIR/../../lib/core/constants.sh"
source "$_SCRIPT_DIR/../../lib/config/config-core.sh"
source "$_SCRIPT_DIR/../../lib/config/config-hub.sh"
source "$_SCRIPT_DIR/../../lib/config/config-features.sh"
source "$_SCRIPT_DIR/../../lib/config/config-tracing.sh"
source "$_SCRIPT_DIR/../../lib/config/config-confluence.sh"
```

## Bash Style Guide (match existing patterns)
### Strict mode
- New scripts: `set -euo pipefail`.
- Some legacy scripts use `set -e`; don't "fix" that unless you are already changing the file and you understand implications.

### Sourcing ("imports")
- Resolve paths from the current file, not the caller:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```
- Source shared constants for colors and paths when practical:
  - `source "$SCRIPT_DIR/../../lib/core/constants.sh"`

### Naming
- Functions: `snake_case` (e.g., `ensure_hub_exists`).
- Locals: `snake_case` and declared `local` inside functions.
- Constants/globals: `UPPER_SNAKE_CASE` + `readonly` where applicable.
- Scripts/modules: `kebab-case.sh`.

### Quoting and safety
- Quote all variable expansions unless you explicitly need word-splitting.
- Treat user-provided paths/strings as hostile; validate and sanitize (see `lib/config/config-core.sh`).
- Prefer arrays over stringly-typed argument lists.

### Errors and exit codes
- Errors go to stderr (`>&2`) and must be actionable.
- Exit codes:
  - `0` success
  - `1` general failure
  - `2` misuse / invalid arguments

### Output formatting
- Prefer color constants from `lib/core/constants.sh` (TTY-aware) over re-defining ANSI codes.
- Keep user messaging consistent: "Error: ...", warnings, and success checkmarks.

### Cross-platform compatibility (macOS/Linux/WSL)
- Avoid GNU-only flags unless guarded.
- `sed -i` differs between macOS and Linux; if you must do in-place edits, use platform detection (see `docs/WORKFLOW.md`).
- Assume paths may contain spaces; always quote.

## Testing Conventions (when adding/changing tests)
- Tests live in `tests/*.bats`.
- Use `tests/test_helper.bash`:
  - `load 'test_helper'`
  - call `common_setup` / `common_teardown` for isolation
- Tests should not depend on real user config; the helper overrides `HOME`, `XDG_CONFIG_HOME`, and `AI_USECASES_DIR`.

## Agent Safety (how to make changes safely)
- Prefer the smallest change that solves the problem; avoid drive-by refactors.
- Don't add new dependencies unless required; prefer existing scripts/modules.
- Don't introduce TODO/FIXME placeholders in generated docs/templates.
- When changing behavior, update docs and add/adjust tests in the same PR.
