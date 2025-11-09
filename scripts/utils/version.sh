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
export CLI_VERSION="3.4.1"

# Version history (for reference)
# 3.4.1 - 2025-11-08 - Fix version references + add version update checklist
# 3.4.0 - 2025-11-08 - Interactive session selection for documentation
# 3.3.0 - 2025-11-07 - Refactor folder structure (.usecase/cases)
# 3.2.1 - 2025-11-06 - Fix CLI version detection bug, add auto-confirm flag
# 3.2.0 - 2025-11-06 - Optional hub repository (local, private-git modes)
# 3.1.1 - 2025-11-03 - Fixed version display in sync script
# 3.1.0 - 2025-11-02 - Hybrid CLI + Project Registry
# 3.0.0 - 2025-11-02 - Claude Code integration
# 2.3.0 - Previous standalone CLI version
