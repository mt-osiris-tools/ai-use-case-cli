# Changelog

All notable changes to the AI Use Case CLI project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
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

[Unreleased]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.2.0...HEAD
[2.2.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.1.1...v2.2.0
[2.1.1]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/mt-osiris-tools/ai-use-case-cli/releases/tag/v1.0.0
