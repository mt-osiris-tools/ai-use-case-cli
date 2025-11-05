# Version Management Guide

This document describes how to properly version the AI Use Case CLI following semantic versioning principles.

## Semantic Versioning

The project follows [Semantic Versioning 2.0.0](https://semver.org/):

```
MAJOR.MINOR.PATCH (e.g., 3.2.0)
```

### Version Increment Rules

- **MAJOR** (X.0.0): Breaking changes that are not backward compatible
  - Examples: Removing commands, changing command behavior, incompatible API changes

- **MINOR** (0.X.0): New features in a backward compatible manner
  - Examples: Adding new commands, new optional parameters, new functionality

- **PATCH** (0.0.X): Backward compatible bug fixes
  - Examples: Fixing bugs, improving error messages, documentation updates

## Automated Version Bump (Recommended)

**Since v3.2.0**, the CLI includes an automated version bump system that handles everything for you.

### Quick Start

```bash
# Bump patch version (3.2.0 -> 3.2.1)
ai-use-case bump-version patch

# Bump minor version (3.2.0 -> 3.3.0)
ai-use-case bump-version minor

# Bump major version (3.2.0 -> 4.0.0)
ai-use-case bump-version major

# Set specific version
ai-use-case bump-version 3.5.0

# Preview changes without applying
ai-use-case bump-version patch --dry-run
```

### What It Does Automatically

The `bump-version` command handles the entire release process:

1. ✅ **Parses current version** from `version.sh`
2. ✅ **Calculates new version** based on bump type
3. ✅ **Updates version.sh** with new version
4. ✅ **Updates README.md** with new version badge
5. ✅ **Updates CHANGELOG.md** (moves Unreleased to versioned section with date)
6. ✅ **Creates git commit** with conventional commit message
7. ✅ **Creates git tag** (vX.Y.Z)
8. ✅ **Pushes to remote** with tags

### Command Options

```bash
ai-use-case bump-version <type> [options]

Types:
  major           Bump major version (X.0.0)
  minor           Bump minor version (0.X.0)
  patch           Bump patch version (0.0.X)
  X.Y.Z           Set specific version

Options:
  --dry-run       Preview changes without applying
  --no-commit     Update files but don't commit
  --no-tag        Don't create git tag
  --no-push       Don't push to remote
  --yes, -y       Skip confirmations (for CI/CD)
  --help, -h      Show detailed help
```

### Examples

#### Standard Release (Patch)
```bash
# Bump from 3.2.0 to 3.2.1
ai-use-case bump-version patch
# Automatically commits, tags, and pushes
```

#### Preview Changes First
```bash
# See what will change without applying
ai-use-case bump-version minor --dry-run

# Apply after reviewing
ai-use-case bump-version minor
```

#### Manual Control
```bash
# Update files only, commit manually later
ai-use-case bump-version patch --no-commit

# Bump and commit, but don't push yet
ai-use-case bump-version minor --no-push
```

#### CI/CD Automation
```bash
# Skip confirmation prompts
ai-use-case bump-version patch --yes
```

### Verification

After bumping, verify the changes:

```bash
# Check version display
ai-use-case --version
# Should show: ai-use-case version 3.3.0

# View commit
git log -1

# Check tag was created
git tag -l v3.3.0

# Verify all scripts use new version
./sync-ai-use-cases.sh --help | head -1
# Should show: AI Use Cases Sync Script v3.3.0
```

## Manual Version Bump (Legacy)

If you need to bump the version manually without using the automated tool:

### 1. Update Version in version.sh

Edit `version.sh` (line 21):

```bash
export CLI_VERSION="3.3.0"
```

### 2. Update README.md

Edit `README.md` (line 4) to update the version badge:

```markdown
<h3><em>**v3.3.0** - Document AI-assisted development workflows with ease.</em></h3>
```

### 3. Update CHANGELOG.md

Move Unreleased section to new version:

```markdown
## [Unreleased]

## [3.3.0] - 2025-11-03

### Added
- New feature description

### Changed
- Modified functionality

### Fixed
- Bug fix description
```

### 4. Test the Version

```bash
./ai-use-case --version
./sync-ai-use-cases.sh --help | head -1
```

### 5. Commit and Tag

```bash
git add version.sh README.md CHANGELOG.md
git commit -m "chore: bump version to 3.3.0"
git tag -a v3.3.0 -m "Release version 3.3.0"
git push origin main --tags
```

## Version Verification Commands

The CLI provides two commands to verify the version:

### Quick Version Check

```bash
ai-use-case --version
# or
ai-use-case -v
```

Output: `ai-use-case version 2.3.0`

### Detailed Version Information

```bash
ai-use-case version
```

Shows:
- Current version number
- Installation directory
- Git commit hash and date
- Current branch
- Last update check time
- Checks for updates from GitHub
- Update instructions if available

## Examples

### Example: Adding a New Feature (Minor)

1. Current version: `2.3.0`
2. Added new `backup` command
3. New version: `2.4.0`
4. Update both files
5. Commit: `chore: Bump version to 2.4.0`
6. Tag: `git tag -a v2.4.0 -m "Release version 2.4.0"`

### Example: Fixing a Bug (Patch)

1. Current version: `2.4.0`
2. Fixed sync command error handling
3. New version: `2.4.1`
4. Update both files
5. Commit: `chore: Bump version to 2.4.1`
6. Tag: `git tag -a v2.4.1 -m "Release version 2.4.1"`

### Example: Breaking Change (Major)

1. Current version: `2.4.1`
2. Removed deprecated `legacy-sync` command
3. New version: `3.0.0`
4. Update both files (document breaking changes clearly)
5. Commit: `chore: Bump version to 3.0.0`
6. Tag: `git tag -a v3.0.0 -m "Release version 3.0.0"`

## Common Mistakes

### ❌ Don't

- Don't forget to update CHANGELOG.md
- Don't skip version links at the bottom of CHANGELOG
- Don't commit version bumps with other changes (keep them separate)
- Don't tag before pushing to ensure the tag points to the pushed commit

### ✅ Do

- Update both `ai-use-case` and `CHANGELOG.md` in the same commit
- Use conventional commit messages for version bumps (`chore: Bump version to X.Y.Z`)
- Tag the release commit for GitHub releases
- Test the version commands before committing

## Automated Version Checking

The CLI automatically checks for updates once every 24 hours when commands are run. The version check:

- Compares local version with GitHub's main branch
- Shows update notification if newer version available
- Provides update instructions
- Caches check results to avoid excessive network requests

### Checking and Updating

Users can check for updates with:

```bash
ai-use-case version        # Detailed version info with update check
```

To update to the latest version:

```bash
ai-use-case update         # Update CLI to latest version
```

The `update` command:
- Checks for the latest version from GitHub
- Shows recent changes from CHANGELOG
- Automatically installs the update with confirmation
- Supports `--check` flag to only check without installing
- Supports `--yes` flag to skip confirmation (useful for automation)

Manual update method (if needed):

```bash
cd ~/.local/share/ai-use-case-cli
git pull
```
