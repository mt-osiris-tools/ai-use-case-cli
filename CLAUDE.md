# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AI Use Case CLI is a documentation tool for AI-assisted development sessions. It consists of:

- **Core CLI**: Unified `ai-use-case` command for initializing projects, documenting sessions, syncing, and searching
- **Shell scripts**: Modular scripts in `scripts/` for setup, sync, documentation, and publishing
- **Git hooks**: Templates in `git-hooks/` for pre-commit branch protection and post-commit auto-sync
- **Slash commands**: Integration with Claude Code (`.claude/commands/`), GitHub Copilot (`.github/prompts/`), and Codex
- **Library modules**: Shared utilities in `lib/` organized by function (config, core, observability, utils)

**Architecture**: This repository (CLI tools) works with a separate `ai-use-case-hub` repository that serves as central documentation storage with symlink-based organization by project, date, and topic.

## Essential Commands

### Testing
```bash
# Initialize test framework (first time only)
git submodule update --init --recursive

# Run all tests
./run-tests.sh

# Run specific test files
./run-tests.sh version config-manager

# Run with verbose output
./run-tests.sh --verbose

# Run tests matching a pattern
./run-tests.sh --filter "help"

# List available test files
./run-tests.sh --list
```

### Development
```bash
# Manual testing of CLI
./ai-use-case --help
./ai-use-case --version

# Test scripts directly
./scripts/project/setup-project.sh /tmp/test-project
./scripts/core/sync-ai-use-cases.sh /tmp/test-project
./scripts/core/document-ai-session.sh /tmp/test-project

# Validate version consistency (during development)
./scripts/utils/validate-versions.sh --unreleased

# Validate version consistency (before release)
./scripts/utils/validate-versions.sh
```

## Code Architecture

### Repository Structure

```
ai-use-case-cli/
├── ai-use-case              # Main CLI entry point (unified command interface)
├── lib/                     # Shared library modules
│   ├── config/             # Configuration management (hub, features, tracing)
│   ├── core/               # Core utilities (constants, version)
│   ├── observability/      # Tracing and progress tracking
│   └── utils/              # File utilities and helpers
├── scripts/                # Modular shell scripts
│   ├── core/              # Core functionality (document, sync, publish)
│   ├── project/           # Project setup and management
│   ├── hub/               # Hub operations (push, view)
│   ├── agents/            # AI agent management (advanced feature)
│   ├── search/            # Search and statistics
│   ├── install/           # Installation and uninstallation
│   └── utils/             # Utility scripts (version, config, reset)
├── git-hooks/             # Git hook templates
├── templates/             # Documentation templates
└── tests/                 # Bats test suite
```

### Main CLI Flow

1. **Entry point**: `ai-use-case` script handles all commands
2. **Configuration**: Sources `lib/` modules for constants, colors, and utilities
3. **Tracing**: Optional OpenTelemetry instrumentation via `lib/observability/tracing.sh`
4. **Command routing**: Routes to appropriate `scripts/` based on command
5. **Feature gating**: Advanced features require `enable-advanced` flag
6. **Hub interaction**: All scripts use `ensure_hub_exists()` function consistently

### Dual-Repository Architecture

**CLI Repository (this repo)**:
- Installation scripts
- CLI commands and shell scripts
- Git hook templates
- Slash command integrations
- Documentation templates

**Hub Repository (separate)**:
- Actual use case documentation files (`.md`)
- Symlink organization (by-project/, by-date/, by-topic/)
- Git-based versioning and sync
- Optional remote git backup

Key principle: CLI tools must **never** merge hub concerns into this repository.

### Configuration System

Configuration stored in `~/.config/ai-use-case-cli/`:
- `config.json` - Hub mode (local/private-git), paths, install mode
- `tracing.json` - OpenTelemetry configuration
- `agents.json` - Agent configurations

Key functions:
- `ensure_hub_exists()` - Validates hub directory before operations
- `is_advanced_enabled()` - Checks if advanced features are enabled
- Hub path: `~/.local/share/ai-use-case-cli/hub` (default) or `$AI_USECASES_DIR`

### Script Patterns

All shell scripts follow these patterns:

```bash
#!/bin/bash
set -euo pipefail  # Robust error handling

# Source required libraries
source "$(dirname "$0")/../lib/core/constants.sh"

# Validate inputs
if [[ -z "${1:-}" ]]; then
    echo "Error: Missing required argument" >&2
    exit 1
fi

# Use hub interaction function
ensure_hub_exists || exit 1

# Provide clear user feedback
echo -e "${GREEN}✓${NC} Operation completed successfully"
```

Key requirements:
- Always use `set -euo pipefail` for new scripts
- Source constants from `lib/core/constants.sh` for colors
- Use `ensure_hub_exists()` before hub operations
- Validate all inputs defensively
- Provide actionable error messages with exit codes (0=success, 1=error, 2=misuse)
- Maintain executable permissions (`chmod +x`)

## Critical Development Rules

### Branch Workflow (NON-NEGOTIABLE)

1. **Never commit directly to main** - Pre-commit hooks enforce this
2. **Branch naming**: `feature/`, `fix/`, `docs/`, `refactor/`, `test/`
3. **Conventional commits**: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
4. **CHANGELOG.md**: MANDATORY update for ALL changes under `## [Unreleased]`
5. **README.md**: MANDATORY review/update if user-facing changes
6. **Testing**: Run `./run-tests.sh` before creating PR
7. **Documentation**: Update relevant docs in `docs/` directory
8. **Pull request**: Always ask user before creating PR

### Version Management

**Source of truth**: `lib/core/version.sh` (line 21: `CLI_VERSION`); `scripts/utils/version.sh` is a compatibility symlink.

When bumping versions, ALL these files must be updated:
- `lib/core/version.sh` - Source of truth
- `README.md` - Header version (line ~4) and footer (line ~392 + date)
- `CHANGELOG.md` - Move Unreleased section to new version section
- `docs/USAGE-GUIDE.md` - Version markers for new commands (e.g., `v3.6.0+`)
- `docs/CONFIGURATION.md` - Version markers for new config options
- `docs/FEATURES.md` - Version markers for new features

**Validation**:
```bash
# During development (allows future version references)
./scripts/utils/validate-versions.sh --unreleased

# Before release (strict mode)
./scripts/utils/validate-versions.sh
```

### Documentation Revision Rule (NON-NEGOTIABLE)

Every code change MUST trigger documentation review:

1. **CHANGELOG.md** - Update for ALL changes (describe what, why, breaking changes)
2. **README.md** - Update for user-facing changes (features, commands, options)
3. **Related docs** - Update if applicable:
   - `docs/USAGE-GUIDE.md` - Usage instructions
   - `docs/CONFIGURATION.md` - Configuration options
   - `docs/FEATURES.md` - Feature descriptions
   - `docs/agents/claude/GUIDE.md` - Developer guide

### Shell Script Standards

- Use `set -euo pipefail` for all new shell scripts
- Check command availability before use:
  ```bash
  if ! command -v git >/dev/null 2>&1; then
      echo "Error: git is required but not installed" >&2
      exit 1
  fi
  ```
- Use descriptive variable names (`hub_directory` not `hd`)
- Document complex functions with purpose, parameters, return values
- Maintain POSIX compatibility for macOS, Linux, and WSL
- Use `ensure_hub_exists()` before hub operations
- Provide clear error messages with suggested solutions

### Security & Safety

- Never expose API tokens or credentials in code/docs
- Validate and sanitize all user inputs to prevent injection
- Maintain proper file permissions (644 files, 755 directories/executables)
- User-scoped installation only (`~/.local/`) - no system-wide changes
- Sanitize logs to remove sensitive information

### Git Hooks

Pre-commit hook: Prevents commits directly to main/master
Post-commit hook: Triggers documentation sync to hub

When modifying hooks:
- Preserve bypass instructions (`git commit --no-verify`)
- Handle PATH issues in hook environment
- Provide clear error messages to guide users
- Test in different git scenarios

## Session Documentation Types

1. **Implementation sessions**: Code changes tied to tickets
   - Format: `YYYY-MM-DD_TICKET-description.md`
   - Template: `docs/TEMPLATE.md`

2. **Research sessions**: Exploratory work without code
   - Format: `YYYY-MM-DD_RESEARCH-description.md`
   - Template: `docs/TEMPLATE-RESEARCH.md`

Documentation workflow:
- AI assistant generates complete documentation (no placeholders/TODOs)
- Post-commit hook auto-syncs to hub repository
- Hub organizes via symlinks (by-project, by-date, by-topic)

## Advanced Features

Gated behind `ai-use-case enable-advanced`:
- `agents` - AI agent management
- `review-quality` - AI-powered documentation review
- `analyze-patterns` - Cross-project pattern analysis
- `extract` - Session data extraction
- `tracing` - OpenTelemetry tracing

Check with `is_advanced_enabled()` function.

## Cross-Platform Compatibility

Must work on:
- Linux (primary development platform)
- macOS
- WSL (Windows Subsystem for Linux)

Requirements:
- Bash 4.0+
- Git
- Standard Unix tools (`realpath`, `find`, `grep`)

Common issues:
- Path handling differences
- Command availability (use `command -v` to check)
- Symlink resolution (`readlink -f` behavior varies)

## Integration Points

### Claude Code
- Slash commands in `.claude/commands/` symlinked to `.ai-tools/commands/`
- Commands: `/use-case:document-session`, `/use-case:sync-usecases`, etc.
- Setup: `ai-use-case --link-claude`

### GitHub Copilot
- Custom prompts in `.github/prompts/` symlinked to `.ai-tools/commands/`
- Setup: `ai-use-case --setup-copilot`

### Codex
- Prompts in `~/.codex/prompts/`
- Setup: `ai-use-case --setup-codex`

### Confluence (Optional)
- Publishing via `publish-confluence.sh`
- Requires MCP Atlassian server
- Uses markdown-to-Confluence conversion

## Testing Strategy

Focus on manual testing due to interactive CLI nature:
1. Test with various inputs and edge cases
2. Verify cross-platform functionality
3. Test hub integration with both existing and new hubs
4. Verify git hooks in different scenarios
5. Test installation/uninstallation in clean environments

Automated tests (Bats framework):
- Located in `tests/` directory
- Run via `./run-tests.sh`
- Use `setup()` and `teardown()` for isolation
- Follow existing patterns

## Common Development Tasks

### Adding a new CLI command

1. Add command handling in `ai-use-case` main script
2. Create script in appropriate `scripts/` subdirectory
3. Use `set -euo pipefail` and source required libs
4. Update `CHANGELOG.md` and `README.md`
5. Add tests in `tests/`
6. Document in `docs/USAGE-GUIDE.md`

### Modifying hub interaction

1. Check `docs/HUB-FILES.md` for hub structure
2. Check `docs/HUB-SYNC-CHECKLIST.md` for sync implications
3. Use `ensure_hub_exists()` consistently
4. Consider impact on both repositories
5. Test with local and private-git hub modes
6. Document migration steps if breaking changes

### Adding a feature flag

1. Update `lib/config/config-features.sh`
2. Add gating logic with `require_advanced()` if needed
3. Update `scripts/utils/config-manager.sh` if new config key
4. Document in `docs/CONFIGURATION.md`
5. Update feature list in help text

## Anti-Patterns to Avoid

**DON'T**:
- Silent failures: `cd "$dir" 2>/dev/null`
- Unclear errors: `echo "Error: Something went wrong"`
- Hard-coded paths: `cp file.txt /home/user/my-dir/`
- Skipping CHANGELOG.md updates
- Committing directly to main
- Using bash echo to communicate with user in code comments
- Leaving placeholder text (TODO, FIXME) in generated documentation
- Merging hub repository concerns into CLI repository

**DO**:
- Robust error handling with `set -euo pipefail`
- Clear, actionable error messages
- User-scoped paths with fallbacks (`${AI_USECASES_DIR:-$HOME/.local/share/ai-use-case-cli/hub}`)
- Update CHANGELOG.md for every change
- Create feature branches and PRs
- Output text directly to communicate with user
- Generate complete documentation with real content
- Maintain separation between CLI tools and hub repository
