# Version Update Checklist

**Purpose**: Ensure all version references are updated consistently across the codebase when releasing a new version.

**⚠️ CRITICAL REMINDER**: The README.md footer is the most commonly forgotten location! It has TWO fields that must BOTH be updated: **Version** AND **Last Updated** date.

## Critical: Version Update Locations

When bumping the version, **ALL** of these files MUST be updated. Missing even one can cause inconsistencies and confusion.

### 1. Source of Truth: `lib/core/version.sh`

**File**: `lib/core/version.sh` (Line 21)

```bash
export CLI_VERSION="X.Y.Z"
```

**Action**: Update the version number
**Note**: This is the single source of truth. `scripts/utils/version.sh` is a compatibility symlink.

---

### 2. User-Facing Documentation: `README.md`

**File**: `README.md`

**Location 1** (Line ~4): Header version badge
```html
<h3><em><strong>vX.Y.Z</strong> - Document AI-assisted development workflows with ease.</em></h3>
```

**Location 2** (Line ~353): Footer version metadata
```markdown
**Version**: X.Y.Z
**Last Updated**: YYYY-MM-DD
```

**Action**: Update both version references AND the last updated date

---

### 3. Change History: `CHANGELOG.md`

**File**: `CHANGELOG.md`

**Location**: Version header section

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added/Changed/Fixed
- Description of changes
```

**Action**:
1. Move items from `## [Unreleased]` to new version section
2. Add release date
3. Document all changes following [Keep a Changelog](https://keepachangelog.com/) format

---

### 4. Developer Guide: `CLAUDE.md`

**File**: `CLAUDE.md`

**Check for**: Version-specific feature documentation

- Feature descriptions that mention version numbers (e.g., "v3.4.0+: Interactive session selection")
- Only update if adding NEW version-specific features
- Keep historical version references intact (they're documentation history)

**Action**: Add version prefix to NEW features only

---

### 5. Installation Script: `scripts/install/install.sh`

**File**: `scripts/install/install.sh`

**Note**: Sources the canonical version module, so no manual update needed

**Action**: No action required (automatically uses `$CLI_VERSION`)

---

## Version Consistency Validation

**NEW in v3.6.0**: Automated version consistency validator

Before releasing, always run the version validator to catch inconsistencies:

```bash
# Check all version references (during release)
./scripts/utils/validate-versions.sh

# Check with unreleased features (during development)
./scripts/utils/validate-versions.sh --unreleased

# Show help
./scripts/utils/validate-versions.sh --help
```

**What it checks**:
- ✅ `lib/core/version.sh` (source of truth)
- ✅ `README.md` (header and footer)
- ✅ `CHANGELOG.md` (latest release matches version.sh)
- ✅ `docs/COMMANDS.md` (no future version references)
- ✅ `docs/CLAUDE.md` (no future version references, version history)

**Usage**:
- **During development**: Use `--unreleased` flag when working on features for next version
- **Before release**: Run without flags to ensure everything is consistent
- **After bumping version**: Automatically run by `bump-version.sh`

---

## Controlled Version Update Script

Use the release preparation command on a `release/*` branch:

```bash
# Bump patch version (3.3.0 -> 3.3.1)
ai-use-case release prepare patch

# Bump minor version (3.3.0 -> 3.4.0)
ai-use-case release prepare minor

# Bump major version (3.3.0 -> 4.0.0)
ai-use-case release prepare major

# Set specific version
ai-use-case release prepare 3.5.0
```

**Script Location**: `scripts/utils/bump-version.sh`

**What preparation automates**:
- ✅ Updates `lib/core/version.sh` (compatibility symlink remains available)
- ✅ Updates `README.md` (header version, footer version, and footer date)
- ✅ Updates `CHANGELOG.md` (moves [Unreleased] to new version section with date)
- ✅ Leaves commit, tag, and push operations separate for PR review and post-merge publication

**What it does NOT automate** (manual check required):
- ❌ CHANGELOG.md content (you must write release notes in [Unreleased] section BEFORE bumping)
- ❌ Version-specific feature documentation in docs/COMMANDS.md
- ❌ Version-specific feature documentation in docs/CLAUDE.md
- ❌ Historical version references (should not be changed)

---

## Pre-Release Checklist

Before creating a release PR:

- [ ] **1. Version Updated**: `lib/core/version.sh` line 21 via `ai-use-case release prepare`
- [ ] **2. README Header**: Line ~4 version badge updated
- [ ] **3. README Footer**: Line ~353 version AND date updated
- [ ] **4. CHANGELOG.md**: New version section with release date and changes
- [ ] **5. Feature Docs**: CLAUDE.md updated if adding versioned features
- [ ] **6. Version Test**: Run `./ai-use-case --version` to verify
- [ ] **7. All Tests Pass**: Run test suite if applicable
- [ ] **8. Documentation Review**: All docs reflect new version capabilities
- [ ] **9. Git Commit**: Use conventional commit message
  ```
  chore: bump version to X.Y.Z

  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```
- [ ] **10. Publish tag after PR merge**: `ai-use-case release publish X.Y.Z`

---

## Verification Commands

After updating, verify all locations:

```bash
# 1. Check source of truth
grep "export CLI_VERSION=" lib/core/version.sh

# 2. Check README header
grep -n "v[0-9]\+\.[0-9]\+\.[0-9]\+" README.md | head -1

# 3. Check README footer
grep -n "**Version**:" README.md

# 4. Check CHANGELOG latest version
grep -n "^## \[" CHANGELOG.md | head -3

# 5. Verify CLI command
./ai-use-case --version

# 6. Search for old version references (replace 3.3.0 with previous version)
grep -r "3\.3\.0" --include="*.md" --include="*.sh" . | grep -v ".git" | grep -v ".usecase"
```

---

## Common Pitfalls

### ❌ Mistake #1: Forgetting README.md footer (MOST COMMON!)

**Problem**: The README.md footer version and date are not updated during manual version bumps

**Why it happens**:
- Developers manually update version.sh and CHANGELOG.md
- They forget README.md has TWO locations (header + footer)
- The footer is at the very end of the file and easily overlooked

**Impact**:
- Users see mismatched versions
- Documentation appears outdated
- Version inconsistency in user-facing docs

**Solution**:
1. **ALWAYS use `ai-use-case bump-version` script** - it updates all locations automatically
2. If manual update needed, run `./scripts/utils/validate-versions.sh` BEFORE committing
3. Add pre-commit hook to automatically validate versions (see below)

---

### ❌ Mistake #2: Only updating `lib/core/version.sh`

**Problem**: README still shows old version, confusing users

**Solution**: Always update README.md (header AND footer)

---

### ❌ Mistake: Forgetting to update README footer date

**Problem**: Footer shows "Last Updated: 2025-11-07" but version is 3.4.0 from 2025-11-08

**Solution**: Update both version AND date in README footer

---

### ❌ Mistake: Not updating CHANGELOG.md

**Problem**: Users don't know what changed in the new version

**Solution**: Move Unreleased changes to new version section with date

---

### ❌ Mistake: Changing historical version references

**Problem**: Documentation of past features becomes incorrect

**Solution**: Only update current version references, keep historical ones (e.g., "v3.1.0+ introduced registry")

---

### ❌ Mistake: Forgetting to test the version command

**Problem**: Version mismatch between what's displayed and what's documented

**Solution**: Always run `./ai-use-case --version` after updating

---

## Automated Pre-Commit Validation (RECOMMENDED)

To prevent version inconsistencies from being committed, add this to your local pre-commit hook:

### Setup Pre-Commit Version Check

Add to `.git/hooks/pre-commit` in this repository:

```bash
#!/bin/bash
# Version validation pre-commit hook
# Prevents commits with inconsistent version references

# Only run validation if version-related files are being committed
if git diff --cached --name-only | grep -qE "(version\.sh|README\.md|CHANGELOG\.md)"; then
    echo "Validating version consistency..."

    # Run version validator
    if ! ./scripts/utils/validate-versions.sh; then
        echo ""
        echo "❌ Version validation failed!"
        echo "Fix version inconsistencies before committing."
        echo "Or run: ai-use-case bump-version [major|minor|patch]"
        exit 1
    fi

    echo "✓ Version validation passed"
fi
```

**Benefits**:
- Automatically catches version inconsistencies before commit
- Only runs when version-related files are modified
- Prevents broken commits from entering git history
- Forces developers to use proper version management

**Installation**:
```bash
# For ai-use-case-cli repository developers
./scripts/install-dev-hooks.sh
```

This script will:
- Install the version validation hook
- Preserve any existing hooks
- Make the hook executable automatically

---

## Integration with PR Process

Add this to your PR checklist (already in root CLAUDE.md):

```markdown
### Pre-PR Checklist

Before creating any PR:

- [ ] **MANDATORY: Updated CHANGELOG.md** (non-negotiable for ALL changes)
- [ ] **MANDATORY: Updated README.md** (non-negotiable if user-facing changes)
- [ ] **If adding features**: Prepared the version with `ai-use-case release prepare`
- [ ] **If adding features**: Verified ALL version locations (see docs/VERSION-UPDATE-CHECKLIST.md)
```

---

## Quick Reference: Version Files Map

| File | Lines | Purpose | Auto-Updated by bump-version.sh | Validated by validate-versions.sh |
|------|-------|---------|----------------------------------|-----------------------------------|
| `lib/core/version.sh` | 21 | Source of truth | ✅ Yes | ✅ Yes |
| `README.md` | 4, footer | User-facing docs | ✅ Yes (header + footer version + date) | ✅ Yes |
| `CHANGELOG.md` | Top | Release history | ✅ Yes (structure), ❌ No (content - must be in [Unreleased] first) | ✅ Yes |
| `docs/COMMANDS.md` | Various | Command reference with version markers | ❌ No (manual) | ✅ Yes |
| `docs/CLAUDE.md` | Various | Developer guide with version markers | ❌ No (manual) | ✅ Yes |
| `ai-use-case` (main script) | N/A | CLI entry point | ✅ Auto (sources version.sh) | N/A |

**Version Marker Format**:
- Use `(v3.6.0+)` for features added in that version
- Example: `### Tracing and Monitoring (v3.6.0+)`
- Never change historical markers (keep `v3.1.0+` as is)

---

**Last Updated**: 2025-11-09
**Checklist Version**: 2.0.0 (Added version validation)
