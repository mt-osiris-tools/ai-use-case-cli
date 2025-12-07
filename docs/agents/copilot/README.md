# Repository Guidelines

## Project Structure & Module Organization
- Entry point: `ai-use-case` shell script at repo root; core workflows live in `scripts/core/` (`document-ai-session.sh`, `sync-ai-use-cases.sh`, `extract-session-data.sh`, `publish-confluence.sh`).
- Project/system helpers: `scripts/utils/` (versioning, config manager, tracing, self-update, validation) and `scripts/project/` (setup, registry, update, list, check-updates).
- Agent scaffolding: `scripts/agents/` for registry and invoker logic; `.ai-tools/commands/` holds AI assistant slash-command definitions.
- Documentation and templates: `docs/` (developer guides, diagrams) and `templates/` (Confluence templates). Example data lives in `.usecase/cases/`.

## Build, Test, and Development Commands
- `./ai-use-case --help` and `./ai-use-case --version` — quick smoke test of the CLI entrypoint.
- `./scripts/utils/validate-versions.sh --unreleased` — verify version strings stay consistent across `version.sh`, README, and changelog during development.
- `./scripts/project/setup-project.sh .` — initialize the current repo; use `--update` to refresh hooks/commands.
- `./scripts/core/document-ai-session.sh [project_path]` — interactive documentation flow (manual mode) for local testing.

## Coding Style & Naming Conventions
- Bash-first codebase; keep `set -e` (and `-u`/`-o pipefail` when safe) at the top of new scripts. Prefer 4-space indentation in functions and align wrapped command flags.
- Use `snake_case` for shell functions, uppercase for environment variables, and kebab-case for files/scripts.
- Keep user-facing output concise and colored as existing scripts do; log paths and decisions explicitly.
- **Color output**: Always use `echo -e` when outputting ANSI color escape sequences (e.g., `echo -e "${CYAN}text${NC}"`). Using `echo` without `-e` will display literal escape codes instead of colors.
- Respect single source of truth: `scripts/utils/version.sh` for versions, `scripts/utils/config-manager.sh` for config reads/writes.

## Testing Guidelines
- No automated CI yet; rely on local smoke tests: run the commands in the Build/Test section plus any touched script directly with representative arguments.
- For tracing changes, use `ai-use-case tracing test` to confirm OpenTelemetry paths; for Confluence changes, dry-run via `scripts/core/publish-confluence.sh` against a test space.
- Add reproducible examples to docs when you change flows; prefer small fixture projects under `/tmp` when manually exercising setup/sync scripts.

## Commit & Pull Request Guidelines
- Branch names: `feature/...`, `fix/...`, `docs/...`, `refactor/...`, `test/...`. Commits use Conventional Commit prefixes (`feat:`, `fix:`, `docs:`, `chore:`).
- Always update `CHANGELOG.md` under `## [Unreleased]` and review `README.md` for user-facing adjustments; run the version validator before opening a PR.
- Include PR descriptions with what/why, linked issues, and screenshots or sample outputs when relevant. Keep changes atomic and ensure docs (including `docs/HUB-SYNC-CHECKLIST.md` if hub-facing) stay in sync.
