#!/bin/bash
# AI Use Case CLI - Version Configuration
# Single source of truth for CLI version
#
# This file should be sourced by all scripts that need version information.
# When bumping the version, only update this file - all scripts will automatically
# use the new version.
#
# Version Format: MAJOR.MINOR.PATCH
# - MAJOR: Breaking changes (X.0.0)
# - MINOR: New features (0.X.0)
# - PATCH: Bug fixes (0.0.X)
#
# To bump version:
# 1. Update CLI_VERSION below
# 2. Update CHANGELOG.md with changes
# 3. Test all commands (ai-use-case --version, sync, etc.)
# 4. Commit with message: "chore: bump version to X.Y.Z"

# Current CLI version
export CLI_VERSION="3.12.0"

# Version history (for reference)
# 3.11.0 - 2025-12-07 - Template-based docs, AI-tool-agnostic refactoring, PR #135 integration
# 3.10.0 - 2025-12-01 - Claude Agent usage tracking
# 3.9.1 - 2025-11-15 - Fix JSON parsing and script permissions
# 3.9.0 - 2025-11-13 - Development git hooks installer
# 3.8.0 - 2025-11-13 - Command-specific progress tracking
# 3.7.1 - 2025-11-10 - Fix extract-session-data SIGPIPE handling
# 3.7.0 - 2025-11-10 - Reset command and critical tracing fixes
# 3.6.0 - 2025-11-09 - Distributed tracing system
# 3.5.0 - 2025-11-09 - Backup cleanup utility
# 3.4.3 - 2025-11-09 - Force refresh slash commands during project updates
# 3.4.2 - 2025-11-08 - Optimize CLAUDE.md token usage (split into WORKFLOW.md, COMMANDS.md)
# 3.4.1 - 2025-11-08 - Fix version references + add version update checklist
# 3.4.0 - 2025-11-08 - Interactive session selection for documentation
# 3.3.0 - 2025-11-07 - Refactor folder structure (.usecase/cases)
# 3.2.1 - 2025-11-06 - Fix CLI version detection bug, add auto-confirm flag
# 3.2.0 - 2025-11-06 - Optional hub repository (local, private-git modes)
# 3.1.1 - 2025-11-03 - Fixed version display in sync script
# 3.1.0 - 2025-11-02 - Hybrid CLI + Project Registry
# 3.0.0 - 2025-11-02 - Claude Code integration
# 2.3.0 - Previous standalone CLI version
