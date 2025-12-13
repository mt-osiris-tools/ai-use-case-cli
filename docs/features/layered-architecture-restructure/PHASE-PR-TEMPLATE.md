# Phase N PR Template - Layered Architecture

Use this template when creating PRs for layered architecture phases 2-8.

---

## Summary

Brief description of what this phase accomplishes (2-3 sentences).

**Phase:** N of 8
**Risk Level:** [LOW | MEDIUM | HIGH]
**Base Branch:** `integration/layered-architecture`

### What Changed

#### 🏗️ Architecture Changes
- List structural changes (new directories, moved files, etc.)

#### 📦 Module Changes
- List new modules created or refactored

#### ✨ Key Improvements
- Highlight main improvements or refactors

#### 📚 Documentation
- List documentation additions/updates

## Backward Compatibility

- [ ] ✅ **100% backward compatible** (describe how)
- [ ] ⚠️ **Breaking changes** (list them and migration path)

Describe compatibility strategy:
- Symlinks maintained?
- Facades created?
- Old APIs still work?

## Testing

### Test Results
```
X/Y tests passing (Z% pass rate)
```

### What Was Tested
- [ ] Full test suite executed
- [ ] Smoke tests pass (`--version`, `--help`, key commands)
- [ ] Backward compatibility verified (old paths still work)
- [ ] New functionality tested
- [ ] Integration with previous phases verified

### Known Issues
- List any known issues or failing tests with plans to address

## Migration Guide

### For Users
If users need to do anything (usually they shouldn't):
```bash
# Example migration steps if needed
```

### For Developers
What developers working on the codebase need to know:
- New import patterns
- Deprecated patterns to avoid
- New conventions to follow

## Rollback Plan

If this phase needs to be reverted:
1. Revert PR commit(s) in integration branch
2. [Additional rollback steps if needed]

## Checklist

### Pre-Merge Checklist
- [ ] All Copilot/reviewer comments addressed
- [ ] Documentation updated (feature plan, requirements, checklist)
- [ ] Tests passing at acceptable rate (>95%)
- [ ] Backward compatibility verified
- [ ] No breaking changes to main branch contracts
- [ ] Phase status table updated in feature plan

### Phase Dependencies
- [ ] Previous phase(s) merged to integration branch
- [ ] No conflicts with integration branch
- [ ] Builds successfully on integration branch

## Related Issues

Link to any related issues or discussions.

## Next Phase Preview

Brief mention of what Phase N+1 will tackle (1-2 sentences).

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
