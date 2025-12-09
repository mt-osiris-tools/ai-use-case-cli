# Requirements: Decouple .ai-tools Setup from .claude Folder

**Feature ID:** FEATURE-012
**Requirements Version:** 1.0
**Created:** 2025-12-08
**Last Updated:** 2025-12-08

---

## Table of Contents

1. [Functional Requirements](#functional-requirements)
2. [Non-Functional Requirements](#non-functional-requirements)
3. [User Stories](#user-stories)
4. [Acceptance Criteria](#acceptance-criteria)
5. [Interface Requirements](#interface-requirements)
6. [Constraints](#constraints)

---

## Functional Requirements

### FR-1: Decoupled .ai-tools Creation

**Priority:** High
**Status:** Required

#### FR-1.1: Unconditional .ai-tools Creation

- **Requirement:** The `ai-use-case --init` command MUST create the `.ai-tools` folder structure regardless of whether the `.claude` folder exists
- **Rationale:** Users should be able to set up ai-use-case-cli independent of Claude Code installation
- **Validation:** Run `--init` in a project without `.claude` folder and verify `.ai-tools` is created

#### FR-1.2: Conditional .claude Symlink Creation

- **Requirement:** The `ai-use-case --init` command MUST only create `.claude/commands/use-case` symlink if `.claude` folder exists
- **Rationale:** Cannot create symlinks in a non-existent directory
- **Validation:** Run `--init` with and without `.claude` folder, verify appropriate behavior

#### FR-1.3: Informational Message When .claude Missing

- **Requirement:** When `.claude` folder doesn't exist during `--init`, the system MUST display an informational message guiding the user to run `--link-claude` later
- **Rationale:** Users need to know how to complete the setup after installing Claude Code
- **Validation:** Run `--init` without `.claude` and verify informational message is displayed

### FR-2: New --link-claude Command

**Priority:** High
**Status:** Required

#### FR-2.1: Symlink Creation Command

- **Requirement:** The CLI MUST accept a `--link-claude` flag that creates the `.claude/commands/use-case` symlink
- **Rationale:** Users need a way to create symlinks after Claude Code is set up
- **Validation:** Run `--link-claude` and verify symlink is created

#### FR-2.2: .ai-tools Prerequisite Check

- **Requirement:** The `--link-claude` command MUST verify that `.ai-tools/commands/use-case/` exists before creating symlinks
- **Rationale:** Symlink target must exist
- **Validation:** Run `--link-claude` without `.ai-tools` and verify appropriate error

#### FR-2.3: .claude Folder Creation

- **Requirement:** If `.claude` folder doesn't exist, `--link-claude` MUST create it along with the `commands/` subdirectory
- **Rationale:** User convenience - don't require manual folder creation
- **Validation:** Run `--link-claude` without `.claude` and verify folders and symlink are created

#### FR-2.4: Existing Symlink Handling

- **Requirement:** If `.claude/commands/use-case` symlink already exists and points to correct target, the command MUST report success without modification
- **Rationale:** Idempotent operation
- **Validation:** Run `--link-claude` twice and verify no errors, symlink unchanged

#### FR-2.5: Incorrect Symlink Warning

- **Requirement:** If `.claude/commands/use-case` exists but points to wrong target, the command MUST warn the user and not modify it
- **Rationale:** Safety - don't destroy user's custom configuration
- **Validation:** Create incorrect symlink, run `--link-claude`, verify warning

---

## Non-Functional Requirements

### NFR-1: Usability

#### NFR-1.1: Clear Messaging

- **Requirement:** All user-facing messages MUST be clear and actionable
- **Examples:**
  - "Note: .claude folder not found. Run 'ai-use-case --link-claude' after setting up Claude Code."
  - "Created Claude Code symlink: .claude/commands/use-case -> .ai-tools/commands/use-case"

#### NFR-1.2: Error Messages

- **Requirement:** Error messages MUST include the specific issue and suggested resolution
- **Examples:**
  - "Error: .ai-tools folder not found. Please run 'ai-use-case --init' first."

### NFR-2: Compatibility

#### NFR-2.1: Backward Compatibility

- **Requirement:** Existing `--init` behavior MUST remain unchanged for users who already have `.claude` folder
- **Testing:** Verify `--init` with `.claude` folder produces same result as before

#### NFR-2.2: Platform Support

- **Requirement:** Feature MUST work on Linux and macOS
- **List:** Linux (primary), macOS (supported)

### NFR-3: Maintainability

#### NFR-3.1: Code Structure

- **Requirement:** New `--link-claude` functionality SHOULD be in a separate script file
- **Rationale:** Separation of concerns, easier maintenance

---

## User Stories

### US-1: Developer - Set Up Without Claude Code

**As a** developer who doesn't have Claude Code installed yet
**I want** to set up ai-use-case-cli in my project
**So that** I can start tracking my development sessions and add Claude integration later

**Acceptance Criteria:**
- Running `ai-use-case --init` creates `.ai-tools` folder successfully
- I see a message about running `--link-claude` when I get Claude Code
- No errors are thrown due to missing `.claude` folder

**Priority:** High

### US-2: Developer - Add Claude Integration Later

**As a** developer who set up ai-use-case before installing Claude Code
**I want** to easily add the Claude Code integration
**So that** Claude Code can discover my ai-use-case slash commands

**Acceptance Criteria:**
- Running `ai-use-case --link-claude` creates the necessary symlink
- Claude Code can now see the `/use-case:` commands
- The command gives clear feedback about what was created

**Priority:** High

### US-3: Developer - Recreate Symlinks After Reset

**As a** developer who recreated my `.claude` folder
**I want** to restore the ai-use-case symlinks
**So that** my Claude Code commands work again without re-running full setup

**Acceptance Criteria:**
- Running `--link-claude` recreates the symlink
- My `.usecase/cases/` files are untouched
- The command is quick and focused

**Priority:** Medium

---

## Acceptance Criteria

### AC-1: --init Without .claude Folder

- [x] `.ai-tools/commands/use-case/` directory is created
- [x] `.ai-tools/agents/` directory is created
- [x] All command files are copied to `.ai-tools/commands/use-case/`
- [x] Informational message is displayed about `.claude` not existing
- [x] No `.claude` folder or symlink is created
- [x] Exit code is 0 (success)

### AC-2: --init With .claude Folder (Existing Behavior)

- [x] `.ai-tools` is created as before
- [x] `.claude/commands/use-case` symlink is created
- [x] All existing functionality works unchanged

### AC-3: --link-claude Command

- [x] Creates `.claude/` directory if not exists
- [x] Creates `.claude/commands/` directory if not exists
- [x] Creates `use-case` symlink pointing to `../../.ai-tools/commands/use-case`
- [x] Succeeds silently if symlink already correct
- [x] Warns if symlink exists but incorrect
- [x] Errors if `.ai-tools` doesn't exist

### AC-4: Documentation

- [x] CHANGELOG.md updated
- [x] README.md updated with new command
- [x] Help text updated (`ai-use-case --help`)

---

## Interface Requirements

### IR-1: Command Line Interface

**Existing Command (Modified):**
```bash
ai-use-case --init [--update]
```

**New Command:**
```bash
ai-use-case --link-claude
```

**Options:**
- `--link-claude` - Create Claude Code command symlinks for an existing ai-use-case project

**Examples:**
```bash
# Set up ai-use-case in a project without Claude Code
ai-use-case --init
# Output: Created .ai-tools directory structure
# Output: Note: .claude folder not found. Run 'ai-use-case --link-claude' after setting up Claude Code.

# Later, after setting up Claude Code
ai-use-case --link-claude
# Output: Created .claude/commands directory
# Output: Created Claude Code symlink: .claude/commands/use-case -> .ai-tools/commands/use-case
```

---

## Constraints

### C-1: Technical Constraints

- **Shell Compatibility:** Bash 4.0+ required
- **Symlink Type:** Must use relative symlinks for portability
- **File Permissions:** Standard user permissions (no root required)

### C-2: Design Constraints

- **Naming:** Must use `--link-claude` flag name (consistent with existing CLI style)
- **Structure:** New functionality in `scripts/project/` directory
- **Error Handling:** Use `set -euo pipefail` per project standards

---

## Dependencies

### D-1: Existing Components

- `scripts/project/setup-project.sh` - Modified for decoupled logic
- `ai-use-case` (main CLI) - Modified for new flag
- `scripts/utils/` - May use existing utility functions

### D-2: Documentation Dependencies

- CHANGELOG.md - Must be updated
- README.md - Must be updated with new command

---

**Status:** Draft
**Next Steps:** Create implementation checklist and begin implementation
