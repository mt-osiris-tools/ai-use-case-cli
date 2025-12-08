# Feature Plan: Decouple .ai-tools Setup from .claude Folder

**Feature ID:** FEATURE-012
**Created:** 2025-12-08
**Status:** In Progress
**Priority:** Medium
**Complexity:** Low

---

## Overview

This feature decouples the creation of the `.ai-tools` folder from the existence of the `.claude` folder during project setup. Additionally, it provides a new command to create Claude Code symlinks when a user sets up Claude in a project after the initial ai-use-case setup.

## Problem Statement

Currently, the `ai-use-case --init` command creates both the `.ai-tools` folder and the `.claude/commands/use-case` symlink together. This creates issues for users who:

1. Want to use ai-use-case-cli but don't have Claude Code installed yet
2. Set up ai-use-case first and later add Claude Code to their project
3. Need to recreate the symlinks after the `.claude` folder is recreated

Without this feature, users must re-run `ai-use-case --init` to get the symlinks created, which may also overwrite other configuration.

## Goals

### Primary Goals

1. **Decouple folder creation** - Create `.ai-tools` folder during setup regardless of `.claude` folder existence
2. **Add symlink command** - Provide a dedicated command to create/recreate `.claude/commands/use-case` symlinks
3. **Improve user experience** - Allow flexible setup order (ai-use-case first, Claude Code later, or vice versa)

### Non-Goals

- Automatic detection and symlink creation when `.claude` folder is created (too complex, out of scope)
- Managing other `.claude` configuration beyond the commands symlink
- Removing or deprecating existing `--init` functionality

## Success Criteria

1. `.ai-tools` folder is created during `--init` even if `.claude` folder doesn't exist
2. New `--link-claude` command creates symlinks when `.claude` folder exists
3. Existing functionality remains unchanged (backward compatible)
4. Clear user feedback in both scenarios

## Proposed Solution

### High-Level Approach

Modify the setup process to:
1. Always create `.ai-tools` folder during `--init`
2. Skip `.claude` symlink creation (with informational message) if `.claude` folder doesn't exist
3. Add new `--link-claude` flag to specifically handle symlink creation

### Detailed Design

#### Component 1: Modified Setup Logic

**Purpose:** Create `.ai-tools` folder regardless of `.claude` existence

**Implementation:**
- Move `.ai-tools` creation to happen unconditionally
- Add conditional check for `.claude` folder before creating symlinks
- Display informational message if `.claude` doesn't exist

**Example:**
```bash
# During setup, always create .ai-tools
mkdir -p ".ai-tools/commands/use-case"
mkdir -p ".ai-tools/agents"
# Copy command files...

# Only create symlinks if .claude exists
if [ -d ".claude" ]; then
    # Create symlinks as usual
else
    echo "Note: .claude folder not found. Run 'ai-use-case --link-claude' after setting up Claude Code."
fi
```

#### Component 2: New --link-claude Command

**Purpose:** Create/recreate Claude Code symlinks on demand

**Implementation:**
- New flag `--link-claude` to the main CLI
- Checks for `.ai-tools` existence (fails if not present)
- Creates `.claude/commands/` directory if needed
- Creates the `use-case` symlink

### User Experience

**Before this feature:**
```
# User runs setup without .claude folder
$ ai-use-case --init
# .ai-tools NOT created because symlink creation fails
# User must have .claude folder first
```

**After this feature:**
```
# User runs setup without .claude folder
$ ai-use-case --init
# .ai-tools IS created successfully
# Message: "Note: .claude folder not found. Run 'ai-use-case --link-claude' after setting up Claude Code."

# Later, user sets up Claude Code and wants the symlinks
$ ai-use-case --link-claude
# Creates .claude/commands/use-case symlink
```

## Technical Architecture

### Components Affected

1. **scripts/project/setup-project.sh** - Modify to decouple .ai-tools and .claude logic
2. **ai-use-case (main CLI)** - Add new `--link-claude` flag
3. **scripts/project/link-claude.sh** - New script to handle symlink creation

### Data Flow

```
User → ai-use-case --init → setup-project.sh → Creates .ai-tools (always)
                                             → Creates .claude symlinks (if .claude exists)

User → ai-use-case --link-claude → link-claude.sh → Creates .claude/commands/ (if needed)
                                                  → Creates use-case symlink
```

### Dependencies

**Internal:**
- Existing setup-project.sh functions
- Main CLI argument parsing

**External:**
- None

## Implementation Phases

### Phase 1: Decouple .ai-tools Creation

**Goals:**
- Modify setup-project.sh to create .ai-tools unconditionally
- Add conditional check for .claude folder

**Tasks:**
- Refactor install_ai_slash_commands function
- Add informational message when .claude doesn't exist

### Phase 2: Add --link-claude Command

**Goals:**
- Create new link-claude.sh script
- Integrate into main CLI

**Tasks:**
- Create link-claude.sh with symlink creation logic
- Add --link-claude flag to main CLI
- Handle edge cases (no .ai-tools, already exists, etc.)

### Phase 3: Testing and Documentation

**Goals:**
- Verify all scenarios work correctly
- Update documentation

**Tasks:**
- Test fresh setup without .claude
- Test --link-claude after setup
- Update CHANGELOG.md and README.md

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing --init behavior | High | Low | Careful refactoring, preserve all existing behavior |
| User confusion about when to run --link-claude | Med | Med | Clear messaging during --init, good documentation |
| Symlink already exists scenarios | Low | Med | Check and handle gracefully |

## Future Enhancements

**Phase 2 (Future):**
- Auto-detect Claude Code installation and suggest --link-claude
- Support for other AI tools beyond Claude Code
- Batch symlink management

**Long-term vision:**
- Universal AI tool integration layer
- Plugin system for different AI assistants

## Related Documentation

- [Setup Project Script](../../scripts/project/setup-project.sh)
- [Main CLI](../../ai-use-case)

---

**Next Steps:**
1. Create feature plan (this document)
2. Generate detailed requirements
3. Create implementation checklist
4. Begin implementation
