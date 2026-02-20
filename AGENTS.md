# Agent Guide (ai-use-case-cli)

Short, practical guidance for coding agents working in this repository.

## Canonical Sources (read first)

- `CLAUDE.md`: primary engineering and workflow rules.
- `CONTRIBUTING.md`: PR process, required docs updates, version checks.
- `.github/copilot-instructions.md`: architecture and AI-agent constraints.
- `docs/WORKFLOW.md` and `docs/COMMANDS.md`: detailed workflows and command reference.

## Cursor and Copilot Rules

- Cursor rules: none found in `.cursor/rules/` or `.cursorrules`.
- Copilot rules: always apply `.github/copilot-instructions.md`.
- OpenCode notes: see `docs/agents/opencode/README.md` (tool mapping and non-interactive setup).
- Preserve dual-repo design: this repo is CLI/tooling; hub content lives in the separate hub repo.
- Any hub operation in scripts must go through `ensure_hub_exists()`.

## Quick Commands (build/lint/test)

There is no traditional build step for the root Bash CLI. Validate using CLI checks, tests, and lint.

### One-time test setup

```bash
git submodule update --init --recursive
```

### Test runner (`run-tests.sh`)

```bash
# All tests
./run-tests.sh

# Single test file (without .bats)
./run-tests.sh version

# Multiple test files
./run-tests.sh version config-manager

# Match test names/descriptions
./run-tests.sh --filter "help"

# Discoverability/debug
./run-tests.sh --help
./run-tests.sh --list
./run-tests.sh --count
./run-tests.sh --verbose
./run-tests.sh --tap
```

### Manual CLI smoke checks

```bash
./ai-use-case --help
./ai-use-case --version
```

### Shell lint

```bash
shellcheck -x ai-use-case run-tests.sh
shopt -s globstar && shellcheck -x scripts/**/*.sh lib/**/*.sh
```

Prefer fixing warnings. If suppression is required, use targeted `# shellcheck disable=SCXXXX` with a short reason.

### Version consistency checks

```bash
# During development
./scripts/utils/validate-versions.sh --unreleased

# Before release / strict checks
./scripts/utils/validate-versions.sh
```

Version source of truth: `scripts/utils/version.sh` (`CLI_VERSION`).

## Repository Architecture

- `ai-use-case`: top-level command router.
- `scripts/`: executable command implementations (`core/`, `project/`, `search/`, `utils/`, etc.).
- `lib/`: shared modules (`core`, `config`, `observability`, `utils`).
- `tests/`: Bats tests and helpers.
- `vscode-extension/`: TypeScript extension that delegates many actions to the CLI.

Core rule: do not hardcode hub layout assumptions in CLI logic beyond documented interfaces.

## Code Style and Engineering Conventions

### Imports and module sourcing (Bash)

- Resolve paths from the current script, not the caller:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

- Source shared modules from `lib/` and prefer existing helpers over duplicate logic.
- For config logic, prefer direct modules (`lib/config/config-*.sh`) over expanding deprecated facades.

### Formatting and structure

- New scripts should use `set -euo pipefail`.
- Keep functions small and focused; favor early validation and early exits.
- Keep command output concise and actionable.

### Types and language-specific guidance

- Bash has no static types; compensate with strict input validation and defensive checks.
- In `vscode-extension/` (TypeScript), keep strict typing; avoid `any` unless unavoidable and justified.
- Keep version values synchronized across CLI and extension files when version-affecting changes are made.

### Naming

- Functions: `snake_case`.
- Local variables: `snake_case` with `local` declarations.
- Constants/global vars: `UPPER_SNAKE_CASE`, use `readonly` when appropriate.
- Script/module filenames: `kebab-case.sh`.

### Quoting, safety, and portability

- Quote variable expansions unless intentional splitting is required.
- Treat user-provided input as untrusted; validate/sanitize paths and arguments.
- Prefer arrays over space-delimited strings for argument lists.
- Assume paths can contain spaces.
- Avoid GNU-only flags unless guarded; account for macOS vs Linux differences (`sed -i` behavior especially).

### Error handling and exit codes

- Send errors to stderr and make messages actionable (`Error: <what failed>`, plus fix hints when useful).
- Use stable exit codes:
  - `0`: success
  - `1`: general failure
  - `2`: misuse/invalid arguments
- Check required command availability (`command -v ...`) before use when relevant.

### Output and UX consistency

- Prefer color constants from `lib/core/constants.sh` (TTY-aware), not ad-hoc ANSI definitions.
- Keep messaging consistent across scripts (errors, warnings, success confirmations).

## Testing Conventions

- Tests are Bats files in `tests/*.bats`.
- Use `tests/test_helper.bash` for isolation (`common_setup` / `common_teardown`).
- Tests must not rely on real user environment; helper overrides `HOME`, `XDG_CONFIG_HOME`, and `AI_USECASES_DIR`.
- When changing behavior, add/update tests in the same PR.

## Workflow Constraints (non-negotiable)

- Never commit directly to `main`.
- Use branch prefixes: `feature/`, `fix/`, `docs/`, `refactor/`, `test/`.
- Use Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
- Update `CHANGELOG.md` (`[Unreleased]`) for all changes.
- Update `README.md` and related `docs/` for user-facing changes.

## Agent Safety Checklist

- Make minimal, targeted changes; avoid drive-by refactors.
- Reuse existing `lib/` and script patterns before introducing new abstractions.
- Do not leave TODO/FIXME placeholders in generated documentation.
- Validate changes with relevant tests/lint before handing off.
