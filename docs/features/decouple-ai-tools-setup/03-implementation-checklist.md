# Implementation Checklist: Decouple .ai-tools Setup from .claude Folder

**Feature ID:** FEATURE-012
**Checklist Version:** 1.0
**Created:** 2025-12-08
**Status:** In Progress

---

## Pre-Implementation Setup

### Environment Preparation

- [x] **Create feature branch**
  - [x] Branch name: `feature/decouple-ai-tools-setup`
  - [x] Branched from: `main` (latest)
  - [x] Command: `git checkout -b feature/decouple-ai-tools-setup`

- [x] **Review related documentation**
  - [x] Read feature plan: `docs/features/decouple-ai-tools-setup/01-feature-plan.md`
  - [x] Read requirements: `docs/features/decouple-ai-tools-setup/02-requirements.md`
  - [x] Review affected files: `scripts/project/setup-project.sh`, `ai-use-case`

---

## Phase 1: Decouple .ai-tools Creation

### Task 1.1: Modify setup-project.sh

**File:** `scripts/project/setup-project.sh`
**Priority:** High

- [ ] **Refactor install_ai_slash_commands function**
  - [ ] Separate .ai-tools creation from .claude symlink creation
  - [ ] Always create .ai-tools folder and copy files
  - [ ] Add conditional check for .claude folder existence

- [ ] **Add informational message**
  - [ ] Display message when .claude folder doesn't exist
  - [ ] Include instruction to run `--link-claude` later

- [ ] **Test changes**
  - [ ] Test with .claude folder present (existing behavior preserved)
  - [ ] Test without .claude folder (.ai-tools created, message shown)
  - [ ] Verify no regressions

- [ ] **Commit changes**
  - [ ] Stage file: `git add scripts/project/setup-project.sh`
  - [ ] Commit: `git commit -m "feat: decouple .ai-tools creation from .claude folder"`

---

## Phase 2: Add --link-claude Command

### Task 2.1: Create link-claude.sh Script

**File:** `scripts/project/link-claude.sh`
**Priority:** High

- [ ] **Create new script file**
  - [ ] Add shebang and `set -euo pipefail`
  - [ ] Add script documentation header

- [ ] **Implement core logic**
  - [ ] Check if .ai-tools/commands/use-case/ exists
  - [ ] Create .claude/ directory if needed
  - [ ] Create .claude/commands/ directory if needed
  - [ ] Create use-case symlink with relative path

- [ ] **Handle edge cases**
  - [ ] Symlink already exists and correct: success message
  - [ ] Symlink exists but incorrect: warning message
  - [ ] .ai-tools not found: error with helpful message

- [ ] **Test script**
  - [ ] Test fresh project (no .claude)
  - [ ] Test with .claude already existing
  - [ ] Test idempotent behavior (run twice)

- [ ] **Commit changes**
  - [ ] Stage file: `git add scripts/project/link-claude.sh`
  - [ ] Commit: `git commit -m "feat: add link-claude.sh script"`

### Task 2.2: Integrate into Main CLI

**File:** `ai-use-case`
**Priority:** High

- [ ] **Add --link-claude flag**
  - [ ] Add to argument parsing
  - [ ] Add help text

- [ ] **Call link-claude.sh**
  - [ ] Source or exec the script when flag is used

- [ ] **Test integration**
  - [ ] `ai-use-case --link-claude` works
  - [ ] `ai-use-case --help` shows new option
  - [ ] Existing flags still work

- [ ] **Commit changes**
  - [ ] Stage file: `git add ai-use-case`
  - [ ] Commit: `git commit -m "feat: add --link-claude CLI flag"`

---

## Phase 3: Testing

### Task 3.1: Comprehensive Testing

**Priority:** High

- [ ] **Test Scenario 1: Fresh project without .claude**
  - [ ] Setup: Create empty project directory
  - [ ] Execute: `ai-use-case --init`
  - [ ] Verify: .ai-tools created, message about .claude shown
  - [ ] Execute: `ai-use-case --link-claude`
  - [ ] Verify: .claude/commands/use-case symlink created

- [ ] **Test Scenario 2: Project with .claude already**
  - [ ] Setup: Create project with .claude folder
  - [ ] Execute: `ai-use-case --init`
  - [ ] Verify: Both .ai-tools and symlink created (existing behavior)

- [ ] **Test Scenario 3: --link-claude without --init first**
  - [ ] Setup: Fresh project
  - [ ] Execute: `ai-use-case --link-claude`
  - [ ] Verify: Error message about running --init first

- [ ] **Test Scenario 4: Idempotent --link-claude**
  - [ ] Setup: Project with ai-use-case set up
  - [ ] Execute: `ai-use-case --link-claude` twice
  - [ ] Verify: No errors, symlink unchanged

---

## Phase 4: Documentation Updates

### Task 4.1: Update CHANGELOG.md

**File:** `CHANGELOG.md`
**Priority:** High (Mandatory)

- [ ] **Add entry under [Unreleased] section**
  ```markdown
  ### Added
  - New `--link-claude` command to create Claude Code symlinks independently
  - Support for setting up `.ai-tools` without requiring `.claude` folder

  ### Changed
  - `--init` now creates `.ai-tools` folder even if `.claude` doesn't exist
  - Added informational message during setup when `.claude` folder is missing
  ```

- [ ] **Commit changes**
  - [ ] Stage file: `git add CHANGELOG.md`
  - [ ] Commit: `git commit -m "docs: update CHANGELOG for decouple-ai-tools-setup feature"`

### Task 4.2: Update README.md

**File:** `README.md`
**Priority:** High (Mandatory)

- [ ] **Add --link-claude to command reference**
- [ ] **Update setup instructions if needed**

- [ ] **Commit changes**
  - [ ] Stage file: `git add README.md`
  - [ ] Commit: `git commit -m "docs: add --link-claude to README"`

---

## Phase 5: Review & Finalization

### Task 5.1: Code Review

**Priority:** High

- [ ] **Self-review all changes**
  - [ ] Check code quality and style
  - [ ] Verify error handling
  - [ ] Check no debug code left

- [ ] **Review against requirements**
  - [ ] Go through requirements document
  - [ ] Verify each requirement is met

### Task 5.2: Pre-PR Checklist

**Priority:** High (Mandatory)

- [ ] **Verify branch is clean**
  - [ ] Run: `git status`
  - [ ] All changes committed

- [ ] **Complete PR checklist items**
  - [ ] Created feature branch (not on `main`)
  - [ ] **MANDATORY: Updated CHANGELOG.md**
  - [ ] **MANDATORY: Updated README.md**
  - [ ] Tested changes locally

### Task 5.3: Create Pull Request

**Priority:** High

- [ ] **Push feature branch**
  - [ ] Run: `git push -u origin feature/decouple-ai-tools-setup`

- [ ] **Ask user for approval**
  - [ ] Present summary to user
  - [ ] Wait for user confirmation

- [ ] **Create PR**
  - [ ] Run: `gh pr create`

---

## Progress Tracking

**Overall Progress:** 10% (Phase 1 preparation complete)

**Phase 1:** 0/4 tasks (Modify setup-project.sh)
**Phase 2:** 0/2 tasks (Add --link-claude command)
**Phase 3:** 0/1 tasks (Testing)
**Phase 4:** 0/2 tasks (Documentation)
**Phase 5:** 0/3 tasks (Review & Finalization)

**Last Updated:** 2025-12-08

---

**Status:** In Progress
**Next Action:** Modify setup-project.sh to decouple .ai-tools creation
