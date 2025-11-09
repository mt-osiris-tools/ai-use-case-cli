# Changelog

All notable changes to the AI Use Case CLI project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Session Data Extraction**: New `ai-use-case extract` command and `/use-case:extract-session` slash command
  - Extracts comprehensive session data from git history and file system
  - **Token usage tracking**: Capture input/output tokens, context size, cache hits, and estimated costs
  - **Multiple output formats**: JSON (structured data) or Markdown (human-readable reports)
  - Calculates metrics: commits, files changed, lines added/removed, duration, interactions
  - Automatic capture from Claude Code conversations when available
  - Manual input via `--token-*` flags for standalone use
  - Designed to support automated use case documentation and ROI reporting
  - Script location: `scripts/core/extract-session-data.sh`
  - Examples:
    - `ai-use-case extract 8 json --token-input 95000 --token-output 9687 --cost 0.43`
    - `ai-use-case extract 24 markdown -o session-report.md`

## [3.3.0] - 2025-11-07

### Changed

- **Folder Structure Refactoring**: Consolidated use case documentation into dedicated `.usecase/` directory
  - Use cases now stored in `.usecase/cases/` instead of `docs/ai-use-cases/`
  - Cleaner separation of use case documentation from project documentation
  - Simplified path structure (reduced nesting)
  - Claude commands remain in `.claude/commands/use-case/` for consistency
  - All documentation, scripts, and slash commands updated to use new paths
  - Project registry default path updated to `.usecase/cases`

### Added

- **Automatic Migration**: Setup script automatically migrates existing `docs/ai-use-cases/` to new structure
  - Detects old structure and prompts for migration during `ai-use-case --init`
  - Preserves all existing use case files
  - Updates `.gitignore` to exclude `.usecase/cases/` instead of old path
  - Backward compatibility in sync script warns users to migrate

- **Hub Configuration Command**: New `ai-use-case config` command for managing hub settings
  - `ai-use-case config show` - Display current hub configuration
  - `ai-use-case config reconfigure` - Interactively change hub mode (local/private)
  - Provides confirmation prompt before replacing existing configuration
  - Cleaner alternative to manually deleting config file

- **Restored ASCII Art Banner**: Brought back the classic installation banner
  - Replaced compact box design with original ASCII art project logo (displays "AI USE-CASE" for visual emphasis; official name remains `ai-use-case-cli`)
  - More visually distinctive and memorable
  - Maintains professional appearance with clear version information
  - Tagline: "Reduce documentation overhead, build knowledge"

### Removed

- **Shared hub option**: Hub configuration now offers only two modes for better privacy control
  - Local only mode (default) - No git, files stored locally
  - Private git mode - Connect to your own repository
  - Removes dependency on external shared repository
  - Users maintain full control over their documentation storage

## [3.2.1] - 2025-11-06

### Fixed

- **CLI Version Detection**: Fixed bug where project management scripts couldn't detect CLI version
  - `update-project.sh`, `list-projects.sh`, and `check-updates.sh` now correctly resolve CLI_ROOT
  - Previously showed "unknown" for CLI version, now displays actual version (e.g., 3.2.1)
  - Fixed by defining CLI_ROOT as parent directory of scripts directory
  - Affects: `scripts/project/update-project.sh:19,100`, `scripts/project/list-projects.sh:19`, `scripts/project/check-updates.sh:19,61`

### Added

- **Auto-confirm flag for update-project**: New `-y/--yes` flag to skip confirmation prompt
  - Enables non-interactive updates for automation and batch operations
  - Usage: `bash update-project.sh -y /path/to/project`
  - Useful for updating multiple projects in a loop
  - Example: `for p in $(check-updates.sh --paths-only); do update-project.sh -y "$p"; done`

## [3.2.0] - 2025-11-06

### Added

- **Optional Hub Repository Configuration**: Two flexible hub modes for documentation storage
  - **Local Only Mode**: Store files locally without git (no version control)
    - Files stored in `~/.local/share/ai-use-case-cli/hub/`
    - No git operations, no remote sync
    - Best for personal use and quick local documentation
    - Default mode for better privacy
  - **Private Git Mode**: Connect to your own private repository
    - Configure custom git repository URL during setup
    - Full version control with your chosen remote
    - Best for private team documentation and company-internal use
  - Configuration stored in `~/.config/ai-use-case-cli/config.json`
  - Interactive mode selection during first setup (`ai-use-case --init`)
  - New utility scripts: `config-manager.sh` and `hub-utils.sh`
  - Environment variable override still supported (`AI_USECASES_DIR`)
  - Users maintain full control over their documentation storage

- **Automated Version Bump System**: Fully automated version management with single command
  - `ai-use-case bump-version [major|minor|patch]` - automated version bumping
  - Automatically updates version.sh and CHANGELOG.md
  - Creates git commit with conventional commit message
  - Creates git tag (vX.Y.Z) for GitHub releases
  - Pushes to remote automatically
  - Supports dry-run, no-commit, no-tag, no-push options
  - Interactive confirmation prompts (can be skipped with --yes for CI/CD)
  - Detailed help with `ai-use-case bump-version --help`
  - Updated VERSION-MANAGEMENT.md with automated workflow documentation

- **Consolidated Templates into CLI**: Moved TEMPLATE.md and TEMPLATE-RESEARCH.md from hub repository to CLI docs/ directory
  - Establishes CLI as single source of truth for documentation structure
  - Templates now version-controlled with the tool that uses them
  - Slash command explicitly reads templates before generating documentation
  - Added header comments identifying templates as authoritative source
  - Updated documentation references across codebase to point to CLI templates
  - Interactive script now dynamically selects template based on session type (implementation vs research)

- **Centralized Version Management**: Introduced `version.sh` as single source of truth for CLI version
  - All scripts now source version from `version.sh` instead of hardcoding
  - Eliminates version drift across scripts
  - Simplifies version bumps - update one file instead of multiple
  - Includes version history and bump instructions in comments

### Changed

- **Hub setup and sync operations** now support all three hub modes
  - `setup-project.sh`: Prompts for hub mode selection on first run
  - `sync-ai-use-cases.sh`: Skips git operations in local-only mode
  - `push-hub.sh`: Warns users when in local-only mode
  - All hub-dependent scripts now use `hub-utils.sh` for consistency
  - Removed duplicate `ensure_hub_exists()` functions across scripts

- **Restructured bash scripts into organized directories**: Improved project organization and maintainability
  - Created logical directory structure under `scripts/`:
    - `core/` - Core functionality (document, sync, publish)
    - `project/` - Project management (setup, registry, updates)
    - `search/` - Search and analytics (search, stats)
    - `hub/` - Hub operations (view, push)
    - `install/` - Installation scripts
    - `utils/` - Utility scripts (version, bump-version, config-manager, hub-utils)
  - Updated all script paths in main CLI, install script, and cross-references
  - Updated documentation (README.md, CLAUDE.md) to reflect new structure
  - Benefits: Better organization, easier navigation, cleaner structure, better scalability

- **Streamlined README.md**: Major improvements for better usability and clarity
  - Consolidated command documentation into single comparison table (CLI vs Claude Code)
  - Removed redundant sections (file structure, verbose migration guide, direct script access)
  - Simplified session types and configuration sections
  - Fixed version inconsistency (footer now matches v3.1.0)
  - Reduced from 588 to 307 lines while maintaining all essential information
  - More scannable and user-focused structure
  - Moved developer-specific content to appropriate documentation files

- **Updated version retrieval in all scripts**:
  - `ai-use-case`: Sources `version.sh` for VERSION variable
  - `sync-ai-use-cases.sh`: Sources `version.sh` for display banner
  - `registry-manager.sh`: `get_cli_version()` now reads from `version.sh`
  - `document-ai-session.sh`: Updated local and remote version checks to use `version.sh`
  - `install.sh`: Updated remote and installed version checks to use `version.sh`
- Remote version checks now fetch `version.sh` instead of grepping `ai-use-case`
- All version display messages now use `$CLI_VERSION` variable

### Fixed

- **Template Path Resolution**: Updated `document-ai-session.sh` to reference templates from CLI docs/ directory
  - Changed from `$CENTRAL_DIR/TEMPLATE.md` (hub) to `$SCRIPT_DIR/docs/TEMPLATE.md` (CLI)
  - Ensures interactive documentation mode uses same template source as automatic mode
  - Addresses PR feedback about template location inconsistency

- Prevents future version inconsistencies like the v2.3.0 issue in sync script
- Makes version management more maintainable and less error-prone

### Removed

- **VS Code Extension**: Removed `vscode-extension/` directory to simplify project scope
  - Extension was at v2.2.0 and not actively maintained
  - Claude Code slash commands (`/use-case:*`) provide better AI-context-aware documentation
  - Simplifies version management and reduces maintenance burden
  - Users should migrate to Claude Code slash commands for best experience

## [3.1.1] - 2025-11-03

### Fixed

- Updated version display in `sync-ai-use-cases.sh` from v2.3.0/v2.0 to v3.1.1 for consistency with main CLI version

## [3.1.0] - 2025-11-02

### 🎉 Major Update: Hybrid CLI + Claude Code Interface

**Standalone CLI commands are back!** v3.1.0 restores all standalone bash commands while maintaining Claude Code integration, giving you the flexibility to choose your preferred workflow.

### Added

- **Restored Standalone CLI Commands**: All v2.x commands work again!
  - `ai-use-case --init` - Setup current project
  - `ai-use-case sync` - Sync use cases to hub
  - `ai-use-case search <term>` - Search documented use cases
  - `ai-use-case list` - List all registered projects
  - `ai-use-case stats` - View statistics
  - `ai-use-case view` - Open hub directory
  - `ai-use-case push` - Push hub changes
  - `ai-use-case publish-confluence` - Publish to Confluence
  - `ai-use-case uninstall` - Uninstall the CLI
  - `ai-use-case list-projects` - List projects with versions
  - `ai-use-case check-updates` - Check for updates
  - `ai-use-case update-project <path>` - Update project

- **Project Registry System**: Track all projects using the CLI tool
  - `registry-manager.sh` - Core registry management functions
  - `~/.local/share/ai-use-case-cli/projects-registry.json` - Registry database
  - Automatic project registration during setup
  - Track CLI version per project
  - Track installation and update timestamps

- **New Commands for Registry Management**:
  - `list-projects.sh` - Enhanced to show both hub and registry information with version status
  - `check-updates.sh` - Identify projects with outdated CLI versions
  - `update-project.sh` - Update a specific project to the latest CLI version

- **New Claude Code Slash Commands**:
  - `/use-case:list-projects` - View all registered projects with version information
  - `/use-case:check-updates` - Check which projects need CLI updates
  - `/use-case:update-project` - Update a project to latest CLI version

### Changed

- **Complete rewrite of `ai-use-case` CLI**: Hybrid approach supporting both standalone and Claude Code workflows
  - Proper symlink resolution for global `ai-use-case` command
  - Clean, aligned UI with consistent box borders
  - Helpful notices directing users to Claude Code for documentation features
- `setup-project.sh` now automatically registers projects in the registry
- `list-projects.sh` enhanced to show registry data alongside hub information
- Project updates now tracked with timestamps for audit trail
- Updated `install.sh` to reflect hybrid approach
- Updated all documentation (README.md, CLAUDE.md) to show both CLI and slash commands

### Fixed

- Symlink resolution: Commands now work correctly from any directory
- Border alignment in help messages and notices
- Path resolution for scripts when called via symlink

### Benefits

- ✅ **Flexibility**: Choose between fast CLI commands or AI-assisted documentation
- ✅ **Backward compatibility**: All v2.x commands work again
- ✅ **Best of both worlds**: Standalone utility + Claude Code integration
- Easily identify which projects are using the CLI
- Track CLI version across multiple projects
- Simplify bulk updates when new CLI versions are released
- Maintain audit trail of project setup and updates
- Enable better project lifecycle management

## [3.0.0] - 2025-11-02

### 🚨 BREAKING CHANGES

- **Removed standalone CLI commands**: The tool now exclusively uses Claude Code slash commands
  - Removed: `ai-use-case document`, `ai-use-case sync`, `ai-use-case init`, etc.
  - Use instead: `/use-case:document-session`, `/use-case:sync-usecases`, `/use-case:setup-project`, etc.
  - The `ai-use-case` command now shows a deprecation notice and available slash commands
  - Direct script access still available for advanced users (see `ai-use-case --help`)

### Added

- **New shell scripts** for direct access to functionality:
  - `search-use-cases.sh` - Search use cases by keyword
  - `stats-use-cases.sh` - Show statistics about use cases
  - `list-projects.sh` - List all projects with use cases
  - `view-hub.sh` - Open hub directory in file explorer
  - `push-hub.sh` - Commit and push hub changes
- **Updated slash commands** to call scripts directly instead of CLI commands
- **Comprehensive deprecation notice** explaining the migration to slash commands

### Changed

- Simplified `ai-use-case` to only show help, version, and deprecation notices
- Updated all slash command documentation to reference scripts directly
- Improved integration with Claude Code workflow

### Migration Guide

**Before (v2.x):**
```bash
ai-use-case document
ai-use-case sync
ai-use-case search authentication
```

**After (v3.x) - Use in Claude Code:**
```
/use-case:document-session
/use-case:sync-usecases
/use-case:search-usecases
```

For advanced users who need direct script access:
```bash
bash ~/.local/share/ai-use-case-cli/document-ai-session.sh
bash ~/.local/share/ai-use-case-cli/sync-ai-use-cases.sh
bash ~/.local/share/ai-use-case-cli/search-use-cases.sh authentication
```

## [2.5.0] - 2025-11-02

### Added
- **Update command**: New `ai-use-case update` command for simplified CLI updates
  - Automatically checks for and installs the latest version from GitHub
  - Shows current vs. latest version comparison
  - Displays recent changes from CHANGELOG before updating
  - Supports `--check` flag to only check for updates without installing
  - Supports `--yes` flag to skip confirmation prompt (useful for automation)
  - Validates git installation and checks for local modifications
  - Clears version check cache after successful update
  - Provides clear error messages and fallback to manual update instructions
  - Replaces manual `cd ~/.local/share/ai-use-case-cli && git pull` process

## [2.4.0] - 2025-11-02

### Added
- **Enhanced documentation templates** (in hub repository):
  - Added comprehensive Token Usage Summary section with input/output tokens and cache hits
  - Added detailed token breakdown tables by phase (analysis, implementation, testing, documentation)
  - Added interaction breakdown by phase with average tokens
  - Added ROI calculations for cost efficiency analysis
  - Enhanced both TEMPLATE.md and TEMPLATE-RESEARCH.md
- **Interactive metrics collection** (in document-ai-session.sh):
  - Added prompts for total interactions count
  - Added prompts for user prompts/messages sent
  - Added prompts for token usage (input, output, total) - optional fields
  - Added prompts for estimated costs - optional field
  - Automatically integrates collected metrics into generated documentation

### Changed
- **Better metrics organization**: Moved token metrics earlier in templates for prominence

## [2.3.0] - 2025-11-01

### Added
- **Detailed version command**: New `ai-use-case version` command for comprehensive version verification
  - Shows current version, installation directory, and git information
  - Displays last update check time
  - Actively checks for updates from GitHub repository
  - Provides update instructions if newer version is available
  - Complements existing `--version`/`-v` flag for quick version check
  - Useful for troubleshooting and verifying installation status
- **Improved CLAUDE.md**: Restructured root CLAUDE.md as concise quick reference guide
  - Critical requirements upfront (branch workflow, version management)
  - Pre-PR checklist and common patterns
  - Clear guardrails and references to detailed documentation
- **ISO 8601 week numbers**: Added week numbers to file naming convention
  - New format: YYYY-Www-MM-DD_TICKET-XXX_description.md
  - Better temporal organization with ISO 8601 week format (W01-W53)
  - Maintains chronological sort order
  - Updated all scripts and documentation

### Changed
- **Compact installation banner**: Reduced banner from 13 lines to 5 lines
  - Removed large ASCII art for cleaner display
  - Shows only essential info: name, version, description
  - More professional and space-efficient

---

**Note**: The following section contains previously documented unreleased changes that remain pending future releases.

### Added
- **Enhanced documentation templates in hub repository**: Templates now include comprehensive AI interaction metrics
  - Added AI Interaction Metrics section (prompts, success rates, tool usage)
  - Added Key User Queries section for query tracking (optional but recommended)
  - Added Query Effectiveness Analysis for research sessions
  - Enhanced Time Analysis with detailed breakdowns
  - Improved Code Quality Metrics section
  - Links to AI_SESSION_STATISTICS_GUIDE.md and CAPTURING_USER_QUERIES.md for detailed guidance
  - Week number added to date fields for better temporal organization
  - Supports prompt quality analysis and learning patterns
  - Hub PR: https://github.com/mt-osiris-tools/ai-use-case-hub/pull/2
- **Version check for document command**: CLI now verifies it's up-to-date before documenting sessions
  - Checks for updates when running `ai-use-case document` or `/use-case/document-session`
  - Warns users if newer version available with update instructions
  - Prompts to continue or update first (interactive mode)
  - **Handles non-interactive contexts** (CI/CD, piped commands, automation):
    - Detects non-interactive terminal using `[ -t 0 ]` check
    - Continues automatically with warning in non-interactive mode
    - No blocking prompts that would fail automation
  - **Automation support**: `--skip-version-check` flag to skip check entirely
  - Ensures users document with latest features and bug fixes
  - Prevents issues from outdated CLI versions during documentation
  - Gracefully handles network failures (continues with current version)

### Changed
- **Claude Code command organization**: Improved command directory structure
  - Commands now organized in `.claude/commands/use-case/` subdirectory
  - Cleaner command invocation: `/use-case/document-session` instead of `/use-case:document-session`
  - Better separation and discoverability of related commands
  - Updated setup-project.sh to install commands in new location
  - Updated all documentation to reflect new command paths
- **Hub git tracking architecture**: Documentation updated to clarify version control behavior
  - `by-project/` directories are tracked in git (canonical storage)
  - `by-date/` and `by-topic/` symlinks excluded via .gitignore (view layer only)
  - Updated hub repository `.gitignore` in v2.1.0+ to explicitly track `by-project/` subdirectories
    - Previously, a broad ignore rule excluded these directories unintentionally
    - Now, all project documentation is versioned as intended
  - README.md and CLAUDE.md updated with git tracking clarifications
- **Installation banner**: Improved installation banner messaging for better professionalism
  - Removed organization-specific branding
  - Updated tagline to be clearer and more concise
  - Removed emoji for cleaner appearance
  - Better suited for open-source project
- **Installation command list**: Now shows all 10 available commands instead of 6
  - Added: push, publish-confluence, view, list
  - Users now see complete CLI capabilities immediately after installation
  - Fixed alignment using printf formatting for professional appearance

### Added
- **Auto-update check for --init command**: Ensures users always run setup with the latest version
  - Checks for updates before running `ai-use-case --init`
  - Prompts user to update if newer version available
  - Automatically restarts with updated version after successful update
  - Critical for ensuring projects are set up with latest features and fixes
- **GitHub Copilot instructions**: Added `.github/copilot-instructions.md` for GitHub Copilot guidance
  - Provides repository context and architecture constraints for Copilot
  - Documents required workflow (branch naming, conventional commits, CHANGELOG updates)
  - Includes CLI scripts, VS Code extension, and documentation generation guidance
  - Ensures Copilot contributions align with team standards and workflows
  - Complements existing CLAUDE.md for AI assistant guidance
- **Hub-CLI Synchronization Checklist**: Comprehensive guide for maintaining consistency between repositories
  - HUB-SYNC-CHECKLIST.md with complete validation process
  - When to review hub repository (templates, workflows, naming, features, tickets)
  - 5-step validation checklist (identify, review, update, version, test)
  - Practical example using research session support (v2.2.0)
  - Quick reference with bash commands for common update patterns
  - Troubleshooting section for common synchronization issues
  - Automation opportunities for future enhancements
  - Hub-CLI Synchronization section added to CLAUDE.md
- **Pre-commit hook for branch protection**: Prevents direct commits to main/master branches
  - Installed automatically by `setup-project.sh` in all projects using the CLI
  - Blocks commits to protected branches with clear error message
  - Provides guidance on creating feature branches with conventional naming
  - Shows branch naming conventions (feature/, fix/, docs/, refactor/, test/)
  - Can be bypassed with `--no-verify` flag in exceptional cases
  - Enforces branch-based workflow across all projects using the CLI
- **Branch-based development workflow**: All changes now require pull requests
  - CONTRIBUTING.md with comprehensive contribution guidelines
  - Branch naming conventions (feature/, fix/, docs/, refactor/, test/)
  - PR requirements checklist (CHANGELOG, testing, documentation)
  - Conventional commit message guidelines
- BRANCH-PROTECTION-SETUP.md with step-by-step GitHub configuration guide
- Development workflow section in CLAUDE.md for AI assistant guidance
- Automated PR workflow for Claude Code with approval prompts

### Changed
- **Documentation structure**: Reorganized project documentation following GitHub best practices
  - Moved project-specific docs to `docs/` directory
  - Kept community standards at root (README.md, CHANGELOG.md, CONTRIBUTING.md)
  - Updated all references and internal links
  - Files moved: CLAUDE.md, HUB-SYNC-CHECKLIST.md, HUB-FILES.md, BRANCH-PROTECTION-SETUP.md, CONFLUENCE-DESIGN.md
- **Slash command organization**: Reorganized commands with `use-case:` namespace prefix
  - Improved command organization with clear namespacing using colon syntax
  - Commands now use `/use-case:` prefix (e.g., `/use-case:document-session`)
  - More conventional syntax compared to slash-based paths
  - All related commands logically grouped for better discoverability
  - Updated documentation across CLAUDE.md, setup-project.sh, and command files
- `setup-project.sh` now installs both pre-commit and post-commit hooks
- Updated README.md with branch protection documentation
- Updated CLAUDE.md to document pre-commit hook functionality
- Enhanced Git Hook Templates section with pre-commit hook details
- Updated troubleshooting section to include both hooks
- README.md Contributing section updated to reference new guidelines
- Enhanced CLAUDE.md with mandatory branch/PR workflow for AI assistants
- Repository now requires PR-based workflow (no direct commits to main)

## [2.2.0] - 2025-10-20

### Added
- **Research session support**: Document exploratory AI sessions without code changes
  - New session type selection in interactive mode (Implementation vs Research)
  - Auto-generated `RESEARCH-XXX` ticket numbering for research sessions
  - Research-specific template with 🔬 icon (vs 🎯 for implementation)
  - Query evolution tracking through conversation iterations
  - Approach evaluation with pros/cons comparison
  - Decision documentation with rationale and implementation guidance
- Research session fields: initial query, iterations, insights, approaches evaluated, final decision
- Automatic session type detection in Claude Code `/use-case:document-session` command
- Research session examples in README and CLAUDE.md
- Comprehensive research session documentation workflow

### Changed
- `document-ai-session.sh` now supports both implementation and research session types
- File naming convention expanded to include `RESEARCH-XXX` format
- `/use-case:document-session` slash command updated to handle research sessions automatically
- CLAUDE.md updated with research session guidance for AI assistants
- README.md enhanced with session types section and examples

### Improved
- Better separation of concerns between code-focused and exploration-focused sessions
- More flexible documentation workflow accommodating different AI interaction patterns
- Enhanced template system with dual templates for different session types

## [2.1.1] - 2025-10-14

### Added
- Version display in install script banner showing current vs. new version
- Automatic version detection from GitHub in install script
- Smart update prompt when outdated version is detected
- Automatic `git pull` for seamless updates when running install script

### Changed
- Install script now offers to update instead of showing "Installation cancelled"
- Update prompt defaults to Yes for better user experience
- Install script provides clear messaging about version status

### Fixed
- Users no longer stuck when running install script with existing installation
- Better handling of various installation scenarios (git repo, non-git, missing versions)

## [2.1.0] - 2025-10-14

### Added
- Unified CLI interface with `ai-use-case` command
- Automatic version checking (once per 24 hours)
- Update notifications with instructions
- `push` command for manual hub synchronization
- `publish-confluence` command for publishing to Atlassian Confluence
- Confluence MCP integration for seamless wiki publishing
- Non-blocking background version checks

### Changed
- Separated CLI tools from documentation hub repository
- Sync command now automatically commits and pushes to hub remote
- Improved error messages and user feedback
- Enhanced documentation in CLAUDE.md and README.md

### Fixed
- Hub repository auto-cloning when not present
- Path resolution for symlinked installations
- Git push confirmation prompts

## [2.0.0] - 2025-10-13

### Added
- Symlink-based architecture in hub repository
- `by-date/` organization (YYYY/MM/ structure)
- `by-topic/` organization (topic slug structure)
- `by-project/` canonical storage
- Post-commit git hook for automatic sync
- VS Code extension for one-click documentation
- Interactive `document-ai-session.sh` script

### Changed
- Complete restructure of hub organization
- Moved from flat structure to multi-view symlink system
- Enhanced template with comprehensive sections

### Removed
- Flat directory structure in hub

## [1.0.0] - 2025-10-10

### Added
- Initial release of AI Use Case CLI
- Basic `sync-ai-use-cases.sh` script
- Project setup functionality
- Simple documentation workflow
- Git integration for tracking AI sessions
- Basic template for use case documentation

[Unreleased]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.3.0...HEAD
[2.3.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.1.1...v2.2.0
[2.1.1]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/releases/tag/v1.0.0
