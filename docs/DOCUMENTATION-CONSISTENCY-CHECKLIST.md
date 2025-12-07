# Documentation Consistency Checklist

**Purpose**: Ensure all documentation files are consistent, accurate, and properly cross-referenced when adding or modifying features.

**When to use**: Before creating any PR, especially when:
- Adding new features
- Modifying existing functionality
- Creating new documentation files
- Updating templates or workflows

## Quick Validation

Run these commands to quickly check documentation consistency:

```bash
# 1. Check for broken markdown links
./scripts/utils/validate-docs.sh --links

# 2. Verify version references are consistent
./scripts/utils/validate-versions.sh

# 3. Check for TODO or placeholder content
grep -r "TODO\|FIXME\|XXX\|PLACEHOLDER" docs/ --include="*.md" | grep -v ".git"

# 4. Find files referencing non-existent paths
./scripts/utils/validate-docs.sh --paths
```

**Note**: If `validate-docs.sh` doesn't exist, see the [Automation Opportunities](#automation-opportunities) section.

---

## Complete Documentation Review Checklist

### 1. Core Documentation Files

When adding a new feature, ensure these files are updated:

- [ ] **CHANGELOG.md** *(MANDATORY)*
  - Add entry in `[Unreleased]` section
  - Follow [Keep a Changelog](https://keepachangelog.com/) format
  - Use appropriate category: Added, Changed, Deprecated, Removed, Fixed, Security

- [ ] **README.md** *(MANDATORY for user-facing changes)*
  - Update features list if new functionality added
  - Verify version references are current
  - Check footer version and date (if releasing)

- [ ] **docs/COMMANDS.md**
  - Document new commands or flags
  - Update existing command documentation if behavior changed
  - Add version markers (e.g., `v3.12.0+`)

### 2. Feature-Specific Documentation

For new features, create or update:

- [ ] **Feature Documentation** (`docs/features/{feature-name}/README.md`)
  - Create comprehensive feature documentation
  - Include: Overview, Usage, Configuration, Testing, Troubleshooting
  - Use existing feature docs as templates

- [ ] **User Guides** (if applicable)
  - Create or update relevant guides in `docs/`
  - Ensure guide references all related files and features

- [ ] **Setup/Configuration Docs** (if applicable)
  - Document any new configuration requirements
  - Include examples and troubleshooting

### 3. Templates and Workflows

If feature affects documentation generation:

- [ ] **docs/TEMPLATE.md**
  - Add new sections if feature provides data for documentation
  - Update examples with realistic data
  - Maintain consistency with TEMPLATE-RESEARCH.md where applicable

- [ ] **docs/TEMPLATE-RESEARCH.md**
  - Update parallel sections to match TEMPLATE.md
  - Adapt examples for research sessions (no code changes)

- [ ] **.ai-tools/commands/use-case/document-session.md**
  - Update workflow if documentation process changed
  - Add steps for capturing new data types
  - Update prompts and instructions

### 4. Agent/AI Assistant Guidance

For features that affect AI assistants:

- [ ] **docs/agents/claude/README.md**
  - Update quick reference with new commands or patterns
  - Add to relevant sections (workflows, features, etc.)

- [ ] **docs/agents/claude/GUIDE.md**
  - Add comprehensive guidance for new feature usage
  - Include examples and best practices
  - Document integration points

### 5. Cross-References and Links

Verify all references are correct:

- [ ] **Markdown Links**
  ```bash
  # Check for broken relative links
  grep -r "\[.*\](.*\.md)" docs/ --include="*.md" | \
    while IFS=: read -r file link; do
      # Extract path from markdown link
      path=$(echo "$link" | sed 's/.*(\(.*\.md\).*/\1/')
      # Check if file exists relative to doc
      # (Manual verification recommended)
    done
  ```

- [ ] **File Path References**
  - Verify all referenced files exist: `.claude/`, `scripts/`, `docs/`
  - Check command examples use correct paths
  - Ensure examples work from repository root

- [ ] **External Links** (if any)
  - Verify links still work
  - Check for redirect chains
  - Use stable URLs when possible

### 6. Version Consistency

Critical when bumping versions or adding features:

- [ ] **Version Markers**
  - Use format: `(v3.12.0+)` for new features
  - Don't change historical markers (keep `v3.4.0+` references)
  - Be consistent across all docs

- [ ] **Version Numbers**
  ```bash
  # Find all version references
  grep -r "v[0-9]\+\.[0-9]\+\.[0-9]\+" docs/ --include="*.md" | \
    grep -v ".git" | grep -v "CHANGELOG"

  # Verify they're correct and intentional
  ```

- [ ] **Release Documentation**
  - Update version.sh if releasing
  - Run `./scripts/utils/validate-versions.sh`
  - See [VERSION-UPDATE-CHECKLIST.md](VERSION-UPDATE-CHECKLIST.md)

### 7. Examples and Code Blocks

Ensure all examples work:

- [ ] **Command Examples**
  - Test all bash commands in examples
  - Verify commands work from repo root
  - Check for correct flags and arguments

- [ ] **Output Examples**
  - Use realistic sample output
  - Ensure examples match current feature behavior
  - Update if output format changed

- [ ] **Configuration Examples**
  - Test configuration snippets
  - Verify syntax is correct
  - Include necessary context

### 8. Consistency Across Similar Files

Check parallel documentation:

- [ ] **Template Consistency**
  - TEMPLATE.md and TEMPLATE-RESEARCH.md should have parallel sections
  - Session statistics, token usage, and metrics sections should match
  - Examples should be adapted appropriately

- [ ] **Agent Documentation**
  - README.md (quick reference) and GUIDE.md (detailed) should align
  - Same features covered in both
  - Quick reference summarizes what guide explains in detail

### 9. Hub Synchronization

If changes affect the ai-use-case-hub repository:

- [ ] **Review Hub Impact**
  - See [HUB-SYNC-CHECKLIST.md](HUB-SYNC-CHECKLIST.md)
  - Update hub templates if CLI templates changed
  - Update hub documentation for new features

- [ ] **Coordinate Versions**
  - Hub CHANGELOG references CLI version
  - Hub documentation mentions compatibility

---

## Common Documentation Issues

### ❌ Issue #1: CHANGELOG.md Not Updated

**Problem**: CHANGELOG.md missing entry for new feature

**Impact**: Users don't know what changed, incomplete release notes

**Solution**:
```bash
# Always update CHANGELOG.md in [Unreleased] section
# Example:
## [Unreleased]
### Added
- Session statistics automation with SessionEnd hook and /cost integration
- OpenTelemetry configuration for enterprise telemetry
```

### ❌ Issue #2: Inconsistent Templates

**Problem**: TEMPLATE.md updated but TEMPLATE-RESEARCH.md forgotten

**Impact**: Research sessions missing important sections

**Solution**: Always update both templates in parallel, adapting examples appropriately

### ❌ Issue #3: Broken Cross-References

**Problem**: Feature docs reference `../../CONTRIBUTING.md` but file doesn't exist

**Impact**: Users can't find referenced documentation

**Solution**:
```bash
# Verify file exists before creating reference
test -f CONTRIBUTING.md && echo "EXISTS" || echo "MISSING"

# Or use correct path
[CONTRIBUTING.md](../../../CONTRIBUTING.md)  # From docs/features/*/
```

### ❌ Issue #4: Version Reference Confusion

**Problem**: Mixing version numbers (v3.4.0+ and v3.12.0+) in same section

**Impact**: Users confused about feature availability

**Solution**:
- Use `v3.12.0+` for new features added in this release
- Keep historical markers unchanged (e.g., `v3.4.0+` for older features)
- Document feature version consistently across all files

### ❌ Issue #5: Outdated Command Examples

**Problem**: Documentation shows old command syntax after changes

**Impact**: Users copy-paste broken commands

**Solution**: Test all command examples after any CLI changes

### ❌ Issue #6: Missing File Path References

**Problem**: Documentation references `.claude/hooks/SessionEnd` but file not installed

**Impact**: Users can't find referenced files

**Solution**:
- Ensure installation scripts create necessary files
- Document installation process
- Verify files exist before referencing them

---

## Automated Validation Scripts

### Available Now

1. **Version Validation**: `./scripts/utils/validate-versions.sh`
   - Checks version consistency across version.sh, README.md, CHANGELOG.md
   - Run before any release

2. **Git Pre-Commit Hook**: `.git/hooks/pre-commit`
   - Install with `./scripts/install-dev-hooks.sh`
   - Automatically validates versions on commit

### Automation Opportunities

Consider creating these scripts:

**1. Link Validator** (`scripts/utils/validate-docs.sh --links`)

```bash
#!/usr/bin/env bash
# Validate all markdown links in docs/

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

echo "Validating markdown links in docs/..."

BROKEN_LINKS=0

# Find all markdown files
find docs -name "*.md" -type f | while read -r file; do
    # Extract relative links: [text](path.md)
    # Using portable grep + sed instead of grep -oP for macOS compatibility
    grep -o '\[.*\]([^)]*)' "$file" 2>/dev/null | sed 's/.*(\([^)]*\)).*/\1/' | while read -r link; do
        # Skip external URLs
        if [[ "$link" =~ ^https?:// ]]; then
            continue
        fi

        # Resolve relative path
        dir=$(dirname "$file")
        target="$dir/$link"

        # Check if file exists
        if [ ! -f "$target" ]; then
            echo "❌ Broken link in $file: $link (target: $target)"
            ((BROKEN_LINKS++))
        fi
    done
done

if [ $BROKEN_LINKS -eq 0 ]; then
    echo "✅ All markdown links valid"
    exit 0
else
    echo "❌ Found $BROKEN_LINKS broken link(s)"
    exit 1
fi
```

**2. File Path Validator** (`scripts/utils/validate-docs.sh --paths`)

```bash
#!/usr/bin/env bash
# Validate all file path references in docs/

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

echo "Validating file path references in docs/..."

MISSING_FILES=0

# Common file path patterns in documentation
# Look for: `.claude/path`, `scripts/path`, ` /path/to/file `
# Using portable grep -oE instead of grep -oP for macOS compatibility
find docs -name "*.md" -type f -exec grep -oE '`[./][^`]+`' {} \; | \
    sort -u | while read -r path; do
    # Remove backticks
    clean_path=$(echo "$path" | tr -d '`')

    # Skip if looks like command or variable
    if [[ "$clean_path" =~ ^\./ ]] || [[ "$clean_path" =~ ^/ ]]; then
        continue
    fi

    # Check if file exists
    if [ ! -f "$clean_path" ] && [ ! -d "$clean_path" ]; then
        echo "⚠️  Referenced path may not exist: $clean_path"
        ((MISSING_FILES++))
    fi
done

if [ $MISSING_FILES -eq 0 ]; then
    echo "✅ All file paths appear valid"
    exit 0
else
    echo "⚠️  Found $MISSING_FILES potentially missing path(s)"
    echo "   (Manual verification recommended)"
    exit 0  # Don't fail, just warn
fi
```

**3. Template Consistency Checker** (`scripts/utils/validate-docs.sh --templates`)

```bash
#!/usr/bin/env bash
# Check TEMPLATE.md and TEMPLATE-RESEARCH.md have parallel sections

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

echo "Validating template consistency..."

TEMPLATE1="docs/TEMPLATE.md"
TEMPLATE2="docs/TEMPLATE-RESEARCH.md"

# Extract section headers (## lines)
sections1=$(grep "^## " "$TEMPLATE1" | sed 's/^## //')
sections2=$(grep "^## " "$TEMPLATE2" | sed 's/^## //')

# Find sections in TEMPLATE.md not in TEMPLATE-RESEARCH.md
diff <(echo "$sections1") <(echo "$sections2") || {
    echo "⚠️  Templates have different sections"
    echo "   This may be intentional, but verify manually"
}

echo "✅ Template consistency check complete"
```

**4. Integration Script** (`scripts/utils/validate-docs.sh`)

**Note**: This example shows the master script calling individual validators. In practice, you would either:
- Create separate validator scripts (`validate-docs-links.sh`, `validate-docs-paths.sh`, `validate-docs-templates.sh`)
- Or implement all validation logic within this single script using internal functions

```bash
#!/usr/bin/env bash
# Master documentation validation script
# This example assumes separate validator scripts exist, or that you'll implement
# the validation logic as internal functions within this script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

function show_help() {
    cat <<EOF
Usage: validate-docs.sh [OPTIONS]

Validate documentation consistency and correctness.

OPTIONS:
    --links         Validate all markdown links
    --paths         Validate all file path references
    --templates     Check template consistency
    --all           Run all validations (default)
    --help          Show this help message

EXAMPLES:
    validate-docs.sh --links
    validate-docs.sh --all
EOF
}

VALIDATE_LINKS=false
VALIDATE_PATHS=false
VALIDATE_TEMPLATES=false

if [ $# -eq 0 ]; then
    VALIDATE_LINKS=true
    VALIDATE_PATHS=true
    VALIDATE_TEMPLATES=true
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --links) VALIDATE_LINKS=true ;;
        --paths) VALIDATE_PATHS=true ;;
        --templates) VALIDATE_TEMPLATES=true ;;
        --all)
            VALIDATE_LINKS=true
            VALIDATE_PATHS=true
            VALIDATE_TEMPLATES=true
            ;;
        --help) show_help; exit 0 ;;
        *) echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
    shift
done

EXIT_CODE=0

if [ "$VALIDATE_LINKS" = true ]; then
    echo "=== Validating Links ==="
    "$SCRIPT_DIR/validate-docs.sh" --links || EXIT_CODE=1
    echo ""
fi

if [ "$VALIDATE_PATHS" = true ]; then
    echo "=== Validating Paths ==="
    "$SCRIPT_DIR/validate-docs.sh" --paths || EXIT_CODE=1
    echo ""
fi

if [ "$VALIDATE_TEMPLATES" = true ]; then
    echo "=== Validating Templates ==="
    "$SCRIPT_DIR/validate-docs.sh" --templates || EXIT_CODE=1
    echo ""
fi

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All documentation validation checks passed"
else
    echo "❌ Some documentation validation checks failed"
fi

exit $EXIT_CODE
```

---

## Integration with PR Workflow

Add to your pre-PR checklist (in docs/agents/claude/README.md or WORKFLOW.md):

```markdown
### Documentation Checklist

Before creating PR:

- [ ] **CHANGELOG.md updated** (MANDATORY)
- [ ] **README.md reviewed** (MANDATORY if user-facing changes)
- [ ] Ran `./scripts/utils/validate-docs.sh --all`
- [ ] Verified all cross-references and links
- [ ] Updated templates (both TEMPLATE.md and TEMPLATE-RESEARCH.md)
- [ ] Updated agent documentation if applicable
- [ ] Reviewed HUB-SYNC-CHECKLIST.md if needed
```

---

## Document Consistency Review Process

### For New Features

1. **Plan Documentation First**
   - List all docs that need updates
   - Identify new docs to create
   - Check HUB-SYNC-CHECKLIST.md impact

2. **Create/Update Feature Docs**
   - Create `docs/features/{feature-name}/README.md`
   - Include comprehensive guide
   - Add cross-references to related docs

3. **Update Core Documentation**
   - CHANGELOG.md (mandatory)
   - README.md (if user-facing)
   - COMMANDS.md (if new commands)

4. **Update Templates/Workflows**
   - Both TEMPLATE.md and TEMPLATE-RESEARCH.md
   - .ai-tools workflow files if needed
   - Agent documentation

5. **Validate Everything**
   ```bash
   # Run all validation
   ./scripts/utils/validate-docs.sh --all
   ./scripts/utils/validate-versions.sh

   # Manual checks
   grep -r "TODO\|FIXME" docs/ --include="*.md"
   ```

6. **Review Cross-References**
   - Check all new links work
   - Verify file paths are correct
   - Test command examples

### For Bug Fixes

1. **Update Relevant Docs**
   - CHANGELOG.md (mandatory)
   - Fix any incorrect documentation
   - Update examples if behavior changed

2. **Validate**
   ```bash
   ./scripts/utils/validate-docs.sh --all
   ```

### For Refactoring

1. **Verify No Documentation Changes Needed**
   - User-facing behavior unchanged
   - Command syntax unchanged
   - Configuration unchanged

2. **Update If Needed**
   - CHANGELOG.md (mention refactoring if significant)
   - Implementation details (if documented)

---

## Quick Reference: Documentation File Map

| File/Directory | Purpose | When to Update |
|----------------|---------|----------------|
| `CHANGELOG.md` | Release history | **Always** (mandatory) |
| `README.md` | Project overview | User-facing changes |
| `docs/COMMANDS.md` | Command reference | New commands, changed behavior |
| `docs/TEMPLATE.md` | Implementation session template | New documentation sections |
| `docs/TEMPLATE-RESEARCH.md` | Research session template | Parallel to TEMPLATE.md |
| `docs/features/*/` | Feature documentation | New features |
| `docs/agents/claude/` | AI assistant guidance | Workflow changes |
| `.ai-tools/commands/` | Slash command prompts | Documentation workflow changes |

---

## Maintenance

This checklist should be reviewed when:
- Adding major new documentation
- Changing documentation structure
- Implementing new validation tools
- Identifying new consistency patterns

---

**Last Updated**: 2025-12-07
**Checklist Version**: 1.0.0
**Related Docs**:
- [WORKFLOW.md](WORKFLOW.md)
- [VERSION-UPDATE-CHECKLIST.md](VERSION-UPDATE-CHECKLIST.md)
- [HUB-SYNC-CHECKLIST.md](HUB-SYNC-CHECKLIST.md)
