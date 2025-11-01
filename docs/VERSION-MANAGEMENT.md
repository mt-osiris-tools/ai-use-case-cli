# Version Management Guide

This document describes how to properly version the AI Use Case CLI following semantic versioning principles.

## Semantic Versioning

The project follows [Semantic Versioning 2.0.0](https://semver.org/):

```
MAJOR.MINOR.PATCH (e.g., 2.3.0)
```

### Version Increment Rules

- **MAJOR** (X.0.0): Breaking changes that are not backward compatible
  - Examples: Removing commands, changing command behavior, incompatible API changes

- **MINOR** (0.X.0): New features in a backward compatible manner
  - Examples: Adding new commands, new optional parameters, new functionality

- **PATCH** (0.0.X): Backward compatible bug fixes
  - Examples: Fixing bugs, improving error messages, documentation updates

## Version Change Checklist

When making changes that require a version bump, follow these steps:

### 1. Update Version Number

Edit `ai-use-case` script (line 73):

```bash
VERSION="X.Y.Z"
```

### 2. Update CHANGELOG.md

Add a new version section following the Keep a Changelog format:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature description with details

### Changed
- Modified functionality description

### Fixed
- Bug fix description
```

### 3. Update Version Links

At the bottom of CHANGELOG.md, update the version comparison links:

```markdown
[Unreleased]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/vX.Y.Z...HEAD
[X.Y.Z]: https://github.com/mt-osiris-tools/ai-use-case-cli/compare/vA.B.C...vX.Y.Z
```

### 4. Test the Version

Verify the version is correct:

```bash
./ai-use-case --version        # Quick version check
./ai-use-case version          # Detailed version info
```

### 5. Commit and Tag

Commit the version changes:

```bash
git add ai-use-case CHANGELOG.md
git commit -m "chore: Bump version to X.Y.Z"
git tag -a vX.Y.Z -m "Release version X.Y.Z"
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

Users can also manually check with:

```bash
ai-use-case version
```

This command always performs a fresh check regardless of cache.
