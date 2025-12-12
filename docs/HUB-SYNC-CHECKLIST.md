# Hub-CLI Synchronization Checklist

This document ensures that changes to the **ai-use-case-cli** repository are properly reflected in the **ai-use-case-hub** repository, and vice versa.

## Overview

The AI Use Case system consists of two interdependent repositories:

- **ai-use-case-cli** (this repo): Command-line tools, scripts, VS Code extension
- **ai-use-case-hub**: Documentation hub, templates, organized storage

Changes in one repository often require corresponding updates in the other to maintain consistency.

## When to Review Hub Repository

### ✅ Always Review Hub When Changing:

1. **Templates or Documentation Structure**
   - CLI generates docs using templates
   - Hub provides the templates users reference
   - **Action**: Update hub templates to match CLI generation

2. **Session Types or Workflows**
   - CLI implements session workflows
   - Hub documents available session types
   - **Action**: Update hub README, QUICK-REFERENCE with new workflows

3. **File Naming Conventions**
   - CLI enforces naming patterns
   - Hub parses and organizes based on these patterns
   - **Action**: Update hub documentation with new patterns/formats

4. **Features or Commands**
   - CLI adds new commands/features
   - Hub provides user documentation
   - **Action**: Update hub CHANGELOG, QUICK-REFERENCE

5. **Ticket Formats**
   - CLI generates/validates tickets
   - Hub organizes docs by ticket format
   - **Action**: Update hub naming convention documentation

### ⚠️ Review Hub If:

- Adding new slash commands
- Changing CLI version numbers
- Modifying sync script behavior
- Adding new documentation fields

### ✓ No Hub Review Needed:

- Internal CLI refactoring (no user-facing changes)
- Bug fixes that don't change behavior
- Performance optimizations
- Code style improvements

## Validation Checklist

When making changes to the CLI, use this checklist:

### 1. Identify Change Type

- [ ] Does this change affect user workflows?
- [ ] Does this change add/remove session types?
- [ ] Does this change modify templates or documentation structure?
- [ ] Does this change affect file naming or organization?
- [ ] Does this change add new commands or features?

### 2. Review Hub Files

If any above is "Yes", review these hub files:

#### Documentation Files
- [ ] `README.md` - User-facing documentation
- [ ] `QUICK-REFERENCE.md` - Command reference
- [ ] `CHANGELOG.md` - Version history
- [ ] `CLAUDE.md` - AI assistant guidance (if applicable)

#### Template Files
- [ ] `TEMPLATE.md` - Implementation session template
- [ ] `TEMPLATE-RESEARCH.md` - Research session template
- [ ] Any new templates needed?

### 3. Update Hub Files

For each file that needs updating:

- [ ] Add new features/commands
- [ ] Update examples with new patterns
- [ ] Add changelog entry for hub version
- [ ] Ensure consistency with CLI version
- [ ] Test that examples work with new CLI

### 4. Version Synchronization

- [ ] CLI version updated in `ai-use-case` script
- [ ] Hub CHANGELOG references correct CLI version
- [ ] Hub documentation mentions CLI version requirements
- [ ] Both repos tagged with coordinated versions

### 5. Cross-Repo Testing

- [ ] Test CLI commands work as documented in hub
- [ ] Verify hub templates match CLI generation
- [ ] Ensure file naming conventions align
- [ ] Check symlink organization works correctly

## Example: Research Session Support (v2.2.0)

### CLI Changes (v2.2.0)
- Added research session type to `document-ai-session.sh`
- Added `RESEARCH-XXX` ticket auto-generation
- Updated `CLAUDE.md` with research session guidance
- Updated `README.md` with session types

### Hub Changes Required (v2.1.0)
- ✅ Created `TEMPLATE-RESEARCH.md`
- ✅ Updated `README.md` with session types section
- ✅ Updated `CHANGELOG.md` with v2.1.0 entry
- ✅ Updated `QUICK-REFERENCE.md` with research commands
- ✅ Updated directory structure documentation

### Version Coordination
- CLI v2.2.0 released with research support
- Hub v2.1.0 released with research templates
- Hub CHANGELOG references CLI v2.2.0 compatibility

## Quick Reference

### Hub Repository Location
```bash
~/.local/share/ai-use-case-cli/hub
# or
$AI_USECASES_DIR
```

### Common Update Pattern

1. **Make CLI changes**
   ```bash
   cd ~/path/to/ai-use-case-cli
   # Make changes, commit
   ```

2. **Review hub impact**
   ```bash
   # Use this checklist to identify hub files to update
   ```

3. **Update hub**
   ```bash
   cd ${AI_USECASES_DIR:-~/.local/share/ai-use-case-cli/hub}
   # Update templates, docs, changelog
   git add .
   git commit -m "docs: Update for CLI v2.X.X feature"
   git push
   ```

4. **Tag versions**
   ```bash
   # CLI repo
   git tag -a v2.X.X -m "Release v2.X.X"
   git push origin v2.X.X

   # Hub repo
   git tag -a v2.Y.Y -m "Release v2.Y.Y - Compatible with CLI v2.X.X"
   git push origin v2.Y.Y
   ```

## Recent Hub Improvements

### v2.1.0+ Hub Updates

**Git Tracking Fix (October 2025)**:
- Hub `.gitignore` updated to properly track `by-project/` subdirectories
- `by-date/` and `by-topic/` remain excluded (symlinks only)
- Ensures all project documentation is version controlled
- CLI documentation updated to reflect this architecture

**Claude Code URL Standardization**:
- All references updated to `claude.com/code` (consistent across hub and CLI)
- Improved professional appearance and URL consistency

## Automation Opportunities

### Future Enhancements

Consider automating:
- [ ] Hub validation script that checks for required updates
- [ ] Cross-repo testing suite
- [ ] Automated changelog synchronization
- [ ] Template validation against CLI generation
- [ ] Documentation consistency checks

## Troubleshooting

### Common Issues

**Issue**: Hub templates don't match CLI output
- **Fix**: Regenerate template from CLI, update hub

**Issue**: Hub documentation references old commands
- **Fix**: Search hub for old command references, update

**Issue**: Version mismatch between CLI and hub
- **Fix**: Update hub CHANGELOG with CLI version reference

**Issue**: New CLI feature not documented in hub
- **Fix**: Follow this checklist for the feature addition

## Related Documents

- **CLI**: `README.md`, `CLAUDE.md`, `CHANGELOG.md`
- **Hub**: `README.md`, `QUICK-REFERENCE.md`, `CHANGELOG.md`
- **Cross-repo**: This file (HUB-SYNC-CHECKLIST.md)

## Maintenance

This checklist should be reviewed and updated:
- When adding major new features
- When changing repository structure
- When identifying new synchronization points
- Annually as part of regular maintenance

---

**Last Updated**: 2025-10-31
**CLI Version**: v2.2.0
**Hub Version**: v2.1.0
