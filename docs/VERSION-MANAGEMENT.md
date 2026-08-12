# Version Management Guide

This document describes how to properly version the AI Use Case CLI following semantic versioning principles.

**⚠️ IMPORTANT**: Before updating any version, see **[VERSION-UPDATE-CHECKLIST.md](./VERSION-UPDATE-CHECKLIST.md)** for a comprehensive checklist of ALL files that must be updated to prevent version inconsistencies.

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

## Controlled Release Workflow (Recommended)

The release workflow separates preparing a release from publishing it. Version changes are reviewed through a PR, and only a merged commit on `main` can receive a release tag.

### Quick Start

```bash
# Prepare a patch release on a release/* branch
ai-use-case release prepare patch

# Prepare a minor release
ai-use-case release prepare minor

# Prepare a major release
ai-use-case release prepare major

# Prepare a specific version
ai-use-case release prepare 3.14.0

# Preview changes without applying
ai-use-case bump-version patch --dry-run

# After the PR is merged to main, validate and publish the tag
ai-use-case release publish 3.14.0
```

### What It Does Automatically

`release prepare` updates:

1. ✅ **Parses current version** from `version.sh`
2. ✅ **Calculates new version** based on bump type
3. ✅ **Updates version.sh** with new version
4. ✅ **Updates CHANGELOG.md** (moves Unreleased to versioned section with date)
5. ✅ Leaves commit, tag, and push operations to the reviewed release workflow

`release publish` runs strict validation and the full test suite in compact mode, creates the annotated tag, and pushes it. If validation or tests fail, their complete diagnostics are printed. The tag-triggered GitHub Actions workflow creates a draft GitHub Release.

The underlying commands remain verbose by default. Use `./scripts/utils/validate-versions.sh --quiet` or `./run-tests.sh --quiet` when a summary-only result is preferred.

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
  --no-commit     Update files but don't commit (default)
  --no-tag        Don't create git tag (default)
  --no-push       Don't push to remote (default)
  --yes, -y       Skip confirmations (for CI/CD)
  --help, -h      Show detailed help
```

### Examples

#### Standard Release (Patch)
```bash
# Prepare from a release branch
ai-use-case release prepare patch
# Commit and open the release PR; publish the tag after merge
ai-use-case release publish 3.13.1
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

# Metadata-only compatibility command (the safe default)
ai-use-case bump-version minor
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

### 2. Update CHANGELOG.md

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

### 3. Test the Version

```bash
./ai-use-case --version
./sync-ai-use-cases.sh --help | head -1
```

### 4. Commit the Release PR

```bash
git add lib/core/version.sh README.md CHANGELOG.md
git commit -m "chore: bump version to 3.3.0"
git push -u origin release/v3.3.0

# After the PR is merged:
ai-use-case release publish 3.3.0
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
2. Added new `export` command
3. New version: `2.4.0`
4. Update both files
5. Commit: `chore: Bump version to 2.4.0`
6. Publish: `ai-use-case release publish 2.4.0`

### Example: Fixing a Bug (Patch)

1. Current version: `2.4.0`
2. Fixed sync command error handling
3. New version: `2.4.1`
4. Update both files
5. Commit: `chore: Bump version to 2.4.1`
6. Publish: `ai-use-case release publish 2.4.1`

### Example: Breaking Change (Major)

1. Current version: `2.4.1`
2. Removed deprecated `legacy-sync` command
3. New version: `3.0.0`
4. Update both files (document breaking changes clearly)
5. Commit: `chore: Bump version to 3.0.0`
6. Publish: `ai-use-case release publish 3.0.0`

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
ai-use-case update --check # Check for an update without installing it
ai-use-case update --dry-run # Preview an available update
```

The `update` command:
- Checks for the latest version from GitHub
- Shows recent changes from CHANGELOG
- Automatically installs the update with confirmation
- Supports `--check` flag to only check without installing
- Supports `--dry-run` flag to preview the update without installing
- Supports `--yes` flag to skip confirmation (useful for automation)

Manual update method (if needed):

```bash
cd ~/.local/share/ai-use-case-cli
git pull
```
