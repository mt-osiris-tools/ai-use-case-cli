# Version Update Checklist

**Purpose**: Ensure all version references are updated consistently across the codebase when releasing a new version.

## Critical: Version Update Locations

When bumping the version, **ALL** of these files MUST be updated. Missing even one can cause inconsistencies and confusion.

### 1. Source of Truth: `scripts/utils/version.sh`

**File**: `scripts/utils/version.sh` (Line 21)

```bash
export CLI_VERSION="X.Y.Z"
```

**Action**: Update the version number
**Note**: This is the single source of truth. The main `ai-use-case` script sources this file.

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

**Note**: Sources `scripts/utils/version.sh`, so no manual update needed

**Action**: No action required (automatically uses `$CLI_VERSION`)

---

## Automated Version Update Script

Use the built-in bump-version script:

```bash
# Bump patch version (3.3.0 -> 3.3.1)
ai-use-case bump-version patch

# Bump minor version (3.3.0 -> 3.4.0)
ai-use-case bump-version minor

# Bump major version (3.3.0 -> 4.0.0)
ai-use-case bump-version major

# Set specific version
ai-use-case bump-version 3.5.0
```

**Script Location**: `scripts/utils/bump-version.sh`

**What it automates**:
- ✅ Updates `scripts/utils/version.sh`
- ✅ Updates `README.md` (both locations)
- ✅ Prompts for CHANGELOG.md update
- ✅ Creates git commit with version bump message
- ✅ Creates git tag

**What it does NOT automate** (manual check required):
- ❌ CHANGELOG.md content (you must write release notes)
- ❌ Version-specific feature documentation in CLAUDE.md
- ❌ Historical version references (should not be changed)

---

## Pre-Release Checklist

Before creating a release PR:

- [ ] **1. Version Updated**: `scripts/utils/version.sh` line 21
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
- [ ] **10. Git Tag**: Create annotated tag after PR merge
  ```bash
  git tag -a vX.Y.Z -m "Release vX.Y.Z"
  git push origin vX.Y.Z
  ```

---

## Verification Commands

After updating, verify all locations:

```bash
# 1. Check source of truth
grep "export CLI_VERSION=" scripts/utils/version.sh

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

### ❌ Mistake: Only updating `scripts/utils/version.sh`

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

## Integration with PR Process

Add this to your PR checklist (already in root CLAUDE.md):

```markdown
### Pre-PR Checklist

Before creating any PR:

- [ ] **MANDATORY: Updated CHANGELOG.md** (non-negotiable for ALL changes)
- [ ] **MANDATORY: Updated README.md** (non-negotiable if user-facing changes)
- [ ] **If adding features**: Updated version in scripts/utils/version.sh
- [ ] **If adding features**: Verified ALL version locations (see docs/VERSION-UPDATE-CHECKLIST.md)
```

---

## Quick Reference: Version Files Map

| File | Lines | Purpose | Auto-Updated by bump-version.sh |
|------|-------|---------|----------------------------------|
| `scripts/utils/version.sh` | 21 | Source of truth | ✅ Yes |
| `README.md` | 4, 353 | User-facing docs | ✅ Yes (header version), Manual (footer date) |
| `CHANGELOG.md` | Top | Release history | ⚠️ Prompts only (manual content) |
| `CLAUDE.md` | Various | Feature docs | ❌ No (manual if new features) |
| `ai-use-case` (main script) | N/A | CLI entry point | ✅ Auto (sources version.sh) |

---

**Last Updated**: 2025-11-08
**Checklist Version**: 1.0.0
